-- Crear el esquema si no existe
CREATE SCHEMA IF NOT EXISTS relacional_extendido;

-- Eliminar el tipo si ya existe para evitar errores
DROP TYPE IF EXISTS relacional_extendido.tipo_combate CASCADE;

-- Crear un tipo de dato compuesto para almacenar la información de cada combate
CREATE TYPE relacional_extendido.tipo_combate AS (
    evento_titulo VARCHAR(100),
    data_combate DATE,
    oponente_nome VARCHAR(100),
    oponente_url TEXT,
    resultado VARCHAR(50),
    metodo_vitoria VARCHAR(100)
);

-- Eliminar la tabla si ya existe
DROP TABLE IF EXISTS relacional_extendido.luchadores_agregado;

-- Crear la tabla de luchadores con datos agregados
CREATE TABLE relacional_extendido.luchadores_agregado (
    url TEXT PRIMARY KEY,
    fighter_name VARCHAR(100) NOT NULL,
    nickname VARCHAR(100),
    birth_date DATE,
    country VARCHAR(100),
    -- Agregamos los estilos como un array de texto
    estilos_de_loita TEXT[],
    -- Agregamos el historial de combates como un array de nuestro tipo compuesto
    historial_combates relacional_extendido.tipo_combate[]
);

-- Insertar los datos transformados en la nueva tabla
INSERT INTO relacional_extendido.luchadores_agregado ( -- relacional_extendido es el esquema donde se crea la tabla
    url,                                               -- cambiar si es necesario
    fighter_name,
    nickname,
    birth_date,
    country,
    estilos_de_loita,
    historial_combates
)
WITH
-- 1. Agregamos los estilos de cada luchador
estilos_agregados AS (
    SELECT
        el.luchador_id,
        ARRAY_AGG(es.nombre) AS lista_estilos -- Agregamos los nombres de los estilos en un array
    FROM
        public.estilos_luchadores el -- public es el esquema predeterminado, ajustar si es necesario
    JOIN
        public.estilos es ON el.estilo_id = es.id
    GROUP BY
        el.luchador_id
),

-- 2. Preparamos el historial de combates
-- Desde la perspectiva de un luchador
todos_los_combates AS (
    -- Parte A: Combates donde el luchador es fighter1
    SELECT
        p.fighter1_url AS luchador_url,
        e.event_title,
        e.date,
        oponente.fighter_name AS oponente_nome,
        p.fighter2_url AS oponente_url,
        p.results,
        p.win_method
    FROM
        public.pelea p
    JOIN
        public.evento e ON p.event_id = e.event_id
    JOIN
        public.luchadores oponente ON p.fighter2_url = oponente.url

    UNION ALL

    -- Parte B: Combates donde el luchador es fighter2
    SELECT
        p.fighter2_url AS luchador_url,
        e.event_title,
        e.date,
        oponente.fighter_name AS oponente_nome,
        p.fighter1_url AS oponente_url,
        -- Invertimos el resultado: si fighter1 ganó ('win'), para fighter2 es una derrota ('loss')
        CASE p.results
            WHEN 'win' THEN 'loss'
            WHEN 'loss' THEN 'win'
            ELSE p.results -- 'draw' y 'NC' no cambian
        END AS results,
        p.win_method
    FROM
        public.pelea p
    JOIN
        public.evento e ON p.event_id = e.event_id
    JOIN
        public.luchadores oponente ON p.fighter1_url = oponente.url
),

-- 3. Agregamos el historial de combates en un array del tipo que definimos
historiales_agregados AS (
    SELECT
        luchador_url,
        ARRAY_AGG(
            ROW(event_title, 
            date, 
            oponente_nome, 
            oponente_url, 
            results, 
            win_method)::relacional_extendido.tipo_combate
            ORDER BY date DESC -- ordenamos por fecha los combates
        ) AS lista_combates
    FROM
        todos_los_combates
    GROUP BY
        luchador_url
)

-- Consulta final que une toda la información
SELECT
    l.url,
    l.fighter_name,
    l.nickname,
    l.birth_date,
    l.country,
    -- Usamos COALESCE por si un luchador no tiene estilos
    COALESCE(ea.lista_estilos, '{}'::TEXT[]),
    -- Usamos COALESCE por si un luchador no tiene combates
    COALESCE(ha.lista_combates, '{}'::relacional_extendido.tipo_combate[])
FROM
    public.luchadores l
LEFT JOIN
    estilos_agregados ea ON l.url = ea.luchador_id
LEFT JOIN
    historiales_agregados ha ON l.url = ha.luchador_url;
