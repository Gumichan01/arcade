

/*
	Script de création des tables

*/

-- On définit le format de date à la française
-- Sinon certaines insertions de dates peuvent échouer
set datestyle to DMY;


-- Création du schema si celui-ci n'existe pas
create schema if not exists projet;


-- Suppression des tables
drop table if exists projet.reservation cascade;
drop table if exists projet.possede cascade;
drop table if exists projet.salle_arcade cascade;
drop table if exists projet.client cascade;
drop table if exists projet.proprietaire cascade;

drop table if exists projet.jeu;
drop table if exists projet.adresse;


-- Suppression des types
drop type if exists genre_jeu;
drop type if exists type_prestation;


-- Création des types 
create type genre_jeu as enum ('SHOOTER','ACTION','COMBAT','BEATEMALL','AVENTURE');
create type type_prestation as enum ('ANNIV','MARIAGE','PROFESSIONNEL','SALON');



/**
	Les tables sans clé étrangère
**/


-- Table adresse
create table if not exists projet.adresse(

	id_lieu serial primary key,

	departement int not null,
	ville varchar(32) not null,
	rue varchar(128) not null
);


-- Table jeu
create table if not exists projet.jeu(

	id_jeu serial primary key,

	nomjeu varchar(64) not null,
	genre genre_jeu not null,
	annee int not null check (annee > 1970)

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
	numero_telephone int8 unique not null,
	courriel varchar(64) not null,

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
	prestation type_prestation not null,

	id_client integer references projet.client (id_pers),
	id_arcade integer references projet.salle_arcade (id_arcade),
	primary key (date_reservation,heure,id_client,id_arcade)

);


/**
	Insertion
**/

-- Insertions dans les adresses
insert into projet.adresse (departement,ville,rue) values
	(75,'PARIS','5, Boulevard des Italiens'),
	(75,'PARIS','12, Boulevard Voltaire'),
	(92,'CLICHY','7, Rue du Bac dAsnières'),
	(38,'ECHIROLLES','19, Avenue de Gruglisco'),
	(78,'ORGEVAL','Route des Quarante Sous');



-- Insertion dans les Clients
insert into projet.client (nom,prenom,numero_telephone,courriel,adresse) values
	('Miku','Gumichan01',0123456789,'gumichan01@mail.fr',3),
	('Hastune','Miku',0147586932,'mikuhatsune@mail.fr',2),
	('Megurine','Luka',0123156789,'megu.luka@mail.fr',2),
	('Pop','Merami',0147586432,'merapop@mail.fr',3);



-- Insertion dans les Propriétaires
insert into projet.proprietaire (nom,prenom,capital,numero_telephone,courriel,adresse) values
	('BOOLCENTER','-',200000.00,0100000000,'boolcenter-info@mail.com',5),
	('LTDM','-',1000000.00,0140130808,'ltdn-info@orange.fr',1);



-- Insertion dans les salles d'arcades
insert into projet.salle_arcade (nom,surface,tarif_horaire,machines,prix_jeton,capacite,heure_ouverture,heure_fermeture,proprietaire,adresse) values
	('LA TETE DANS LES NUAGES',1500, 50.00, 150,2.00, 800, '10:30', '2:00',2,1),
	('BOLLCENTER ECHIROLLES',2000,75.00,200,1.00,900,'10:00','01:00',1,4),
	('BOLLCENTER ORGEVAL',1750,60.00,150,2.00,800,'10:00','00:30',1,5);



-- Insertion des Jeux
insert into projet.jeu (nomjeu,genre,annee) values
	('DodonPachi','SHOOTER',1998),
	('DodonPachi DaiOujou','SHOOTER',2002),
	('Donkey Kong','AVENTURE',1981),
	('Metal Slug 2','ACTION',1998),
	('Street Fighter Alpha','COMBAT',1996),
	('Street of Rage','BEATEMALL',1991);



-- Insertion des couple Jeu/Salle
insert into projet.possede values
	(1,1),(1,2),(2,1),(2,6),
	(3,2),(1,3),(2,3),(1,4),
	(1,6),(3,6),(2,4),(3,3);



-- Insertion dans reservation
insert into projet.reservation (date_reservation,heure,duree,type, id_client,id_arcade) values
	('11/04/2015','20:00',8,'MARIAGE',4,3),
	('10/05/2015','10:00',8,'PROFESSIONNEL',1,1),
	('21/02/2014','18:00',4,'ANNIV',3,2),
	('14/03/2014','15:00',5,'ANNIV',3,3),
	('02/07/2014','09:00',10,'SALON',2,1),
	('03/03/2014','09:00',10,'SALON',2,1),
	('04/03/2014','09:00',10,'SALON',2,1),
	('05/03/2014','09:00',10,'SALON',2,1),
	('06/03/2014','09:00',10,'SALON',2,1);



-- Requete cadeau pour tester vite fait ^^
/*select projet.jeu.nomjeu 
	from projet.salle_arcade 
	natural join projet.possede 
	natural join projet.jeu 
	where projet.possede.id_arcade = 1 ;*/








