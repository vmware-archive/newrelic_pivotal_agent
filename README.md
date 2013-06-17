# Pivotal Plugins for New Relic

This README describes how to install and configure the Pivotal Plugins for New Relic.  For convenience, you can install all plugins at once using the procedure below.  

This procedure installs the following plugins:

* **RabbitMQ**: Allows you to gather metrics for a RabbitMQ server and display them in your New Relic dashboard.

## Before You Begin

* Be sure that Ruby (version 1.8.7 or later) is installed on the computer on which you will install the Pivotal Plugins for New Relic.  
* Install the `bundle` Ruby gem.
* Ensure that the computer on which you are installing the Pivotal plugins has network access to the computer on which the desired product to be monitored is installed, or that both are installed on the same computer.
* For RabbitMQ Monitoring: Enable the RabbitMQ management plugins by executing the `rabbitmq-plugins enable rabbitmq_management` command.  See [Management Plugins](http://www.rabbitmq.com/management.html).
* For VFWS Monitoring: mod_bmx is enabled by default and allows access from localhost. If monitoring remotely you will need to enable access. The default URL for BMX is http://localhost/bmx.

## Installation Procedure

1. Create a directory that will contain the Pivotal Plugins for New Relic.

1. Download the latest ZIP of the Pivotal Agent for New Relic from the tags section of  [https://github.com/gopivotal/newrelic_pivotal_agent](https://github.com/gopivotal/newrelic_pivotal_agent) and extract the contents into the directory you just created.

3. In the `config` directory, make a copy of the `template_newrelic_plugin.yml` file and name it `newrelic_plugin.yml`

4. Edit `config/newrelic_plugin.yml` and replace the string "YOUR_LICENSE_KEY_HERE" with your [New Relic license key](https://newrelic.com/docs/subscriptions/license-key).   

5a. For RabbitMQ: In the same `config/newrelic_plugin.yml` file, set the `rabbitmq:management_api_url` property to your RabbitMQ management URL.  The default value is `http://guest:guest@localhost:55672`, which assumes that RabbitMQ is running on the same computer on which you are installing the Pivotal Plugins for New Relic, you are using the default port (55672), and you connect using the default `guest` RabbitMQ user.  If your RabbitMQ management URL is different, update the property accordingly.

5b. For VFWS/mod_Bmx: In the same `config/newrelic_plugin.yml` file, set the configuration properties for your servers. The template contains example of multiple servers to be monitored.

6. From the top-level directory, run the following commands: 

        $ bundle install
        $ ./pivotal_agent
7. After a brief period, the Pivotal Plugins will appear in your New Relic Dashboard under the Plugins tab on the left. 

## Reporting Issues

Please use the Github [issue tracker](https://github.com/gopivotal/newrelic_pivotal_agent/issues)

## Contributing

We welcome contributions. Please fork the repository and issue a pull request for changes

