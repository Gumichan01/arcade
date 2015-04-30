/*
	Script de création des tables

*/

-- On définit le format de date à la française
-- Sinon certaines insertions de dates peuvent échouer
set datestyle to DMY;

-- Création du schema si celui-ci n'existe pas
create schema if not exists projet;

-- Suppression des tables
drop table if exists projet.proprietaire cascade;
drop table if exists projet.client cascade;
drop table if exists projet.salle_arcade cascade;
drop table if exists projet.possede cascade;
drop table if exists projet.reservation cascade;
drop table if exists projet.adresse;
drop table if exists projet.jeu;

-- Suppression des types
drop type if exists genre_jeu;
drop type if exists type_r cascade;

-- Suppression des functions
drop function if exists insert_reservation(client integer, arcade integer, dateDemandeReservation date, dateReservation date, heure time, duree integer, prestation type_r);
drop function if exists cumul_reservation();

-- Suppression trigger
drop trigger if exists test_cumul_reservation on projet.reservation;

-- Création des types 
create or replace type  genre_jeu as enum ('SHOOTER','ACTION','COMBAT','BEATEMALL','AVENTURE');
create or replace type  type_r as enum ('ANNIV','MARIAGE','PROFESSIONNEL','SALON');

-- Création trigger
create or replace test_cumul_reservation before insert on projet.reservation for each row execute procedure cumul_reservation();

/**
	Les tables sans clé étrangère
**/

-- Table adresse
create table if not exists projet.adresse(
	idLieu serial,
	departement int not null,
	ville varchar(32) not null,
	rue varchar(128) not null,
	constraint pk_idLieu primary key (idLieu)
);

-- Table jeu
create table if not exists projet.jeu(
	idJeu serial,
	nomjeu varchar(64) not null,
	genre genre_jeu not null,
	annee int not null,
	constraint pk_idJeu primary key (idJeu),
	constraint ck_annee check (annee > 1970)
);


/**
	Les tables avec clé étrangère
**/

-- Table proprietaire
create table if not exists projet.proprietaire(
	idProprietaire serial,
	nom varchar(32) not null,
	prenom varchar(32) not null,
	capital float not null,
	numero_telephone int8 unique not null,
	courriel varchar(64) not null,
	adresse integer,
	constraint pk_idProprietaire primary key (idProprietaire),
	constraint ck_capital check (capital >= 0.0),
	constraint fk_adresse_idLieu foreign key (adresse) references projet.adresse (idLieu)
);

-- Table client
create table if not exists projet.client(
	idClient serial,
	nom varchar(32) not null,
	prenom varchar(32) not null,
	numero_telephone int8 unique not null,
	courriel varchar(64) unique not null,
	adresse integer,
	constraint pk_idClient primary key (idClient),
	constraint fk_adresse_idLieu foreign key (adresse) references projet.adresse (idLieu)
);

-- Table salle_arcade
create table if not exists projet.salle_arcade(
	idArcade serial,
	nom varchar(64) not null,
	surface integer not null,
	tarif_horaire float not null,
	machines integer not null,
	prix_jeton float not null,
	capacite integer not null,
	heure_ouverture time not null,
	heure_fermeture time not null,
	adresse integer,
	proprietaire integer,
	constraint pk_idArcade primary key (idArcade),
	constraint ck_surface check (surface > 0),
	constraint ck_tarif_horaire check (tarif_horaire >= 0.0),
	constraint ck_prix_jeton check (prix_jeton >= 0.0),
	constraint fk_adresse_idLieu foreign key (adresse) references projet.adresse (idLieu),
	constraint fk_proprietaire_idProprietaire foreign key (proprietaire) references projet.proprietaire (idProprietaire)
);

-- Table possede
create table if not exists projet.possede(
	arcade integer,
	jeu integer,
	constraint pk_arcade_jeu primary key (arcade, jeu),
	constraint fk_arcade_idArcade foreign key (arcade) references projet.salle_arcade (idArcade),
	constraint fk_jeu_idJeu foreign key (jeu) references projet.jeu (idJeu)
);

-- Table reservation
create table if not exists projet.reservation(
	client integer,
	arcade integer,
	dateDemandeReservation date not null,
	dateReservation date not null,
	heure time not null,
	duree integer not null,
	prestation type_r not null,
	constraint pk_client_arcade_dateReservation primary key (client, arcade, dateReservation),
	constraint ck_duree check (duree > 0),
	constraint fk_client_idClient foreign key (client) references projet.client (idClient),
	constraint fk_arcade_idArcade foreign key (arcade) references projet.salle_arcade (idArcade)
);


/**

	Fonctions - Triggers

**/

