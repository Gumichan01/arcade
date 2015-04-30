-- 2)  Donner les recettes du mois en cours, par type de prestation, en ordre croissant de recettes.
--select * as cout from projet.reservation natural join projet.salle_arcade where
/*
select distinct r.type, sum(duree * tarif_horaire) as recette from projet.reservation r inner join projet.salle_arcade s on r.arcade = s.idArcade
where extract(YEAR from current_date)=extract(YEAR from dateReservation)
and extract(MONTH from current_date)=extract(MONTH from dateReservation)
group by r.type
order by recette ASC;
*/


-- 3) Donner la liste des prestations n’ayant fait l’objet d’aucune réservation le mois dernier. 
/*
select distinct e.enumlabel from projet.reservation r, pg_type t inner join pg_enum e on t.oid = e.enumtypid 
where t.typname='type_r'
except
select distinct prestation::text from projet.reservation
where extract(YEAR from current_date)=extract(YEAR from dateReservation)
and (extract(MONTH from current_date)-1)=(extract(MONTH from dateReservation)-1);
*/


-- 5) En moyenne, combien de jours à l’avance les clients font-ils une réservation ?

--select avg(date_part('day', dateReservation::timestamp - dateDemandeReservation::timestamp)) as nombreJours from projet.reservation;






