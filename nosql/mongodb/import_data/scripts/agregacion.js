db.luchadores.aggregate([

  // 1. Agregar estilos
  {
    $lookup: {
      from: "estilos_luchadores",
      localField: "url",
      foreignField: "luchador_id",
      as: "estilos_rel"
    }
  },
  {
    $addFields: {
      estilos_de_loita: {
        $map: {
          input: "$estilos_rel",
          as: "e",
          in: "$$e.nombre"
        }
      }
    }
  },

  // 2. Agregar combates donde el luchador es fighter1
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

  // 3. Unir combates y transformar resultados
  {
    $addFields: {
      historial_combates: {
        $concatArrays: [
          {
            $map: {
              input: "$combates_f1",
              as: "c",
              in: {
                evento_titulo: "$$c.event_title",
                data_combate: "$$c.date",
                oponente_nome: "$$c.fighter2_name",
                oponente_url: "$$c.fighter2_url",
                resultado: "$$c.results",
                metodo_vitoria: "$$c.win_method"
              }
            }
          },
          {
            $map: {
              input: "$combates_f2",
              as: "c",
              in: {
                evento_titulo: "$$c.event_title",
                data_combate: "$$c.date",
                oponente_nome: "$$c.fighter1_name",
                oponente_url: "$$c.fighter1_url",
                resultado: {
                  $switch: {
                    branches: [
                      { case: { $eq: ["$$c.results", "win"] }, then: "loss" },
                      { case: { $eq: ["$$c.results", "loss"] }, then: "win" }
                    ],
                    default: "$$c.results"
                  }
                },
                metodo_vitoria: "$$c.win_method"
              }
            }
          }
        ]
      }
    }
  },

  // 4. Ordenar combates por fecha descendente
  {
    $addFields: {
      historial_combates: {
        $sortArray: {
          input: "$historial_combates",
          sortBy: { data_combate: -1 }
        }
      }
    }
  },

  // 5. Limitar campos finales
  {
    $project: {
      url: 1,
      fighter_name: 1,
      nickname: 1,
      birth_date: 1,
      country: 1,
      estilos_de_loita: 1,
      historial_combates: 1
    }
  },

  // 6. Guardar resultados
  {
    $out: "luchadores_agregados"
  }

]);
