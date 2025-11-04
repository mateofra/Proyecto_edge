-- Eliminar tablas si ya existen (en el orden correcto por dependencias)
DROP TABLE IF EXISTS pelea;
DROP TABLE IF EXISTS evento;
DROP TABLE IF EXISTS luchadores;

-- Crear tabla de luchadores
CREATE TABLE luchadores (
    fighter_id SERIAL PRIMARY KEY,  -- url
    fighter_name VARCHAR(100) NOT NULL,
    birth_date DATE,
    age INT,
    alias TEXT,                 -- Apodo para luego hacer busquedas?
    country VARCHAR(50),        -- ¿añadir ciudad?
    height DECIMAL(4,2),        -- Ej: 1.85 (metros)
    weight DECIMAL(5,2),        -- Ej: 77.50 (kg)
    weight_class VARCHAR(50)
    associated_organisation TEXT -- Gym o equipo asociado 
);

-- Crear tabla de eventos
CREATE TABLE evento (
    event_id SERIAL PRIMARY KEY,  -- url?
    event_title VARCHAR(100) NOT NULL,
    organisation VARCHAR(100),
    date DATE,
    location VARCHAR(255)
);

-- Crear tabla de peleas
CREATE TABLE pelea (
    pelea_id SERIAL PRIMARY KEY,
    event_id INT REFERENCES evento(event_id) ON DELETE CASCADE,
    ord_fight INT,          -- Orden de la pelea en el evento (1 = Main Event, 2 = Co-Main Event, etc.) 
    fighter1_id INT REFERENCES luchadores(fighter_id) ON DELETE CASCADE,
    fighter2_id INT REFERENCES luchadores(fighter_id) ON DELETE CASCADE,
    fighter1_result VARCHAR(20),  -- el luchador 1 siempre es ganador a no ser que sea un empate o NC
    fighter2_result VARCHAR(20),
    win_method VARCHAR(100),
    win_details VARCHAR(255),
    referee VARCHAR(100),
    round INT,
    time VARCHAR(10)
);

