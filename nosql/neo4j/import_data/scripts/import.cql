// --------------------
// Importar Luchadores
// --------------------
CALL apoc.load.jdbc(
  "jdbc:postgresql://edge-gria-pgsql/alumnobd?user=alumnobd&password=pwalumnobd",
  "SELECT url, fighter_name, nickname, birth_date, age, country, height_cm, weight_kg,
   association, weight_class, wins, losses FROM luchadores"
) YIELD row
CREATE (l:Luchador {
  url: row.url, nombre: row.fighter_name, nickname: row.nickname,
  birthDate: row.birth_date, age: row.age, country: row.country,
  heightCm: row.height_cm, weightKg: row.weight_kg, association: row.association,
  weightClass: row.weight_class, wins: row.wins, losses: row.losses
});

// -------------------- 
// Importar Estilos
// --------------------
CALL apoc.load.jdbc(
  "jdbc:postgresql://edge-gria-pgsql/alumnobd?user=alumnobd&password=pwalumnobd",
  "SELECT id, nombre FROM estilos"
) YIELD row
CREATE (e:Estilo {
  id: row.id,
  nombre: row.nombre
});

// --------------------
// Relacionar Luchadores con Estilos
// --------------------
CALL apoc.load.jdbc(
  "jdbc:postgresql://edge-gria-pgsql/alumnobd?user=alumnobd&password=pwalumnobd",
  "SELECT luchador_id, estilo_id FROM estilos_luchadores"
) YIELD row
MATCH (l:Luchador {url: row.luchador_id})
MATCH (e:Estilo {id: row.estilo_id})
CREATE (l)-[:TIENE_ESTILO]->(e);

// --------------------
// Importar Eventos
// --------------------
CALL apoc.load.jdbc(
  "jdbc:postgresql://edge-gria-pgsql/alumnobd?user=alumnobd&password=pwalumnobd",
  "SELECT event_id, event_title, organisation, date, location, latitud, longitud FROM evento"
) YIELD row
CREATE (ev:Evento {
  id: row.event_id,
  title: row.event_title,
  organisation: row.organisation,
  date: row.date,
  location: row.location,
  latitud: row.latitud,
  longitud: row.longitud
});

// --------------------
// Importar Peleas y relaciones
// --------------------
CALL apoc.load.jdbc(
  "jdbc:postgresql://edge-gria-pgsql/alumnobd?user=alumnobd&password=pwalumnobd",
  "SELECT pelea_id, event_id, match_nr, fighter1_url, fighter2_url, results, win_method, win_details, referee, round, time FROM pelea"
) YIELD row
MATCH (ev:Evento {id: row.event_id})
MATCH (f1:Luchador {url: row.fighter1_url})
MATCH (f2:Luchador {url: row.fighter2_url})
CREATE (p:Pelea {
  id: row.pelea_id,
  matchNr: row.match_nr,
  results: row.results,
  winMethod: row.win_method,
  winDetails: row.win_details,
  referee: row.referee,
  round: row.round,
  time: row.time
})
CREATE (ev)-[:INCLUYE]->(p)
CREATE (f1)-[:PARTICIPA {rol:"fighter1"}]->(p)
CREATE (f2)-[:PARTICIPA {rol:"fighter2"}]->(p);
