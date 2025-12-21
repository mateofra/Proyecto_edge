// 1. Consultamos el número de victorias que se han obtenido por estilo, ordenado de forma descendente.
  db.luchadores_agregados.aggregate([
    { $unwind: "$historial_combates" },
    { $unwind: "$estilos_de_loita" },
    { $match: { "historial_combates.resultado": "win" } },
    { $group: { 
        _id: "$estilos_de_loita", 
        vitorias_por_estilo: { $sum: 1 } 
    }},
    { $sort: { vitorias_por_estilo: -1 } },
    { $limit: 5 }
  ]).forEach(printjson);

// La salida da :
//   { _id: 'judo', vitorias_por_estilo: 2030 },
//   { _id: 'sambo', vitorias_por_estilo: 2028 },
//   { _id: 'jiu-jitsu', vitorias_por_estilo: 2026 },
//   { _id: 'karate', vitorias_por_estilo: 1960 },
//   { _id: 'taekwondo', vitorias_por_estilo: 1936 },
//   { _id: 'kickboxing', vitorias_por_estilo: 1904 },
//   { _id: 'boxing', vitorias_por_estilo: 1875 },
//   { _id: 'wrestling', vitorias_por_estilo: 1814 }



// 2. Consultamos el número de peleas que ha tenido cada luchador, ordenado de forma descendiente.
db.luchadores_agregados.aggregate([
  { $unwind: "$historial_combates" },
  { $group: {
      _id: "$fighter_name",
      total_peleas: { $sum: 1 }
    }},
  { $sort: { total_peleas: -1 } },
  { $project: { _id: 0, luchador: "$_id", total_peleas: 1 } },
  { $limit: 5 }
]).forEach(printjson);


// La salida da:
//   { fighter_name: 'Jim Miller', total_peleas: 37 },
//   { fighter_name: 'Donald Cerrone', total_peleas: 37 },
//   { fighter_name: 'Andrei Arlovski', total_peleas: 36 },
//   { fighter_name: 'Jeremy Stephens', total_peleas: 34 },
//   { fighter_name: 'Cheick Kongo', total_peleas: 33 },
//   { fighter_name: 'Demian Maia', total_peleas: 33 },


// 3. Luchadores con más de 5 victorias por sumisión.
db.luchadores_agregados.aggregate([
  { $unwind: "$historial_combates" },
  { $match: { "historial_combates.resultado": "win", "historial_combates.metodo_vitoria": /Submission/i } },
  { $group: { _id: "$fighter_name",vitorias_por_submision: { $sum: 1 }}},
  { $match: { vitorias_por_submision: { $gt: 5 } } },
  { $sort: { vitorias_por_submision: -1 } },
  { $project: { _id: 0, fighter_name: "$_id", vitorias_por_submision: 1 } },
  { $limit: 5 }
]).forEach(printjson);

// 4. Luchadores de Brasil o especialistas en jiu-jitsu.
db.luchadores_agregados.aggregate([
  { $match: { $or: [ { country: "Brazil" }, { estilos_de_loita: "jiu-jitsu" } ] } },
  { $project: { fighter_name: 1, country: 1, estilos_de_loita: 1, _id: 0 } },
  { $limit: 5 }
]).forEach(printjson);

// 5. Consultar luchadores cuyo nombre o apodo contenga "mar" (ignorando mayúsculas y minúsculas).
db.luchadores_agregados.find(
  { url: /mar/i },
  { _id: 0, fighter_name: 1, nickname: 1, url: 1 }
).limit(5).forEach(printjson);

// 6. Consulta luchas con 3 grados de separación
db.luchadores_agregados.aggregate([
  { $match: { fighter_name: "Conor McGregor" } },
  // ===== NIVEL 1 =====
  { $unwind: "$historial_combates" },
  {
    $lookup: {
      from: "luchadores_agregados",
      localField: "historial_combates.oponente_url",
      foreignField: "url",
      as: "l2"
    }
  },
  { $unwind: "$l2" },
  // ===== NIVEL 2 =====
  { $unwind: "$l2.historial_combates" },
  {
    $lookup: {
      from: "luchadores_agregados",
      localField: "l2.historial_combates.oponente_url",
      foreignField: "url",
      as: "l3"
    }
  },
  { $unwind: "$l3" },
  // ===== NIVEL 3 =====
  { $unwind: "$l3.historial_combates" },
  {
    $lookup: {
      from: "luchadores_agregados",
      localField: "l3.historial_combates.oponente_url",
      foreignField: "url",
      as: "l4"
    }
  },
  { $unwind: "$l4" },
  // ===== FILTROS =====
  {
    $match: {
      $expr: {
        $and: [
          { $ne: ["$url", "$l3.url"] },   // l1 != l3
          { $ne: ["$l2.url", "$l4.url"] } // l2 != l4
        ]
      }
    }
  },
  // ===== RESULTADO FINAL =====
  {
    $project: {
      _id: 0,
      loitador_inicial: "$fighter_name",
      opoñente_nivel_1: "$l2.fighter_name",
      opoñente_nivel_2: "$l3.fighter_name",
      opoñente_nivel_3: "$l4.fighter_name"
    }
  },
  { $limit: 20 }
]).forEach(printjson);


