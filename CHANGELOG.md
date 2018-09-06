# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased

### Changed
- Change common cells source URL and minimum version requirement to 1.7.3.
- Remove defines and switch to common `axi_pkg`
- Switch to common interface for wrappers (including slices), slices from common axi repo

### Fixed
- Prevent reading from empty FIFO in `axi_address_decoder_DW.sv`.

## 1.0.3

### Changed
- Adopt to real generic FIFO.
- Replace non-ASCII characters in headers.
- Rename `axi_node_wrap.sv` to `axi_node_intf_wrap.sv` in accordance with module name.

## 1.0.2

### Added
- Benderize (add Bender.yml file).

## 1.0.1

### Changed
- Bugfixes for 64-bit support on address line.

## 1.0.0

### Changed
- Open source release.

### Added
- Initial commit.
