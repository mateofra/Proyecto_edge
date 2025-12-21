const db = db.getSiblingDB("luchasDB");

db.luchadores.aggregate([

  {
    $lookup: {
      from: "estilos_luchadores",
      localField: "url",
      foreignField: "luchador_id",
      as: "estilos_rel"
    }
  },

  {
    $lookup: {
      from: "estilos",
      localField: "estilos_rel.estilo_id",
      foreignField: "id",
      as: "estilos_nombres"
    }
  },
  
  {
    $addFields: {
      estilos_de_loita: {
        $map: {
          input: "$estilos_nombres",
          as: "e",
          in: "$$e.nombre"
        }
      }
    }
  },

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
      historial_combates: {
        $concatArrays: [
          {
            $map: {
              input: "$combates_f1",
              as: "c",
              in: {
                evento_titulo: "$$c.event_id",
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
                evento_titulo: "$$c.event_id",
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

  {
    $out: "luchadores_agregados"
  }

]);


db.estilos.drop();
db.estilos_luchadores.drop();
db.peleas.drop();
db.eventos.drop();
db.luchadores.drop();
