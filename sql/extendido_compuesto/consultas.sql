
-- 1. Consultamos el número de victorias que se han obtenido por estilo, ordenado de forma descendente.
SELECT
    estilo,
    COUNT(*) AS vitorias_por_estilo
FROM
    luchadores_agregado,
    UNNEST(historial_combates) AS combate,
    UNNEST(estilos_de_loita) AS estilo
WHERE
    combate.resultado = 'win' 
GROUP BY
    estilo
ORDER BY
    vitorias_por_estilo DESC;

-- 2. USO DE FUNCIÓN DE AGRAGADO COUNT. Consultamos el número de peleas que ha tenido cada luchador, ordenado de forma descendiente.

select 
	fighter_name,
	count(*) as victorias_luchador
from 
	luchadores_agregado,
	UNNEST(historial_combates) as combate
group by 
	fighter_name 
order by 
	victorias_luchador desc

-- 3. luchadores con más de 5 vistorias por sumisión
SELECT
    l.fighter_name,
    COUNT(*) AS vitorias_por_submision
FROM
    luchadores_agregado l,
    UNNEST(l.historial_combates) AS combate
WHERE
    LOWER(combate.resultado) NOT IN ('draw', 'NC')
    AND combate.metodo_vitoria LIKE '%Submission%'
GROUP BY
    l.fighter_name
HAVING
    COUNT(*) > 5
ORDER BY
    vitorias_por_submision DESC;

-- 4. luchadores de brasil o de jiu-jitsu

SELECT fighter_name, country, estilos_de_loita 
FROM luchadores_agregado
WHERE
    country = 'Brazil'
    OR 'jiu-jitsu' = ANY(estilos_de_loita);

-- Consultas Beneficiadas:
    ---Consulta 4 (Jiu-Jitsu ou Brasil):A comprobación de pertenza a un array
---(`= ANY()`) é drasticamente máis eficiente que múltiples `JOINs`.
--Calquera consulta que pida toda a información dun único loitador.
--O modelo relacional necesitaría múltiples `JOINs`, mentres que este modelo
-- só require unha simple selección de fila (`SELECT * FROM luchadores_agregado WHERE ...`).
-- A atomicidade da información do loitador é máxima.

-- Consultas Prexudicadas:
  --Consulta 6 (Cadea de Opoñentes):Navegar relacións entre distintas entidades 
  --(loitador -> opoñente -> opoñente do opoñente) é natural no modelo relacional.
 -- Aquí, require expandir (`UNNEST`) o historial dun loitador para atopar un opoñente
-- despois buscar a fila dese opoñente na mesma táboa e volver a expandir o seu historial.

-- As consultas de agregación masiva (como a 1, 2 e 3) poden ser lixeiramente prexudicadas
-- se a táboa é moi grande, xa que `UNNEST` sobre toda a táboa pode crear un conxunto de 
-- datos intermedio masivo en memoria antes de poder filtrar. O optimizador de consultas 
-- relacional adoita ser mellor manexando `JOINs` con índices.












