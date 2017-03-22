#!/usr/bin/env ruby
# Switchvox PBX SNMP Metrics
# ===
#
# Collects Metrics via SNMP for a Switchvox PBX
#   - Disk
#     - Used
#     - Total
#   - Load
#   - Memory
#     - Used
#     - Total
#   - Swap
#     - Used
#     - Total
#   - Extentions
#     - Used
#     - Max
#   - Calls
#     - Total
#     - Agent login
#     - Agent logout
#     - IVR
#     - Parked
#     - Queued
#     - Ringing
#     - Talking
#     - Unknown
#   - Sucscription Days Left
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: snmp
#
# USAGE:
#
#   check-switchvox-pbx  -h host -C community -p prefix
#

require 'sensu-plugin/metric/cli'
require 'snmp'

# Class that collects and outputs SNMP metrics in graphite format
class MetricsSwitchvox < Sensu::Plugin::Metric::CLI::Graphite
  option :host,
         short: '-h host',
         boolean: true,
         default: '127.0.0.1',
         required: true

  option :community,
         short: '-C snmp community',
         boolean: true,
         default: 'public'

  option :prefix,
         short: '-p prefix',
         description: 'prefix to attach to graphite path',
         default: 'sensu'

  option :snmp_version,
         short: '-v version',
         description: 'SNMP version to use (SNMPv1, SNMPv2c (default))',
         default: 'SNMPv2c'

  option :graphite,
         short: '-g',
         description: 'Replace dots with underscores in hostname',
         boolean: true

  option :mibdir,
         short: '-d mibdir',
         description: 'Full path to custom MIB directory.'

  option :mibs,
         short: '-l mib[,mib,mib...]',
         description: 'Custom MIBs to load (from custom mib path).',
         default: ''

  def run
    metrics = {
      '1.3.6.1.4.1.22736.10.3.2.2' => 'disk.total',
      '1.3.6.1.4.1.22736.10.3.2.1' => 'disk.used',
      '1.3.6.1.4.1.22736.10.3.3.1' => 'load',
      '1.3.6.1.4.1.22736.10.3.1.1' => 'mem.used',
      '1.3.6.1.4.1.22736.10.3.1.2' => 'mem.total',
      '1.3.6.1.4.1.22736.10.3.1.3' => 'swap.used',
      '1.3.6.1.4.1.22736.10.3.1.4' => 'swap.total',
      '1.3.6.1.4.1.22736.10.1.5'   => 'extentions.used',
      '1.3.6.1.4.1.22736.10.1.6'   => 'extentions.max',
      '1.3.6.1.4.1.22736.10.5.1'   => 'calls.current.total',
      '1.3.6.1.4.1.22736.10.5.2'   => 'calls.agent.login',
      '1.3.6.1.4.1.22736.10.5.3'   => 'calls.agent.logout',
      '1.3.6.1.4.1.22736.10.5.9'   => 'calls.ivr',
      '1.3.6.1.4.1.22736.10.5.10'  => 'calls.leaving.voicemail',
      '1.3.6.1.4.1.22736.10.5.12'  => 'calls.parked',
      '1.3.6.1.4.1.22736.10.5.13'  => 'calls.queued',
      '1.3.6.1.4.1.22736.10.5.15'  => 'calls.ringing',
      '1.3.6.1.4.1.22736.10.5.16'  => 'calls.talking',
      '1.3.6.1.4.1.22736.10.5.17'  => 'calls.unknown',
      '1.3.6.1.4.1.22736.10.7.2'   => 'subscription.days.left'
    }
    metrics.each do |objectid, suffix|
      mibs = config[:mibs].split(',')
      begin
        manager = SNMP::Manager.new(host: config[:host].to_s, community: config[:community].to_s, version: config[:snmp_version].to_sym)
        if config[:mibdir] && !mibs.empty?
          manager.load_modules(mibs, config[:mibdir])
        end
        response = manager.get([objectid.to_s])
      rescue SNMP::RequestTimeout
        unknown "#{config[:host]} not responding"
      rescue => e
        unknown "An unknown error occured: #{e.inspect}"
      end
      host = config[:host]
      host = config[:host].tr('.', '_') if config[:graphite]
      response.each_varbind do |vb|
        if config[:prefix]
          output "#{config[:prefix]}.#{host}.#{suffix}", vb.value.to_f
        else
          output "#{host}.#{suffix}", vb.value.to_f
        end
      end
      manager.close
    end
    ok
  end
end
