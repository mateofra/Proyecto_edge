-- 1 estadísticas de estilos con más victorias

select 
    estilo, 
    count(*) as total_victorias
from 
    eventos_schema.eventos_json,
    jsonb_array_elements(cartelera_combates) as combate,
    -- El ganador siempre es fighter1 según el DDL original si el resultado es 'win'
    jsonb_array_elements(combate->'fighter1'->'styles') as estilo
where 
    combate->>'result' = 'win'
group by estilo
order by total_victorias desc;

-- 2 número de peleas por luchador

select 
    luchador_nombre,
    count(*) as total_peleas
from (
    select combate->'fighter1'->>'name' as luchador_nombre from eventos_schema.eventos_json, jsonb_array_elements(cartelera_combates) as combate
    union all
    select combate->'fighter2'->>'name' as luchador_nombre from eventos_schema.eventos_json, jsonb_array_elements(cartelera_combates) as combate
) as todas_las_peleas
group by luchador_nombre
order by total_peleas desc;

-- 3 luchadores con más de 5 victorias por sumisión
select 
    combate->'fighter1'->>'name' as fighter_name,
    count(*) as vitorias_por_submision
from 
    eventos_schema.eventos_json,
    jsonb_array_elements(cartelera_combates) as combate
where 
    combate->>'result' = 'win' 
    and combate->>'win_method' ilike '%Submission%'
group by fighter_name
having count(*) > 5
order by vitorias_por_submision desc;

--- 4 luchadores de Brasil o de jiu-jitsu

select distinct
    luchador->>'name' as fighter_name,
    luchador->>'country' as country
from 
    eventos_schema.eventos_json,
    jsonb_array_elements(cartelera_combates) as combate,
    lateral (select (combate->'fighter1') union all select (combate->'fighter2')) as l(luchador)
where 
    luchador->>'country' = 'Brazil'
    or luchador->'styles' @> '["jiu-jitsu"]'::jsonb;

--- 5 palabra clave 

select 
    luchador->>'name' as fighter_name
from 
    eventos_schema.eventos_json,
    jsonb_array_elements(cartelera_combates) as combate,
    lateral (select (combate->'fighter1') union all select (combate->'fighter2')) as l(luchador)
where 
    luchador->>'name' ilike '%mar%'; 

--- 6 cadena de oponentes

select distinct
    e1.cartelera_combates->0->'fighter1'->>'name' as luchador_inicial,
    e1.event_title as evento_1,
    c1->'fighter2'->>'name' as oponente_nivel_1,
    e2.event_title as evento_2,
    c2->'fighter2'->>'name' as oponente_nivel_2
from 
    eventos_schema.eventos_json e1
    cross join jsonb_array_elements(e1.cartelera_combates) c1
    join eventos_schema.eventos_json e2 on e2.cartelera_combates @> jsonb_build_array(jsonb_build_object('fighter1', jsonb_build_object('url', c1->'fighter2'->>'url')))
    cross join jsonb_array_elements(e2.cartelera_combates) c2
where 
    e1.cartelera_combates @> '[{"fighter1": {"name": "Conor McGregor"}}]'
    and e1.date < e2.date;

-- 7 Consulta espacial 
SELECT
    event_title,
    location,
    date,
    ST_MakePoint(longitud, latitud)::geography AS punto_geografico
FROM
    public.evento -- Usamos la tabla original para las coordenadas
JOIN 
    eventos_schema.eventos_json ej ON ej.event_id = public.evento.event_id
WHERE
    ST_DWithin(
        ST_MakePoint(longitud, latitud)::geography,
        ST_MakePoint(-115.1728, 36.1025)::geography, 
        10000 
    );


-- Consultas Beneficiadas:
    --- Consulta de Cartelera: Es la consulta con mayor beneficio. Para mostrar 
    --- todos los combates de un evento con nombres y estilos de los luchadores, 
    --- el modelo relacional haría 5 o 6 JOINs. Aquí es un simple `SELECT *`.
    --- Ideal para enviar datos directamente a una App móvil o Web (JSON listo).

-- Consultas Perjudicadas:
    --- Consultas de Agregación (1, 2, 3): El motor debe parsear el JSON en tiempo 
    --- real. Aunque `jsonb` es binario y rápido, extraer datos de arrays 
    --- anidados (`styles` dentro de `fighter` dentro de `cartelera`) es mucho 
    --- más lento que consultar columnas indexadas.
    
    --- Integridad de datos: Al duplicar información (como el nombre del país o 
    --- los estilos) dentro del JSON, si un luchador cambia de estilo, habría 
    --- que actualizar miles de documentos JSON en lugar de una sola fila.

-- conclusión:
-- Este esquema es un enfoque "Document-Oriented". Prioriza la lectura rápida de 
-- documentos completos (eventos) sobre la flexibilidad de hacer preguntas cruzadas 
-- sobre los luchadores.