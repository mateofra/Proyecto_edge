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
    losses INT);


CREATE table estilos (
	id SERIAL primary key,
	nombre VARCHAR(50));

create table estilos_luchadores (
	luchador_id TEXT REFERENCES luchadores(url) ON DELETE CASCADE,
	estilo_id INT REFERENCES estilos(id) ON DELETE CASCADE,
	PRIMARY KEY (luchador_id, estilo_id));

CREATE TABLE evento (
    event_id TEXT PRIMARY KEY,  
    event_title VARCHAR(100) NOT NULL,
    organisation VARCHAR(100),
    date DATE,
    location VARCHAR(255),
    latitud NUMERIC(10, 7),
    longitud NUMERIC(11, 8)
);

CREATE TABLE pelea (
    -- Eliminamos SERIAL PRIMARY KEY en pelea_id
    pelea_id INT,
    event_id TEXT REFERENCES evento(event_id) ON DELETE CASCADE,
    match_nr INT,          
    fighter1_url TEXT REFERENCES luchadores(url) ON DELETE CASCADE,
    fighter2_url TEXT, 
    results VARCHAR(50),
    win_method VARCHAR(100),
    win_details VARCHAR(255),
    referee VARCHAR(100),
    round INT,
    time VARCHAR(10),
    -- NUEVA CLAVE PRIMARIA COMPUESTA que incluye la columna de distribución (fighter1_url)
    PRIMARY KEY (fighter1_url, event_id, match_nr) 
);