#!/usr/bin/env python
import sys
from collections import OrderedDict, defaultdict
import yaml

from verilogwriter import Signal, Wire, Instance, ModulePort, Port, VerilogWriter

def axi_signals(id_width, addr_width, user_width, data_width):
    signals = [
        ("awid"    , False, id_width),
        ("awaddr"  , False, addr_width  ),
        ("awlen"   , False, 8  ),
        ("awsize"  , False, 3  ),
        ("awburst" , False, 2 ),
        ("awlock"  , False, 0 ),
        ("awcache" , False, 4 ),
        ("awprot"  , False, 3 ),
        ("awregion", False, 4),
    ]
    if user_width:
        signals.append(("awuser"  , False, user_width))
    signals += [
        ("awqos"   , False, 4),
        ("awvalid" , False, 0),
        ("awready" , True , 0),

        ("arid"    , False, id_width),
        ("araddr"  , False, addr_width),
        ("arlen"   , False, 8),
        ("arsize"  , False, 3),
        ("arburst" , False, 2),
        ("arlock"  , False, 0),
        ("arcache" , False, 4),
        ("arprot"  , False, 3),
        ("arregion", False, 4),
    ]
    if user_width:
        signals.append(("aruser"  , False, user_width))
    signals += [
        ("arqos"   , False, 4),
        ("arvalid" , False, 0),
        ("arready" , True , 0),
            
        ("wdata" , False, data_width),
        ("wstrb" , False, data_width//8),
        ("wlast" , False, 0),
    ]
    if user_width:
        signals.append(("wuser"  , False, user_width))
    signals += [
        ("wvalid", False, 0),
        ("wready", True , 0),

        ("bid"   , True , id_width),
        ("bresp" , True , 2),
        ("bvalid", True , 0),
    ]
    if user_width:
        signals.append(("buser"  , True, user_width))
    signals += [
        ("bready", False, 0),

        ("rid"   , True , id_width),
        ("rdata" , True , data_width),
        ("rresp" , True , 2),
        ("rlast" , True , 0),
    ]
    if user_width:
        signals.append(("ruser"  , True, user_width))
    signals += [
        ("rvalid", True , 0),
        ("rready", False, 0),
    ]
    return signals

class AxiBus(object):
    def __init__(self, name, id_width, addr_width, user_width, data_width):
        self.name = name
        self.signals = [
            ("awid"    , False, id_width),
            ("awaddr"  , False, addr_width  ),
            ("awlen"   , False, 8  ),
            ("awsize"  , False, 3  ),
            ("awburst" , False, 2 ),
            ("awlock"  , False, 0 ),
            ("awcache" , False, 4 ),
            ("awprot"  , False, 3 ),
            ("awregion", False, 4),
            ]
        if user_width:
            self.signals.append(("awuser"  , False, user_width))
        self.signals += [
            ("awqos"   , False, 4),
            ("awvalid" , False, 0),
            ("awready" , True , 0),

            ("arid"    , False, id_width),
            ("araddr"  , False, addr_width),
            ("arlen"   , False, 8),
            ("arsize"  , False, 3),
            ("arburst" , False, 2),
            ("arlock"  , False, 0),
            ("arcache" , False, 4),
            ("arprot"  , False, 3),
            ("arregion", False, 4),
            ]
        if user_width:
            self.signals.append(("aruser"  , False, user_width))
        self.signals += [
            ("arqos"   , False, 4),
            ("arvalid" , False, 0),
            ("arready" , True , 0),
            
            ("wdata" , False, data_width),
            ("wstrb" , False, data_width//8),
            ("wlast" , False, 0),
            ]
        if user_width:
            self.signals.append(("wuser"  , False, user_width))
        self.signals += [
            ("wvalid", False, 0),
            ("wready", True , 0),

            ("bid"   , True , id_width),
            ("bresp" , True , 2),
            ("bvalid", True , 0),
            ]
        if user_width:
            self.signals.append(("buser"  , True, user_width))
        self.signals += [
            ("bready", False, 0),

            ("rid"   , True , id_width),
            ("rdata" , True , data_width),
            ("rresp" , True , 2),
            ("rlast" , True , 0),
            ]
        if user_width:
            self.signals.append(("ruser"  , True, user_width))
        self.signals += [
            ("rvalid", True , 0),
            ("rready", False, 0),
        ]

    def assigns(self, masters, slaves, addr_width):
        raw = '\n'
        i = 0
        for m in masters:
            for s in self.signals:
                if s[1]:
                    raw += "   assign o_{}_{} = slave_{}[{}];\n".format(m.name, s[0], s[0], i)
                else:
                    raw += "   assign slave_{}[{}] = i_{}_{};\n".format(s[0], i, m.name, s[0])
            raw += "   assign connectivity_map[{}] = {}'b{};\n".format(i, len(slaves), '1'*len(slaves))
            i += 1

        raw += '\n'

        i = 0
        for m in slaves:
            for s in self.signals:
                if s[1]:
                    raw += "   assign master_{}[{}] = i_{}_{};\n".format(s[0], i, m.name, s[0])
                else:
                    raw += "   assign o_{}_{} = master_{}[{}];\n".format(m.name, s[0], s[0], i)
            raw += "   assign start_addr[0][{}] = 32'h{:08x};\n".format(i, m.offset)
            raw += "   assign end_addr[0][{}] = 32'h{:08x};\n".format(i, m.offset+m.size-1)
            i += 1
        raw += "   assign valid_rule[0] = {}'b{};\n".format(len(slaves), '1'*len(slaves))
        return raw

    def module_ports(self, is_input):
        ports = []
        for s in self.signals:
            prefix = 'o' if is_input == s[1] else 'i'
            ports.append(ModulePort("{}_{}_{}".format(prefix, self.name, s[0]),
                                    'output' if is_input == s[1] else 'input',
                                    s[2]))
        return ports

    def instance_ports(self, masters, slaves):
        ports = [Port('clk'  , 'clk'),
                 Port('rst_n', 'rst_n'),
                 Port('test_en_i', "1'b0")]
        for s in self.signals:
            suffix = 'o' if s[1] else 'i'
            name = "slave_{}_{}".format(s[0], suffix)
            value = "slave_{}".format(s[0])
            ports.append(Port(name, value))

        for s in self.signals:
            suffix = 'i' if s[1] else 'o'
            name = "master_{}_{}".format(s[0], suffix)
            value = "master_{}".format(s[0])
            ports.append(Port(name, value))

        value = '{' + ', '.join(["32'h{start:08x}".format(start=s.offset) for s in slaves]) + '}'
        ports.append(Port('cfg_START_ADDR_i', 'start_addr'))#value))

        value = '{' + ', '.join(["32'h{end:08x}".format(end=s.offset+s.size-1) for s in slaves]) + '}'
        ports.append(Port('cfg_END_ADDR_i', 'end_addr'))#value))
        ports.append(Port('cfg_valid_rule_i', "valid_rule"))
        ports.append(Port('cfg_connectivity_map_i', "connectivity_map"))
        return ports

    def template_ports(self, is_input):
        ports = []
        for s in self.signals:
            port_name = "{}_{}".format(self.name, s[0])
            prefix = 'o' if is_input == s[1] else 'i'
            ports.append(Port("{}_{}".format(prefix, port_name), port_name))
        return ports

    def template_wires(self):
        wires = []
        for s in self.signals:
            wires.append(Wire("{}_{}".format(self.name, s[0]), s[2]))
        return wires

class Master:
    def __init__(self, name, d=None):
        self.name = name
        self.slaves = []
        if d:
            self.load_dict(d)

    def load_dict(self, d):
        for key, value in d.items():
            if key == 'slaves':
                # Handled in file loading, ignore here
                continue
            else:
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
        if d:
            self.load_dict(d)

    def load_dict(self, d):
        for key, value in d.items():
            if key == 'offset':
                self.offset = value
            elif key == 'size':
                self.size = value
                self.mask = ~(self.size-1) & 0xffffffff
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
        #FIXME
        addr_width = 32
        data_width = 64
        id_width = 3
        user_width = 1
        file = self.output_file

        template_ports = [Port('clk'  , 'clk'),
                          Port('rst_n', 'rstn')]
        template_parameters = []

        #Module header
        self.verilog_writer.add(ModulePort('clk'  , 'input'))
        self.verilog_writer.add(ModulePort('rst_n', 'input'))
        for master in self.masters:
            bus = AxiBus(master.name, id_width, addr_width, user_width, data_width)
            for port in bus.module_ports(True):
                self.verilog_writer.add(port)
            for wire in bus.template_wires():
                self.template_writer.add(wire)
            template_ports += bus.template_ports(True)

        for slave in self.slaves:
            bus = AxiBus(slave.name, id_width+1, addr_width, user_width, data_width)
            for port in bus.module_ports(False):
                self.verilog_writer.add(port)
            for wire in bus.template_wires():
                self.template_writer.add(wire)
            template_ports += bus.template_ports(False)

        raw = ""

        nm = len(self.masters)
        for s in axi_signals(id_width, addr_width, user_width, data_width):
            raw += "   wire [{}:0]".format(nm-1)
            if s[2]:
                raw += "[{}:0]".format(s[2]-1)
            raw += " slave_{};\n".format(s[0])
        ns = len(self.slaves)
        for s in axi_signals(id_width+1, addr_width, user_width, data_width):
            raw += "   wire [{}:0]".format(ns-1)
            if s[2]:
                raw += "[{}:0]".format(s[2]-1)
            raw += " master_{};\n".format(s[0])
            
        raw += """
   wire [0:0][{ns}:0][{aw}:0] start_addr;
   wire [0:0][{ns}:0][{aw}:0] end_addr;
   wire [0:0][{ns}:0]       valid_rule;
   wire [{nm}:0][{ns}:0]      connectivity_map;
        """.format(nm=nm-1,aw=addr_width-1, ns=ns-1)
            
        raw += AxiBus("", id_width, addr_width, user_width, data_width).assigns(self.masters, self.slaves, addr_width)

        self.verilog_writer.raw = raw
        parameters = [Parameter('AXI_ADDRESS_W', addr_width),
                      Parameter('AXI_DATA_W'   , data_width),
                      Parameter('N_MASTER_PORT', len(self.slaves)),
                      Parameter('N_SLAVE_PORT' , len(self.masters)),
                      Parameter('AXI_ID_IN'    , id_width),
                      Parameter('AXI_USER_W'   , user_width),
                      Parameter('N_REGION'     , 1),
                      ]
        ports = AxiBus(name, id_width, addr_width, user_width, data_width).instance_ports(self.masters, self.slaves)
        
        self.verilog_writer.add(Instance('axi_node',
                                         'axi_node',
                                         parameters,
                                         ports))

        self.template_writer.add(Instance(self.name,
                                          self.name,
                                          template_parameters,
                                          template_ports))

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

