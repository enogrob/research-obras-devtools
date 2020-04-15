FROM ruby:2.6.5
MAINTAINER Roberto Nogueira <roberto.nogueira@tecnogroup.com.br>

# Install platform requirements for rails
RUN apt-get update -yqq
RUN apt-get install -yqq --no-install-recommends nodejs

# Install gem files for Development flow
COPY Gemfile* /usr/src/app/
WORKDIR /usr/src/app

ENV RUBYOPT=-W0
ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle
ENV PATH="${BUNDLE_BIN}:${PATH}"

RUN ! test -d /gems/bundler-2.1.4 && gem install bundler:2.1.4
RUN bundle install

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["./docker-entrypoint.sh"]
