--Tablas de referencia
SELECT create_reference_table('estilos');
SELECT create_reference_table('evento');

--Tablas distribuidas
SELECT create_distributed_table('luchadores', 'url');

SELECT create_distributed_table('estilos_luchadores','luchador_id',colocate_with => 'luchadores');
SELECT create_distributed_table('pelea', 'fighter1_url', colocate_with => 'luchadores');


SELECT * from citus_tables

SELECT * from citus_shards

SELECT * from pg_dist_node



