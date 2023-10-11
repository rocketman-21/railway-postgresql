FROM ghcr.io/railwayapp-templates/postgres-ssl:15

LABEL maintainer="Clever Cactus - https://clevercactus.nl" \
			org.opencontainers.image.description="PostGIS 3.4.0+dfsg-1.pgdg120+1 spatial database extension with PostgreSQL 15" \
			org.opencontainers.image.source="https://github.com/joggienl/railway-postgresql"

ENV POSTGIS_MAJOR 3
ENV POSTGIS_VERSION 3.4.0+dfsg-1.pgdg120+1

RUN apt-get update \
    && apt-cache showpkg postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
		&& apt-get install -y --no-install-recommends \
				# ca-certificates: for accessing remote raster files;
				#   fix: https://github.com/postgis/docker-postgis/issues/307
				ca-certificates \
				\
				postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
				postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts \
		&& rm -rf /var/lib/apt/lists/*

# Add init script and update script
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./update-postgis.sh /usr/local/bin

# Set permissions
RUN chmod +x /docker-entrypoint-initdb.d/10_postgis.sh
RUN chmod +x /usr/local/bin/update-postgis.sh

CMD ["postgres", "--port=5432"]
