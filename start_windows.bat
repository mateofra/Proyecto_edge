@echo off
setlocal enabledelayedexpansion

echo Copiando archivos de 'data' y 'sql' a C:\tmp...
xcopy data C:\tmp\data /E /I /Y
xcopy sql C:\tmp\sql /E /I /Y
echo Archivos copiados.

echo Iniciando proceso de importación en la base de datos...

:: ----- PASO 1: estructura -----
echo 1. Creando estructura de la base de datos...
docker exec -u alumnobd edge-gria-pgsql psql -d alumnobd -f /home/alumnobd/host-temp/sql/relacional/estructura.sql

:: ----- PASO 2: comandos en archivos temporales -----
set TMPDIR=%TEMP%\psql_tmp
mkdir "%TMPDIR%" 2>nul

echo SET datestyle TO 'DMY'; >> "%TMPDIR%\luchadores.sql"
echo \copy luchadores FROM '/home/alumnobd/host-temp/data/luchadores/pro_mma_fighters_cocinados.csv' WITH (FORMAT csv, HEADER true); >> "%TMPDIR%\luchadores.sql"

echo \copy estilos FROM '/home/alumnobd/host-temp/data/luchadores/estilos.csv' WITH (FORMAT csv, HEADER true); >> "%TMPDIR%\estilos.sql"

echo \copy estilos_luchadores FROM '/home/alumnobd/host-temp/data/luchadores/estilos-luchadores.csv' WITH (FORMAT csv, HEADER true); >> "%TMPDIR%\estilos_luchadores.sql"

echo SET datestyle TO 'DMY'; >> "%TMPDIR%\eventos.sql"
echo \copy evento FROM '/home/alumnobd/host-temp/data/luchas/events_con_coordenadas.csv' WITH (FORMAT csv, HEADER true); >> "%TMPDIR%\eventos.sql"

echo \copy pelea(event_id, match_nr, fighter1_url, fighter2_url, results, win_method, win_details, referee, round, "time") FROM '/home/alumnobd/host-temp/data/luchas/fights.csv' WITH (FORMAT csv, HEADER true); >> "%TMPDIR%\peleas.sql"

:: ----- PASO 3: ejecutar importaciones -----
echo 2. Importando luchadores...
docker exec -u alumnobd edge-gria-pgsql psql -d alumnobd -f /home/alumnobd/host-temp/tmp/luchadores.sql

echo 3. Importando estilos...
docker exec -u alumnobd edge-gria-pgsql psql -d alumnobd -f /home/alumnobd/host-temp/tmp/estilos.sql

echo 4. Importando estilos_luchadores...
docker exec -u alumnobd edge-gria-pgsql psql -d alumnobd -f /home/alumnobd/host-temp/tmp/estilos_luchadores.sql

echo 5. Importando eventos...
docker exec -u alumnobd edge-gria-pgsql psql -d alumnobd -f /home/alumnobd/host-temp/tmp/eventos.sql

echo 6. Importando peleas...
docker exec -u alumnobd edge-gria-pgsql psql -d alumnobd -f /home/alumnobd/host-temp/tmp/peleas.sql

echo --- Proceso de importación completado con éxito ---
exit /b 0
