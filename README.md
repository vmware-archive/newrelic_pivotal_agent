## Pivotal New Relic Monitoring Agent 

This is a combined agent that will run all extensions for Pivotal products.

Individual extensions can be ran separately by pulling them out of the extensions directory and configuring them individually.

Pre-requisites
A recent version of ruby and the bundle gem installed

1. Download the latest tagged version from `https://github.com/pivotal/some_yet_to_be_determined_url`
2. Extract to the location you want to run the agent
3. Copy `config/template_newrelic_plugin.yml` to `config/newrelic_plugin.yml`
4. Edit `config/newrelic_plugin.yml` and replace "YOUR_LICENSE_KEY_HERE" with your New Relic license key
5. run bundle install
6. run `./newrelic_example_agent`
