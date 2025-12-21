-- Crear el esquema si no existe
create schema if not exists eventos_schema;

-- Eliminar la tabla si ya existe
drop table if exists eventos_schema.eventos_json;

-- Crear la tabla de eventos con datos agregados en jsonb
create table eventos_schema.eventos_json (
    event_id text primary key,
    event_title varchar(100) not null,
    organisation varchar(100),
    date date,
    location varchar(255),
    cartelera_combates jsonb
);

-- SE HA ELIMINADO EL TRUNCATE PORQUE ES INNECESARIO Y DABA ERROR DE SINTAXIS

-- 1: Insertar los datos transformados en la tabla eventos_json
insert into eventos_schema.eventos_json (event_id, event_title, organisation, date, location, cartelera_combates)
with
    -- CTE que agrupa los estilos de lucha por luchador
    estilos_por_luchador as (
        select
            el.luchador_id,
            jsonb_agg(es.nombre) as estilos_json
        from
            estilos_luchadores el
        join
            estilos es on el.estilo_id = es.id
        group by
            el.luchador_id
    ),

    -- CTE que construye el objeto JSON de cada combate con detalles de ambos luchadores
    combates_json as (
        select
            p.event_id,
            jsonb_build_object(
                'match_nr', p.match_nr,
                'result', p.results,
                'win_method', p.win_method,
                'fighter1', jsonb_build_object(
                    'url', l1.url,
                    'name', l1.fighter_name,
                    'country', l1.country,
                    'styles', coalesce(s1.estilos_json, '[]'::jsonb)
                ),
                'fighter2', jsonb_build_object(
                    'url', l2.url,
                    'name', l2.fighter_name,
                    'country', l2.country,
                    'styles', coalesce(s2.estilos_json, '[]'::jsonb)
                )
            ) as combate_obj
        from
            pelea p
        join luchadores l1 on p.fighter1_url = l1.url
        join luchadores l2 on p.fighter2_url = l2.url
        left join estilos_por_luchador s1 on l1.url = s1.luchador_id
        left join estilos_por_luchador s2 on l2.url = s2.luchador_id
    ),

    -- CTE que agrega todos los combates en un array ordenado por número de combate
    cartelera_final as (
        select
            event_id,
            jsonb_agg(combate_obj order by (combate_obj->>'match_nr')::int) as cartelera
        from
            combates_json
        group by
            event_id
    )

-- SELECT final que une eventos con sus carteles completas en formato JSONB
select
    e.event_id,
    e.event_title,
    e.organisation,
    e.date,
    e.location,
    coalesce(cf.cartelera, '[]'::jsonb)
from
    evento e
left join -- Cambiado a LEFT JOIN por si hay eventos sin peleas registradas
    cartelera_final cf on e.event_id = cf.event_id;