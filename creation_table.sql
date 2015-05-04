-- ----------------------------------------- --
-- BD. ARCADE - Université Diderot-Paris7	 --
-- auteurs : DIBO Pierre - JEAN-PIERRE Luxon --						 --
-- date création : 2015-04-26				 --
-- ----------------------------------------- --


-- Suppression du schema
drop schema if exists projet cascade;

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
drop table if exists projet.facture;
drop table if exists projet.adresse;
drop table if exists projet.jeu;

-- Suppression des types
drop type if exists genre_jeu;
drop type if exists type_r cascade;

-- Création des types 
create type genre_jeu as enum ('SHOOTER','ACTION','COMBAT','BEATEMALL','AVENTURE');
create type type_r as enum ('ANNIV','MARIAGE','PROFESSIONNEL','SALON');

-- Suppression des functions
drop function if exists create_facture(integer, integer, integer, type_r);
drop function if exists insert_reservation(integer, integer, date, date, integer, time, integer, type_r, integer);


/**
	Creation des tables
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


-- Table facture
create table if not exists projet.facture(
	idFacture serial,
	jeton_shooter integer,
	jeton_action integer,
	jeton_combat integer,
	jeton_beatemall integer,
	jeton_aventure integer,
	prix_facturation float,
	constraint pk_idFacture primary key (idFacture)
);


-- Table reservation
create table if not exists projet.reservation(
	client integer,
	arcade integer,
	facture integer,
	dateDemandeReservation date not null,
	dateReservation date,
	nombreDePersonne integer not null,
	heure time not null,
	duree integer not null,
	prestation type_r not null,
	nombreJeton integer not null,
	constraint pk_client_arcade_dateReservation primary key (client, arcade, facture, dateReservation),
	constraint ck_nombreDePersonne check (nombreDePersonne > 0),
	constraint ck_duree check (duree > 0),
	constraint fk_client_idClient foreign key (client) references projet.client (idClient),
	constraint fk_arcade_idArcade foreign key (arcade) references projet.salle_arcade (idArcade),
	constraint fk_facture_idFacture foreign key (facture) references projet.facture (idFacture) 
);



/**
	Creation des fonctions et triggers
**/


-- Function create_facture
create or replace function create_facture(arcade in integer, duree in integer, nb_jeton in integer, prestation in type_r) returns integer as $$
declare
	id integer;
	coût_heure float;
	coût_jeton float;
	coût_total float;
	pourcent float;
	shooter integer;
	action_ integer;
	combat integer;
	beatemall integer;
	aventure integer;
begin
	if(nb_jeton >= 100) then
		select (nb_jeton / 100) into pourcent;
	else
		select (nb_jeton / 10) into pourcent;
	end if;
	
	select tarif_horaire from projet.salle_arcade where idArcade=arcade into coût_heure;
	select prix_jeton from projet.salle_arcade where idArcade=arcade into coût_jeton;
	select (coût_heure * duree) + (coût_jeton + nb_jeton) into coût_total;
	
	case when prestation = 'ANNIV' then
		select 35 * pourcent into shooter;
		select 25 * pourcent into action_;
		select 25 * pourcent into combat;
		select 10 * pourcent into beatemall;
		select 5 * pourcent into aventure;
	when prestation = 'MARIAGE' then
		select 20 * pourcent into shooter;
		select 40 * pourcent into action_;
		select 20 * pourcent into combat;
		select 12 * pourcent into beatemall;
		select 8 * pourcent into aventure;
	when prestation = 'PROFESSIONNEL' then
		select 20 * pourcent into shooter;
		select 20 * pourcent into action_;
		select 20 * pourcent into combat;
		select 20 * pourcent into beatemall;
		select 20 * pourcent into aventure;
	when prestation = 'SALON' then
		select 15 * pourcent into shooter;
		select 15 * pourcent into action_;
		select 30 * pourcent into combat;
		select 30 * pourcent into beatemall;
		select 10 * pourcent into aventure;
	else
		raise exception 'prestation inconnu';
		return -1;
	end case;
	
	insert into projet.facture(jeton_shooter, jeton_action, jeton_combat, jeton_beatemall, jeton_aventure, prix_facturation) 
	values(shooter, action_, combat, beatemall, aventure, coût_total);
	select count(*) from projet.facture into id;

	return id;
end;
$$ language 'plpgsql';


-- Function insert_reservation
create or replace function insert_reservation(client in integer, arcade in integer, dateDemandeReservation in date, dateReservation in date, nombreDePersonne in integer, heure in time, duree in integer, prestation in type_r, nombreJeton in integer) returns void as $$
declare
	nb integer;
	nb_row integer;
	id_facture  integer;
