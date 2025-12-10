// Cambiar a la base de datos config para ajustar chunksize
const configDB = db.getSiblingDB("config");
configDB.settings.updateOne(
  { _id: "chunksize" },
  { $set: { value: 1 } },
  { upsert: true }
);

// Volver a la base de datos principal
const dbLuchas = db.getSiblingDB("luchasDB");

// 1️⃣ Crear índice para sharding
dbLuchas.luchadores_agregados.createIndex({ url: "hashed" });

// 2️⃣ Habilitar sharding
sh.enableSharding("luchasDB");

// 3️⃣ Shardear colección
sh.shardCollection("luchasDB.luchadores_agregados", { url: "hashed" });

// 4️⃣ Índices secundarios
dbLuchas.luchadores_agregados.createIndex({ fighter_name: 1 });
dbLuchas.luchadores_agregados.createIndex({ country: 1 });
dbLuchas.luchadores_agregados.createIndex({ "historial_combates.data_combate": -1 });

print("Sharding e índices aplicados con éxito.");
