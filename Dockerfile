FROM ubuntu:trusty
MAINTAINER Dezső BICZÓ <mxr576@gmail.com>

ENV REDIS_PASS **Random**
ENV REDIS_DIR /data

# Update the base image.
RUN apt-get update && \
    apt-get dist-upgrade -y

# Install additional packages.
RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends pwgen curl gcc libc6-dev make && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Redis.
RUN mkdir -p /usr/src/redis && \
	curl -sSL "http://download.redis.io/redis-stable.tar.gz" -o redis.tar.gz && \
	tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 && \
	rm redis.tar.gz && \
	make -C /usr/src/redis && \
	make -C /usr/src/redis install && \
	rm -r /usr/src/redis && \
	apt-get purge -y --auto-remove curl gcc libc6-dev make

# Enable vm.overcommit_memory
RUN echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf

VOLUME ["/data"]
WORKDIR /data

EXPOSE 6379

# Add start script.
ADD run.sh /run.sh

CMD ["/run.sh"]