begin
	select capacite from projet.salle_arcade where idArcade=arcade into nb;
	
	if(client <= 0 or arcade <= 0) then
		raise notice 'valeur de client=% arcade=%', client, arcade;
		return;
	end if;

	
	if(dateDemandeReservation >= dateReservation) then
		raise notice 'Date de la réservation antérieur à celle de la demande.';
		return;
	end if;
	
	if(dateDemandeReservation > current_date) then
		raise notice 'Date actuel antérieur à celle de la demande de reservation.';
		return;
	end if;
	
	
	select count(r.*) from projet.reservation r where r.arcade=$2 
	and r.dateReservation=$4
	and $6 between r.heure and r.heure + cast(r.duree || ' hours' as interval)
	and $6 + cast($7 || ' hours' as interval) between r.heure and r.heure + cast(r.duree || ' hours' as interval)
	into nb_row;
	
	if(nb_row = 1) then
		raise notice 'Ne peut réserver sur une plage horaire déjà occupée.';
		return;
	end if;
	
	if(nb < nombreDePersonne) then
		raise notice 'Nombre de personnes supérieur à la capacité de la salle.';
		return;
	end if;

	if(nombreJeton <= 0) then
		raise notice 'Nombre de jeton(s) % invalide.', nombreJeton;
		return;
	end if;
	
	select create_facture(arcade, duree, nombreJeton, prestation) into id_facture;
	
	if(id_facture = -1) then
		raise exception 'Facturation impossible';
		return;
	end if;
	
	insert into projet.reservation values(client, arcade, id_facture, dateDemandeReservation, dateReservation, 
	nombreDePersonne, heure, duree, prestation, nombreJeton);
end;
$$ language 'plpgsql';


/**
	Insertion valeurs dans les tables
**/


-- Insertions dans les adresses
insert into projet.adresse (departement, ville, rue) values
	(75, 'PARIS', '5, Boulevard des Italiens'),
	(75, 'PARIS', '12, Boulevard Voltaire'),
	(92, 'CLICHY', '7, Rue du Bac d''Asnières'),
	(38, 'ECHIROLLES', '19, Avenue de Gruglisco'),
	(78, 'ORGEVAL', 'Route des Quarante Sous');


-- Insertion dans les Clients
insert into projet.client (nom, prenom, numero_telephone, courriel, adresse) values
	('Miku', 'Gumichan01', 0123456789, 'gumichan01@mail.fr', 1),
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
	('BOLLCENTER ECHIROLLES', 2000, 75.00, 200, 1.00, 900, '10:00', '01:00', 1, 2),
	('BOLLCENTER ORGEVAL', 1750, 60.00, 150, 2.00, 800, '10:00', '00:30', 1, 4);


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
select insert_reservation(4, 3, '03/01/2015', '11/01/2015', 69, '20:00:00', 8, 'PROFESSIONNEL', 1507);
select insert_reservation(4, 3, '27/03/2015', '11/04/2015', 113, '20:00:00', 8, 'MARIAGE', 2008);
select insert_reservation(1, 1, '02/05/2015', '10/05/2015', 50, '10:00:00', 8, 'PROFESSIONNEL', 1560);
select insert_reservation(3, 2, '18/02/2014', '21/02/2014', 20, '18:00:00', 4, 'ANNIV', 900);
select insert_reservation(3, 3, '11/03/2014', '14/03/2014', 5, '08:00:00', 1, 'ANNIV', 600);
select insert_reservation(2, 1, '01/07/2014', '02/07/2014', 300, '09:00:00', 10, 'SALON', 12033);
select insert_reservation(2, 1, '02/03/2014', '03/03/2014', 444, '09:00:00', 10, 'SALON', 14571);
select insert_reservation(2, 1, '01/03/2014', '04/03/2014', 800, '09:00:00', 10, 'SALON', 29585);
select insert_reservation(2, 1, '27/01/2014', '05/03/2014', 712, '09:00:00', 10, 'SALON', 2264);
select insert_reservation(2, 1, '03/05/2015', '19/05/2015', 155, '09:00:00', 10, 'SALON', 8716);
select insert_reservation(2, 1, '08/04/2014', '10/04/2014', 477, '09:00:00', 10, 'SALON', 11111);
select insert_reservation(2, 1, '03/05/2015', '09/10/2016', 711, '09:00:00', 10, 'SALON', 31299);
select insert_reservation(3, 1, '03/05/2015', '24/04/2016', 711, '10:00:00', 10, 'SALON', 31299 );






