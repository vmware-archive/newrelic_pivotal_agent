#!/usr/bin/env ruby
require "rubygems"
require "bundler/setup"
require "newrelic_plugin"
require "net/http"

# This is based on the New Relic HTTPD mod_status extension

#
#
# The entire agent should be enclosed in a "ApacheHTTPDAgent" module
#
module HttpdModBmxExtension
  #
  # Agent, Metric and PollCycle classes
  #
  # Each agent module must have an Agent, Metric and PollCycle class that
  # inherits from their
  # Component counterparts as you can see below.
  #
  class Agent < NewRelic::Plugin::Agent::Base

    agent_config_options :hostname, :username, :password, :hostport, :agent_name, :debug, :testrun
    agent_guid "com.gopivotal.newrelic.extensions.httpd_mod_bmx"
    agent_version "0.0.1"
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
      @metric_types["Total Accesses"] = "accesses"
      @metric_types["Total kBytes"] = "kb"
      @metric_types["CPULoad"] = "%"
      @metric_types["Uptime"] = "sec"
      @metric_types["ReqPerSec"] = "requests"
      @metric_types["InBytesGET"] = "bytes"
      @metric_types["BytesPerReq"] = "bytes/req"
      @metric_types["BusyWorkers"] = "workers"
      @metric_types["IdleWorkers"] = "workers"
      @metric_types["ConnsTotal"] = "connections"
      @metric_types["ConnsAsyncWriting"] = "connections"
      @metric_types["ConnsAsyncKeepAlive"] = "connections"
      @metric_types["ConnsAsyncClosing"] = "connections"

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
        when @metric_types[skey] == "workers"
          statstree = "#{statstree}/Workers/#{skey}"
        when @metric_types[skey] == "connections"
          statstree = "#{statstree}/Connections/#{skey}"
        when @metric_types[skey] == "%"
          statshash[skey] = 100 * statshash[skey].to_f
          statstree = "#{statstree}/#{skey}"
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
  # main pivotal agent calls this with all the extensions installed
  #
    if __FILE__==$0
      NewRelic::Plugin::Run.setup_and_run
    end

end
