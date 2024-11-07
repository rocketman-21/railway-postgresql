ALTER SYSTEM SET shared_preload_libraries = 'pg_parquet';
SELECT pg_reload_conf();

CREATE EXTENSION pg_parquet;