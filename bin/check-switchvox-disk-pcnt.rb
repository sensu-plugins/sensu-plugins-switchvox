#!/usr/bin/env ruby
# Switchvox PBX SNMP Load Check
# ===
#
# Checks the reported SNMP disk usage percentage for Switchvox PBX
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

class CheckSwitchvoxDisk < Sensu::Plugin::Check::CLI
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
         default: '70',
         required: true

  option :crit,
         description: 'Critical load average threshold',
         short: '-c VALUE',
         long: '--critical VALUE',
         default: '80',
         required: true

  def run
    metrics = {
      '1.3.6.1.4.1.22736.10.3.2.2' => 'disk.total',
      '1.3.6.1.4.1.22736.10.3.2.1' => 'disk.used'
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

    pct_used = ((response_hash['disk.used'] / response_hash['disk.total']) * 100).round.to_i

    if pct_used >= config[:crit].to_i
      critical "Disk Usage #{pct_used}%"
    elsif pct_used >= config[:warn].to_i
      warning "Disk Usage #{pct_used}%"
    else
      ok "Disk Usage #{pct_used}%"
    end
  end
end
