# Pivotal Plugins for New Relic Monitoring

*This project is unsupported* - Please see "Support" section below for more details

This README describes how to install and configure the Pivotal Plugins for New Relic.  For convenenience, the procedure installs all plugins at once. 

This procedure installs plugins that gather metrics about the following products and displays them in your New Relic dashboard:

* **RabbitMQ**: A protocol-based messaging solution designed for cloud computing and modern, widely distributed web applications. It is the de facto standard for cloud messaging and the leading implementer of Advanced Message Queuing Protocol (AMQP), an open-standards alternative to costly, proprietary commercial messaging technologies.
* **Pivotal Web Server**: Web server and load-balancing component based on Apache HTTP Server.
* **Redis**: Redis is an open source, BSD licensed, advanced key-value store.

## What's New in v1.0.6 (beta)

* The rabbitmq debug logging option now works properly
* Support for running as a daemon

## What's New in v1.0.5

* The RabbitMQ Plugin now reports queue individual queue stats and a new Queues Dashboard has been introduced.
* The default verbose setting has been changed to 0 to reduce the output in log files.
* Redis plugin now supports passwords

## Before You Begin

* Ensure that Ruby (version 1.9.1 or later if using the RabbitMQ Plugin) is installed on the computer on which you will install the Pivotal Plugins for New Relic.  
* Install the `bundle` Ruby gem.
* Ensure that the computer on which you are installing the Pivotal plugins has network access to the computer on which the desired product to be monitored (such as RabbitMQ) is installed, or that both are installed on the same computer.
* For RabbitMQ Monitoring: Enable the RabbitMQ management plugins by executing the `rabbitmq-plugins enable rabbitmq_management` command.  See [Management Plugins](http://www.rabbitmq.com/management.html).
* For vFabric Web Server Monitoring: The vFabric Web Server monitoring module (mod_bmx) is enabled by default in a Web Server instance and allows access from `localhost`. If, however, the Web Server instance is on a remote machine, you will need to enable access. The default URL for BMX is http://localhost/bmx.  See [Configure BMX for Monitoring vFabric Web Server Instances](http://pubs.vmware.com/vfabric53/topic/com.vmware.vfabric.web-server.5.3/web-server/config-mod-bmx.html).

## Installation Procedure

1. Create a directory that will contain the Pivotal Plugins for New Relic.

2. Download the latest ZIP of the Pivotal Agent for New Relic from the tags section of  [https://github.com/gopivotal/newrelic_pivotal_agent](https://github.com/gopivotal/newrelic_pivotal_agent) and extract the contents into the directory you just created.

3. In the `config` directory, make a copy of the `template_newrelic_plugin.yml` file and name it `newrelic_plugin.yml`

4. Edit `config/newrelic_plugin.yml` and replace the string YOUR_LICENSE_KEY_HERE with your [New Relic license key](https://newrelic.com/docs/subscriptions/license-key).   

5. **If you are installing the RabbitMQ plugin**: In the same `config/newrelic_plugin.yml` file, set the `rabbitmq:management_api_url` property to your RabbitMQ management URL.  The configuration file contains examples which are commented out. Different RabbitMQ version use different ports. 

6. **If you are installing the vFabric Web Server plugin**: In the `config/newrelic_plugin.yml` file, set the configuration properties for your Web Server instances, such as the host and port to which they are listening. The template shows how to configure multiple Web server instances.

7. **If you are using the Redis server monitoring plugin**: In `config/newrelic_plugin.yml` file, set the configuration properties for your redis server.

8. **If you are only using one plugin** in the agent make sure the unused plugin's configuration is commented out with # in front of the lines

9. Be sure to comment out configuration information for plugins that you are not installing from the `config/newrelic_plugin.yml` file.

10. From the top-level directory, run the following commands: 

        $ bundle install
        $ ./pivotal_agent

11. After a brief period, the Pivotal Plugins will appear on the left of your New Relic dashboard.

## Support

**Support is not guaranteed** - This project is considered a community project and as such we are only able to provide support on a limited as time is available basis.

Report any issues with these plugins with the Github [issue tracker](https://github.com/pivotalsoftware/newrelic_pivotal_agent/issues)

When reporting issues please note the following:

* Open new issues: Please do not comment on someone else's issue with regards to your own issue. Often different people may have similar errors but different solutions. It makes it difficult to help multiple people on the same issue thead.
* Be as specific as possible. Include pivotal_agent version, monitored software version, log information, etc
* Some problems are directly related with new relic or new relic agent. Faster help would come from reporting them directly to New Relic.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for more information
