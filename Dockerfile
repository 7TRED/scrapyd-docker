FROM debian:bullseye-slim

ARG TARGETPLATFORM
ARG SCRAPY_VERSION=2.8.0
ARG SCRAPYD_VERSION=1.4.1
ARG SCRAPYD_CLIENT_VERSION=1.2.3

SHELL [ "/bin/bash","-c" ]

RUN set -xe \
        && apt-get update \
        && apt-get install -y \
                        autoconf \
                        build-essential \
                        libssl-dev \
                        libffi-dev \
                        python3-dev \
                        python3-pip \
                        curl \
                        cron \
                        systemctl \
        && systemctl enable cron \
        && pip install --no-cache-dir ipython \
                        scrapy==$SCRAPY_VERSION \
                        scrapyd==$SCRAPYD_VERSION \
                        scrapyd-client==$SCRAPYD_CLIENT_VERSION \
        && apt-get purge -y --auto-remove autoconf \
                                          build-essential \
                                          libssl-dev \
                                          libffi-dev \
                                          python3-dev \
                                          curl \
        && rm -rf /var/lib/apt/lists/*

ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

EXPOSE 6800

ADD ./scrapyd.conf /etc/scrapyd/scrapyd.conf

ADD ./scrapyd.service /lib/systemd/system/scrapyd.service

RUN systemctl enable scrapyd.service

VOLUME /etc/scrapyd /var/lib/scrapyd/

ADD ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod 777 /usr/local/bin/docker-entrypoint.sh \
        && ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

CMD tail -f /var/log/journal/scrapyd.service.log
