#!/usr/bin/env ruby
# The MIT License
#
# Copyright (c) 2013-2014 Pivotal Software, Inc.
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
require "net/http"

# This is based on the New Relic HTTPD mod_status plugin

#
#
# The entire agent should be enclosed in a "HttpdModBmxPlugin" module
#
module HttpdModBmxPlugin
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
    agent_version "1.0.5"
    #
    # Each agent class must also include agent_human_labels. agent_human_labels
    # requires:
    # A friendly name of your component to appear in graphs.
    # A block that returns a friendly name for this instance of your component.

    # The block runs in the context of the agent instance.
    #
    if :hostport then agent_human_labels("ModBmx") { "#{hostname}:#{hostport}" }
    else agent_human_labels("ModBMX") { "#{hostname}:80" } end

    def setup_metrics
      if !self.hostport then self.hostport = 80 end

      begin
        @mod_bmx_stat_url = URI.parse("http://#{self.hostname}:#{self.hostport}/bmx?query=mod_bmx_vhost:Type=forever,Host=#{hostname},Port=#{hostport}")
      rescue
        $stderr.puts "Error Parsing URL: http://#{self.hostname}:#{self.hostport}/bmx?query=mod_bmx_vhost:Type=forever,Host=#{hostname},Port=#{hostport}"
      end
      @metric_types = Hash.new("ms")
      @metric_types["InBytesGET"] = "bytes"
      @metric_types["InBytesPOST"] = "bytes"
      @metric_types["InBytesHEAD"] = "bytes"
      @metric_types["InBytesPUT"] = "bytes"
      @metric_types["InRequestsGET"] = "requests"
      @metric_types["InRequestsPOST"] = "requests"
      @metric_types["InRequestsPUT"] = "requests"
      @metric_types["InRequestsHEAD"] = "requests"
      @metric_types["OutBytes200"] = "bytes"
      @metric_types["OutBytes301"] = "bytes"
      @metric_types["OutBytes302"] = "bytes"
      @metric_types["OutBytes401"] = "bytes"
      @metric_types["OutBytes403"] = "bytes"
      @metric_types["OutBytes404"] = "bytes"
      @metric_types["OutBytes500"] = "bytes"
      @metric_types["OutResponses200"] = "responses"
      @metric_types["OutResponses301"] = "responses"
      @metric_types["OutResponses302"] = "responses"
      @metric_types["OutResponses401"] = "responses"
      @metric_types["OutResponses403"] = "responses"
      @metric_types["OutResponses404"] = "responses"
      @metric_types["OutResponses500"] = "responses"
      @metric_types["InLowBytes"] = "bytes"
      @metric_types["OutLowBytes"] = "bytes"
      @metric_types["InRequests"] = "requests"
      @metric_types["OutResponses"] = "responses"

    end

    def poll_cycle
      begin
        if "#{self.debug}" == "true"
          puts "[ModBmx] Debug Mode On: Metric data will not be sent to new relic"
        end

        mod_bmx_stats()
        # Only do testruns once, then quit
        if "#{self.testrun}" == "true" then exit end
      rescue => e
        $stderr.puts "[ModBmx] Exception while processing metrics. Check configuration."
        $stderr.puts e.message
        if "#{self.debug}" == "true" 
          $stderr.puts e.backtrace.inspect
        end
      end
    end

    private

    def get_stats(staturl)
      lines = Array.new
      begin
        if "#{self.testrun}" == "true"
          flines = File.open(statfile, "r")
          flines.each {|l| lines << l}
        flines.close
        else
          if "#{self.debug}" == "true" then puts("[ModBmx] URL: #{staturl}") end
          resp = ::Net::HTTP.get_response(staturl)
          data = resp.body
          lines = data.split("\n")
        end
      rescue => e
        $stderr.puts "[ModBmx] ERROR: #{e}"
        $stderr.puts "[ModBmx] Please check configuration and that host is available"
        if "#{self.debug}" == "true" 
          $stderr.puts "[ModBmx] #{e}: #{e.backtrace.join("\n  ")}"
        end
      end
      return lines
    end

    def mod_bmx_stats
      lines = get_stats @mod_bmx_stat_url
      if lines.empty? then return end

      stats = Hash.new
      lines.each { |line|
        marray = line.split(": ")
        stats[marray[0]] = marray[1]
      }

      if !stats.empty? then process_stats stats end
    end

    def process_stats(statshash)
      statshash.each_key { |skey|
        statstree = "HTTPD"
        case 
        when @metric_types[skey] == "%"
          statshash[skey] = 100 * statshash[skey].to_f
          statstree = "#{statstree}/#{skey}"
        when skey == "StartDate"
          next 
        when skey == "StartTime" 
          next
        when skey == "Name"
          next
        when skey == "StartElapsed"
          next
        else
          statstree = "#{statstree}/#{skey}"
        end
        report_metric_check_debug statstree, @metric_types[skey], statshash[skey]
      }
    end

    def report_metric_check_debug(metricname, metrictype, metricvalue)
      if "#{self.debug}" == "true"
        puts("#{metricname}[#{metrictype}] : #{metricvalue}")
      else
        report_metric metricname, metrictype, metricvalue
      end
    end
  end
  
  NewRelic::Plugin::Setup.install_agent :httpd_mod_bmx, self

  # Check if we're included as a module and if not we launch the agent, otherwise the 
  # main pivotal agent calls this with all the plugins installed
  #
  if __FILE__==$0
    NewRelic::Plugin::Run.setup_and_run
  end

end
