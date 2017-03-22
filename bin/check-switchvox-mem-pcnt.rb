#!/usr/bin/env ruby
# Switchvox PBX SNMP Memory Check
# ===
#
# Checks the reported SNMP memory usage percentage for Switchvox PBX
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

class CheckSwitchvoxMemory < Sensu::Plugin::Check::CLI
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

  option :mem_warn,
         description: 'Warning memory usage percentage threshold',
         short: '-w VALUE',
         long: '--mem_warning VALUE',
         default: '85',
         required: true

  option :mem_crit,
         description: 'Critical memory usage percentage threshold',
         short: '-c VALUE',
         long: '--mem_critical VALUE',
         default: '90',
         required: true

  option :swap_warn,
         description: 'Warning swap usage percentage threshold',
         short: '-x VALUE',
         long: '--swap_warning VALUE',
         default: '20',
         required: true

  option :swap_crit,
         description: 'Critical swap usage percentage threshold',
         short: '-y VALUE',
         long: '--swap_critical VALUE',
         default: '30',
         required: true

  def run
    metrics = {
      '1.3.6.1.4.1.22736.10.3.1.1' => 'mem.used',
      '1.3.6.1.4.1.22736.10.3.1.2' => 'mem.total',
      '1.3.6.1.4.1.22736.10.3.1.3' => 'swap.used',
      '1.3.6.1.4.1.22736.10.3.1.4' => 'swap.total'
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

    mem_pct_used = ((response_hash['mem.used'] / response_hash['mem.total']) * 100).round.to_i
    swap_pct_used = ((response_hash['swap.used'] / response_hash['swap.total']) * 100).to_i

    if mem_pct_used >= config[:mem_crit].to_i || swap_pct_used >= config[:swap_crit].to_i
      critical "Active Memory Usage: #{mem_pct_used}% -- Swap Usage: #{swap_pct_used}%"
    elsif mem_pct_used >= config[:mem_warn].to_i || swap_pct_used >= config[:swap_warn].to_i
      warning "Active Memory Usage: #{mem_pct_used}% -- Swap Usage: #{swap_pct_used}%"
    else
      ok "Active Memory Usage: #{mem_pct_used}% -- Swap Usage: #{swap_pct_used}%"
    end
  end
end
