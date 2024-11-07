FROM ghcr.io/railwayapp-templates/postgres-ssl:15

LABEL maintainer="Clever Cactus - https://clevercactus.nl" \
      org.opencontainers.image.description="PostGIS spatial database extension with PostgreSQL 15" \
      org.opencontainers.image.source="https://github.com/joggienl/railway-postgresql"

ENV POSTGIS_MAJOR 3

# Install PostGIS without version pinning
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
       postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies for pg_parquet
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       libssl-dev \
       pkg-config \
       curl \
       ca-certificates \
       git \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install cargo-pgrx
RUN cargo install cargo-pgrx

# Initialize pgrx for PostgreSQL 15
RUN cargo pgrx init --pg15 $(which pg_config)

# Clone pg_parquet repository
RUN git clone https://github.com/CrunchyData/pg_parquet.git /pg_parquet

# Build and install pg_parquet
WORKDIR /pg_parquet
RUN cargo pgrx install --release

# Clean up
RUN apt-get remove -y build-essential libssl-dev pkg-config curl git \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /pg_parquet

# Add init scripts
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./initdb-pg_parquet.sql /docker-entrypoint-initdb.d/11_pg_parquet.sql
COPY ./update-postgis.sh /usr/local/bin

# Set permissions
RUN chmod +x /docker-entrypoint-initdb.d/10_postgis.sh
RUN chmod +x /usr/local/bin/update-postgis.sh

# Set shared_preload_libraries via environment variable
ENV POSTGRES_SHARED_PRELOAD_LIBRARIES pg_parquet

CMD ["postgres", "--port=5432"]
