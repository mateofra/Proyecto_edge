-- 1. USO DE JOIN. Consultamos el número de victorias que se han obtenido por estilo, ordenado de forma descendente.
SELECT 
    e.nombre AS estilo,
    SUM(l.wins) AS total_victorias
FROM estilos e
JOIN estilos_luchadores el ON e.id = el.estilo_id
JOIN luchadores l ON el.luchador_id = l.url
GROUP BY e.nombre
ORDER BY total_victorias DESC;


-- 2. USO DE FUNCIÓN DE AGRAGADO COUNT. Consultamos el número de peleas que ha tenido cada luchador, ordenado de forma descendiente.
SELECT 
    l.fighter_name,
    COUNT(p.pelea_id) AS total_peleas
FROM luchadores l
LEFT JOIN pelea p 
    ON l.url = p.fighter1_url OR l.url = p.fighter2_url
GROUP BY l.fighter_name
ORDER BY total_peleas DESC;


