# Pivotal Extensions for New Relic

This README describes how to install and configure the Pivotal Extensions for New Relic.  For convenience, you can install all extensions at once using the procedure below.  You can also install each extension separately from its corresponding sub-directory under the `extensions` directory.

This procedure installs the following extensions:

* **RabbitMQ**: Allows you to gather metrics for a RabbitMQ server.

## Before You Begin

* Install Ruby, version X.X or later.
* Install the `bundle` Ruby gem.
* If you want to install the RabbitMQ extenion, it is assumed that you have:
    * [Installed RabbitMQ, version X.X or later.](http://www.rabbitmq.com/download.html)
    * Enabled the RabbitMQ management plugins by executing the `rabbitmq-plugins enable rabbitmq_management` command.  See [Management Plugins](http://www.rabbitmq.com/management.html).

## Installation Procedure

Execute the following procedure on either the same computer on which the RabbitMQ server is running, or on a computer that has network access to the RabbitMQ computer.

1. Create a directory that will contain the Pivotal Extensions for New Relic.
1. Download the ZIP of the Pivotal Extensions for New Relic from [https://github.com/gopivotal/newrelic_pivotal_agent](https://github.com/gopivotal/newrelic_pivotal_agent) and extract the contents into the directory you just created.
3. In the `config` directory, make a copy of the `template_newrelic_plugin.yml` file and name it `newrelic_plugin.yml`
4. Edit `config/newrelic_plugin.yml` and make the following changes:
    * Replace the string "YOUR_LICENSE_KEY_HERE" with your [New Relic license key](https://newrelic.com/docs/subscriptions/license-key).   
    * If you are installing the RabbitMQ extension, ensure that the value of the `rabbitmq:management_api_url` property correctly points to the RabbitMQ management URL.  The default value is `http://guest:guest@localhost:55672`, which assumes that you are running RabbitMQ on the same computer on which you install the Pivotal Extensions for New Relic.  It also assumes that you are using the `guest` user which is created at the time you installed RabbitMQ.  If your RabbitMQ installation is different, update the URL appropriately.
5. From the top-level directory, run `bundle install`.
6. Run `./pivotal_agent`.  
7. After a brief period, the Pivotal Extensions will appear in your New Relic Dashboard under the Extensions tab on the left. 

