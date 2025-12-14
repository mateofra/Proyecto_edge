//1-- Consultamos el número de victorias que se han obtenido por estilo, ordenado de forma descendente
MATCH (l:Luchador)-[:TIENE_ESTILO]->(e:Estilo),
      (l)-[r:PARTICIPA]->(p:Pelea)
WHERE r.rol = "fighter1" AND NOT p.results IN ['draw', 'NC']
RETURN e.nombre AS estilo,
       COUNT(*) AS total_victorias
ORDER BY total_victorias DESC;

// 2. Consultamos el número de peleas que ha tenido cada luchador, ordenado de forma descendiente.
MATCH (l:Luchador)
OPTIONAL MATCH (l)-[:PARTICIPA]->(p:Pelea)
RETURN l.nombre AS luchador,
       COUNT(p) AS total_peleas
ORDER BY total_peleas DESC
LIMIT 5;