FROM redis
MAINTAINER Dezső BICZÓ <mxr576@gmail.com>

# Update the base image.
RUN apt-get update && \
    apt-get install pwgen -y && \
    rm -rf /var/lib/apt/lists/*

# Copy default configuration files, based on
# Pantheon's recommended settings.
COPY redis.conf /usr/local/etc/redis/redis.conf

# Add start script.
ADD run.sh /run.sh
RUN chmod +x /run.sh

ENV REDIS_PASS **Random**

VOLUME ["/var/log/redis"]

EXPOSE 6379

CMD ["/run.sh"]
