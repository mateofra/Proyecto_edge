#!/bin/bash
set -e

# Ruta del volumen de importación
RUTA_AL_VOLUMEN="/mnt/c/Users/usuario/root/usc/bd/Proyecto_edge/nosql/neo4j/import_data"

# Nombre del contenedor
CONTAINER="edge-gria-neo4j"

# Borrar contenedor si existe
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
    echo "Eliminando contenedor existente..."
    docker rm -f $CONTAINER
fi

# Ejecutar contenedor Neo4j
docker run --name $CONTAINER \
    -p 7474:7474 -p 7687:7687 \
    -d --platform=linux/amd64 \
    -e NEO4J_AUTH=neo4j/pwalumnobd \
    -v $RUTA_AL_VOLUMEN:/home/alumnobd/host-temp \
    --network network-edge-gria \
    neo4j:5.26.0

# Esperar unos segundos a que el contenedor arranque
echo "Esperando a que Neo4j arranque..."
sleep 5

# Copiar plugins y cambiar permisos
docker exec -u root $CONTAINER bash -c "
cd /
cp /home/alumnobd/host-temp/config_data/*.jar /var/lib/neo4j/plugins/ || true
chown neo4j:neo4j /var/lib/neo4j/plugins/*.jar || true
"

# Reiniciar contenedor para cargar plugins
docker restart $CONTAINER
