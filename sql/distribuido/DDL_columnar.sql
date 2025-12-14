DROP TABLE IF EXISTS estilos_luchadores;
DROP TABLE IF EXISTS estilos;
DROP TABLE IF EXISTS pelea;
DROP TABLE IF EXISTS evento;
DROP TABLE IF EXISTS luchadores;

CREATE TABLE luchadores (
    url TEXT PRIMARY KEY,
    fighter_name VARCHAR(100) NOT NULL,
    nickname VARCHAR(100),
    birth_date DATE,
    age INT,
    country VARCHAR(100),
    height_cm NUMERIC(5,2),
    weight_kg NUMERIC(5,2),
    association VARCHAR(100),
    weight_class VARCHAR(50),
    wins INT,
    losses INT
) USING columnar;

-- PELEA (COLUMNA)
CREATE TABLE pelea (
    pelea_id INT,
    event_id TEXT, -- NO REFERENCES
    match_nr INT,
    fighter1_url TEXT, -- NO REFERENCES
    fighter2_url TEXT,
    results VARCHAR(50),
    win_method VARCHAR(100),
    win_details VARCHAR(255),
    referee VARCHAR(100),
    round INT,
    time VARCHAR(10),
    PRIMARY KEY (fighter1_url, event_id, match_nr)
) USING columnar;

-- ESTILOS (FILA)
CREATE table estilos (
	id SERIAL primary key,
	nombre VARCHAR(50));

-- EVENTO (FILA)
CREATE TABLE evento (
    event_id TEXT PRIMARY KEY,
    event_title VARCHAR(100) NOT NULL,
    organisation VARCHAR(100),
    date DATE,
    location VARCHAR(255),
    latitud NUMERIC(10, 7),
    longitud NUMERIC(11, 8)
);

-- ESTILOS_LUCHADORES (FILA)
create table estilos_luchadores (
	luchador_id TEXT, -- NO REFERENCES
	estilo_id INT, -- NO REFERENCES
	PRIMARY KEY (luchador_id, estilo_id));