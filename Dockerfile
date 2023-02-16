FROM debian:bullseye-20190708-slim

ARG TARGETPLATFORM
ARG SCRAPY_VERSION=2.8.0
ARG SCRAPYD_VERSION=1.4.1
ARG SCRAPYD_CLIENT_VERSION=v1.2.3

ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

EXPOSE 6800

RUN set -xe \
        && echo ${TARGETPLATFORM} \
        && apt-get update \
        && apt-get install -y autoconf \
                              build-essential \
                              curl \
                              libffi-dev \
                              libssl-dev \
                              libtool \
                              libxml2 \
                              libxml2-dev \
                              libxslt1.1 \
                              libxslt1-dev \
                              python3 \
                              python3-cryptography \
                              python3-dev \
                              python3-distutils \
                              python3-pil \
                              cron \
                              systemctl \
        && systemctl enable cron \
        && if [[ ${TARGETPLATFORM} = "linux/arm/v7" ]]; then apt install -y cargo; fi \
        && curl -sSL https://bootstrap.pypa.io/get-pip.py | python3 \
        && pip install --no-cache-dir ipython \
                https://github.com/scrapy/scrapy/archive/refs/tags/$SCRAPY_VERSION.zip \
                https://github.com/scrapy/scrapyd/archive/refs/tags/$SCRAPYD_VERSION.zip \
                https://github.com/scrapy/scrapyd-client/archive/refs/tags/$SCRAPYD_CLIENT_VERSION.zip \
        && if [[ ${TARGETPLATFORM} = "linux/arm/v7" ]]; then apt purge -y --auto-remove cargo; fi \
        && apt-get purge -y --auto-remove autoconf \
                                          build-essential \
                                          curl \
                                          libffi-dev \
                                          libssl-dev \
                                          libtool \
                                          libxml2-dev \
                                          libxslt1-dev \
                                          python3-dev \
        && rm -rf /var/lib/apt/lists/*

ADD ./scrapyd.conf /etc/scrapyd/scrapyd.conf

ADD ./scrapyd.service /lib/systemd/system/scrapyd.service

RUN systemctl enable scrapyd.service

VOLUME /etc/scrapyd /var/lib/scrapyd/

COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod 777 /usr/local/bin/docker-entrypoint.sh \
        && ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh

WORKDIR /usr/project/

ENTRYPOINT ["docker-entrypoint.sh"]

CMD tail -f /var/log/journal/scrapyd.service.log
