## sensu-plugins-switchvox

[![Build Status](https://travis-ci.org/smbambling/sensu-plugins-switchvox.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-switchvox)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-switchvox.svg)](http://badge.fury.io/rb/sensu-plugins-switchvox)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-switchvox.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-switchvox)

## Functionality

**check-switchvox-disk-pcnt.rb**
Checks the reported SNMP disk usage percentage for Switchvox PBX

**check-switchvox-load.rb**
Checks the reported SNMP system load for Switchvox PBX

**check-switchvox-mem-pcnt.rb**
Checks the reported SNMP memory usage percentage for Switchvox PBX

**metrics-switchvox-pbx**

Collects Metrics via SNMP for a Switchvox PBX

  - Disk
    - Used
    - Total
  - Load
  - Memory
    - Used
    - Total
  - Swap
    - Used
    - Total
  - Extentions
    - Used
    - Max
  - Calls
    - Total
    - Agent login
    - Agent logout
    - IVR
    - Parked
    - Queued
    - Ringing
    - Talking
    - Unknown
  - Sucscription Days Left


## Files
 * check-switchvox-disk-pcnt.rb
 * check-switchvox-load.rb
 * check-switchvox-mem-pcnt.rb
 * metrics-switchvox-pbx

## Usage

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)
