#! /usr/bin/env ruby
#
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

require 'rubygems'
require 'bundler/setup'
require 'newrelic_plugin'
require 'rabbitmq_manager'
require 'uri'

module NewRelic
  module RabbitMQPlugin
    class Agent < NewRelic::Plugin::Agent::Base
      agent_guid 'com.pivotal.newrelic.plugin.rabbitmq'
      agent_version '1.0.5'
      agent_config_options :management_api_url, :debug
      agent_human_labels('RabbitMQ') do
        rmq_manager.overview["cluster_name"]
      end

      def poll_cycle
        if debug
          puts "[RabbitMQ] Debug Mode On: Metric data will not be sent to new relic"
        end

        @overview = rmq_manager.overview
        report_metric_check_debug 'Queued Messages/Ready', 'messages', queue_size_ready
        report_metric_check_debug 'Queued Messages/Unacknowledged', 'messages', queue_size_unacknowledged

        report_metric_check_debug 'Message Rate/Acknowledge', 'messages/sec', ack_rate
        report_metric_check_debug 'Message Rate/Confirm', 'messages/sec', confirm_rate
        report_metric_check_debug 'Message Rate/Deliver', 'messages/sec', deliver_rate
        report_metric_check_debug 'Message Rate/Publish', 'messages/sec', publish_rate
        report_metric_check_debug 'Message Rate/Return', 'messages/sec', return_unroutable_rate

        report_nodes
        report_queues

      rescue => e
        $stderr.puts "[RabbitMQ] Exception while processing metrics. Check configuration."
        $stderr.puts e.message
        $stderr.puts e.backtrace.inspect if debug
      end

      def report_metric_check_debug(metricname, metrictype, metricvalue)
        if debug
          puts("#{metricname}[#{metrictype}] : #{metricvalue}")
        else
          report_metric metricname, metrictype, metricvalue
        end
      end

      private

      def rmq_manager
        @rmq_manager ||= ::RabbitMQManager.new(management_api_url)
      end

      def queue_size_for(type = nil)
        totals_key = 'messages'
        totals_key << "_#{type}" if type

        queue_totals = @overview['queue_totals']
        if queue_totals.size == 0
          $stderr.puts "[RabbitMQ] No data found for queue_totals[#{totals_key}]. Check that queues are declared. No data will be reported."
        else
          queue_totals[totals_key] || 0
        end
      end

      def queue_size_ready
        queue_size_for 'ready'
      end

      def queue_size_unacknowledged
        queue_size_for 'unacknowledged'
      end

      def ack_rate
        rate_for 'ack'
      end

      def confirm_rate
        rate_for 'confirm'
      end

      def deliver_rate
        rate_for 'deliver'
      end

      def publish_rate
        rate_for 'publish'
      end

      def rate_for(type)
        msg_stats = @overview['message_stats']

        if msg_stats.is_a?(Hash)
          details = msg_stats["#{type}_details"]
          details ? details['rate'] : 0
        else
          0
        end
      end

      def return_unroutable_rate
        rate_for 'return_unroutable'
      end

      def report_nodes
        rmq_manager.nodes.each do |n|
          report_metric_check_debug mk_path('Node', n['name'], 'File Descriptors'), 'file_descriptors', n['fd_used']
          report_metric_check_debug mk_path('Node', n['name'], 'Sockets'), 'sockets', n['sockets_used']
          report_metric_check_debug mk_path('Node', n['name'], 'Erlang Processes'), 'processes', n['proc_used']
          report_metric_check_debug mk_path('Node', n['name'], 'Memory Used'), 'bytes', n['mem_used']
        end
      end

      def report_queues
        rmq_manager.queues.each do |q|
          next if q['name'].start_with?('amq.gen')
          report_metric_check_debug mk_path('Queue', q['vhost'], q['name'], 'Messages', 'Ready'), 'message', q['messages_ready']
          report_metric_check_debug mk_path('Queue', q['vhost'], q['name'], 'Memory'), 'bytes', q['memory']
          report_metric_check_debug mk_path('Queue', q['vhost'], q['name'], 'Messages', 'Total'), 'message', q['messages']
          report_metric_check_debug mk_path('Queue', q['vhost'], q['name'], 'Consumers', 'Total'), 'consumers', q['consumers']
          report_metric_check_debug mk_path('Queue', q['vhost'], q['name'], 'Consumers', 'Active'), 'consumers', q['active_consumers']
        end
      end

      def mk_path(*args)
        args.map { |a| URI.encode_www_form_component a }.join "/"
      end
    end

    NewRelic::Plugin::Setup.install_agent :rabbitmq, self

    # Launch the agent; this never returns.
    NewRelic::Plugin::Run.setup_and_run if __FILE__ == $PROGRAM_NAME
  end
end
