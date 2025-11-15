-- Eliminar a táboa se xa existe
DROP TABLE IF EXISTS eventos_json;

-- Crear a táboa de eventos con datos agregados en JSONB
CREATE TABLE eventos_json (
    event_id TEXT PRIMARY KEY,
    event_title VARCHAR(100) NOT NULL,
    organisation VARCHAR(100),
    date DATE,
    location VARCHAR(255),
    -- Agregamos a cartelera de combates como un array JSON
    cartelera_combates JSONB
);

-- PASO 0: (Opcional pero recomendado) Baleirar a táboa de destino para evitar duplicados se se executa varias veces.
TRUNCATE TABLE eventos_json;

-- PASO 1: Inserir os datos transformados na táboa eventos_json
INSERT INTO eventos_json (event_id, event_title, organisation, date, location, cartelera_combates)

-- Usamos un WITH para construír a nosa estrutura JSON paso a paso
WITH
    -- CTE 1: Agregamos os estilos de cada loitador nun array JSON.
    -- Este é o noso primeiro nivel de agregación.
    estilos_por_luchador AS (
        SELECT
            el.luchador_id,
            -- jsonb_agg agrega todos os nomes de estilo nun array JSONB.
            jsonb_agg(es.nombre) AS estilos_json
        FROM
            estilos_luchadores el
        JOIN
            estilos es ON el.estilo_id = es.id
        GROUP BY
            el.luchador_id
    ),

    -- CTE 2: Construímos un obxecto JSON completo para cada combate individual.
    -- Aquí combinamos os datos da pelexa, os loitadores e os seus estilos (da CTE anterior).
    combates_json AS (
        SELECT
            p.event_id,
            -- jsonb_build_object crea un obxecto JSON a partir de pares clave-valor.
            jsonb_build_object(
                'match_nr', p.match_nr,
                'result', p.results,
                'win_method', p.win_method,
                'fighter1', jsonb_build_object(
                    'url', l1.url,
                    'name', l1.fighter_name,
                    'country', l1.country,
                    -- Usamos COALESCE para asegurarnos de que se un loitador non ten estilos, obteña un array baleiro [].
                    'styles', COALESCE(s1.estilos_json, '[]'::jsonb)
                ),
                'fighter2', jsonb_build_object(
                    'url', l2.url,
                    'name', l2.fighter_name,
                    'country', l2.country,
                    'styles', COALESCE(s2.estilos_json, '[]'::jsonb)
                )
            ) AS combate_obj -- Este é o obxecto JSON que representa un único combate
        FROM
            pelea p
        -- Unimos para obter os datos do loitador 1
        JOIN luchadores l1 ON p.fighter1_url = l1.url
        -- Unimos para obter os datos do loitador 2
        JOIN luchadores l2 ON p.fighter2_url = l2.url
        -- Usamos LEFT JOIN para os estilos, por se algún loitador non ten estilos definidos
        LEFT JOIN estilos_por_luchador s1 ON l1.url = s1.luchador_id
        LEFT JOIN estilos_por_luchador s2 ON l2.url = s2.luchador_id
    ),

    -- CTE 3: Agregamos todos os obxectos JSON dos combates nun único array por evento.
    -- Este é o noso nivel final de agregación.
    cartelera_final AS (
        SELECT
            event_id,
            -- Agregamos todos os obxectos JSON de combates (combate_obj) nun array JSON por evento.
            jsonb_agg(combate_obj ORDER BY combate_obj->'match_nr') AS cartelera -- Ordenamos os combates polo seu número
        FROM
            combates_json
        GROUP BY
            event_id
    )

-- FINAL SELECT: Unimos os datos do evento co seu array JSON de combates xa construído.
SELECT
    e.event_id,
    e.event_title,
    e.organisation,
    e.date,
    e.location,
    -- Se un evento non ten combates, COALESCE asegúrase de que a columna cartelera_combates teña un array baleiro '[]' en lugar de NULL.
    COALESCE(cf.cartelera, '[]'::jsonb)
FROM
    evento e
-- Usamos LEFT JOIN para incluír eventos que poidan non ter combates rexistrados.
LEFT JOIN
    cartelera_final cf ON e.event_id = cf.event_id;

---