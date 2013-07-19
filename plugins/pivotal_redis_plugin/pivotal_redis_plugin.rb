#!/usr/bin/env ruby
# The MIT License
#
# Copyright (c) 2013 Pivotal
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
    agent_guid "com.gopivotal.newrelic.plugins.httpd_mod_bmx"
    agent_version "1.0.4"

    # The block runs in the context of the agent instance.
    #
    if :hostport then agent_human_labels("Redis") { "#{hostname}:#{hostport}" }
    else agent_human_labels("Redis") { "#{hostname}:80" } end

    def poll_cycle
      begin
        # Gather and report stats here

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
