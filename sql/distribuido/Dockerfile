FROM ubuntu:jammy
EXPOSE 5432
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt install -y curl && \
    curl https://install.citusdata.com/community/deb.sh | bash && \
    apt update && \
    apt install -y postgresql-16 && \
    apt install -y postgresql-16-citus-12.1 && \
    apt install -y postgresql-16-postgis-3 

COPY pg_hba.conf /etc/postgresql/16/main/

RUN pg_conftool 16 main set shared_preload_libraries citus
RUN pg_conftool 16 main set listen_addresses '*'
RUN pg_conftool 16 main set wal_level 'logical'
CMD service postgresql start;su postgres -c "psql -c 'CREATE EXTENSION citus'";su postgres
