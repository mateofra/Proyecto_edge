-- 1. consultamos el número de victorias que se han obtenido por estilo, ordenado de forma descendente.
select 
    estilo,
    count(*) as total_victorias
from 
    relacional_extendido.luchadores_agregado,
    unnest(estilos_de_loita) as estilo,
    unnest(historial_combates) as h
where 
    h.resultado = 'win'
group by estilo
order by total_victorias desc;

-- 2. consultamos el número de peleas que ha tenido cada luchador, ordenado de forma descendiente.

select 
    fighter_name,
    array_length(historial_combates, 1) as total_peleas
from 
    relacional_extendido.luchadores_agregado
order by total_peleas desc;

-- 3. luchadores con más de 5 victorias por sumisión
select 
    fighter_name,
    count(*) as vitorias_por_submision
from 
    relacional_extendido.luchadores_agregado,
    unnest(historial_combates) as h
where 
    h.resultado = 'win' 
    and h.metodo_vitoria like '%submission%'
group by fighter_name
having count(*) > 5
order by vitorias_por_submision desc;

-- 4. luchadores de brasil o de jiu-jitsu

select fighter_name, country, estilos_de_loita 
from relacional_extendido.luchadores_agregado
where
    country = 'brazil'
    or 'jiu-jitsu' = any(estilos_de_loita);

-- 5. búsqueda palabra clave

select fighter_name, nickname, url
from relacional_extendido.luchadores_agregado
where url ilike '%mar%';

-- 6. cadena de oponentes

select distinct
    l1.fighter_name as loitador_inicial,
    h1.evento_titulo as evento_1,
    l2.fighter_name as oponente_nivel_1,
    h2.evento_titulo as evento_2,
    l3.fighter_name as oponente_nivel_2,
    h3.evento_titulo as evento_3,
    l4.fighter_name as oponente_nivel_3
from
    relacional_extendido.luchadores_agregado l1
    cross join unnest(l1.historial_combates) h1
    join relacional_extendido.luchadores_agregado l2 on h1.oponente_url = l2.url
    cross join unnest(l2.historial_combates) h2
    join relacional_extendido.luchadores_agregado l3 on h2.oponente_url = l3.url
    cross join unnest(l3.historial_combates) h3
    join relacional_extendido.luchadores_agregado l4 on h3.oponente_url = l4.url
where
    l1.fighter_name = 'conor mcgregor'
    and l1.url != l3.url
    and l2.url != l4.url
    and h1.data_combate < h2.data_combate
    and h2.data_combate < h3.data_combate;

-- 7. eventos cerca de las vegas

-- esta se mantiene igual apuntando a la tabla 'evento' original
select
    event_title, location, date,
    st_makepoint(longitud, latitud)::geography
from
    public.evento
where
    st_dwithin(
        st_makepoint(longitud, latitud)::geography,
        st_makepoint(-115.1728, 36.1025)::geography,
        10000 
    );

-- consultas beneficiadas:

    --- consulta 2 (total de peleas): es la consulta más beneficiada. 
    --- en el modelo original requeriría un join costoso y un group by. aquí, el dato ya 
    --- reside dentro de la fila del luchador y basta con usar `array_length`, 
    --- eliminando cualquier necesidad de computación pesada.

    --- consulta 4 (luchadores de brasil o jiu-jitsu): la eliminación de dos joins 
    --- con las tablas de estilos mejora el rendimiento. el uso de `= any(estilos_de_loita)` 
    --- permite buscar directamente dentro de la fila, aprovechando la localidad de los datos.

    --- consulta 5 (búsqueda por nombre/url): al estar toda la información consolidada 
    --- en una única tabla (`luchadores_agregado`), el motor de base de datos no 
    --- tiene que saltar entre diferentes bloques de disco para reconstruir el objeto, 
    --- acelerando las búsquedas simples.

-- consultas perjudicadas:

    --- consulta 6 (cadena de oponentes/grados de separación): esta consulta sufre 
    --- considerablemente. en el modelo relacional, las claves foráneas indexadas facilitan 
    --- seguir el "rastro" de los combates. aquí, para cada nivel de la cadena, el motor debe 
    --- realizar un `unnest` del array de combates para encontrar la url del oponente y 
    --- luego hacer un nuevo escaneo en la tabla principal para buscar ese objeto.

    --- consultas 1 y 3 (agregaciones con filtros específicos): consultas que filtran 
    --- por atributos internos del tipo compuesto (como `metodo_vitoria` o `resultado`) 
    --- obligan a "desempaquetar" el array (`unnest`) para poder analizar cada combate. 
    --- esto genera una carga de cpu mayor que filtrar una tabla plana de peleas 
    --- donde cada fila ya es una unidad independiente e indexable.

-- la consulta 7 no varía, ya que apunta a la tabla de eventos original y no se ve afectada
-- por el nuevo esquema de luchadores extendido compuesto.

-- resumen de diseño:
-- este esquema "extendido compuesto" es ideal para aplicaciones tipo api o web, 
-- donde se quiere recuperar el "perfil completo" de un luchador (con sus estilos e 
-- historial) en una única viaje a la base de datos. sin embargo, para analítica compleja 
-- que relacione múltiples luchadores entre sí, el modelo relacional clásico 
-- sigue siendo superior en eficiencia y flexibilidad.
