FROM ubuntu:14.04
MAINTAINER VanNguyen <vannk1984@gmail.com>

RUN apt-get update && apt-get -y install php5 && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN /usr/sbin/a2dismod 'mpm_*' && /usr/sbin/a2enmod mpm_prefork

RUN /usr/sbin/a2enmod rewrite

ADD 000-phalcon.conf /etc/apache2/sites-available/
ADD 001-phalcon-ssl.conf /etc/apache2/sites-available/
RUN /usr/sbin/a2dissite '*' && /usr/sbin/a2ensite 000-phalcon 001-phalcon-ssl
RUN a2enmod expires
RUN a2enmod headers

WORKDIR /tmp
# Run build process on one line to avoid generating bloat via intermediate images
RUN /usr/bin/apt-get update && apt-get -y install git build-essential curl php5-xdebug php5-dev php5-curl php5-mysqlnd php5-cli php5-gd php5-mcrypt php5-intl libpcre3-dev gcc make && \
    /usr/bin/apt-get -y purge git php5-dev libpcre3-dev build-essential gcc make && apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -o mod-pagespeed.deb https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-beta_current_amd64.deb && dpkg -i mod-pagespeed.deb && apt-get -f install
RUN /usr/sbin/php5enmod pagespeed

WORKDIR /var/www/wordpress

RUN ln -sf /proc/self/fd/1 /var/log/apache2/error.log

EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
