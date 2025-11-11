!#bin/bash

docker buildx build --platform=linux/amd64 -t postgresql:edge-gria .
docker run --name=edge-gria-pgsql -dti -p 25432:5432 --platform=linux/amd64 -v c:/temp:/home/alumnobd/host-temp postgresql:edge-gria
docker start edge-gria-pgsql

echo Ejecutando contenedor ...

docker start edge-gria-pgsql
