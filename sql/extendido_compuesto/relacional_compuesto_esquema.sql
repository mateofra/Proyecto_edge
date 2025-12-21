-- crear el esquema si no existe
create schema if not exists relacional_extendido;

-- eliminar el tipo si ya existe para evitar errores
drop type if exists relacional_extendido.tipo_combate cascade;

-- crear un tipo de dato compuesto para almacenar la información de cada combate
create type relacional_extendido.tipo_combate as (
    evento_titulo varchar(100),
    data_combate date,
    oponente_nome varchar(100),
    oponente_url text,
    resultado varchar(50),
    metodo_vitoria varchar(100)
);

-- eliminar la tabla si ya existe
drop table if exists relacional_extendido.luchadores_agregado;

-- crear la tabla de luchadores con datos agregados
create table relacional_extendido.luchadores_agregado (
    url text primary key,
    fighter_name varchar(100) not null,
    nickname varchar(100),
    birth_date date,
    country varchar(100),
    -- agregamos los estilos como un array de texto
    estilos_de_loita text[],
    -- agregamos el historial de combates como un array de nuestro tipo compuesto
    historial_combates relacional_extendido.tipo_combate[]
);

-- insertar los datos transformados en la nueva tabla
insert into relacional_extendido.luchadores_agregado (
    url,
    fighter_name,
    nickname,
    birth_date,
    country,
    estilos_de_loita,
    historial_combates
)
with
-- 1. agregamos los estilos de cada luchador
estilos_agregados as (
    select
        el.luchador_id,
        array_agg(es.nombre) as lista_estilos
    from
        public.estilos_luchadores el
    join
        public.estilos es on el.estilo_id = es.id
    group by
        el.luchador_id
),

-- 2. preparamos el historial de combates
-- desde la perspectiva de un luchador
todos_los_combates as (
    -- parte a: combates donde el luchador es fighter1
    select
        p.fighter1_url as luchador_url,
        e.event_title,
        e.date,
        oponente.fighter_name as oponente_nome,
        p.fighter2_url as oponente_url,
        p.results,
        p.win_method
    from
        public.pelea p
    join
        public.evento e on p.event_id = e.event_id
    join
        public.luchadores oponente on p.fighter2_url = oponente.url

    union all

    -- parte b: combates donde el luchador es fighter2
    select
        p.fighter2_url as luchador_url,
        e.event_title,
        e.date,
        oponente.fighter_name as oponente_nome,
        p.fighter1_url as oponente_url,
        case p.results
            when 'win' then 'loss'
            when 'loss' then 'win'
            else p.results
        end as results,
        p.win_method
    from
        public.pelea p
    join
        public.evento e on p.event_id = e.event_id
    join
        public.luchadores oponente on p.fighter1_url = oponente.url
),

-- 3. agregamos el historial de combates en un array del tipo que definimos
historiales_agregados as (
    select
        luchador_url,
        array_agg(
            row(event_title, 
            date, 
            oponente_nome, 
            oponente_url, 
            results, 
            win_method)::relacional_extendido.tipo_combate
            order by date desc
        ) as lista_combates
    from
        todos_los_combates
    group by
        luchador_url
)

-- consulta final que une toda la información
select
    l.url,
    l.fighter_name,
    l.nickname,
    l.birth_date,
    l.country,
    coalesce(ea.lista_estilos, '{}'::text[]),
    coalesce(ha.lista_combates, '{}'::relacional_extendido.tipo_combate[])
from
    public.luchadores l
left join
    estilos_agregados ea on l.url = ea.luchador_id
left join
    historiales_agregados ha on l.url = ha.luchador_url;
