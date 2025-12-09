#!/bin/bash
set -e

# --- Configuración ---
NETWORK="network-edge-gria"
DATA_DIR="/mnt/c/Users/usuario/root/usc/bd/Proyecto_edge/nosql/mongodb/data"
CSV_DIR="/home/alumnobd/host-temp"

MACHINES=("m1" "m2" "m3")
SHARDS=("shard1" "shard2" "shard3")
CONFIGSVR="configsvr"
MONGOS="mongos"
MONGOS_PORT=27019
DBNAME="luchasDB"
SHARD_KEY="id"

# Crear red si no existe
if ! docker network ls --format '{{.Name}}' | grep -q "^$NETWORK$"; then
    docker network create $NETWORK
fi

# Función para crear contenedores sin mongod autoiniciado
recreate_container() {
    local name=$1
    docker rm -f $name 2>/dev/null || true
    docker run --name $name -d \
        --network $NETWORK \
        --entrypoint bash mongo:latest -c "sleep infinity"
}

# ------------------------
# Crear contenedores por máquina
# ------------------------
for m in "${MACHINES[@]}"; do
    recreate_container "$m-$CONFIGSVR"
    for s in "${SHARDS[@]}"; do
        recreate_container "$m-$s"
    done
    recreate_container "$m-$MONGOS"
done

# Función para esperar que mongod/mongos responda
wait_for_mongo() {
    local container=$1
    local port=$2
    echo "Esperando a que $container arranque en el puerto $port..."
    until docker exec $container mongosh --port $port --eval "db.adminCommand('ping')" &>/dev/null; do
        sleep 2
    done
}

# ------------------------
# Iniciar mongod en config server y shards
# ------------------------
for m in "${MACHINES[@]}"; do
    docker exec -d "$m-$CONFIGSVR" mongod --configsvr --replSet rsConfig --port 27017 --bind_ip_all --dbpath /data/configdb
    for s in "${SHARDS[@]}"; do
        rsName="rs${s:5}"  # shard1 → rs1
        docker exec -d "$m-$s" mongod --shardsvr --replSet "$rsName" --port 27017 --bind_ip_all --dbpath /data/db
    done
done

# Esperar a que todos los mongod estén listos
for m in "${MACHINES[@]}"; do
    wait_for_mongo "$m-$CONFIGSVR" 27017
    for s in "${SHARDS[@]}"; do
        wait_for_mongo "$m-$s" 27017
    done
done

# ------------------------
# Inicializar replica sets de shards
# ------------------------
for i in {1..3}; do
    echo "Inicializando replica set rs$i..."
    docker exec "m1-shard$i" mongosh --eval "
rs.initiate({
  _id: 'rs$i',
  members: [
    {_id:0, host:'m1-shard$i:27017'},
    {_id:1, host:'m2-shard$i:27017'},
    {_id:2, host:'m3-shard$i:27017'}
  ]
})
"
done

# ------------------------
# Inicializar replica set de config server
# ------------------------
docker exec m1-$CONFIGSVR mongosh --eval "
rs.initiate({
  _id: 'rsConfig',
  configsvr: true,
  members: [
    {_id:0, host:'m1-configsvr:27017'},
    {_id:1, host:'m2-configsvr:27017'},
    {_id:2, host:'m3-configsvr:27017'}
  ]
})
"

# ------------------------
# Iniciar mongos en cada máquina
# ------------------------
for m in "${MACHINES[@]}"; do
    docker exec -d "$m-$MONGOS" mongos \
        --configdb rsConfig/m1-configsvr:27017,m2-configsvr:27017,m3-configsvr:27017 \
        --bind_ip_all --port $MONGOS_PORT
    wait_for_mongo "$m-$MONGOS" $MONGOS_PORT
done

# ------------------------
# Agregar shards usando el primer mongos
# ------------------------
docker exec m1-$MONGOS mongosh --port $MONGOS_PORT --eval "
sh.addShard('rs1/m1-shard1:27017,m2-shard1:27017,m3-shard1:27017');
sh.addShard('rs2/m1-shard2:27017,m2-shard2:27017,m3-shard2:27017');
sh.addShard('rs3/m1-shard3:27017,m2-shard3:27017,m3-shard3:27017');
sh.status();
"

echo "Cluster listo: 3 máquinas simuladas con 3 shards cada una y 3 mongos activos."
