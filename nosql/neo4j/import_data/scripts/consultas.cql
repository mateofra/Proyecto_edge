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

// 3. Luchadores con más de 5 victorias por sumisión.
MATCH (l:Luchador)-[:PARTICIPA]->(p:Pelea)
WHERE p.winMethod = "Submission"
WITH l, COUNT(p) AS vitorias_por_submision
WHERE vitorias_por_submision > 5
RETURN l.nombre, vitorias_por_submision
ORDER BY vitorias_por_submision DESC
LIMIT 5;

// 4. Luchadores de Brasil o especialistas en jiu-jitsu.
CALL {
  MATCH (l:Luchador)-[:TIENE_ESTILO]->(e:Estilo)
  WHERE l.country = "Brazil"
  RETURN l.nombre AS nombre, l.country AS country, e.nombre AS estilo
  UNION
  MATCH (l:Luchador)-[:TIENE_ESTILO]->(e:Estilo)
  WHERE e.nombre = "jiu-jitsu"
  RETURN l.nombre AS nombre, l.country AS country, e.nombre AS estilo
}
RETURN *
LIMIT 5;


// 5. Consultar luchadores cuyo nombre o apodo contenga "mar" (ignorando mayúsculas y minúsculas).
MATCH (l:Luchador)
WHERE toLower(l.url) CONTAINS "mar"
RETURN l.nombre AS nombre, l.nickname AS nickname, l.url AS url
LIMIT 5;

// 6. Consulta luchas con 3 grados de separación
MATCH (l1:Luchador {nombre: "Conor McGregor"})-[:PARTICIPA]->(p1:Pelea)<-[:PARTICIPA]-(l2:Luchador)
MATCH (l2)-[:PARTICIPA]->(p2:Pelea)<-[:PARTICIPA]-(l3:Luchador)
MATCH (l3)-[:PARTICIPA]->(p3:Pelea)<-[:PARTICIPA]-(l4:Luchador)
WITH l1, l2, l3, l4, p1, p2, p3
MATCH (ev1:Evento)-[:INCLUYE]->(p1),
      (ev2:Evento)-[:INCLUYE]->(p2),
      (ev3:Evento)-[:INCLUYE]->(p3)
WHERE l1 <> l3 AND l2 <> l4 AND
      p1 <> p2 AND p2 <> p3 AND
      ev1.date < ev2.date AND ev2.date < ev3.date
RETURN DISTINCT
  l1.nombre AS luchador_inicial,
  ev1.title AS evento_1,
  l2.nombre AS oponente_nivel_1,
  ev2.title AS evento_2,
  l3.nombre AS oponente_nivel_2,
  ev3.title AS evento_3,
  l4.nombre AS oponente_nivel_3
LIMIT 50;