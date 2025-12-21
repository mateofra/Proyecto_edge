// Cambiar a la base de datos config para ajustar chunksize
const configDB = db.getSiblingDB("config");
configDB.settings.updateOne(
  { _id: "chunksize" },
  { $set: { value: 1 } },
  { upsert: true }
);

// Volver a la base de datos principal
const dbLuchas = db.getSiblingDB("luchasDB");
dbLuchas.luchadores_agregados.createIndex({ url: "hashed" });

// Habilitar sharding
sh.enableSharding("luchasDB");

// Shardear colección
sh.shardCollection("luchasDB.luchadores_agregados", { url: "hashed" });

// Índices secundarios
dbLuchas.luchadores_agregados.createIndex({ fighter_name: 1 });
db.luchadores_agregados.createIndex({ "historial_combates.resultado": 1, "historial_combates.metodo_vitoria": 1 })
db.luchadores_agregados.createIndex({ estilos_de_loita: 1 })

print("Sharding e índices aplicados con éxito.");
