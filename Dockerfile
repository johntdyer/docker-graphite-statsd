FROM phusion/baseimage:0.9.17
MAINTAINER Nathan Hopkins <natehop@gmail.com>

RUN curl -k -sS http://nginx.org/keys/nginx_signing.key | apt-key add -v -
RUN echo deb http://nginx.org/packages/mainline/ubuntu/ $(lsb_release -cs) nginx > /etc/apt/sources.list.d/nginx.list

RUN apt-get -y update\
 && apt-get -y upgrade

# dependencies
RUN apt-get -y --force-yes install vim\
 nginx\
 python-dev\
 python-flup\
 python-pip\
 expect\
 git\
 memcached\
 sqlite3\
 libcairo2\
 libcairo2-dev\
 python-cairo\
 pkg-config\
 nodejs \
 python-ldap

# python dependencies
RUN pip install django==1.4\
 python-memcached==1.57\
 django-tagging==0.3.1\
 twisted==11.1.0\
 txAMQP==0.6.2\
 pytz

# install graphite
RUN git clone -b 0.9.15 --depth 1 https://github.com/graphite-project/graphite-web.git /usr/local/src/graphite-web
WORKDIR /usr/local/src/graphite-web
RUN python ./setup.py install
ADD scripts/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
ADD conf/graphite/ /opt/graphite/conf/

# install whisper
RUN git clone -b 0.9.15 --depth 1 https://github.com/graphite-project/whisper.git /usr/local/src/whisper
WORKDIR /usr/local/src/whisper
RUN python ./setup.py install

# install carbon
RUN git clone -b 0.9.15 --depth 1 https://github.com/graphite-project/carbon.git /usr/local/src/carbon
WORKDIR /usr/local/src/carbon
RUN python ./setup.py install

# install statsd
RUN git clone -b v0.7.2 --depth 1 https://github.com/etsy/statsd.git /opt/statsd
ADD conf/statsd/config.js /opt/statsd/config.js

# config nginx
RUN rm /etc/nginx/conf.d/default.conf
ADD conf/nginx/nginx.conf /etc/nginx/nginx.conf
ADD conf/nginx/graphite.conf /etc/nginx/conf.d/graphite.conf

# init django admin
ENV LANG=en_US.UTF-8
ADD scripts/django_admin_init.exp /usr/local/bin/django_admin_init.exp
RUN /usr/local/bin/django_admin_init.exp

# logging support
RUN mkdir -p /var/log/carbon /var/log/graphite /var/log/nginx
ADD conf/logrotate /etc/logrotate.d/graphite
RUN chmod 644 /etc/logrotate.d/graphite

# daemons
ADD daemons/carbon.sh /etc/service/carbon/run
ADD daemons/carbon-aggregator.sh /etc/service/carbon-aggregator/run
ADD daemons/graphite.sh /etc/service/graphite/run
ADD daemons/statsd.sh /etc/service/statsd/run
ADD daemons/nginx.sh /etc/service/nginx/run

WORKDIR /

# cleanup
RUN apt-get clean\
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# defaults
EXPOSE 80:80 2003:2003 2004:2004 2023:2023 2024:2024 8125:8125/udp 8126:8126
ENV HOME /root
CMD ["/sbin/my_init"]
