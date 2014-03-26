#! /usr/bin/env ruby
#
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
      agent_config_options :management_api_url
      agent_human_labels('RabbitMQ') do
        uri = URI.parse(management_api_url)
        "#{uri.host}:#{uri.port}"
      end

      def poll_cycle
        begin
          report_metric 'Queued Messages/Ready', 'messages', queue_size_ready
          report_metric 'Queued Messages/Unacknowledged', 'messages', queue_size_unacknowledged

          report_metric 'Message Rate/Acknowledge', 'messages/sec', ack_rate
          report_metric 'Message Rate/Confirm', 'messages/sec', confirm_rate
          report_metric 'Message Rate/Deliver', 'messages/sec', deliver_rate
          report_metric 'Message Rate/Publish', 'messages/sec', publish_rate
          report_metric 'Message Rate/Return', 'messages/sec', return_unroutable_rate

          report_metric 'Node/File Descriptors', 'file_descriptors', node_info('fd_used')
          report_metric 'Node/Sockets', 'sockets', node_info('sockets_used')
          report_metric 'Node/Erlang Processes', 'processes', node_info('proc_used')
          report_metric 'Node/Memory Used', 'bytes', node_info('mem_used')

          report_queues

        rescue Exception => e
          $stderr.puts "[RabbitMQ] Exception while processing metrics. Check configuration."
          $stderr.puts e.message  
          if "#{self.debug}" == "true"
            $stderr.puts e.backtrace.inspect
          end
        end
      end

      private
      def rmq_manager
        @rmq_manager ||= ::RabbitMQManager.new(management_api_url)
      end

      #
      # Queue size
      #
      def queue_size_for(type = nil)
        totals_key = 'messages'
        totals_key << "_#{type}" if type

        queue_totals = rmq_manager.overview['queue_totals']
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

      #
      # Rates
      #
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
        msg_stats = rmq_manager.overview['message_stats']

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

      #
      # Node info
      #
      def node_info(key)
        default_node_name = rmq_manager.overview['node']
        node = rmq_manager.node(default_node_name)
        node[key]
      end

      def user_count
        rmq_manager.users.length
      end

      def report_queues
        return unless rmq_manager.queues.length > 0
        rmq_manager.queues.each do |q|
          prefix = q['vhost'][0] == '/' ? 'Queue' : 'Queue/'
          report_metric prefix + q['vhost'] + q['name'] + '/Messages/Ready', 'message', q['messages_ready']
          report_metric prefix + q['vhost'] + q['name'] + '/Memory', 'bytes', q['memory']
          report_metric prefix + q['vhost'] + q['name'] + '/Messages/Total', 'message', q['messages']
          report_metric prefix + q['vhost'] + q['name'] + '/Consumers/Total', 'consumers', q['consumers']
          report_metric prefix + q['vhost'] + q['name'] + '/Consumers/Active', 'consumers', q['active_consumers']
        end
      end
    end

    NewRelic::Plugin::Setup.install_agent :rabbitmq, self

    #
    # Launch the agent; this never returns.
    #
    if __FILE__==$0
      NewRelic::Plugin::Run.setup_and_run
    end
  end
end
