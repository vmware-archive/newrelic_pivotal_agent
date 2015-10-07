# Dockerfile for newrelic pivotal agent
#
# To build:
#   docker build -t $(whoami)/newrelic_pivotal_agent .
#
# To run, share the directory the config file is loacated
# to `/usr/src/app/config` in the container:
#   docker run -it -v $(pwd)/config/:/usr/src/app/config/ $(whoami)/newrelic_pivotal_agent

FROM ruby:2.2.3

ENV APP_DIR /usr/src/app
WORKDIR $APP_DIR
RUN bundle config --global frozen 1 \
    && mkdir -p $APP_DIR

COPY . $APP_DIR
RUN bundle install

CMD ["./pivotal_agent"]
