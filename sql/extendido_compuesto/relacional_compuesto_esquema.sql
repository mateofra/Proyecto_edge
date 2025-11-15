-- Eliminar o tipo se xa existe para evitar erros
DROP TYPE IF EXISTS tipo_combate CASCADE;

-- Crear un tipo de dato composto para almacenar a información de cada combate
CREATE TYPE tipo_combate AS (
    evento_titulo VARCHAR(100),
    data_combate DATE,
    oponente_nome VARCHAR(100),
    oponente_url TEXT,
    resultado VARCHAR(50),
    metodo_vitoria VARCHAR(100)
);

-- Eliminar a táboa se xa existe
DROP TABLE IF EXISTS luchadores_agregado;

-- Crear a táboa de loitadores con datos agregados
CREATE TABLE luchadores_agregado (
    url TEXT PRIMARY KEY,
    fighter_name VARCHAR(100) NOT NULL,
    nickname VARCHAR(100),
    birth_date DATE,
    country VARCHAR(100),
    -- Agregamos os estilos como un array de texto
    estilos_de_loita TEXT[],
    -- Agregamos o historial de combates como un array do noso tipo composto
    historial_combates tipo_combate[]
);

-- Inserir os datos transformados na nova táboa
INSERT INTO relacional_extendido.luchadores_agregado (
    url,
    fighter_name,
    nickname,
    birth_date,
    country,
    estilos_de_loita,
    historial_combates
)
WITH
-- 1. Agregamos os estilos de cada loitador nun array de texto
estilos_agregados AS (
    SELECT
        el.luchador_id,
        ARRAY_AGG(es.nombre) AS lista_estilos
    FROM
        public.estilos_luchadores el
    JOIN
        public.estilos es ON el.estilo_id = es.id
    GROUP BY
        el.luchador_id
),

-- 2. Preparamos o historial de combates completo para cada loitador
todos_los_combates AS (
    -- Parte A: Combates onde o loitador é fighter1
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

    -- Parte B: Combates onde o loitador é fighter2
    SELECT
        p.fighter2_url AS luchador_url,
        e.event_title,
        e.date,
        oponente.fighter_name AS oponente_nome,
        p.fighter1_url AS oponente_url,
        -- Invertemos o resultado: se fighter1 gañou ('win'), para fighter2 é unha derrota ('loss')
        CASE p.results
            WHEN 'win' THEN 'loss'
            WHEN 'loss' THEN 'win'
            ELSE p.results -- 'draw' e 'no contest' non cambian
        END AS results,
        p.win_method
    FROM
        public.pelea p
    JOIN
        public.evento e ON p.event_id = e.event_id
    JOIN
        public.luchadores oponente ON p.fighter1_url = oponente.url
),

-- 3. Agregamos o historial de combates nun array do noso tipo composto
historiales_agregados AS (
    SELECT
        luchador_url,
        ARRAY_AGG(
            ROW(event_title, date, oponente_nome, oponente_url, results, win_method)::relacional_extendido.tipo_combate
            ORDER BY date DESC -- Opcional: ordena os combates do máis recente ao máis antigo
        ) AS lista_combates
    FROM
        todos_los_combates
    GROUP BY
        luchador_url
)

-- Consulta final que une toda a información
SELECT
    l.url,
    l.fighter_name,
    l.nickname,
    l.birth_date,
    l.country,
    -- Usamos COALESCE para poñer un array baleiro se un loitador non ten estilos
    COALESCE(ea.lista_estilos, '{}'::TEXT[]),
    -- Usamos COALESCE para poñer un array baleiro se un loitador non ten combates
    COALESCE(ha.lista_combates, '{}'::relacional_extendido.tipo_combate[])
FROM
    public.luchadores l
LEFT JOIN
    estilos_agregados ea ON l.url = ea.luchador_id
LEFT JOIN
    historiales_agregados ha ON l.url = ha.luchador_url;




