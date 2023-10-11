FROM ghcr.io/railwayapp-templates/postgres-ssl:15

LABEL maintainer="Clever Cactus - https://clevercactus.nl"

RUN apt-get update \
      && apt-get install -y --no-install-recommends postgis \
           # ca-certificates: for accessing remote raster files;
           #   fix: https://github.com/postgis/docker-postgis/issues/307
           ca-certificates \
      && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./update-postgis.sh /usr/local/bin
