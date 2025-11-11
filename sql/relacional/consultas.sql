-- 1. USO DE JOIN. Consultamos el número de victorias que se han obtenido por estilo, ordenado de forma descendente.
SELECT 
    e.nombre AS estilo,
    SUM(l.wins) AS total_victorias
FROM estilos e
JOIN estilos_luchadores el ON e.id = el.estilo_id
JOIN luchadores l ON el.luchador_id = l.url
GROUP BY e.nombre
ORDER BY total_victorias DESC;
