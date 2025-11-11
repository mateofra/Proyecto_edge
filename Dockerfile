
FROM ubuntu:latest
EXPOSE 5432
RUN useradd -rm -d /home/alumnobd -s /bin/bash -g root -G sudo -p pwalumnobd alumnobd
RUN apt update
RUN apt install -y postgresql-16
RUN apt install -y postgis
RUN echo "host all all all md5" >> /etc/postgresql/16/main/pg_hba.conf
RUN pg_conftool 16 main set listen_addresses '*'
RUN service postgresql start && su postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD 'pwalumnobd'\"" && su postgres -c "psql -c \"CREATE USER alumnobd WITH superuser createdb createrole login password 'pwalumnobd'\"" && su postgres -c "psql -c \"CREATE Database alumnobd WITH owner = alumnobd\""
CMD service postgresql start;su alumnobd
