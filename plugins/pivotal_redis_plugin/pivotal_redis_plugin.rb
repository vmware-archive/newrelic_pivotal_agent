#!/usr/bin/env ruby
# The MIT License
#
# Copyright (c) 2013 GoPivotal, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

require "rubygems"
require "bundler/setup"
require "newrelic_plugin"
require "redis"

#
#
# The entire agent should be enclosed in a "RedisPlugin" module
#
module RedisPlugin
  #
  # Agent, Metric and PollCycle classes
  #
  # Each agent module must have an Agent, Metric and PollCycle class that
  # inherits from their
  # Component counterparts as you can see below.
  #
  class Agent < NewRelic::Plugin::Agent::Base

    agent_config_options :hostname, :username, :password, :hostport, :agent_name, :debug, :testrun
    agent_guid "com.gopivotal.newrelic.plugins.redis"
    agent_version "1.0.4"

    # The block runs in the context of the agent instance.
    #
    if :hostport then agent_human_labels("Redis") { "#{hostname}:#{hostport}" }
    else agent_human_labels("Redis") { "#{hostname}:80" } end

    def setup_metrics
      @metric_types = Hash.new("unit") # Default metric label
      @metric_types["uptime_in_seconds"] = "seconds"
      @metric_types["connected_clients"] = "clients"
      @metric_types["blocked_clients"] = "clients"
      @metric_types["used_memory"] = "bytes"
      @metric_types["used_memory_rss"] = "bytes"
      @metric_types["used_memory_peak"] = "bytes"
      @metric_types["used_memory_lua"] = "bytes"
      @metric_types["mem_fragmentation_ratio"] = "percent"
      @metric_types["rdb_changes_since_last_save"] = "changes"
      @metric_types["rdb_last_bgsave_time_sec"] = "seconds"
      @metric_types["rdb_current_bgsave_time_sec"] = "seconds"
      @metric_types["total_connections_received"] = "connections"
      @metric_types["total_commands_processed"] = "commands"
      @metric_types["instantaneous_ops_per_sec"] = "Ops/sec"
      @metric_types["rejected_connections"] = "connections"
      @metric_types["expired_keys"] = "keys"
      @metric_types["evicted_keys"] = "keys"
      @metric_types["keyspace_hits"] = "hits"
      @metric_types["keyspace_misses"] = "misses"
      @metric_types["connected_slaves"] = "slaves"
      @metric_types["used_cpu_sys"] = "seconds"
      @metric_types["used_cpu_user"] = "seconds"
      @metric_types["used_cpu_sys_children"] = "seconds"
      @metric_types["used_cpu_user_children"] = "seconds"
    end

    def poll_cycle
      begin
        # Gather and report stats here
        url = "redis://#{":#{self.password}" if self.password }@#{self.hostname}:#{self.hostport}/4"
        redis = Redis.new('url' => url)
        info = redis.info
        report_stats(info)
        # Only do testruns once, then quit
        if "#{self.testrun}" == "true" then exit end
      rescue => e
        $stderr.puts "[Redis] Exception while processing metrics. Check configuration."
        $stderr.puts e.message
        if "#{self.debug}" == "true"
          $stderr.puts e.backtrace.inspect
        end
      end
    end

    private

    def report_stats(stats)
      report_metric_check_debug("UsedCPU/System", @metric_types["used_cpu_sys"], stats["used_cpu_sys"])
      report_metric_check_debug("UsedCPU/User", @metric_types["used_cpu_user"], stats["used_cpu_user"])
      report_metric_check_debug("UsedCPU/SystemChildren", @metric_types["used_cpu_sys_children"], stats["used_cpu_sys_children"])
      report_metric_check_debug("UsedCPU/UserChildren", @metric_types["used_cpu_user_children"], stats["used_cpu_user_children"])
      report_metric_check_debug("Connections/SlavesConnected", @metric_types["connected_slaves"], stats["connected_slaves"])
      report_metric_check_debug("Connections/TotalReceived", @metric_types["total_connections_received"], stats["total_connections_received"])
      report_metric_check_debug("Connections/ConnectedClients", @metric_types["connected_clients"], stats["connected_clients"])
      report_metric_check_debug("Connections/RejectedConnections", @metric_types["rejected_connections"], stats["rejected_connections"])
      report_metric_check_debug("Memory/UsedMemory", @metric_types["used_memory"], stats["used_memory"])
      report_metric_check_debug("Memory/RSS", @metric_types["used_memory_rss"], stats["used_memory_rss"])
      report_metric_check_debug("Memory/Peak", @metric_types["used_memory_peak"], stats["used_memory_peak"])
      report_metric_check_debug("Memory/LUA", @metric_types["used_memory_lua"], stats["used_memory_lua"])
      report_metric_check_debug("Memory/FragmentationRation", @metric_types["mem_fragmentation_ratio"], stats["mem_fragmentation_ratio"])
      report_metric_check_debug("Keys/KeySpaceHits", @metric_types["keyspace_hits"], stats["keyspace_hits"])
      report_metric_check_debug("Keys/KeySpaceMisses", @metric_types["keyspace_misses"], stats["keyspace_misses"])
      report_metric_check_debug("Keys/Expired", @metric_types["expired_keys"], stats["expired_keys"])
      report_metric_check_debug("Keys/Evicted", @metric_types["evicted_keys"], stats["evicted_keys"])
    end


    def report_metric_check_debug(metricname, metrictype, metricvalue)
      if "#{self.debug}" == "true"
        puts("#{metricname}[#{metrictype}] : #{metricvalue}")
      else
        report_metric metricname, metrictype, metricvalue
      end
    end
  end

  NewRelic::Plugin::Setup.install_agent :redis, self

  # Check if we're included as a module and if not we launch the agent, otherwise the
  # main pivotal agent calls this with all the plugins installed
  #
  if __FILE__==$0
    NewRelic::Plugin::Run.setup_and_run
  end

end
