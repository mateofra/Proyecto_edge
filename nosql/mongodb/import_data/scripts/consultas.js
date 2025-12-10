// 1. Consultamos el número de victorias que se han obtenido por estilo, ordenado de forma descendente.
const dbLuchas = db.getSiblingDB("luchasDB");

const resultado = dbLuchas.luchadores_agregados.aggregate([
  // Desenrollar historial_combates
  { $unwind: "$historial_combates" },
  // Filtrar solo combates ganados
  { $match: { "historial_combates.resultado": "win" } },
  // Desenrollar estilos_de_loita
  { $unwind: "$estilos_de_loita" },
  // Agrupar por estilo y contar victorias
  {
    $group: {
      _id: "$estilos_de_loita",
      vitorias_por_estilo: { $sum: 1 }
    }
  },
  // Ordenar descendente por número de victorias
  { $sort: { vitorias_por_estilo: -1 } }
]);

// Mostrar resultados
resultado.forEach(doc => printjson(doc));
