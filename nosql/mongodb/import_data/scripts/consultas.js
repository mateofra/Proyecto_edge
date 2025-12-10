// 1. Consultamos el número de victorias que se han obtenido por estilo, ordenado de forma descendente.
db.luchadores_agregados.aggregate([
  { $unwind: "$historial_combates" },
  { $unwind: "$estilos_de_loita" },
  { $match: { "historial_combates.resultado": "win" } },
  { $group: { 
      _id: "$estilos_de_loita", 
      vitorias_por_estilo: { $sum: 1 } 
  }},
  { $sort: { vitorias_por_estilo: -1 } }
])

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
  {
    $lookup: {
      from: "peleas",
      localField: "url",
      foreignField: "fighter1_url",
      as: "combates_f1"
    }
  },
  {
    $lookup: {
      from: "peleas",
      localField: "url",
      foreignField: "fighter2_url",
      as: "combates_f2"
    }
  },
  {
    $addFields: {
      total_peleas: { $add: [ { $size: "$combates_f1" }, { $size: "$combates_f2" } ] }
    }
  },
  {
    $project: {
      _id: 0,
      fighter_name: 1,
      total_peleas: 1
    }
  },
      {
    $sort: { total_peleas: -1 }
  }

]);

// La salida da:
//   { fighter_name: 'Jim Miller', total_peleas: 37 },
//   { fighter_name: 'Donald Cerrone', total_peleas: 37 },
//   { fighter_name: 'Andrei Arlovski', total_peleas: 36 },
//   { fighter_name: 'Jeremy Stephens', total_peleas: 34 },
//   { fighter_name: 'Cheick Kongo', total_peleas: 33 },
//   { fighter_name: 'Demian Maia', total_peleas: 33 },
//   { fighter_name: 'Diego Sanchez', total_peleas: 32 },
//   { fighter_name: 'Tito Ortiz', total_peleas: 31 },
//   { fighter_name: 'Rafael dos Anjos', total_peleas: 30 },
//   { fighter_name: 'Frank Mir', total_peleas: 30 },
//   { fighter_name: 'Clay Guida', total_peleas: 30 },
//   { fighter_name: 'Ben Saunders', total_peleas: 29 },
//   { fighter_name: 'Lyoto Machida', total_peleas: 29 },
//   { fighter_name: 'Michael Bisping', total_peleas: 29 },
//   { fighter_name: 'Gleison Tibau', total_peleas: 28 },
//   { fighter_name: 'Charles Oliveira', total_peleas: 28 },
//   { fighter_name: 'Matt Brown', total_peleas: 28 },
//   { fighter_name: 'Frankie Edgar', total_peleas: 28 },
//   { fighter_name: 'Ryan Bader', total_peleas: 28 },
//   { fighter_name: 'Thiago Alves', total_peleas: 27 }