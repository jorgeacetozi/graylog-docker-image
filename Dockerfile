# Set the base image to Java8
FROM openjdk:8-jre

# File Author / Maintainer
MAINTAINER Jorge Acetozi

# Define default environment variables
ENV GRAYLOG_VERSION 2.2.3
ENV GRAYLOG_HOME /opt/graylog

# Install image dependencies
#RUN apt-get update && apt-get install wget 

RUN cd /tmp \
  && wget -q https://packages.graylog2.org/releases/graylog/graylog-$GRAYLOG_VERSION.tgz \
  && tar xvzf graylog-$GRAYLOG_VERSION.tgz \
  && mv graylog-$GRAYLOG_VERSION /opt/graylog \
  && rm graylog-$GRAYLOG_VERSION.tgz

WORKDIR $GRAYLOG_HOME

# Add contentpacks
COPY contentpacks/* data/contentpacks

# Add initialization script
COPY bin/entrypoint.sh bin/entrypoint.sh

# Create graylog group/user and change directories ownership
RUN groupadd -g 1000 graylog \
  && useradd -d "$GRAYLOG_HOME" -u 1000 -g 1000 -s /sbin/nologin graylog \
  && mkdir -p /etc/graylog/server \
  && chown -R graylog:graylog $GRAYLOG_HOME /etc/graylog

# Run container using graylog user
USER graylog

# Define mountable directories
VOLUME $GRAYLOG_HOME/data

# Graylog Web Interface / Rest API
EXPOSE 9000

# GELF TCP/UDP
EXPOSE 12201
EXPOSE 12201/udp

# syslog
EXPOSE 514
EXPOSE 514/udp

# Define main command
ENTRYPOINT ["bin/entrypoint.sh"]
