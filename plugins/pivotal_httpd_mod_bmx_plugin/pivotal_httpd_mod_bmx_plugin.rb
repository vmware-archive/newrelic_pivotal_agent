#!/usr/bin/env ruby
require "rubygems"
require "bundler/setup"
require "newrelic_plugin"
require "net/http"

# This is based on the New Relic HTTPD mod_status plugin

#
#
# The entire agent should be enclosed in a "ApacheHTTPDAgent" module
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
    agent_version "0.0.2"
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

      @mod_bmx_stat_url = URI.parse("http://#{self.hostname}:#{self.hostport}/bmx?query=mod_bmx_vhost:Type=forever,Host=#{hostname},Port=#{hostport}")

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
      @metric_types["OutResponses200"] = "requests"
      @metric_types["OutResponses301"] = "requests"
      @metric_types["OutResponses302"] = "requests"
      @metric_types["OutResponses401"] = "requests"
      @metric_types["OutResponses403"] = "requests"
      @metric_types["OutResponses404"] = "requests"
      @metric_types["OutResponses500"] = "requests"
      @metric_types["InLowBytes"] = "bytes"
      @metric_types["OutLowBytes"] = "bytes"
      @metric_types["InRequests"] = "requests"
      @metric_types["OutResponses"] = "responses"

    end

    def poll_cycle
      mod_bmx_stats()
      # Only do testruns once, then quit
      if "#{self.testrun}" == "true" then exit end
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
          if "#{self.debug}" == "true" then puts("URL: #{staturl}") end
          resp = ::Net::HTTP.get_response(staturl)
          data = resp.body
          lines = data.split("\n")
        end
      rescue => e
        $stderr.puts "#{e}: #{e.backtrace.join("\n  ")}"
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
