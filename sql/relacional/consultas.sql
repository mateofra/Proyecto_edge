-- 1. USO DE JOIN. Consultamos el número de victorias que se han obtenido por estilo, ordenado de forma descendente.

select 
    e.nombre as estilo,
    count(*) as total_victorias
from 
    estilos e
join 
    estilos_luchadores el on e.id = el.estilo_id
join 
    luchadores l on el.luchador_id = l.url
join 
    pelea p on l.url = p.fighter1_url 
where
    p.results not in ('draw', 'nc')
group by e.nombre
order by total_victorias desc;


-- 2. USO DE FUNCIÓN DE AGREGADO COUNT. Consultamos el número de peleas que ha tenido cada luchador, ordenado de forma descendiente.
select 
    l.fighter_name,
    count(p.pelea_id) as total_peleas
from luchadores l
left join pelea p 
    on l.url = p.fighter1_url or l.url = p.fighter2_url
group by l.fighter_name
order by total_peleas desc;


-- 3. USO DE FUNCIÓN HAVING Y GROUP BY. Luchadores con más de 5 victorias por sumisión

select
    l.fighter_name,
    count(p.pelea_id) as victorias_por_sumision
from
    pelea p
join
    luchadores l on p.fighter1_url = l.url
where
    p.win_method like '%submission%'           
group by
    l.fighter_name
having
    count(p.pelea_id) > 5 
order by
    victorias_por_sumision desc;

-- 4. USO DE FUNCIÓN UNION. Luchadores de Brasil o especialistas en jiu-jitsu.

-- Primera consulta: luchadores de Brasil
select l.fighter_name, l.country, es.nombre 
from luchadores l
join estilos_luchadores el on l.url = el.luchador_id
join estilos es on el.estilo_id = es.id
where l.country = 'Brazil'

union

-- Segunda consulta: luchadores con estilo Jiu-Jitsu
select l.fighter_name, l.country, es.nombre 
from luchadores l
join estilos_luchadores el on l.url = el.luchador_id
join estilos es on el.estilo_id = es.id
where es.nombre = 'jiu-jitsu';


-- 5 BÚSQUEDA DE PALABRAS CLAVE EN CAMPO DE TEXTO. Luchadores con 'mar' en su nombre o apellido.
select
    fighter_name,
    nickname,
    url
from
    luchadores
where
    url ilike '%mar%';

-- Luchas con 3 grados de separación

select distinct
    l1.fighter_name as luchador_inicial,
    p1_evento.event_title as evento_1,
    l2.fighter_name as oponente_nivel_1,
    p2_evento.event_title as evento_2,
    l3.fighter_name as oponente_nivel_2,
    p3_evento.event_title as evento_3,
    l4.fighter_name as oponente_nivel_3
from
    -- Primera pelea: l1 vs l2
    pelea p1
    join luchadores l1 on p1.fighter1_url = l1.url
    join luchadores l2 on p1.fighter2_url = l2.url
    join evento p1_evento on p1.event_id = p1_evento.event_id

    -- Segunda pelea: l2 vs l3
    join pelea p2 on (p2.fighter1_url = l2.url or p2.fighter2_url = l2.url)
    join luchadores l3 on (p2.fighter1_url = l3.url or p2.fighter2_url = l3.url) and l3.url != l2.url
    join evento p2_evento on p2.event_id = p2_evento.event_id

    -- Tercera pelea: l3 vs l4
    join pelea p3 on (p3.fighter1_url = l3.url or p3.fighter2_url = l3.url)
    join luchadores l4 on (p3.fighter1_url = l4.url or p3.fighter2_url = l4.url) and l4.url != l3.url
    join evento p3_evento on p3.event_id = p3_evento.event_id
where
    -- Especificamos el luchador de partida
    l1.fighter_name = 'Conor McGregor'

    -- Condiciones para asegurar una cadena lógica
    and l1.url != l3.url                         -- El luchador inicial no puede ser su propio "nieto"
    and l2.url != l4.url                         -- El primer oponente no puede ser el tercero
    and p1.pelea_id != p2.pelea_id
    and p2.pelea_id != p3.pelea_id
    and p1_evento.date < p2_evento.date          
    and p2_evento.date < p3_evento.date;

-- Consulta espacial sobre las representaciones geométricas
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