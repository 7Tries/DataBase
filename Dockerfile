FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends postgresql postgresql-contrib \
    && rm -rf /var/lib/apt/lists/*

COPY docker.entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 5433

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
