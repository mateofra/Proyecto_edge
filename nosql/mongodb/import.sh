#!/bin/bash
set -e

# --- Configuración ---
CSV_DIR="/home/alumnobd/host-temp"
DBNAME="luchasDB"
MONGOS="m1-mongos"
MONGOS_PORT=27019

echo "==========================================="
echo "Importando CSVs para hacer la agregacion"
echo "==========================================="

docker exec "$MONGOS" bash -c "
set -e
for csvfile in $CSV_DIR/data/*.csv; do
    [ -e \"\$csvfile\" ] || continue
    filename=\$(basename \"\$csvfile\")
    collection=\"\${filename%.*}\"
    echo \"Importando \$collection desde \$filename...\"
    mongoimport --uri mongodb://localhost:$MONGOS_PORT/$DBNAME \
                --collection \"\$collection\" \
                --type csv \
                --headerline \
                --file \"\$csvfile\"
done
"

echo "==========================================="
echo "Realizando la agregacion"
echo "==========================================="

docker exec "$MONGOS" bash -c "
mongosh mongodb://localhost:$MONGOS_PORT/$DBNAME $CSV_DIR/scripts/agregacion.js
"

echo "AGREGACION REALIZADA CON EXITO"

echo "==========================================="
echo "Aplicando índices y sharding"
echo "==========================================="

docker exec "$MONGOS" bash -c "
mongosh mongodb://localhost:$MONGOS_PORT/$DBNAME $CSV_DIR/scripts/indexado_sharding.js
"

echo "INDEXADO + SHARDING COMPLETADO"
