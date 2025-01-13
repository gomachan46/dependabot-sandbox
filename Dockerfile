# syntax = docker/dockerfile:1
# check=error=true

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.3.5
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl default-mysql-client libjemalloc2 libvips && \
    apt-get install --no-install-recommends -y locales vim less procps dnsutils netcat-openbsd && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives && \
    locale-gen ja_JP.UTF-8 && \
    localedef -f UTF-8 -i ja_JP ja_JP.UTF-8

# # Set production environment
# ENV RAILS_ENV="production" \
#     BUNDLE_DEPLOYMENT="1" \
#     BUNDLE_PATH="/usr/local/bundle" \
#     BUNDLE_WITHOUT="development"

# Set environment for project
ENV TZ=Asia/Tokyo \
    LANGUAGE=ja_JP.UTF-8 \
    LC_ALL=ja_JP.UTF-8 \
    LANG=ja_JP.UTF-8 \
    RAILS_ROOT=/app \
    NODE_ENV=development

# Rails app lives here
WORKDIR ${RAILS_ROOT}

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential default-libmysqlclient-dev git pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install JavaScript dependencies
ARG NODE_VERSION=22.9.0
ARG YARN_VERSION=1.22.22
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf /tmp/node-build-master

# Copy application code
COPY ./ .





# Final stage for app image
FROM build AS development

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["echo", "Hello, World!"]
