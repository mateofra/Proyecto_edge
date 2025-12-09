#!/bin/bash
set -e

# --- Configuración ---
CSV_DIR="/home/alumnobd/host-temp"
DBNAME="luchasDB"
MONGOS="m1-mongos"
MONGOS_PORT=27019
MONGOS_URI="mongodb://$MONGOS:$MONGOS_PORT/$DBNAME"

echo "==========================================="
echo "Importando CSVs temporales (_temp.csv)"
echo "==========================================="

# Importar CSVs temporales
for csvfile in "$CSV_DIR"/*_temp.csv; do
    [ -e "$csvfile" ] || continue
    filename=$(basename "$csvfile")
    collection="${filename%.*}"

    echo "Importando $collection desde $filename..."
    mongoimport --uri "$MONGOS_URI" \
        --collection "$collection" \
        --type csv \
        --headerline \
        --file "$csvfile" \
        || { echo "Error importando $filename"; exit 1; }
done

echo " -> CSVs temporales importados"

echo "==========================================="
echo "Creando colección final 'luchadores' con agregación"
echo "==========================================="

# Agregación y shard de luchadores usando $merge
docker exec -i $MONGOS mongosh "$MONGOS_URI" <<'EOF'
db = db.getSiblingDB("luchasDB");

// Agregación con $merge (evita problema de $out y sharding)
db.luchadores_temp.aggregate([
    {
        $lookup: {
            from: "estilos_luchadores_temp",
            localField: "id",
            foreignField: "id_luchador",
            as: "estilos"
        }
    },
    {
        $lookup: {
            from: "estilos_temp",
            localField: "estilos.id_estilo",
            foreignField: "id",
            as: "detalles_estilos"
        }
    },
    {
        $merge: { into: "luchadores" }
    }
]);

// Crear índice hashed y shardear la colección
db.luchadores.createIndex({ id: "hashed" });
sh.shardCollection("luchasDB.luchadores", { id: "hashed" });
EOF

echo " -> Colección 'luchadores' creada y shardeda correctamente"

echo "==========================================="
echo "Importando y shardando colecciones restantes: peleas y eventos"
echo "==========================================="

for csvfile in "$CSV_DIR"/peleas.csv "$CSV_DIR"/eventos.csv; do
    [ -e "$csvfile" ] || continue
    filename=$(basename "$csvfile")
    collection="${filename%.*}"

    echo "Procesando $collection desde $filename..."

    # Crear índice hashed y shardear antes de importar
    docker exec -i $MONGOS mongosh "$MONGOS_URI" --eval "
        db = db.getSiblingDB('$DBNAME');
        if (db.getCollection('$collection').exists()) { db.$collection.drop(); }
        db.$collection.createIndex({ _id: 'hashed' });
        sh.shardCollection('$DBNAME.$collection', { _id: 'hashed' });
    "

    # Importación CSV
    mongoimport --uri "$MONGOS_URI" \
        --collection "$collection" \
        --type csv \
        --headerline \
        --file "$csvfile" \
        || { echo "Error importando $filename"; exit 1; }
done

echo " -> Importación y sharding completados para todas las colecciones"
