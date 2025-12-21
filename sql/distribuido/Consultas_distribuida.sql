#Primera consulta
SELECT 
    e.nombre AS estilo,
    SUM(l.wins) AS total_victorias
FROM estilos e
JOIN estilos_luchadores el ON e.id = el.estilo_id
JOIN luchadores l ON el.luchador_id = l.url
GROUP BY e.nombre
ORDER BY total_victorias DESC;

#Segunda consulta
SELECT 
    l.fighter_name,
    COALESCE(p1.c1, 0) + COALESCE(p2.c2, 0) AS total_peleas
FROM luchadores l
LEFT JOIN (
    SELECT fighter1_url AS url, COUNT(*) AS c1
    FROM pelea
    GROUP BY fighter1_url
) p1 ON l.url = p1.url
LEFT JOIN (
    SELECT fighter2_url AS url, COUNT(*) AS c2
    FROM pelea
    GROUP BY fighter2_url
) p2 ON l.url = p2.url
ORDER BY total_peleas DESC;

#Tercera consulta
SELECT
    l.fighter_name,
    COUNT(p.pelea_id) AS vitorias_por_submision
FROM
    pelea p
JOIN
    luchadores l ON p.fighter1_url = l.url
WHERE
    p.win_method LIKE '%Submission%'           
GROUP BY
    l.fighter_name
HAVING
    COUNT(p.pelea_id) > 5 
ORDER BY
    vitorias_por_submision DESC;


# Cuarta consulta
SELECT l.fighter_name, l.country, es.nombre 
FROM luchadores l
JOIN estilos_luchadores el ON l.url = el.luchador_id
JOIN estilos es ON el.estilo_id = es.id
WHERE l.country = 'Brazil'

UNION

-- Segunda consulta: loitadores con estilo Jiu-Jitsu
SELECT l.fighter_name, l.country, es.nombre 
FROM luchadores l
JOIN estilos_luchadores el ON l.url = el.luchador_id
JOIN estilos es ON el.estilo_id = es.id
WHERE es.nombre = 'jiu-jitsu';


#Consulta espacial
SELECT
    event_title,
    location,
    date,
    ST_MakePoint(longitud, latitud )
FROM
    evento
WHERE
    ST_DWithin(
        ST_MakePoint(longitud, latitud)::geography,
        ST_MakePoint(-115.1728, 36.1025)::geography,-- Las Vegas
        10000 -- Distancia en metros
    );











