

/*
	Script de création des tables

*/

-- Création du schema si celui-ci n'existe pas
create schema if not exists projet;

-- Suppression des tables
drop table if exists projet.reservation;
drop table if exists projet.possede;
drop table if exists projet.salle_arcade cascade;
drop table if exists projet.client cascade;
drop table if exists projet.proprietaire cascade;

drop table if exists projet.type_reservation;
drop table if exists projet.jeu;
drop table if exists projet.adresse;


-- Suppression des types
drop type if exists genre_jeu;
drop type if exists type_r;


-- Création des types 
create type  genre_jeu as enum ('SHOOTER','ACTION','COMBAT','BEATEMALL','AVENTURE');

create type  type_r as enum ('ANNIV','MARIAGE','PROFESSIONNEL','SALON');



/**
	Les tables sans clé étrangère
**/


-- Table adresse
create table if not exists projet.adresse(

	id_lieu serial primary key,

	departement int unique not null,
	ville varchar(32) unique not null,
	rue varchar(128) not null
);


-- Table jeu
create table if not exists projet.jeu(

	id_jeu serial primary key,

	nomjeu varchar(64) not null,
	genre genre_jeu not null,
	annee date not null

);


-- Table type_reservation
create table if not exists projet.type_reservation(

	id_type serial primary key,

	type type_r not null

);




/**
	Les tables avec clé étrangère
**/

-- Table proprietaire
create table if not exists projet.proprietaire(

	id_pers serial primary key,

	nom varchar(32) not null,
	prenom varchar(32) not null,
	capital float not null check (capital >= 0.0),
	adresse integer references projet.adresse (id_lieu)

);



-- Table client
create table if not exists projet.client(

	id_pers serial primary key,

	nom varchar(32) not null,
	prenom varchar(32) not null,
	numero_telephone int8 unique not null,
	courriel varchar(64) not null,

	adresse integer references projet.adresse (id_lieu)

);



-- Table salle_arcade
create table if not exists projet.salle_arcade(

	id_arcade serial primary key,

	nom varchar(64) not null,
	surface integer not null check (surface > 0),
	tarif_horaire float not null check (tarif_horaire > 0.0),
	machines integer not null,
	prix_jeton float not null check (prix_jeton > 0.0),
	capacite integer not null,
	heure_ouverture time not null,
	heure_fermeture time not null,

	adresse integer references projet.adresse (id_lieu),
	proprietaire integer references projet.proprietaire (id_pers)

);




-- Table possede
create table if not exists projet.possede(

	id_arcade integer references projet.salle_arcade (id_arcade),
	id_jeu integer references projet.jeu (id_jeu),
	primary key (id_arcade,id_jeu)

);



-- Table reservation
create table if not exists projet.reservation(

	date_reservation date not null,
	heure time not null,
	duree integer not null check (duree > 0),

	id_type integer references projet.type_reservation (id_type),
	id_client integer references projet.client (id_pers),
	id_arcade integer references projet.salle_arcade (id_arcade),
	primary key (date_reservation,heure,id_client,id_arcade)

);




















