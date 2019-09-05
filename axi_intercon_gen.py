#!/usr/bin/env python
import math
import sys
from collections import OrderedDict, defaultdict
import yaml

from verilogwriter import Signal, Wire, Instance, ModulePort, Port, VerilogWriter

if sys.version[0] == '2':

    math.log2 = lambda x : math.log(x, 2)

class Widths:
    addr = 0
    user = 0
    data = 0
    max_id = 0

def axi_signals(w, id_width):
    signals = [
        ("awid"    , False, id_width),
        ("awaddr"  , False, w.addr  ),
        ("awlen"   , False, 8  ),
        ("awsize"  , False, 3  ),
        ("awburst" , False, 2 ),
        ("awlock"  , False, 0 ),
        ("awcache" , False, 4 ),
        ("awprot"  , False, 3 ),
        ("awregion", False, 4),
        ("awuser"  , False, w.user),
        ("awqos"   , False, 4),
        ("awvalid" , False, 0),
        ("awready" , True , 0),

        ("arid"    , False, id_width),
        ("araddr"  , False, w.addr),
        ("arlen"   , False, 8),
        ("arsize"  , False, 3),
        ("arburst" , False, 2),
        ("arlock"  , False, 0),
        ("arcache" , False, 4),
        ("arprot"  , False, 3),
        ("arregion", False, 4),
        ("aruser"  , False, w.user),
        ("arqos"   , False, 4),
        ("arvalid" , False, 0),
        ("arready" , True , 0),
            
        ("wdata" , False, w.data),
        ("wstrb" , False, w.data//8),
        ("wlast" , False, 0),
        ("wuser"  , False, w.user),
        ("wvalid", False, 0),
        ("wready", True , 0),

        ("bid"   , True , id_width),
        ("bresp" , True , 2),
        ("bvalid", True , 0),
        ("buser"  , True, w.user),
        ("bready", False, 0),

        ("rid"   , True , id_width),
        ("rdata" , True , w.data),
        ("rresp" , True , 2),
        ("rlast" , True , 0),
        ("ruser"  , True, w.user),
        ("rvalid", True , 0),
        ("rready", False, 0),
    ]
    return signals

def module_ports(w, intf, id_width, is_input):
    ports = []
    for s in axi_signals(w, id_width):
        if s[0].endswith('user') and not w.user:
            continue
        if s[0].startswith('aw') and intf.read_only:
            continue
        if s[0].startswith('w') and intf.read_only:
            continue
        if s[0].startswith('b') and intf.read_only:
            continue
        prefix = 'o' if is_input == s[1] else 'i'
        ports.append(ModulePort("{}_{}_{}".format(prefix, intf.name, s[0]),
                                'output' if is_input == s[1] else 'input',
                                s[2]))
    return ports

def assigns(w, max_idw, masters, slaves):
    raw = '\n'
    i = 0
    for m in masters:
        for s in axi_signals(w, m.idw):
            if s[0].endswith('user') and not w.user:
                continue
            if s[1]:
                if m.read_only and (s[0].startswith('aw') or s[0].startswith('w') or s[0].startswith('b')):
                    continue
                src = "slave_{}[{}]".format(s[0], i)
                if s[0] in ['bid', 'rid'] and m.idw < max_idw:
                    src = src+'[{}:0]'.format(m.idw-1)
                raw += "   assign o_{}_{} = {};\n".format(m.name, s[0], src)
            else:
                src = "i_{}_{}".format(m.name, s[0])
                if s[0] in ['arid', 'awid'] and m.idw < max_idw:
                    src = "{"+ str(max_idw-m.idw)+"'d0,"+src+"}"
                if m.read_only and (s[0].startswith('aw') or s[0].startswith('w') or s[0].startswith('b')):
                    if s[0] in ['awid']:
                        _w = max_idw
                    else:
                        _w = max(1,s[2])
                    src = "{}'d0".format(_w)
                raw += "   assign slave_{}[{}] = {};\n".format(s[0], i, src)
        raw += "   assign connectivity_map[{}] = {}'b{};\n".format(i, len(slaves), '1'*len(slaves))
        i += 1

    raw += '\n'

    i = 0
    for m in slaves:
        for s in axi_signals(w, max_idw):
            if s[0].endswith('user') and not w.user:
                continue
            if s[1]:
                raw += "   assign master_{}[{}] = i_{}_{};\n".format(s[0], i, m.name, s[0])
            else:
                raw += "   assign o_{}_{} = master_{}[{}];\n".format(m.name, s[0], s[0], i)
        raw += "   assign start_addr[0][{}] = 32'h{:08x};\n".format(i, m.offset)
        raw += "   assign end_addr[0][{}] = 32'h{:08x};\n".format(i, m.offset+m.size-1)
        i += 1
    raw += "   assign valid_rule[0] = {}'b{};\n".format(len(slaves), '1'*len(slaves))
    return raw

def instance_ports(w, id_width, masters, slaves):
    ports = [Port('clk'  , 'clk'),
             Port('rst_n', 'rst_n'),
             Port('test_en_i', "1'b0"),
             Port('slave_awatop_i', "{}'d0".format(len(masters)*6)),
             Port('master_awatop_o', '')]
    for s in axi_signals(w, id_width):
        suffix = 'o' if s[1] else 'i'
        name = "slave_{}_{}".format(s[0], suffix)
        if s[0].endswith('user') and not w.user:
            value = "" if s[1] else "{}'d0".format(len(masters))
        else:
            value = "slave_{}".format(s[0])
        ports.append(Port(name, value))

    for s in axi_signals(w, id_width):
        suffix = 'i' if s[1] else 'o'
        name = "master_{}_{}".format(s[0], suffix)
        if s[0].endswith('user') and not w.user:
            value = "{}'d0".format(len(slaves)) if s[1] else ""
        else:
            value = "master_{}".format(s[0])
        ports.append(Port(name, value))

    value = '{' + ', '.join(["32'h{start:08x}".format(start=s.offset) for s in slaves]) + '}'
    ports.append(Port('cfg_START_ADDR_i', 'start_addr'))#value))

    value = '{' + ', '.join(["32'h{end:08x}".format(end=s.offset+s.size-1) for s in slaves]) + '}'
    ports.append(Port('cfg_END_ADDR_i', 'end_addr'))#value))
    ports.append(Port('cfg_valid_rule_i', "valid_rule"))
    ports.append(Port('cfg_connectivity_map_i', "connectivity_map"))
    return ports

def template_ports(w, intf, id_width, is_input):
    ports = []
    for s in axi_signals(w, id_width):
        if s[0].endswith('user') and not w.user:
            continue
        if intf.read_only and (s[0].startswith('aw') or s[0].startswith('w') or s[0].startswith('b')):
            continue
        port_name = "{}_{}".format(intf.name, s[0])
        prefix = 'o' if is_input == s[1] else 'i'
        ports.append(Port("{}_{}".format(prefix, port_name), port_name))
    return ports

def template_wires(w, intf, id_width):
    wires = []
    for s in axi_signals(w, id_width):
        if s[0].endswith('user') and not w.user:
            continue
        if intf.read_only and (s[0].startswith('aw') or s[0].startswith('w') or s[0].startswith('b')):
            continue
        wires.append(Wire("{}_{}".format(intf.name, s[0]), s[2]))
    return wires

class Master:
    def __init__(self, name, d=None):
        self.name = name
        self.slaves = []
        self.idw = 1
        self.read_only = False
        if d:
            self.load_dict(d)

    def load_dict(self, d):
        for key, value in d.items():
            if key == 'slaves':
                # Handled in file loading, ignore here
                continue
            if key == 'id_width':
                self.idw = value
            elif key == 'read_only':
                self.read_only = value
            else:
                print(key)
                raise UnknownPropertyError(
                    "Unknown property '%s' in master section '%s'" % (
                    key, self.name))

class Slave:
    def __init__(self, name, d=None):
        self.name = name
        self.masters = []
        self.offset = 0
        self.size = 0
        self.mask = 0
        self.read_only = False
        if d:
            self.load_dict(d)

    def load_dict(self, d):
        for key, value in d.items():
            if key == 'offset':
                self.offset = value
            elif key == 'size':
                self.size = value
                self.mask = ~(self.size-1) & 0xffffffff
            elif key == 'read_only':
                self.read_only = value
            else:
                raise UnknownPropertyError(
                    "Unknown property '%s' in slave section '%s'" % (
                    key, self.name))

class Parameter:
    def __init__(self, name, value):
        self.name  = name
        self.value = value



class AxiIntercon:
    def __init__(self, name, config_file):
        self.verilog_writer = VerilogWriter(name)
        self.template_writer = VerilogWriter(name);
        self.name = name
        d = OrderedDict()
        self.slaves = []
        self.masters = []
        import yaml

        def ordered_load(stream, Loader=yaml.Loader, object_pairs_hook=OrderedDict):
            class OrderedLoader(Loader):
                pass
            def construct_mapping(loader, node):
                loader.flatten_mapping(node)
                return object_pairs_hook(loader.construct_pairs(node))
            OrderedLoader.add_constructor(
                yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
                construct_mapping)
            return yaml.load(stream, OrderedLoader)
        data = ordered_load(open(config_file))

        config     = data['parameters']
        #files_root = data['files_root']
        self.vlnv       = data['vlnv']

        for k,v in config['masters'].items():
            print("Found master " + k)
            self.masters.append(Master(k,v))
            #d[k] = v['slaves']
        for k,v in config['slaves'].items():
            print("Found slave " + k)
            self.slaves.append(Slave(k,v))

        #for master in self.masters:
            
        #Create master/slave connections
        #for master, slaves in d.items():
        #    for slave in slaves:
        #        self.masters[master].slaves += [self.slaves[slave]]
        #        #self.slaves[slave].masters += [self.masters[master]]

        self.output_file = config.get('output_file', 'axi_intercon.v')

    def _dump(self):
        print("*Masters*")
        for master in self.masters.values():
            print(master.name)
            for slave in master.slaves:
                print(' ' + slave.name)

        print("*Slaves*")
        for slave in self.slaves.values():
            print(slave.name)
            for master in slave.masters:
                print(' ' + master.name)
                            
    def write(self):
        w = Widths()
        w.addr = 32
        w.data = 64
        w.user = 0

        max_idw = max([m.idw for m in self.masters])
        max_sidw = max_idw + int(math.ceil(math.log2(len(self.masters))))
        file = self.output_file

        _template_ports = [Port('clk'  , 'clk'),
                           Port('rst_n', 'rstn')]
        template_parameters = []

        #Module header
        self.verilog_writer.add(ModulePort('clk'  , 'input'))
        self.verilog_writer.add(ModulePort('rst_n', 'input'))
        for master in self.masters:
            for port in module_ports(w, master, master.idw, True):
                self.verilog_writer.add(port)
            for wire in template_wires(w, master, master.idw):
                self.template_writer.add(wire)
            _template_ports += template_ports(w, master, master.idw, True)

        for slave in self.slaves:
            for port in module_ports(w, slave, max_sidw, False):
                self.verilog_writer.add(port)
            for wire in template_wires(w, slave, max_sidw):
                self.template_writer.add(wire)
            _template_ports += template_ports(w, slave, max_sidw, False)

        raw = ""

        nm = len(self.masters)
        for s in axi_signals(w, max_idw):
            if s[0].endswith('user') and not w.user:
                continue
            raw += "   wire [{}:0]".format(nm-1)
            if s[2]:
                raw += "[{}:0]".format(s[2]-1)
            raw += " slave_{};\n".format(s[0])
        ns = len(self.slaves)
        for s in axi_signals(w, max_sidw):
            if s[0].endswith('user') and not w.user:
                continue
            raw += "   wire [{}:0]".format(ns-1)
            if s[2]:
                raw += "[{}:0]".format(s[2]-1)
            raw += " master_{};\n".format(s[0])
            
        raw += """
   wire [0:0][{ns}:0][{aw}:0] start_addr;
   wire [0:0][{ns}:0][{aw}:0] end_addr;
   wire [0:0][{ns}:0]       valid_rule;
   wire [{nm}:0][{ns}:0]      connectivity_map;
        """.format(nm=nm-1,aw=w.addr-1, ns=ns-1)
            
        raw += assigns(w, max_idw, self.masters, self.slaves)

        self.verilog_writer.raw = raw
        parameters = [Parameter('AXI_ADDRESS_W', w.addr),
                      Parameter('AXI_DATA_W'   , w.data),
                      Parameter('N_MASTER_PORT', len(self.slaves)),
                      Parameter('N_SLAVE_PORT' , len(self.masters)),
                      Parameter('AXI_ID_IN'    , max_idw),
                      Parameter('AXI_USER_W'   , w.user or 1),
                      Parameter('N_REGION'     , 1),
                      ]
        ports = instance_ports(w, max_idw, self.masters, self.slaves)
        
        self.verilog_writer.add(Instance('axi_node',
                                         'axi_node',
                                         parameters,
                                         ports))

        self.template_writer.add(Instance(self.name,
                                          self.name,
                                          template_parameters,
                                          _template_ports))

        self.verilog_writer.write(file)
        self.template_writer.write(file+'h')
        
        core_file = self.vlnv.split(':')[2]+'.core'
        vlnv = self.vlnv
        with open(core_file, 'w') as f:
            f.write('CAPI=2:\n')
            files = [{file     : {'file_type' : 'systemVerilogSource'}},
                     {file+'h' : {'is_include_file' : True,
                                  'file_type' : 'verilogSource'}}
            ]
            coredata = {'name' : vlnv,
                        'targets' : {'default' : {}},
            }
                        
            coredata['filesets'] = {'rtl' : {'files' : files}}
            coredata['targets']['default']['filesets'] = ['rtl']
                    
            f.write(yaml.dump(coredata))

if __name__ == "__main__":
    name = "axi_intercon"
    g = AxiIntercon(name, sys.argv[1])
    print("="*80)
    g.write()