create or replace function insert_reservation(client integer, arcade integer, dateDemandeReservation date, dateReservation date, heure time, duree integer, prestation type_r) returns void as $$
begin
	if(client <= 0 or arcade <= 0) then
		raise notice 'valeur de client=% arcade=%', client, arcade;
		return;
	end if;
	if(dateDemandeReservation >= dateReservation) then
		raise notice 'Date de la réservation antérieur à celle de la demande.';
		return;
	end if;
	insert into projet.reservation values(client, arcade, dateDemandeReservation, dateReservation, heure, duree, prestation);
end;
$$ language 'plpgsql';

/* TODO : duree en minute our heure ?
create or replace function cumul_reservation() returns trigger as $$
begin
	if(old.dateReservation=new.dateReservation)
		if(old.heure >= new heure)
		
	select * where old.dateReservation=new.dateReservation and  
end;
$$ language 'plpgsql';*/


/**
	Insertion
**/

-- Insertions dans les adresses
insert into projet.adresse (departement, ville, rue) values
	(75, 'PARIS', '5, Boulevard des Italiens'),
	(75, 'PARIS', '12, Boulevard Voltaire'),
	(92, 'CLICHY', '7, Rue du Bac dAsnières'),
	(38, 'ECHIROLLES', '19, Avenue de Gruglisco'),
	(78, 'ORGEVAL', 'Route des Quarante Sous');

-- Insertion dans les Clients
insert into projet.client (nom, prenom, numero_telephone, courriel, adresse) values
	('Miku', 'Gumichan01', 0123456789, 'gumichan01@mail.fr', 3),
	('Hastune', 'Miku', 0147586932, 'mikuhatsune@mail.fr', 2),
	('Megurine', 'Luka', 0123156789, 'megu.luka@mail.fr', 2),
	('Pop', 'Merami', 0147586432, 'merapop@mail.fr', 3);

-- Insertion dans les Propriétaires
insert into projet.proprietaire (nom, prenom, capital, numero_telephone, courriel, adresse) values
	('BOOLCENTER', '-', 200000.00, 0100000000, 'boolcenter-info@mail.com', 5),
	('LTDM', '-', 1000000.00, 0140130808, 'ltdn-info@orange.fr', 1);


-- Insertion dans les salles d'arcades
insert into projet.salle_arcade (nom, surface, tarif_horaire, machines, prix_jeton, capacite, heure_ouverture, heure_fermeture, proprietaire, adresse) values
	('LA TETE DANS LES NUAGES', 1500, 50.00, 150, 2.00, 800, '10:30', '2:00', 2, 1),
	('BOLLCENTER ECHIROLLES', 2000, 75.00, 200, 1.00, 900, '10:00', '01:00', 1, 4),
	('BOLLCENTER ORGEVAL', 1750, 60.00, 150, 2.00, 800, '10:00', '00:30', 1, 5);

-- Insertion des Jeux
insert into projet.jeu (nomjeu, genre, annee) values
	('DodonPachi', 'SHOOTER', 1998),
	('DodonPachi DaiOujou', 'SHOOTER', 2002),
	('Donkey Kong', 'AVENTURE', 1981),
	('Metal Slug 2', 'ACTION', 1998),
	('Street Fighter Alpha', 'COMBAT', 1996),
	('Street of Rage', 'BEATEMALL', 1991);

-- Insertion des couple Jeu/Salle
insert into projet.possede values
	(1,1),(1,2),(2,1),(2,6),
	(3,2),(1,3),(2,3),(1,4),
	(1,6),(3,6),(2,4),(3,3);

-- Insertion dans reservation

select insert_reservation(4, 3, '27/03/2015', '11/04/2015', '20:00:00', 8, 'MARIAGE');
select insert_reservation(1, 1, '04/05/2015', '10/05/2015', '10:00:00', 8, 'PROFESSIONNEL');
select insert_reservation(3, 2, '18/02/2014', '21/02/2014', '18:00:00', 4, 'ANNIV');
select insert_reservation(3, 3, '11/03/2014', '14/03/2014', '15:00:00', 5, 'ANNIV');
select insert_reservation(2, 1, '01/07/2014', '02/07/2014', '09:00:00', 10, 'SALON');
select insert_reservation(2, 1, '02/03/2014', '03/03/2014', '09:00:00', 10, 'SALON');
select insert_reservation(2, 1, '01/03/2014', '04/03/2014', '09:00:00', 10, 'SALON');
select insert_reservation(2, 1, '11/02/2014', '05/03/2014', '09:00:00', 10, 'SALON');
select insert_reservation(2, 1, '05/04/2015', '06/04/2015', '09:00:00', 10, 'SALON');
select insert_reservation(2, 1, '06/04/2015', '05/04/2015', '09:00:00', 10, 'SALON');

-- Requete cadeau pour tester vite fait ^^
/*select projet.jeu.nomjeu 
	from projet.salle_arcade 
	natural join projet.possede 
	natural join projet.jeu 
	where projet.possede.id_arcade = 1 ;*/

--select * from projet.reservation;
--delete from projet.reservation where client=2 and arcade=1 and date_reservation=dateDemandeReservation;
--select * from projet.reservation;