-- 1. USO DE JOIN. Consultamos el número de victorias que se han obtenido por estilo, ordenado de forma descendente.

SELECT 
    e.nombre AS estilo,
    COUNT(*) AS total_victorias
FROM 
	estilos e
JOIN 
	estilos_luchadores el ON e.id = el.estilo_id
JOIN 
	luchadores l ON el.luchador_id = l.url
join 
	pelea p on l.url = p.fighter1_url 
where
	p.results NOT IN ('draw', 'NC')
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


-- 3. USO DE FUNCIÓN HAVING Y GROUP BY. Loitadores con máis de 5 vitorias por submisión

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

-- 4. USO DE FUNCION union. Luchadores de brasil o especialistas en jiu-jitsu.

-- Primeira consulta: loitadores de Brasil
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


-- 5 BÚSQUEDA DE PALABRAS CLAVE EN CAMPO DE TEXTO. Luchadores con 'mar' en su nombre o apellido.
SELECT
    fighter_name,
    nickname,
    url
FROM
    luchadores
WHERE
    url ILIKE '%mar%';

-- luchas con 3 grados de separación

SELECT DISTINCT
    l1.fighter_name AS loitador_inicial,
    p1_evento.event_title AS evento_1,
    l2.fighter_name AS opoñente_nivel_1,
    p2_evento.event_title AS evento_2,
    l3.fighter_name AS opoñente_nivel_2,
    p3_evento.event_title AS evento_3,
    l4.fighter_name AS opoñente_nivel_3
FROM
    -- Primeira pelexa: l1 vs l2
    pelea p1
    JOIN luchadores l1 ON p1.fighter1_url = l1.url
    JOIN luchadores l2 ON p1.fighter2_url = l2.url
    JOIN evento p1_evento ON p1.event_id = p1_evento.event_id

    -- Segunda pelexa: l2 vs l3
    JOIN pelea p2 ON (p2.fighter1_url = l2.url OR p2.fighter2_url = l2.url)
    JOIN luchadores l3 ON (p2.fighter1_url = l3.url OR p2.fighter2_url = l3.url) AND l3.url != l2.url
    JOIN evento p2_evento ON p2.event_id = p2_evento.event_id

    -- Terceira pelexa: l3 vs l4
    JOIN pelea p3 ON (p3.fighter1_url = l3.url OR p3.fighter2_url = l3.url)
    JOIN luchadores l4 ON (p3.fighter1_url = l4.url OR p3.fighter2_url = l4.url) AND l4.url != l3.url
    JOIN evento p3_evento ON p3.event_id = p3_evento.event_id
WHERE
    -- Especificamos o loitador de partida
    l1.fighter_name = 'Conor McGregor'

    -- Condicións para asegurar unha cadea lóxica
    AND l1.url != l3.url                         -- O loitador inicial non pode ser o seu propio "neto"
    AND l2.url != l4.url                         -- O primeiro opoñente non pode ser o terceiro
    AND p1.pelea_id != p2.pelea_id
    AND p2.pelea_id != p3.pelea_id
    AND p1_evento.date < p2_evento.date          
    AND p2_evento.date < p3_evento.date;

--  consulta espacial sobre as representacións xeométrica
create extension postgis;
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



