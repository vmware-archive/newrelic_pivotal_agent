## New Relic RabbitMQ Extension

### Instructions for running the RabbitMQ extension agent

1. Go to the [tags section](https://github.com/newrelic-platform/pivotal_rabbitmq_extension/tags) and find the latest tar.gz
2. Download and extract the source
3. Run `bundle install` to install required gems
4. Copy `config/template_newrelic_plugin.yml` to `config/newrelic_plugin.yml`
5. Edit `config/newrelic_plugin.yml` and replace "YOUR_LICENSE_KEY_HERE" with your New Relic license key
6. Edit the `config/newrelic_plugin.yml` file and add the URL for the RabbitMQ broker you wish to monitor
7. Execute `./newrelic_rabbitmq_agent`
8. Go back to the Extensions list and after a brief period you will see the extension listed
