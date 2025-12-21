## Modelo Relacional

Para iniciar el Dockerimage ejecuta el script `start.sh`
~~~bash
./start.sh
~~~

Para generar las tablas e importar los datos ejecuta el script `importar.sh`
~~~bash
./importar.sh
~~~
 Para cerrar la sesión ejecuta el script `stop.sh`
 ~~~bash
./stop.sh
~~~

El script `generar_datos` ejecutará los scripts de python que utilizamos para modificar los datos originales. Debido al script que guarda los datos geográficos el script tardará aproximadamente 12 minutos en ejecutarse.
~~~bash
./generar_datos.sh
~~~
Para ejecutar las consultas y la creación de esquemas copia y pega de los archivos en los directorios de `sql/` :)

## NoSql

### Mongodb
Ejecuta el script '/nosql/mongodb/cluster.sh'
~~~bash
cd nosql/mongodb/ $$ ./cluster.sh
~~~~
Ejecuta el script `ìmport.sh`
~~~bash
./import.sh
~~~
Entra en el contenedor **m1-mongos** 
~~~bash
docker exec -it m1-mongos mongosh --port 27019
~~~
Para ejecutar las consultas, copialas y pégalas de consultas.js

### Neo4j
Ejecuta el script '/nosql/neo4j/build.sh'
~~~bash
cd nosql/neo4j/ $$ ./build.sh
~~~~
TENEIS QUE TENER LA RED DE DOCKER `network-edge-gria` CON EL CONTENEDOR DE POSTGRSQL CONECTADO
ENTRAIS EN EL CONTENEDOR `edge-gria-neo4j` EN MODO INTERACTIVO, 
~~~bash
docker exec -it edge-gria-neo4j bash --port 7474
~~~
PARA ENTRAR EN NEO4J PONER `cypher-shell` , USUARIO : neo4j CONTRASEÑA : pwalumnobd
CAMBIAIS EN EL SCRIPT `import.cql` "NOMBRE" POR EL NOMBRE DE VUESTRA BASE DE DATOS.
`jdbc:postgresql://edge-gria-pgsql/"NOMBRE"?user=alumnobd&password=pwalumnobd`, creo que el que usais es alumnobd
~~~bash
nano import_data/scripts/import.cql
~~~
EJECUTAIS EL SCRIPT DE CREACION DEL GRAFO EN EL VOLUMEN:
neo4j@neo4j> 
~~~neo4j
source /home/alumnobd/host-temp/scripts/import.cql
~~~
AHORA YA PODEMOS REALIZAR LAS CONSULTAS
PARA EJECUTAR TODAS LAS CONSULTAS
~~~neo4j
source /home/alumnobd/host-temp/scripts/consultas.cql
~~~
