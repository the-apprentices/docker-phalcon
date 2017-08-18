FROM eboraas/apache-php
MAINTAINER Ed Boraas <ed@boraas.ca>

RUN /usr/sbin/a2enmod rewrite
RUN /usr/sbin/a2enmod expires
RUN /usr/sbin/a2enmod headers

ADD 000-phalcon.conf /etc/apache2/sites-available/
ADD 001-phalcon-ssl.conf /etc/apache2/sites-available/
RUN /usr/sbin/a2dissite '*' && /usr/sbin/a2ensite 000-phalcon 001-phalcon-ssl

WORKDIR /tmp
# Run build process on one line to avoid generating bloat via intermediate images
RUN /usr/bin/apt-get update && /usr/bin/apt-get install -y python-software-properties software-properties-common && \
	LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && \
	/usr/bin/apt-get update && apt-get -y install python-software-properties git build-essential curl php-xdebug php7.0-dev php7.0-curl php7.0 php7.0-cli php7.0-common libapache2-mod-php7.0 php7.0-fpm php7.0-mysql php7.0-mysqlnd php7.0-gd imagemagick php-imagick php7.0-mcrypt php7.0-intl libpcre3-dev gcc make && \
    /usr/bin/git clone --branch v3.1.2 --depth=1 git://github.com/phalcon/cphalcon.git && \
    cd cphalcon/build/ && \
    ./install && \
    cd /tmp && \
    /bin/rm -rf /tmp/cphalcon/ && \
    /usr/bin/apt-get -y purge git php7.0-dev libpcre3-dev build-essential gcc make && apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN /bin/echo 'extension=phalcon.so' >/etc/php5/mods-available/phalcon.ini
RUN /usr/sbin/php5enmod phalcon
WORKDIR /var/www/phalcon/web
RUN /bin/echo '<html><body><h1>It works!</h1></body></html>' > /var/www/phalcon/web/index.html

RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && ln -sf /proc/self/fd/1 /var/log/apache2/error.log


EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
