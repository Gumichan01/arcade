
/* Requêtes imposées */

﻿-- 1)Quel a été le taux d’occupation d’un lieu en 2014 ?
\echo "Requete 1"
deallocate taux_occupation;
prepare taux_occupation(void) as
select idArcade, ((cast(sum(nombreDePersonne) as float) / cast(sum(capacite) as float)) * 100) as taux_occupation
from projet.reservation natural join projet.salle_arcade 
where dateReservation between '01/01/2014' and '31/12/2014'
group by idArcade
order by idArcade ASC;

execute taux_occupation(null);


-- 2)  Donner les recettes du mois en cours, par type de prestation, en ordre croissant de recettes.
\echo "Requete 2"
deallocate recette_mois_courant;
prepare recette_mois_courant(void) as
select r.prestation, sum(f.prix_facturation) as recette_du_mois 
from projet.reservation r join projet.facture f on r.facture=f.idFacture
where extract(year from current_date)=extract(year from dateReservation)
and extract(month from current_date)=extract(month from dateReservation)
group by r.prestation
order by recette_du_mois asc;

execute recette_mois_courant(null);


-- 3) Donner la liste des prestations n’ayant fait l’objet d’aucune réservation le mois dernier.
\echo "Requete 3"
deallocate prestation_sans_reservation_precedent_mois;
prepare prestation_sans_reservation_precedent_mois(void) as
select e.enumlabel as prestation_sans_reservation_mois_dernier
from projet.reservation r, pg_type t inner join pg_enum e on t.oid = e.enumtypid 
where t.typname='type_r'
except
select distinct prestation::text from projet.reservation
where extract(year from current_date)=extract(year from dateReservation)
and (extract(month from current_date)-1)=(extract(month from dateReservation)-1);

execute prestation_sans_reservation_precedent_mois(null);


-- 4) Quelle a été la journée la plus occupée de chaque semaine, pour les 8 dernières semaines ? Comptez la durée des réservations et non pas le nombre de réservations par jour.
\echo "Requete 4"
deallocate journée_la_plus_occupée;
prepare journée_la_plus_occupée(void) as
(select dateReservation as occupation_journées, sum(duree) as duree_en_heure
from projet.reservation 
where dateReservation <= current_date and dateReservation >= (current_date - integer '56')
group by dateReservation
order by duree_en_heure desc);

execute journée_la_plus_occupée(null);


--select * from projet.reservation where dateReservation='13/04/2015';

-- 5) En moyenne, combien de jours à l’avance les clients font-ils une réservation ?
\echo "Requete 5"
deallocate moyenne_jours_en_avance;
prepare moyenne_jours_en_avance(void) as
select avg(date_part('day', dateReservation::timestamp - dateDemandeReservation::timestamp)) as moyenne_jours_en_avance_pourcent 
from projet.reservation;

execute moyenne_jours_en_avance(null);


-- 6) Pour chaque mois de 2014, identifiez le client ayant le plus dépensé sur le site.
\echo "Requete 6"
deallocate client_depense_mois_2014;
prepare client_depense_mois_2014(void) as
select r.arcade, c.idClient, extract(month from r.dateReservation) as mois_2014, sum(f.prix_facturation) as depense
from projet.client c
inner join projet.reservation r on c.idCLient=r.client
inner join projet.facture f on r.facture=f.idFacture
where r.dateReservation between '01/01/2014' and '31/12/2014'
group by r.arcade, c.idClient, mois_2014
order by depense desc;

execute client_depense_mois_2014(null);


/* Requetes inventées */

-- 1) Quels sont les propriétaire dont le chiffre d'affaire de l'année 2014 dépasse 5% du capital de départ ?

\echo "Requete invente 1"
deallocate requete_inventée_1;
prepare requete_inventée_1(void) as
select proprietaire, p_ca.*, capital 
from projet.proprietaire join projet.salle_arcade 
on proprietaire=idProprietaire 
full outer join (select arcade, sum(prix_facturation) as chiffre_affaire 
from projet.reservation 
right outer join projet.facture 
on facture=idFacture
where dateReservation between '01/01/2014' and '31/12/2014'
group by arcade
order by chiffre_affaire desc) p_ca
on idArcade=p_ca.arcade
where  p_ca.chiffre_affaire >= capital / 20;

execute requete_inventée_1(null);


-- 2) Quel est le client ayant le plus dépensé en 2014 dont l'adresse de la salle d'arcade est la même que son lieu d'habitation ?

\echo "Requete invente 2"
deallocate requete_inventée_2;
prepare requete_inventée_2(void) as
select client, arcade, sum(prix_facturation) as depense from projet.facture join projet.reservation on facture=idFacture
where dateReservation between '01/01/2014' and '31/12/2014'
group by client, arcade
having (select adresse from projet.client where idClient=client)=(select adresse from projet.salle_arcade where idArcade=arcade)
order by depense desc;

execute requete_inventée_2(null);


-- 3) Quelle sont les jeux possedés par la salle d'arcade ayant le plus de reservations dans l'année ?
\echo "Requete invente 3"


-- 4) Lister les salles d'arcade avec leur nom et le nombre de reservation.
\echo "Requete invente 4"












