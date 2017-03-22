#!/usr/bin/env ruby
# Switchvox PBX SNMP Load Check
# ===
#
# Checks the reported SNMP system load for Switchvox PBX
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: snmp
#
# USAGE:
#
#   check-switchvox-pbx  -h host -C community -p prefix
#

require 'sensu-plugin/check/cli'
require 'snmp'

class CheckSwitchvoxLoad < Sensu::Plugin::Check::CLI
  option :host,
         short: '-h host',
         boolean: true,
         default: '127.0.0.1',
         required: true

  option :community,
         short: '-C snmp community',
         boolean: true,
         default: 'public'

  option :snmp_version,
         short: '-v version',
         description: 'SNMP version to use (SNMPv1, SNMPv2c (default))',
         default: 'SNMPv2c'

  option :warn,
         description: 'Warning load average threshold',
         short: '-w VALUE',
         long: '--warning VALUE',
         default: '3',
         required: true

  option :crit,
         description: 'Critical load average threshold',
         short: '-c VALUE',
         long: '--critical VALUE',
         default: '5',
         required: true

  def run
    metrics = {
      '1.3.6.1.4.1.22736.10.3.3.1' => 'load'
    }
    response_hash = {}
    metrics.each do |objectid, suffix|
      begin
        manager = SNMP::Manager.new(host: config[:host].to_s, community: config[:community].to_s, version: config[:snmp_version].to_sym)
        response = manager.get([objectid.to_s])
      rescue SNMP::RequestTimeout
        unknown "#{config[:host]} not responding"
      rescue => e
        unknown "An unknown error occured: #{e.inspect}"
      end
      response.each_varbind do |vb|
        response_hash[suffix.to_s] = vb.value.to_f
      end
      manager.close
    end

    if response_hash['load'] >= config[:crit].to_f
      critical "Load average #{response_hash['load']}"
    elsif response_hash['load'] >= config[:warn].to_f
      warning "Load average #{response_hash['load']}"
    else
      ok "Load average #{response_hash['load']}"
    end
  end
end
