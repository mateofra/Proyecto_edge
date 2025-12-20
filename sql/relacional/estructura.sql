-- eliminar tablas si ya existen (en el orden correcto por dependencias)
drop table if exists estilos_luchadores;
drop table if exists estilos;
drop table if exists pelea;
drop table if exists evento;
drop table if exists luchadores;

create table luchadores (
    url text primary key,
    fighter_name varchar(100) not null,
    nickname varchar(100),
    birth_date date,
    age int,
    country varchar(100),
    height_cm numeric(5,2),
    weight_kg numeric(5,2),
    association varchar(100),
    weight_class varchar(50),
    wins int,
    losses int
);

create table estilos (
    id serial primary key,
    nombre varchar(50)
);

create table estilos_luchadores (
    luchador_id text references luchadores(url) on delete cascade,
    estilo_id int references estilos(id) on delete cascade,
    primary key (luchador_id, estilo_id)
);

create table evento (
    event_id text primary key,  
    event_title varchar(100) not null,
    organisation varchar(100),
    date date,
    location varchar(255),
    latitud numeric(10, 7),
    longitud numeric(11, 8)
);

create table pelea (
    pelea_id serial primary key,
    event_id text references evento(event_id) on delete cascade,
    match_nr int,          
    fighter1_url text references luchadores(url) on delete cascade,
    fighter2_url text references luchadores(url) on delete cascade,
    results varchar(50),
    win_method varchar(100),
    win_details varchar(255),
    referee varchar(100),
    round int,
    time varchar(10)
);