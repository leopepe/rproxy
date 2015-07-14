FROM ubuntu:trusty

# Installing dependencies
RUN apt-get update && \
  apt-get install -y \
    gcc \
    make \
    libpcre3-dev \
    zlib1g-dev \
    libldap2-dev \
    libssl-dev \
    wget \
    git \
    unzip && \
  apt-get clean

ENV NGINX_VERSION 1.9.3

VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html", "/var/log/nginx", "/var/cache/nginx"]

# Expose ports.
EXPOSE 80
EXPOSE 443

# Compiling everything
RUN mkdir /tmp/src
RUN wget -P /tmp/src http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
RUN cd /tmp/src ; tar -xf nginx-${NGINX_VERSION}.tar.gz
RUN cd /tmp/src ; git clone https://github.com/kvspb/nginx-auth-ldap.git

COPY ./src/configure.sh /tmp/src/
RUN cd /tmp/src ; /tmp/src/configure.sh
RUN cd /tmp/src/nginx-${NGINX_VERSION} ; make && make install

# Default and base config
COPY ./config/* /

# Define working directory.
WORKDIR /etc/nginx

# clean everything
RUN apt-get remove -y \
  gcc \
  make
RUN rm -rf /tmp/*

# Define default command.
CMD ["nginx"]
