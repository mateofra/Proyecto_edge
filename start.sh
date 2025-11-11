docker buildx build --platform=linux/amd64 -t postgresql:edge-gria .
docker run --name=edge-gria-pgsql -dti -p 25432:5432 --platform=linux/amd64 -v /tmp:/home/alumnobd/host-temp postgresql:edge-gria
docker start edge-gria-pgsql

echo Ejecutando contenedor ...

echo Para utilizar la linea de comandos del contenedor ejecuta:
echo docker start edge-gria-pgsql
