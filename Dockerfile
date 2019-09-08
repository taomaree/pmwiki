FROM ubuntu:18.04

ENV TZ=Asia/Shanghai LANG=C.UTF-8 DEBIAN_FRONTEND=noninteractive

RUN apt-get update ; apt-get install -y --no-install-recommends ca-certificates curl wget apt-transport-https tzdata \
    dumb-init iproute2 iputils-ping iputils-arping telnet less vim-tiny unzip gosu fonts-dejavu-core tcpdump \
    net-tools socat netcat traceroute jq mtr-tiny dnsutils psmisc \
    cron logrotate runit rsyslog-kafka gosu bsdiff libtcnative-1 libjemalloc-dev nginx php-fpm ; \
    mkdir -p /run/php /var/www/html/wiki.d ;\
    sed -i 's@ .*.ubuntu.com@ https://mirrors.ustc.edu.cn@g' /etc/apt/sources.list ;\
    sed -i '/session    required     pam_loginuid.so/c\#session    required   pam_loginuid.so' /etc/pam.d/cron ;\
    sed -i 's/^module(load="imklog"/#module(load="imklog"/g' /etc/rsyslog.conf ;\
    mkdir -p /etc/service/cron /etc/service/syslog /etc/service/php /etc/service/nginx ;\
    bash -c 'echo -e "#!/bin/bash\nexec /usr/sbin/rsyslogd -n" > /etc/service/syslog/run' ;\
    bash -c 'echo -e "#!/bin/bash\nexec /usr/sbin/cron -f" > /etc/service/cron/run' ;\
    bash -c 'echo -e "#!/bin/bash\nexec /usr/sbin/php-fpm7.2 --nodaemonize --fpm-config /etc/php/7.2/fpm/php-fpm.conf" > /etc/service/php/run' ; \
    bash -c 'echo -e "#!/bin/bash\nexec chown www-data:www-data -R /var/www/html/ \nexec /usr/sbin/nginx -g \"daemon off;\"" > /etc/service/nginx/run' ; \
    chmod 755 /etc/service/cron/run /etc/service/syslog/run /etc/service/php/run /etc/service/nginx/run ;\
    wget -P /tmp http://www.pmwiki.org/pub/pmwiki/pmwiki-latest.tgz http://pmwiki.org/pub/pmwiki/i18n/i18n-all.zip ;\
    tar zxfv /tmp/pmwiki-latest.tgz -C /var/www/html/ --strip-components 1 ;\
    echo "<?php include_once('pmwiki.php');" > /var/www/html/index.php ;\
    chown www-data:www-data -R /var/www/html/ ;\
    apt-get clean  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD default.conf /etc/nginx/sites-enabled/default

EXPOSE 80/tcp 443/tcp

VOLUME ["/var/www/html/wiki.d/","/var/www/html/local/","/var/www/html/cookbook/", "/var/www/html/pub"]

CMD ["runsvdir", "/etc/service"]
