# Pivotal Extensions for New Relic

This README describes how to install and configure the Pivotal Extensions for New Relic.  For convenience, you can install all extensions at once using the procedure below.  You can also install each extension separately from its corresponding sub-directory under the `extensions` directory; see the README in that directory for more information.

This procedure installs the following extensions:

* **RabbitMQ**: Allows you to gather metrics for a RabbitMQ server and display them in your New Relic dashboard.

## Before You Begin

* Be sure that Ruby (version 1.8.7 or later) is installed on the computer on which you will install the Pivotal Extensions for New Relic.  
* Install the `bundle` Ruby gem.
* Ensure that the computer on which you are installing the Pivotal extensions has network access to the computer on which RabbitMQ is installed, or that both are installed on the same computer.
* Enable the RabbitMQ management plugins by executing the `rabbitmq-plugins enable rabbitmq_management` command.  See [Management Plugins](http://www.rabbitmq.com/management.html).

## Installation Procedure

1. Create a directory that will contain the Pivotal Extensions for New Relic.

1. Download the ZIP of the Pivotal Extensions for New Relic from [https://github.com/gopivotal/newrelic_pivotal_agent](https://github.com/gopivotal/newrelic_pivotal_agent) and extract the contents into the directory you just created.

3. In the `config` directory, make a copy of the `template_newrelic_plugin.yml` file and name it `newrelic_plugin.yml`

4. Edit `config/newrelic_plugin.yml` and replace the string "YOUR_LICENSE_KEY_HERE" with your [New Relic license key](https://newrelic.com/docs/subscriptions/license-key).   

5. In the same `config/newrelic_plugin.yml` file, set the `rabbitmq:management_api_url` property to your RabbitMQ management URL.  The default value is `http://guest:guest@localhost:55672`, which assumes that RabbitMQ is running on the same computer on which you are installing the Pivotal Extensions for New Relic, you are using the default port (55672), and you connect using the default `guest` RabbitMQ user.  If your RabbitMQ management URL is different, update the property accordingly.

6. From the top-level directory, run the following commands: 

        $ bundle install
        $ ./pivotal_agent
7. After a brief period, the Pivotal Extensions will appear in your New Relic Dashboard under the Extensions tab on the left. 

