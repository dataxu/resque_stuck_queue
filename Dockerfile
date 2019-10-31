FROM ruby:2.5.1
ARG BUNDLER_VERSION=1.16.4

RUN touch /etc/apt/apt.conf.d/99fixbadproxy \
    && echo "Acquire::http::Pipeline-Depth 0;" >> /etc/apt/apt.conf.d/99fixbadproxy \
    && echo "Acquire::http::No-Cache true;" >> /etc/apt/apt.conf.d/99fixbadproxy \
    && echo "Acquire::BrokenProxy true;" >> /etc/apt/apt.conf.d/99fixbadproxy \
    && apt-get update -o Acquire::CompressionTypes::Order::=gz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get update -y && \
    apt-get install -qy curl jq python3 python3-dev python3-pip python3-yaml && \
    pip3 install awscli && \
    apt-get clean

RUN useradd -c 'builder of ruby projs' -m -d /home/builder -s /bin/bash builder

ENV GEM_HOME /usr/local/bundle
RUN chmod -R 777 "$GEM_HOME"

USER builder
ENV HOME /home/builder
RUN mkdir -p $HOME/app
ADD --chown=builder:builder . $HOME/app/
WORKDIR $HOME/app/

RUN gem install bundler -v $BUNDLER_VERSION && bundle install
