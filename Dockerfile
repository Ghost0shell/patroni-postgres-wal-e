FROM postgres:9.6
LABEL author="Seo Cahill <seo@seocahill.com>"

# Install patroni and WAL-e
ENV PATRONIVERSION=1.2.5
ENV WALE_VERSION=1.0.3

RUN export DEBIAN_FRONTEND=noninteractive \
    export BUILD_PACKAGES="python3-pip" \
    && apt-get update \
    && apt-get install -y \
            curl \
            jq \
            # Required for wal-e
            daemontools lzop pv \
            # Required for /usr/local/bin/patroni
            python3 python3-setuptools python3-pystache python3-prettytable python3-six \
            ${BUILD_PACKAGES} 
RUN mkdir -p /home/postgres \
    && chown postgres:postgres /home/postgres 
RUN apt-get install -y libpq-dev
RUN pip3 install pip --upgrade \
    && pip3 install --upgrade patroni==$PATRONIVERSION 
RUN pip3 install --upgrade wal-e[aws]==$WALE_VERSION

RUN apt-get purge -y ${BUILD_PACKAGES} \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /root/.cache

RUN mkdir /data/ && touch /pgpass \
    && chown postgres:postgres -R /data/ /pgpass /var/run/ /var/lib/ /var/log/

USER postgres

RUN pip3 install awscli --upgrade --user

ENV PATH="~/.local/bin:${PATH}"

EXPOSE 5432 8008

ENTRYPOINT patroni
