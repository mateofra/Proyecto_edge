#!/bin/bash

# Asegúrate de que el script principal se detenga si cualquier comando falla
set -e

# --- PASO 1: Copiar archivos ---
echo "Copiando archivos de 'data' y 'sql' a /tmp..."
cp -r data /tmp
cp -r sql /tmp
echo "Archivos copiados."

# --- PASO 2: Ejecutar el proceso de la base de datos ---
echo "Iniciando proceso de importación en la base de datos..."

# Usamos un "Here Document" para pasar los comandos a psql de forma segura
docker exec -u alumnobd edge-gria-pgsql sh -c "
    echo '  1. Creando estructura de la base de datos...'
    psql -d alumnobd -f /home/alumnobd/host-temp/sql/relacional/estructura.sql

    # Usamos Here Documents para los comandos de importación, lo que evita problemas con las comillas y las barras invertidas.
    echo '  2. Importando luchadores...'
    psql -d alumnobd <<EOF
        SET datestyle TO 'DMY';
        \\copy luchadores FROM '/home/alumnobd/host-temp/data/luchadores/pro_mma_fighters_cocinados.csv' WITH (FORMAT csv, HEADER true);
EOF

    echo '  3. Importando estilos...'
    psql -d alumnobd <<EOF
        \\copy estilos FROM '/home/alumnobd/host-temp/data/luchadores/estilos.csv' WITH (FORMAT csv, HEADER true);
EOF

    echo '  4. Importando estilos_luchadores...'
    psql -d alumnobd <<EOF
        \\copy estilos_luchadores FROM '/home/alumnobd/host-temp/data/luchadores/estilos-luchadores.csv' WITH (FORMAT csv, HEADER true);
EOF

    echo '  5. Importando eventos...'
    psql -d alumnobd <<EOF
        SET datestyle TO 'DMY';
        \\copy evento FROM '/home/alumnobd/host-temp/data/luchas/events_con_coordenadas.csv' WITH (FORMAT csv, HEADER true);
EOF

    echo '  6. Importando peleas...'
    psql -d alumnobd <<EOF
        \\copy pelea(event_id, match_nr, fighter1_url, fighter2_url, results, win_method, win_details, referee, round, \"time\") FROM '/home/alumnobd/host-temp/data/luchas/fights.csv' WITH (FORMAT csv, HEADER true);
EOF
"

echo "--- ¡Proceso de importación completado con éxito! ---"
