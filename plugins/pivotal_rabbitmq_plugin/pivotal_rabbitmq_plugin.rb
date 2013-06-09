#! /usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'newrelic_plugin'
require 'rabbitmq_manager'
require 'uri'

module NewRelic
  module RabbitMQPlugin
    class Agent < NewRelic::Plugin::Agent::Base
      agent_guid 'com.pivotal.newrelic.plugin.rabbitmq'
      agent_version '0.0.2'
      agent_config_options :management_api_url
      agent_human_labels('RabbitMQ') do
        uri = URI.parse(management_api_url)
        "#{uri.host}:#{uri.port}"
      end

      def poll_cycle
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
        queue_totals[totals_key] || 0
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
