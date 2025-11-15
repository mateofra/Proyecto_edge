-- 3 luchadores con mas de 5 victorias por sumisión
WITH vitorias AS (
    SELECT
        combate->'fighter1'->>'name' AS nome_ganador,
        combate->>'win_method' AS metodo
    FROM
        eventos_json,
        jsonb_array_elements(cartelera_combates) AS combate
    WHERE
        LOWER(combate->>'result') NOT IN ('draw', 'no contest')
)
SELECT
    nome_ganador,
    COUNT(*) AS vitorias_por_submision
FROM
    vitorias
WHERE
    metodo LIKE '%Submission%'
GROUP BY
    nome_ganador
HAVING
    COUNT(*) > 5
ORDER BY
    vitorias_por_submision DESC;