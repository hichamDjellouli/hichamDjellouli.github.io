--
-- PostgreSQL database dump
--

-- Dumped from database version 13.0
-- Dumped by pg_dump version 13.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: beneficiaire_before_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.beneficiaire_before_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

 BEGIN
      NEW.nin = REPLACE(NEW.nin, ' ', '');
      NEW.nom = TRIM(initcap(NEW.nom));
      NEW.nom_jeune_fille = TRIM(initcap(NEW.nom_jeune_fille));
      NEW.prenom = TRIM(initcap(NEW.prenom));
      NEW.sexe = CASE WHEN (UPPER(TRIM(NEW.sexe))='F') THEN 'F' ELSE 'M' END;
      NEW.type_date_naiss = CASE WHEN (UPPER(TRIM(NEW.type_date_naiss))='P') THEN 'P' ELSE 'N' END;
      NEW.lieu_naiss = TRIM(initcap(NEW.lieu_naiss));
      NEW.situation_familiale = CASE WHEN (UPPER(TRIM(NEW.situation_familiale))='D') THEN 'D'
				     WHEN (UPPER(TRIM(NEW.situation_familiale))='V') THEN 'V'
				     WHEN (UPPER(TRIM(NEW.situation_familiale))='M') THEN 'M'
				     ELSE 'C' END;
      NEW.ppere = TRIM(initcap(NEW.ppere));
      NEW.nmere = TRIM(initcap(NEW.nmere));
      NEW.pmere = TRIM(initcap(NEW.pmere));
      NEW.key = get_key(NEW.nom,NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);            
      NEW.key1 = get_key(COALESCE(NEW.nom_jeune_fille,NEW.nom),NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);
      NEW.uuid = get_uuid(NEW.nom,NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);
      NEW.uuid1 = get_uuid(COALESCE(NEW.nom_jeune_fille,NEW.nom),NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);
      NEW.lib =  NEW.nom ||' '||NEW.prenom||' '||to_char(NEW.date_naiss, 'DD/MM/YYYY');

 RETURN NEW;

 END;
$$;


ALTER FUNCTION public.beneficiaire_before_insert() OWNER TO postgres;

--
-- Name: beneficiaire_before_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.beneficiaire_before_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
DECLARE

 BEGIN
      NEW.nin = REPLACE(NEW.nin, ' ', '');
      NEW.nom = TRIM(initcap(NEW.nom));
      NEW.nom_jeune_fille = TRIM(initcap(NEW.nom_jeune_fille));
      NEW.prenom = TRIM(initcap(NEW.prenom));
      NEW.sexe = CASE WHEN (UPPER(TRIM(NEW.sexe))='F') THEN 'F' ELSE 'M' END;
      NEW.type_date_naiss = CASE WHEN (UPPER(TRIM(NEW.type_date_naiss))='P') THEN 'P' ELSE 'N' END;
      NEW.lieu_naiss = TRIM(initcap(NEW.lieu_naiss));
      NEW.situation_familiale = CASE WHEN (UPPER(TRIM(NEW.situation_familiale))='D') THEN 'D'
				     WHEN (UPPER(TRIM(NEW.situation_familiale))='V') THEN 'V'
				     WHEN (UPPER(TRIM(NEW.situation_familiale))='M') THEN 'M'
				     ELSE 'C' END;
      NEW.ppere = TRIM(initcap(NEW.ppere));
      NEW.nmere = TRIM(initcap(NEW.nmere));
      NEW.pmere = TRIM(initcap(NEW.pmere));
      NEW.key = get_key(NEW.nom,NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);
      NEW.key1 = get_key(COALESCE(NEW.nom_jeune_fille,NEW.nom),NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);
      NEW.uuid = get_uuid(NEW.nom,NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);
      NEW.uuid1 = get_uuid(COALESCE(NEW.nom_jeune_fille,NEW.nom),NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);
      NEW.lib =  NEW.nom ||' '||NEW.prenom||' '||to_char(NEW.date_naiss, 'DD/MM/YYYY');



/*********** save modification in beneficiaire history table**************/
INSERT INTO beneficiaire_history(
             beneficiaire_id, nin, nom, nom_jeune_fille, prenom, date_naiss, 
            date_naiss_presume, type_date_naiss, lieu_naiss, situation_familiale, 
            sexe, ppere, nmere, pmere, created, createdby, updated, updatedby, 
            active, uuid, key, key1, uuid1, pointage_id, lib, postulant_id)
    VALUES (old.id, old.nin, old.nom, old.nom_jeune_fille, old.prenom, old.date_naiss, old.
            date_naiss_presume, old.type_date_naiss, old.lieu_naiss, old.situation_familiale, old.
            sexe, old.ppere, old.nmere, old.pmere, old.created, old.createdby, old.updated, old.updatedby, old.
            active, old.uuid, old.key, old.key1, old.uuid1, old.pointage_id, old.lib, old.postulant_id);



 RETURN NEW;

 END;
$$;


ALTER FUNCTION public.beneficiaire_before_update() OWNER TO postgres;

--
-- Name: close_older_sessions(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.close_older_sessions() RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
DECLARE
BEGIN
/*
select max_conn,used,res_for_super,max_conn-used-res_for_super res_for_normal 
from 
  (select count(*) used from pg_stat_activity) t1,
  (select setting::int res_for_super from pg_settings where name=$$superuser_reserved_connections$$) t2,
  (select setting::int max_conn from pg_settings where name=$$max_connections$$) t3;
*/
UPDATE users_session SET updated=now(),date_exit = now(),online=false 
WHERE token IN (
SELECT token FROM vue_users_sessions_age WHERE age_hours >= 12
);
UPDATE users SET token = null,first_visit=false 
WHERE token IN (
SELECT token FROM vue_users_sessions_age WHERE age_hours >= 12
);
return 'ok'; 
END;
$_$;


ALTER FUNCTION public.close_older_sessions() OWNER TO postgres;

--
-- Name: controle_resultat_before_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.controle_resultat_before_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
DECLARE

 BEGIN
   INSERT INTO controle_resultat_history(
            controle_resultat_id, controle_id, demande_controle_id, postulant_id, controle_resultat_type_id, 
            created, createdby, updated, updatedby, active, found_nin, found_nin_cjt, 
            found_key, found_key_cjt, found_key1, found_key1_cjt, found_uuid, 
            found_uuid_cjt, found_uuid1, found_uuid1_cjt)
    VALUES ( old.id,old.controle_id,old.demande_controle_id,old.postulant_id,old.controle_resultat_type_id,
             old.created,old.createdby,old.updated,old.updatedby,old.active,old.found_nin,old.found_nin_cjt,
             old.found_key,old.found_key_cjt,old.found_key1,old.found_key1_cjt,old.found_uuid,
             old.found_uuid_cjt,old.found_uuid1,old.found_uuid1_cjt);


 RETURN NEW;

 END;
$$;


ALTER FUNCTION public.controle_resultat_before_update() OWNER TO postgres;

--
-- Name: get_phonetique(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_phonetique(chaine character varying) RETURNS character
    LANGUAGE plpgsql
    AS $$
DECLARE
	new_chaine      varchar;
	size		int;
	i		int;
BEGIN
	new_chaine = lower(chaine);
	
	-- Supprimer les caractères identiques consécutives Ex: mohammed==>mohamed
	size = length(new_chaine); 
	i = 1;
	
	while(i<size)
	LOOP
		if((substring(new_chaine from i for 1) = substring(new_chaine from i+1 for 1)) 
		    OR ((substring(new_chaine from i for 1)='d') AND (substring(new_chaine from i+1 for 1)='h')))
			then begin
				--new_chaine=substring(new_chaine from 1 for i-1)||substring(new_chaine from i+1 for size-i+1);
				new_chaine = substring(new_chaine from 1 for i) || substring(new_chaine from i+2 for size-i+1);
				size = size-1;
			     end;
		else i=i+1;
		END IF;
	end LOOP;
	
	new_chaine=replace(new_chaine, 'a', '');
	new_chaine=replace(new_chaine, 'e', '');
	new_chaine=replace(new_chaine, 'é', '');
	new_chaine=replace(new_chaine, 'è', '');
	new_chaine=replace(new_chaine, 'i', '');
	new_chaine=replace(new_chaine, 'o', '');
	new_chaine=replace(new_chaine, 'u', '');
	new_chaine=replace(new_chaine, 'y', '');
	--new_chaine=replace(new_chaine, 'h', '');
	new_chaine=replace(new_chaine, ' ', '');
	new_chaine=replace(new_chaine, '', '');
	new_chaine=replace(new_chaine, '''', '');

        --Phonétique
	new_chaine=replace(new_chaine, 'dj', 'j');
	new_chaine=replace(new_chaine, 'sh', 'ch');

	RETURN new_chaine;

END;
$$;


ALTER FUNCTION public.get_phonetique(chaine character varying) OWNER TO postgres;

--
-- Name: get_uuid(character, character, date, character, character, character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_uuid(nom character, prenom character, date_naiss date, ppere character, nmere character, pmere character) RETURNS character
    LANGUAGE plpgsql
    AS $$
DECLARE
 	uuid			varchar;
BEGIN
   
	uuid = (
	SELECT  COALESCE((to_char(date_naiss, 'DDMMYYYY')),'') ||
		COALESCE((select * from get_phonetique(nom)),'') ||
		COALESCE((select * from get_phonetique(prenom)),'') ||
		COALESCE((select * from get_phonetique(ppere)),'') ||
		COALESCE((select * from get_phonetique(nmere)),'') ||
		COALESCE((select * from get_phonetique(pmere)),'')
	);

	RAISE NOTICE 'uuid generated ==> %',   LOWER(REPLACE(REPLACE(uuid,' ',''),'''','')) ;

	return LOWER(REPLACE(REPLACE(uuid,' ',''),'''',''));
END;
$$;


ALTER FUNCTION public.get_uuid(nom character, prenom character, date_naiss date, ppere character, nmere character, pmere character) OWNER TO postgres;

--
-- Name: org_produits_after_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.org_produits_after_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
DECLARE

 BEGIN
  DELETE FROM users_produits WHERE users_produits.produit_id = OLD.produit_id AND EXISTS(SELECT * FROM users WHERE users.org_id = OLD.org_id);
 RETURN NEW;

 END;
$$;


ALTER FUNCTION public.org_produits_after_delete() OWNER TO postgres;

--
-- Name: patient_before_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.patient_before_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

 BEGIN
      NEW.nin = REPLACE(NEW.nin, ' ', '');
      NEW.nom = TRIM(initcap(NEW.nom));
      NEW.nom_jeune_fille = TRIM(initcap(NEW.nom_jeune_fille));
      NEW.prenom = TRIM(initcap(NEW.prenom));
      NEW.ppere = TRIM(initcap(NEW.ppere));
      NEW.nmere = TRIM(initcap(NEW.nmere));
      NEW.pmere = TRIM(initcap(NEW.pmere));
	  NEW.sexe = CASE WHEN (UPPER(TRIM(NEW.sexe))='F') THEN 'F' ELSE 'M' END;
      NEW.type_date_naiss = CASE WHEN (UPPER(TRIM(NEW.type_date_naiss))='P') THEN 'P' ELSE 'N' END;
      NEW.lieu_naiss = TRIM(initcap(NEW.lieu_naiss));
      NEW.situation_familiale = CASE WHEN (UPPER(TRIM(NEW.situation_familiale))='D') THEN 'D'
				     WHEN (UPPER(TRIM(NEW.situation_familiale))='V') THEN 'V'
				     WHEN (UPPER(TRIM(NEW.situation_familiale))='M') THEN 'M'
				     ELSE 'C' END;
       
      NEW.lib =  NEW.nom ||' '||NEW.prenom||' '||to_char(NEW.date_naiss, 'DD/MM/YYYY');
      NEW.uuid = get_uuid(NEW.nom,NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);
       

 RETURN NEW;

 END;
$$;


ALTER FUNCTION public.patient_before_insert() OWNER TO postgres;

--
-- Name: patient_before_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.patient_before_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

 BEGIN
      NEW.nin = REPLACE(NEW.nin, ' ', '');
      NEW.nom = TRIM(initcap(NEW.nom));
      NEW.nom_jeune_fille = TRIM(initcap(NEW.nom_jeune_fille));
      NEW.prenom = TRIM(initcap(NEW.prenom));
      NEW.sexe = CASE WHEN (UPPER(TRIM(NEW.sexe))='F') THEN 'F' ELSE 'M' END;
      NEW.type_date_naiss = CASE WHEN (UPPER(TRIM(NEW.type_date_naiss))='P') THEN 'P' ELSE 'N' END;
      NEW.lieu_naiss = TRIM(initcap(NEW.lieu_naiss));
      NEW.situation_familiale = CASE WHEN (UPPER(TRIM(NEW.situation_familiale))='D') THEN 'D'
				     WHEN (UPPER(TRIM(NEW.situation_familiale))='V') THEN 'V'
				     WHEN (UPPER(TRIM(NEW.situation_familiale))='M') THEN 'M'
				     ELSE 'C' END;
      NEW.ppere = TRIM(initcap(NEW.ppere));
      NEW.nmere = TRIM(initcap(NEW.nmere));
      NEW.pmere = TRIM(initcap(NEW.pmere));
      NEW.lib =  NEW.nom ||' '||NEW.prenom||' '||to_char(NEW.date_naiss, 'DD/MM/YYYY');
      NEW.uuid = get_uuid(NEW.nom,NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);
   
 RETURN NEW;

 END;
$$;


ALTER FUNCTION public.patient_before_update() OWNER TO postgres;

--
-- Name: postulant_before_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.postulant_before_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
DECLARE

 BEGIN
 --Postulant
      NEW.num = REPLACE(NEW.num, ' ', '');
      NEW.nin = REPLACE(NEW.nin, ' ', '');
      NEW.nom = TRIM(initcap(NEW.nom));
      NEW.nom_jeune_fille = TRIM(initcap(NEW.nom_jeune_fille));
      NEW.prenom = TRIM(initcap(NEW.prenom));
      NEW.sexe = CASE WHEN (UPPER(TRIM(NEW.sexe))='F') THEN 'F' ELSE 'M' END;
      NEW.type_date_naiss = CASE WHEN (UPPER(TRIM(NEW.type_date_naiss))='P') THEN 'P' ELSE 'N' END;
      NEW.lieu_naiss = TRIM(initcap(NEW.lieu_naiss));
      NEW.situation_familiale = CASE WHEN (UPPER(TRIM(NEW.situation_familiale))='D') THEN 'D'
				     WHEN (UPPER(TRIM(NEW.situation_familiale))='V') THEN 'V'
				     WHEN (UPPER(TRIM(NEW.situation_familiale))='M') THEN 'M'
				     ELSE 'C' END;
      NEW.ppere = TRIM(initcap(NEW.ppere));
      NEW.nmere = TRIM(initcap(NEW.nmere));
      NEW.pmere = TRIM(initcap(NEW.pmere));
      NEW.lib =  NEW.nom ||' '||NEW.prenom||' '||to_char(NEW.date_naiss, 'DD/MM/YYYY');

      NEW.key = get_key(NEW.nom,NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);
      NEW.key1 = get_key(COALESCE(NEW.nom_jeune_fille,NEW.nom),NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);
      NEW.uuid = get_uuid(NEW.nom,NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);
      NEW.uuid1 = get_uuid(COALESCE(NEW.nom_jeune_fille,NEW.nom),NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);

      -- v1 : Cas inversion nmere et pmere
      NEW.key_v1 = get_key(NEW.nom,NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.pmere,NEW.nmere);
      NEW.key1_v1 = get_key(COALESCE(NEW.nom_jeune_fille,NEW.nom),NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.pmere,NEW.nmere);
      NEW.uuid_v1 = get_uuid(NEW.nom,NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.pmere,NEW.nmere);
      NEW.uuid1_v1 = get_uuid(COALESCE(NEW.nom_jeune_fille,NEW.nom),NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.pmere,NEW.nmere);
      
/********************/
/***** Conjoint *****/
/********************/
IF(NEW.situation_familiale='M') THEN
      NEW.nin_cjt = REPLACE(NEW.nin_cjt, ' ', '');
      NEW.nom_cjt = TRIM(initcap(NEW.nom_cjt));
      NEW.nom_jeune_fille_cjt = TRIM(initcap(NEW.nom_jeune_fille_cjt));
      NEW.prenom_cjt = TRIM(initcap(NEW.prenom_cjt));
      NEW.sexe_cjt = CASE WHEN (UPPER(TRIM(NEW.sexe))='F') THEN 'M' ELSE 'F' END;
      NEW.type_date_naiss_cjt = CASE WHEN (UPPER(TRIM(NEW.type_date_naiss_cjt))='P') THEN 'P' ELSE 'N' END;
      NEW.lieu_naiss_cjt = TRIM(initcap(NEW.lieu_naiss_cjt));
      NEW.situation_familiale_cjt = CASE WHEN (UPPER(TRIM(NEW.situation_familiale_cjt))='M') THEN 'M' END;
      NEW.ppere_cjt = TRIM(initcap(NEW.ppere_cjt));
      NEW.nmere_cjt = TRIM(initcap(NEW.nmere_cjt));
      NEW.pmere_cjt = TRIM(initcap(NEW.pmere_cjt));

      NEW.key_cjt = get_key(NEW.nom_cjt,NEW.prenom_cjt,NEW.date_naiss_cjt,NEW.ppere_cjt,NEW.nmere_cjt,NEW.pmere_cjt);
      NEW.key1_cjt = get_key(COALESCE(NEW.nom_jeune_fille_cjt,NEW.nom_cjt),NEW.prenom_cjt,NEW.date_naiss_cjt,NEW.ppere_cjt,NEW.nmere_cjt,NEW.pmere_cjt);
      NEW.uuid_cjt = get_uuid(NEW.nom_cjt,NEW.prenom_cjt,NEW.date_naiss_cjt,NEW.ppere_cjt,NEW.nmere_cjt,NEW.pmere_cjt);
      NEW.uuid1_cjt = get_uuid(COALESCE(NEW.nom_jeune_fille_cjt,NEW.nom_cjt),NEW.prenom_cjt,NEW.date_naiss_cjt,NEW.ppere_cjt,NEW.nmere_cjt,NEW.pmere_cjt);

      -- v1 : Cas inversion nmere et pmere
      NEW.key_cjt_v1 = get_key(NEW.nom_cjt,NEW.prenom_cjt,NEW.date_naiss_cjt,NEW.ppere_cjt,NEW.pmere_cjt,NEW.nmere_cjt);
      NEW.key1_cjt_v1 = get_key(COALESCE(NEW.nom_jeune_fille_cjt,NEW.nom_cjt),NEW.prenom_cjt,NEW.date_naiss_cjt,NEW.ppere_cjt,NEW.pmere_cjt,NEW.nmere_cjt);
      NEW.uuid_cjt_v1 = get_uuid(NEW.nom_cjt,NEW.prenom_cjt,NEW.date_naiss_cjt,NEW.ppere_cjt,NEW.pmere_cjt,NEW.nmere_cjt);
      NEW.uuid1_cjt_v1 = get_uuid(COALESCE(NEW.nom_jeune_fille_cjt,NEW.nom_cjt),NEW.prenom_cjt,NEW.date_naiss_cjt,NEW.ppere_cjt,NEW.pmere_cjt,NEW.nmere_cjt);
ELSE 
      NEW.nin_cjt = NULL;
      NEW.nom_cjt = NULL;
      NEW.nom_jeune_fille_cjt = NULL;
      NEW.prenom_cjt = NULL;
      NEW.sexe_cjt = NULL;
      NEW.date_naiss_cjt = NULL;
      NEW.type_date_naiss_cjt = NULL;
      NEW.lieu_naiss_cjt = NULL;
      NEW.situation_familiale_cjt = NULL;
      NEW.ppere_cjt = NULL;
      NEW.nmere_cjt =NULL;
      NEW.pmere_cjt =NULL;

      NEW.key_cjt = NULL;
      NEW.key1_cjt = NULL;
      NEW.uuid_cjt = NULL;      
      NEW.uuid1_cjt = NULL;

      NEW.key_cjt_v1 = NULL;
      NEW.key1_cjt_v1 = NULL;
      NEW.uuid_cjt_v1 = NULL;      
      NEW.uuid1_cjt_v1 = NULL;

END IF;

 RETURN NEW;

 END;
$$;


ALTER FUNCTION public.postulant_before_insert() OWNER TO postgres;

--
-- Name: postulant_before_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.postulant_before_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
DECLARE

 BEGIN
 --Postulant
      NEW.num = REPLACE(NEW.num, ' ', '');
      NEW.nin = REPLACE(NEW.nin, ' ', '');
      NEW.nom = TRIM(initcap(NEW.nom));
      NEW.nom_jeune_fille = TRIM(initcap(NEW.nom_jeune_fille));
      NEW.prenom = TRIM(initcap(NEW.prenom));
      NEW.sexe = CASE WHEN (UPPER(TRIM(NEW.sexe))='F') THEN 'F' ELSE 'M' END;
      NEW.type_date_naiss = CASE WHEN (UPPER(TRIM(NEW.type_date_naiss))='P') THEN 'P' ELSE 'N' END;
      NEW.lieu_naiss = TRIM(initcap(NEW.lieu_naiss));
      NEW.situation_familiale = CASE WHEN (UPPER(TRIM(NEW.situation_familiale))='D') THEN 'D'
				     WHEN (UPPER(TRIM(NEW.situation_familiale))='V') THEN 'V'
				     WHEN (UPPER(TRIM(NEW.situation_familiale))='M') THEN 'M'
				     ELSE 'C' END;
      NEW.ppere = TRIM(initcap(NEW.ppere));
      NEW.nmere = TRIM(initcap(NEW.nmere));
      NEW.pmere = TRIM(initcap(NEW.pmere));
      NEW.lib =  NEW.nom ||' '||NEW.prenom||' '||to_char(NEW.date_naiss, 'DD/MM/YYYY');

      NEW.key = get_key(NEW.nom,NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);
      NEW.key1 = get_key(COALESCE(NEW.nom_jeune_fille,NEW.nom),NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);
      NEW.uuid = get_uuid(NEW.nom,NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);
      NEW.uuid1 = get_uuid(COALESCE(NEW.nom_jeune_fille,NEW.nom),NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);

      -- v1 : Cas inversion nmere et pmere
      NEW.key_v1 = get_key(NEW.nom,NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.pmere,NEW.nmere);
      NEW.key1_v1 = get_key(COALESCE(NEW.nom_jeune_fille,NEW.nom),NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.pmere,NEW.nmere);
      NEW.uuid_v1 = get_uuid(NEW.nom,NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.pmere,NEW.nmere);
      NEW.uuid1_v1 = get_uuid(COALESCE(NEW.nom_jeune_fille,NEW.nom),NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.pmere,NEW.nmere);

/********************/
/***** Conjoint *****/
/********************/
 IF(NEW.situation_familiale='M') THEN
      NEW.nin_cjt = REPLACE(NEW.nin_cjt, ' ', '');
      NEW.nom_cjt = TRIM(initcap(NEW.nom_cjt));
      NEW.nom_jeune_fille_cjt = TRIM(initcap(NEW.nom_jeune_fille_cjt));
      NEW.prenom_cjt = TRIM(initcap(NEW.prenom_cjt));
      NEW.sexe_cjt = CASE WHEN (UPPER(TRIM(NEW.sexe))='F') THEN 'M' ELSE 'F' END;
      NEW.type_date_naiss_cjt = CASE WHEN (UPPER(TRIM(NEW.type_date_naiss_cjt))='P') THEN 'P' ELSE 'N' END;
      NEW.lieu_naiss_cjt = TRIM(initcap(NEW.lieu_naiss_cjt));
      NEW.situation_familiale_cjt = CASE WHEN (UPPER(TRIM(NEW.situation_familiale_cjt))='M') THEN 'M' END;
      NEW.ppere_cjt = TRIM(initcap(NEW.ppere_cjt));
      NEW.nmere_cjt = TRIM(initcap(NEW.nmere_cjt));
      NEW.pmere_cjt = TRIM(initcap(NEW.pmere_cjt));
      
      NEW.key_cjt = get_key(NEW.nom_cjt,NEW.prenom_cjt,NEW.date_naiss_cjt,NEW.ppere_cjt,NEW.nmere_cjt,NEW.pmere_cjt);
      NEW.key1_cjt = get_key(COALESCE(NEW.nom_jeune_fille_cjt,NEW.nom_cjt),NEW.prenom_cjt,NEW.date_naiss_cjt,NEW.ppere_cjt,NEW.nmere_cjt,NEW.pmere_cjt);
      NEW.uuid_cjt = get_uuid(NEW.nom_cjt,NEW.prenom_cjt,NEW.date_naiss_cjt,NEW.ppere_cjt,NEW.nmere_cjt,NEW.pmere_cjt);
      NEW.uuid1_cjt = get_uuid(COALESCE(NEW.nom_jeune_fille_cjt,NEW.nom_cjt),NEW.prenom_cjt,NEW.date_naiss_cjt,NEW.ppere_cjt,NEW.nmere_cjt,NEW.pmere_cjt);

      -- v1 : Cas inversion nmere et pmere
      NEW.key_cjt_v1 = get_key(NEW.nom_cjt,NEW.prenom_cjt,NEW.date_naiss_cjt,NEW.ppere_cjt,NEW.pmere_cjt,NEW.nmere_cjt);
      NEW.key1_cjt_v1 = get_key(COALESCE(NEW.nom_jeune_fille_cjt,NEW.nom_cjt),NEW.prenom_cjt,NEW.date_naiss_cjt,NEW.ppere_cjt,NEW.pmere_cjt,NEW.nmere_cjt);
      NEW.uuid_cjt_v1 = get_uuid(NEW.nom_cjt,NEW.prenom_cjt,NEW.date_naiss_cjt,NEW.ppere_cjt,NEW.pmere_cjt,NEW.nmere_cjt);
      NEW.uuid1_cjt_v1 = get_uuid(COALESCE(NEW.nom_jeune_fille_cjt,NEW.nom_cjt),NEW.prenom_cjt,NEW.date_naiss_cjt,NEW.ppere_cjt,NEW.pmere_cjt,NEW.nmere_cjt);

ELSE 
      NEW.nin_cjt = NULL;
      NEW.nom_cjt = NULL;
      NEW.nom_jeune_fille_cjt = NULL;
      NEW.prenom_cjt = NULL;
      NEW.sexe_cjt = NULL;
      NEW.date_naiss_cjt = NULL;
      NEW.type_date_naiss_cjt = NULL;
      NEW.lieu_naiss_cjt = NULL;
      NEW.situation_familiale_cjt = NULL;
      NEW.ppere_cjt = NULL;
      NEW.nmere_cjt =NULL;
      NEW.pmere_cjt =NULL;

      NEW.key_cjt = NULL;
      NEW.key1_cjt = NULL;
      NEW.uuid_cjt = NULL;
      NEW.uuid1_cjt = NULL;

      NEW.key_cjt_v1 = NULL;
      NEW.key1_cjt_v1 = NULL;
      NEW.uuid_cjt_v1 = NULL;      
      NEW.uuid1_cjt_v1 = NULL;

END IF;
 RETURN NEW;

 END;
$$;


ALTER FUNCTION public.postulant_before_update() OWNER TO postgres;

--
-- Name: rdv_before_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.rdv_before_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

 BEGIN
      IF (OLD.etat_id = 0 AND NEW.etat_id = 1) THEN
         INSERT INTO patient_consultations 
	            (patient_id,date_consultation,startsat,endsat,duree) 
	             values (NEW.patient_id,OLD.updated,OLD.updated,now(),
				(date_part('hours',age(now(),OLD.updated))*60 
			   + date_part('minutes',age(now(),OLD.updated)))::integer);
      END IF;
 RETURN NEW;

 END;
$$;


ALTER FUNCTION public.rdv_before_update() OWNER TO postgres;

--
-- Name: recherche_before_insert_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.recherche_before_insert_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

 BEGIN
      NEW.nin = REPLACE(NEW.nin, ' ', '');
      NEW.nom = TRIM(initcap(NEW.nom));
      NEW.nom_jeune_fille = TRIM(initcap(NEW.nom_jeune_fille));
      NEW.prenom = TRIM(initcap(NEW.prenom));
      NEW.type_date_naiss = CASE WHEN (UPPER(TRIM(NEW.type_date_naiss))='P') THEN 'P' ELSE 'N' END;
      NEW.ppere = TRIM(initcap(NEW.ppere));
      NEW.nmere = TRIM(initcap(NEW.nmere));
      NEW.pmere = TRIM(initcap(NEW.pmere));
      NEW.key = get_key(NEW.nom,NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);            
      NEW.key1 = get_key(COALESCE(NEW.nom_jeune_fille,NEW.nom),NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);
      NEW.uuid = get_uuid(NEW.nom,NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);
      NEW.uuid1 = get_uuid(COALESCE(NEW.nom_jeune_fille,NEW.nom),NEW.prenom,NEW.date_naiss,NEW.ppere,NEW.nmere,NEW.pmere);
      NEW.lib =  NEW.nom ||' '||NEW.prenom||' '||to_char(NEW.date_naiss, 'DD/MM/YYYY');

 RETURN NEW;

 END;
$$;


ALTER FUNCTION public.recherche_before_insert_update() OWNER TO postgres;

--
-- Name: reset_database(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.reset_database() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN
DELETE FROM org_transactions;
DELETE FROM partenaires;
DELETE FROM patient_certificats;
DELETE FROM patient_consultations;
DELETE FROM patient_ordonnances;
DELETE FROM patient_ordonnances_details;
DELETE FROM patient_pathologies;
DELETE FROM patient_radiographies;
DELETE FROM patient_rdvs;
DELETE FROM patient_traitements;
DELETE FROM patient_vitals;
DELETE FROM patients;
DELETE FROM users_messages;
DELETE FROM users_notifications;
DELETE FROM users_session;

PERFORM public.reset_id_sequences();
return 'The database was rested'; 
END;
$$;


ALTER FUNCTION public.reset_database() OWNER TO postgres;

--
-- Name: reset_id_sequences(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.reset_id_sequences() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN
PERFORM  setval('actes_id_seq', COALESCE((SELECT MAX(id)+1 FROM actes), 1), false);
PERFORM  setval('certificat_motifs_id_seq', COALESCE((SELECT MAX(id)+1 FROM certificat_motifs), 1), false);
PERFORM  setval('commune_id_seq', COALESCE((SELECT MAX(id)+1 FROM commune), 1), false);
--PERFORM  setval('dents_id_seq', COALESCE((SELECT MAX(num::integer)+1 FROM dents), 1), false);
PERFORM  setval('etats_id_seq', COALESCE((SELECT MAX(id)+1 FROM etats), 1), false);
PERFORM  setval('medicaments_id_seq', COALESCE((SELECT MAX(id)+1 FROM medicaments), 1), false);
PERFORM  setval('motifs_rdv_id_seq', COALESCE((SELECT MAX(id)+1 FROM motifs), 1), false);
PERFORM  setval('ordonnance_posologies_id_seq', COALESCE((SELECT MAX(id)+1 FROM ordonnance_posologies), 1), false);
PERFORM  setval('org_id_seq', COALESCE((SELECT MAX(id)+1 FROM org), 1), false);
PERFORM  setval('org_professions_id_seq', COALESCE((SELECT MAX(id)+1 FROM org_professions), 1), false);
PERFORM  setval('org_sales_id_seq', COALESCE((SELECT MAX(id)+1 FROM org_sales), 1), false);
PERFORM  setval('org_transactions_id_seq', COALESCE((SELECT MAX(id)+1 FROM org_transactions), 1), false);
PERFORM  setval('org_annuaire_id_seq', COALESCE((SELECT MAX(id)+1 FROM partenaires), 1), false);
PERFORM  setval('pathologies_id_seq', COALESCE((SELECT MAX(id)+1 FROM  pathologies ), 1), false);
PERFORM  setval('patient_certificats_id_seq', COALESCE((SELECT MAX(id)+1 FROM  patient_certificats ), 1), false);
PERFORM  setval('patient_consultations_id_seq', COALESCE((SELECT MAX(id)+1 FROM  patient_consultations ), 1), false);
PERFORM  setval('patient_ordonnances_id_seq', COALESCE((SELECT MAX(id)+1 FROM  patient_ordonnances ), 1), false);
PERFORM  setval('patient_ordonnances_details_id_seq', COALESCE((SELECT MAX(id)+1 FROM  patient_ordonnances_details ), 1), false);
PERFORM  setval('patient_pathologies_id_seq', COALESCE((SELECT MAX(id)+1 FROM  patient_pathologies ), 1), false);
PERFORM  setval('patient_radiographies_id_seq', COALESCE((SELECT MAX(id)+1 FROM  patient_radiographies ), 1), false);
PERFORM  setval('patient_rdv_id_seq', COALESCE((SELECT MAX(id)+1 FROM  patient_rdvs ), 1), false);
PERFORM  setval('patient_traitements_id_seq', COALESCE((SELECT MAX(id)+1 FROM  patient_traitements ), 1), false);
PERFORM  setval('patient_vitals_id_seq', COALESCE((SELECT MAX(id)+1 FROM  patient_vitals ), 1), false);
PERFORM  setval('patient_id_seq', COALESCE((SELECT MAX(id)+1 FROM  patients ), 1), false);
PERFORM  setval('procedures_id_seq', COALESCE((SELECT MAX(id)+1 FROM  procedures ), 1), false);
PERFORM  setval('radiographies_id_seq', COALESCE((SELECT MAX(id)+1 FROM  radiographies ), 1), false);
PERFORM  setval('severites_id_seq', COALESCE((SELECT MAX(id)+1 FROM  severites ), 1), false);
PERFORM  setval('types_id_seq', COALESCE((SELECT MAX(id)+1 FROM  types_paiements ), 1), false);
PERFORM  setval('types_transactions_id_seq', COALESCE((SELECT MAX(id)+1 FROM  types_transactions ), 1), false);
PERFORM  setval('users_id_seq', COALESCE((SELECT MAX(id)+1 FROM  users ), 1), false);
PERFORM  setval('users_messages_id_seq', COALESCE((SELECT MAX(id)+1 FROM  users_messages ), 1), false);
PERFORM  setval('users_notifications_id_seq', COALESCE((SELECT MAX(id)+1 FROM  users_notifications ), 1), false);
PERFORM  setval('users_roles_access_control_id_seq', COALESCE((SELECT MAX(id)+1 FROM  users_roles_access_control ), 1), false);
PERFORM  setval('users_session_id_seq', COALESCE((SELECT MAX(id)+1 FROM  users_session ), 1), false);
PERFORM  setval('vitals_id_seq', COALESCE((SELECT MAX(id)+1 FROM  vitals ), 1), false);
PERFORM  setval('wilaya_id_seq', COALESCE((SELECT MAX(id)+1 FROM  wilaya ), 1), false);
 
return 'All IDs were updated'; 
END;
$$;


ALTER FUNCTION public.reset_id_sequences() OWNER TO postgres;

--
-- Name: statistiques_patients_ages_sexes_consultations_by_org(integer, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.statistiques_patients_ages_sexes_consultations_by_org(p_org_id integer, p_date_du date, p_date_au date) RETURNS TABLE(org_id integer, patients numeric, patients_masculin numeric, patients_feminin numeric, patients_inf_18 numeric, patients_18_30 numeric, patients_30_40 numeric, patients_40_50 numeric, patients_50_60 numeric, patients_sup_60 numeric, patient_consultation_current_01 numeric, patient_consultation_current_02 numeric, patient_consultation_current_03 numeric, patient_consultation_current_04 numeric, patient_consultation_current_05 numeric, patient_consultation_current_06 numeric, patient_consultation_current_07 numeric, patient_consultation_current_08 numeric, patient_consultation_current_09 numeric, patient_consultation_current_10 numeric, patient_consultation_current_11 numeric, patient_consultation_current_12 numeric, patient_consultation_current_duree_01 double precision, patient_consultation_current_duree_02 double precision, patient_consultation_current_duree_03 double precision, patient_consultation_current_duree_04 double precision, patient_consultation_current_duree_05 double precision, patient_consultation_current_duree_06 double precision, patient_consultation_current_duree_07 double precision, patient_consultation_current_duree_08 double precision, patient_consultation_current_duree_09 double precision, patient_consultation_current_duree_10 double precision, patient_consultation_current_duree_11 double precision, patient_consultation_current_duree_12 double precision, patient_consultation_last_01 numeric, patient_consultation_last_02 numeric, patient_consultation_last_03 numeric, patient_consultation_last_04 numeric, patient_consultation_last_05 numeric, patient_consultation_last_06 numeric, patient_consultation_last_07 numeric, patient_consultation_last_08 numeric, patient_consultation_last_09 numeric, patient_consultation_last_10 numeric, patient_consultation_last_11 numeric, patient_consultation_last_12 numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN

return query 
	 SELECT 
stats_users.org_id,SUM(stats_users.patients) patients,
SUM(stats_users.patients_masculin)patients_masculin,SUM(stats_users.patients_feminin)patients_feminin,
SUM(stats_users.patients_inf_18)patients_inf_18,SUM(stats_users.patients_18_30)patients_18_30,
SUM(stats_users.patients_30_40)patients_30_40,SUM(stats_users.patients_40_50)patients_40_50,
SUM(stats_users.patients_50_60)patients_50_60,SUM(stats_users.patients_sup_60)patients_sup_60,
SUM(stats_users.patient_consultation_current_01)patient_consultation_current_01,
SUM(stats_users.patient_consultation_current_02)patient_consultation_current_02,
SUM(stats_users.patient_consultation_current_03)patient_consultation_current_03,
SUM(stats_users.patient_consultation_current_04)patient_consultation_current_04,
SUM(stats_users.patient_consultation_current_05)patient_consultation_current_05,
SUM(stats_users.patient_consultation_current_06)patient_consultation_current_06,
SUM(stats_users.patient_consultation_current_07)patient_consultation_current_07,
SUM(stats_users.patient_consultation_current_08)patient_consultation_current_08,
SUM(stats_users.patient_consultation_current_09)patient_consultation_current_09,
SUM(stats_users.patient_consultation_current_10)patient_consultation_current_10,
SUM(stats_users.patient_consultation_current_11)patient_consultation_current_11,
SUM(stats_users.patient_consultation_current_12)patient_consultation_current_12,
AVG(stats_users.patient_consultation_current_Duree_01)patient_consultation_current_Duree_01,
AVG(stats_users.patient_consultation_current_Duree_02)patient_consultation_current_Duree_02,
AVG(stats_users.patient_consultation_current_Duree_03)patient_consultation_current_Duree_03,
AVG(stats_users.patient_consultation_current_Duree_04)patient_consultation_current_Duree_04,
AVG(stats_users.patient_consultation_current_Duree_05)patient_consultation_current_Duree_05,
AVG(stats_users.patient_consultation_current_Duree_06)patient_consultation_current_Duree_06,
AVG(stats_users.patient_consultation_current_Duree_07)patient_consultation_current_Duree_07,
AVG(stats_users.patient_consultation_current_Duree_08)patient_consultation_current_Duree_08,
AVG(stats_users.patient_consultation_current_Duree_09)patient_consultation_current_Duree_09,
AVG(stats_users.patient_consultation_current_Duree_10)patient_consultation_current_Duree_10,
AVG(stats_users.patient_consultation_current_Duree_11)patient_consultation_current_Duree_11,
AVG(stats_users.patient_consultation_current_Duree_12)patient_consultation_current_Duree_12,

SUM(stats_users.patient_consultation_last_01)patient_consultation_last_01,
SUM(stats_users.patient_consultation_last_02)patient_consultation_last_02,
SUM(stats_users.patient_consultation_last_03)patient_consultation_last_03,
SUM(stats_users.patient_consultation_last_04)patient_consultation_last_04,
SUM(stats_users.patient_consultation_last_05)patient_consultation_last_05,
SUM(stats_users.patient_consultation_last_06)patient_consultation_last_06,
SUM(stats_users.patient_consultation_last_07)patient_consultation_last_07,
SUM(stats_users.patient_consultation_last_08)patient_consultation_last_08,
SUM(stats_users.patient_consultation_last_09)patient_consultation_last_09,
SUM(stats_users.patient_consultation_last_10)patient_consultation_last_10,
SUM(stats_users.patient_consultation_last_11)patient_consultation_last_11,
SUM(stats_users.patient_consultation_last_12)patient_consultation_last_12 
FROM public.statistiques_patients_ages_sexes_consultations_by_users(p_org_id,p_date_du::date,p_date_au::date) stats_users
WHERE stats_users.org_id = p_org_id 
GROUP BY stats_users.org_id;
END;
$$;


ALTER FUNCTION public.statistiques_patients_ages_sexes_consultations_by_org(p_org_id integer, p_date_du date, p_date_au date) OWNER TO postgres;

--
-- Name: statistiques_patients_ages_sexes_consultations_by_users(integer, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.statistiques_patients_ages_sexes_consultations_by_users(p_org_id integer, p_date_du date, p_date_au date) RETURNS TABLE(org_id integer, org character varying, user_id integer, user_name character varying, patients bigint, patients_masculin bigint, patients_feminin bigint, patients_inf_18 bigint, patients_18_30 bigint, patients_30_40 bigint, patients_40_50 bigint, patients_50_60 bigint, patients_sup_60 bigint, patient_consultation_current_01 bigint, patient_consultation_current_02 bigint, patient_consultation_current_03 bigint, patient_consultation_current_04 bigint, patient_consultation_current_05 bigint, patient_consultation_current_06 bigint, patient_consultation_current_07 bigint, patient_consultation_current_08 bigint, patient_consultation_current_09 bigint, patient_consultation_current_10 bigint, patient_consultation_current_11 bigint, patient_consultation_current_12 bigint, patient_consultation_current_duree_01 double precision, patient_consultation_current_duree_02 double precision, patient_consultation_current_duree_03 double precision, patient_consultation_current_duree_04 double precision, patient_consultation_current_duree_05 double precision, patient_consultation_current_duree_06 double precision, patient_consultation_current_duree_07 double precision, patient_consultation_current_duree_08 double precision, patient_consultation_current_duree_09 double precision, patient_consultation_current_duree_10 double precision, patient_consultation_current_duree_11 double precision, patient_consultation_current_duree_12 double precision, patient_consultation_last_01 bigint, patient_consultation_last_02 bigint, patient_consultation_last_03 bigint, patient_consultation_last_04 bigint, patient_consultation_last_05 bigint, patient_consultation_last_06 bigint, patient_consultation_last_07 bigint, patient_consultation_last_08 bigint, patient_consultation_last_09 bigint, patient_consultation_last_10 bigint, patient_consultation_last_11 bigint, patient_consultation_last_12 bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN

return query 
		SELECT org.id AS org_id,
    org.designation AS org,
    users.id AS user_id,
    users.lib AS user_name,
    COALESCE(patients.nb, (0)::bigint) AS patients,
    COALESCE(patient_masculin.nb, (0)::bigint) AS patients_masculin,
    COALESCE(patient_feminin.nb, (0)::bigint) AS patients_feminin,
    COALESCE(patient_0_18.nb, (0)::bigint) AS patients_inf_18,
    COALESCE(patient_18_30.nb, (0)::bigint) AS patients_18_30,
    COALESCE(patient_30_40.nb, (0)::bigint) AS patients_30_40,
    COALESCE(patient_40_50.nb, (0)::bigint) AS patients_40_50,
    COALESCE(patient_50_60.nb, (0)::bigint) AS patients_50_60,
    COALESCE(patient_60.nb, (0)::bigint) AS patients_sup_60,
    COALESCE(patient_current_01.nb, (0)::bigint) AS patient_consultation_current_01,
    COALESCE(patient_current_02.nb, (0)::bigint) AS patient_consultation_current_02,
    COALESCE(patient_current_03.nb, (0)::bigint) AS patient_consultation_current_03,
    COALESCE(patient_current_04.nb, (0)::bigint) AS patient_consultation_current_04,
    COALESCE(patient_current_05.nb, (0)::bigint) AS patient_consultation_current_05,
    COALESCE(patient_current_06.nb, (0)::bigint) AS patient_consultation_current_06,
    COALESCE(patient_current_07.nb, (0)::bigint) AS patient_consultation_current_07,
    COALESCE(patient_current_08.nb, (0)::bigint) AS patient_consultation_current_08,
    COALESCE(patient_current_09.nb, (0)::bigint) AS patient_consultation_current_09,
    COALESCE(patient_current_10.nb, (0)::bigint) AS patient_consultation_current_10,
    COALESCE(patient_current_11.nb, (0)::bigint) AS patient_consultation_current_11,
    COALESCE(patient_current_12.nb, (0)::bigint) AS patient_consultation_current_12,
COALESCE(patient_current_01.duree,0) / COALESCE(patient_current_01.nb, (1)::bigint) AS patient_consultation_current_Duree_01,
COALESCE(patient_current_02.duree,0) / COALESCE(patient_current_02.nb, (1)::bigint) AS patient_consultation_current_Duree_02,
COALESCE(patient_current_03.duree,0) / COALESCE(patient_current_03.nb, (1)::bigint) AS patient_consultation_current_Duree_03,
COALESCE(patient_current_04.duree,0) / COALESCE(patient_current_04.nb, (1)::bigint) AS patient_consultation_current_Duree_04,
COALESCE(patient_current_05.duree,0) / COALESCE(patient_current_05.nb, (1)::bigint) AS patient_consultation_current_Duree_05,
COALESCE(patient_current_06.duree,0) / COALESCE(patient_current_06.nb, (1)::bigint) AS patient_consultation_current_Duree_06,
COALESCE(patient_current_07.duree,0) / COALESCE(patient_current_07.nb, (1)::bigint) AS patient_consultation_current_Duree_07,
COALESCE(patient_current_08.duree,0) / COALESCE(patient_current_08.nb, (1)::bigint) AS patient_consultation_current_Duree_08,
COALESCE(patient_current_09.duree,0) / COALESCE(patient_current_09.nb, (1)::bigint) AS patient_consultation_current_Duree_09,
COALESCE(patient_current_10.duree,0) / COALESCE(patient_current_10.nb, (1)::bigint) AS patient_consultation_current_Duree_10,
COALESCE(patient_current_11.duree,0) / COALESCE(patient_current_11.nb, (1)::bigint) AS patient_consultation_current_Duree_11,
COALESCE(patient_current_12.duree,0) / COALESCE(patient_current_12.nb, (1)::bigint) AS patient_consultation_current_Duree_12,
 
    COALESCE(patient_last_01.nb, (0)::bigint) AS patient_consultation_last_01,
    COALESCE(patient_last_02.nb, (0)::bigint) AS patient_consultation_last_02,
    COALESCE(patient_last_03.nb, (0)::bigint) AS patient_consultation_last_03,
    COALESCE(patient_last_04.nb, (0)::bigint) AS patient_consultation_last_04,
    COALESCE(patient_last_05.nb, (0)::bigint) AS patient_consultation_last_05,
    COALESCE(patient_last_06.nb, (0)::bigint) AS patient_consultation_last_06,
    COALESCE(patient_last_07.nb, (0)::bigint) AS patient_consultation_last_07,
    COALESCE(patient_last_08.nb, (0)::bigint) AS patient_consultation_last_08,
    COALESCE(patient_last_09.nb, (0)::bigint) AS patient_consultation_last_09,
    COALESCE(patient_last_10.nb, (0)::bigint) AS patient_consultation_last_10,
    COALESCE(patient_last_11.nb, (0)::bigint) AS patient_consultation_last_11,
    COALESCE(patient_last_12.nb, (0)::bigint) AS patient_consultation_last_12
   FROM ((((((((((((((((((((((((((((((((((org
     JOIN users ON ((org.id = users.org_id)))
     LEFT JOIN ( SELECT patient_temp.createdby,
            count(*) AS nb
           FROM patients patient_temp 
		   INNER JOIN (SELECT DISTINCT patient_id,date_consultation FROM patient_consultations WHERE (date_consultation >= p_date_du AND date_consultation <= p_date_Au)) pc on patient_temp.id = pc.patient_id
          GROUP BY patient_temp.createdby) patients ON ((patients.createdby = users.id)))
     LEFT JOIN ( SELECT patient_temp.createdby,
            count(*) AS nb
           FROM patients patient_temp
						   INNER JOIN (SELECT DISTINCT patient_id,date_consultation FROM patient_consultations WHERE (date_consultation >= p_date_du AND date_consultation <= p_date_Au)) pc on patient_temp.id = pc.patient_id

          WHERE (patient_temp.sexe = 'M'::bpchar) 
          GROUP BY patient_temp.createdby) patient_masculin ON ((patient_masculin.createdby = users.id)))
     LEFT JOIN ( SELECT patient_temp.createdby,
            count(*) AS nb
           FROM patients patient_temp
           INNER JOIN (SELECT DISTINCT patient_id,date_consultation FROM patient_consultations WHERE (date_consultation >= p_date_du AND date_consultation <= p_date_Au)) pc on patient_temp.id = pc.patient_id
          WHERE (patient_temp.sexe = 'F'::bpchar)   
          GROUP BY patient_temp.createdby) patient_feminin ON ((patient_feminin.createdby = users.id)))
     LEFT JOIN ( SELECT patient_temp.createdby,
            count(*) AS nb
           FROM patients patient_temp
          INNER JOIN (SELECT DISTINCT patient_id,date_consultation FROM patient_consultations WHERE (date_consultation >= p_date_du AND date_consultation <= p_date_Au)) pc on patient_temp.id = pc.patient_id

          WHERE (date_part('year'::text, age((patient_temp.date_naiss)::timestamp with time zone)) < (18)::double precision)
				 
          GROUP BY patient_temp.createdby) patient_0_18 ON ((patient_0_18.createdby = users.id)))
     LEFT JOIN ( SELECT patient_temp.createdby,
            count(*) AS nb
           FROM patients patient_temp
           INNER JOIN (SELECT DISTINCT patient_id,date_consultation FROM patient_consultations  WHERE (date_consultation >= p_date_du AND date_consultation <= p_date_Au)) pc on patient_temp.id = pc.patient_id

          WHERE ((date_part('year'::text, age((patient_temp.date_naiss)::timestamp with time zone)) >= (18)::double precision) AND (date_part('year'::text, age((patient_temp.date_naiss)::timestamp with time zone)) < (30)::double precision))
            
			GROUP BY patient_temp.createdby) patient_18_30 ON ((patient_18_30.createdby = users.id)))
     LEFT JOIN ( SELECT patient_temp.createdby,
            count(*) AS nb
           FROM patients patient_temp
						   INNER JOIN (SELECT DISTINCT patient_id,date_consultation FROM patient_consultations  WHERE (date_consultation >= p_date_du AND date_consultation <= p_date_Au)) pc on patient_temp.id = pc.patient_id

          WHERE ((date_part('year'::text, age((patient_temp.date_naiss)::timestamp with time zone)) >= (30)::double precision) AND (date_part('year'::text, age((patient_temp.date_naiss)::timestamp with time zone)) < (40)::double precision))
       
				GROUP BY patient_temp.createdby) patient_30_40 ON ((patient_30_40.createdby = users.id)))
     LEFT JOIN ( SELECT patient_temp.createdby,
            count(*) AS nb
           FROM patients patient_temp
						   INNER JOIN (SELECT DISTINCT patient_id,date_consultation FROM patient_consultations  WHERE (date_consultation >= p_date_du AND date_consultation <= p_date_Au)) pc on patient_temp.id = pc.patient_id

          WHERE ((date_part('year'::text, age((patient_temp.date_naiss)::timestamp with time zone)) >= (40)::double precision) AND (date_part('year'::text, age((patient_temp.date_naiss)::timestamp with time zone)) < (50)::double precision))
          
				GROUP BY patient_temp.createdby) patient_40_50 ON ((patient_40_50.createdby = users.id)))
     LEFT JOIN ( SELECT patient_temp.createdby,
            count(*) AS nb
           FROM patients patient_temp
						   INNER JOIN (SELECT DISTINCT patient_id,date_consultation FROM patient_consultations  WHERE (date_consultation >= p_date_du AND date_consultation <= p_date_Au)) pc on patient_temp.id = pc.patient_id

          WHERE ((date_part('year'::text, age((patient_temp.date_naiss)::timestamp with time zone)) >= (50)::double precision) AND (date_part('year'::text, age((patient_temp.date_naiss)::timestamp with time zone)) < (60)::double precision))
         
				GROUP BY patient_temp.createdby) patient_50_60 ON ((patient_50_60.createdby = users.id)))
     LEFT JOIN ( SELECT patient_temp.createdby,
            count(*) AS nb
           FROM patients patient_temp
						   INNER JOIN (SELECT DISTINCT patient_id,date_consultation FROM patient_consultations  WHERE (date_consultation >= p_date_du AND date_consultation <= p_date_Au)) pc on patient_temp.id = pc.patient_id

          WHERE (date_part('year'::text, age((patient_temp.date_naiss)::timestamp with time zone)) >= (60)::double precision)
           
				GROUP BY patient_temp.createdby) patient_60 ON ((patient_60.createdby = users.id)))
  LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb,SUM(duree) duree
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (1)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, p_date_Au)))
  GROUP BY consultation_temp.consulte_par) patient_current_01 ON ((patient_current_01.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb,SUM(duree) duree
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (2)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, p_date_Au)))
 GROUP BY consultation_temp.consulte_par) patient_current_02 ON ((patient_current_02.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb,SUM(duree) duree
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (3)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, p_date_Au)))
  GROUP BY consultation_temp.consulte_par) patient_current_03 ON ((patient_current_03.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb,SUM(duree) duree
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (4)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, p_date_Au)))
  GROUP BY consultation_temp.consulte_par) patient_current_04 ON ((patient_current_04.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb,SUM(duree) duree
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (5)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, p_date_Au)))
  GROUP BY consultation_temp.consulte_par) patient_current_05 ON ((patient_current_05.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb,SUM(duree) duree
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (6)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, p_date_Au)))
  GROUP BY consultation_temp.consulte_par) patient_current_06 ON ((patient_current_06.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb,SUM(duree) duree
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (7)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, p_date_Au)))
  GROUP BY consultation_temp.consulte_par) patient_current_07 ON ((patient_current_07.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb,SUM(duree) duree
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (8)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, p_date_Au)))
  GROUP BY consultation_temp.consulte_par) patient_current_08 ON ((patient_current_08.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb,SUM(duree) duree
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (9)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, p_date_Au)))
 GROUP BY consultation_temp.consulte_par) patient_current_09 ON ((patient_current_09.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb,SUM(duree) duree
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (10)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, p_date_Au)))
  GROUP BY consultation_temp.consulte_par) patient_current_10 ON ((patient_current_10.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb,SUM(duree) duree
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (11)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, p_date_Au)))
 GROUP BY consultation_temp.consulte_par) patient_current_11 ON ((patient_current_11.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb,SUM(duree) duree
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (12)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, p_date_Au)))
 GROUP BY consultation_temp.consulte_par) patient_current_12 ON ((patient_current_12.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (1)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, p_date_Au) - (1)::double precision)))
  GROUP BY consultation_temp.consulte_par) patient_last_01 ON ((patient_last_01.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (2)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, p_date_Au) - (1)::double precision)))
   

		   GROUP BY consultation_temp.consulte_par) patient_last_02 ON ((patient_last_02.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (3)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, p_date_Au) - (1)::double precision)))
 GROUP BY consultation_temp.consulte_par) patient_last_03 ON ((patient_last_03.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (4)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, p_date_Au) - (1)::double precision)))
  GROUP BY consultation_temp.consulte_par) patient_last_04 ON ((patient_last_04.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (5)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, p_date_Au) - (1)::double precision)))
  GROUP BY consultation_temp.consulte_par) patient_last_05 ON ((patient_last_05.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (6)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, p_date_Au) - (1)::double precision)))
  GROUP BY consultation_temp.consulte_par) patient_last_06 ON ((patient_last_06.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (7)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, p_date_Au) - (1)::double precision)))
 GROUP BY consultation_temp.consulte_par) patient_last_07 ON ((patient_last_07.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (8)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, p_date_Au) - (1)::double precision)))
  GROUP BY consultation_temp.consulte_par) patient_last_08 ON ((patient_last_08.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (9)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, p_date_Au) - (1)::double precision)))
 GROUP BY consultation_temp.consulte_par) patient_last_09 ON ((patient_last_09.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (10)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, p_date_Au) - (1)::double precision)))
 GROUP BY consultation_temp.consulte_par) patient_last_10 ON ((patient_last_10.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (11)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, p_date_Au) - (1)::double precision)))
 GROUP BY consultation_temp.consulte_par) patient_last_11 ON ((patient_last_11.consulte_par = users.id)))
LEFT JOIN ( SELECT consultation_temp.consulte_par,
count(*) AS nb
   FROM patient_consultations consultation_temp
  WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (12)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, p_date_Au) - (1)::double precision)))
 GROUP BY consultation_temp.consulte_par) patient_last_12 ON ((patient_last_12.consulte_par = users.id))

)
   WHERE org.id = p_org_id 
		 
;
END;
$$;


ALTER FUNCTION public.statistiques_patients_ages_sexes_consultations_by_users(p_org_id integer, p_date_du date, p_date_au date) OWNER TO postgres;

--
-- Name: statistiques_rdvs_by_org(integer, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.statistiques_rdvs_by_org(p_org_id integer, p_date_du date, p_date_au date) RETURNS TABLE(org_id integer, rdvs numeric, rdv_au_fauteuil numeric, rdv_processed numeric, rdv_presented numeric, rdv_confirmed numeric, rdv_unconfirmed numeric, rdv_cancelled numeric, rdv_current_01 numeric, rdv_current_02 numeric, rdv_current_03 numeric, rdv_current_04 numeric, rdv_current_05 numeric, rdv_current_06 numeric, rdv_current_07 numeric, rdv_current_08 numeric, rdv_current_09 numeric, rdv_current_10 numeric, rdv_current_11 numeric, rdv_current_12 numeric, rdv_last_01 numeric, rdv_last_02 numeric, rdv_last_03 numeric, rdv_last_04 numeric, rdv_last_05 numeric, rdv_last_06 numeric, rdv_last_07 numeric, rdv_last_08 numeric, rdv_last_09 numeric, rdv_last_10 numeric, rdv_last_11 numeric, rdv_last_12 numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN

return query 
	 SELECT 
stats_users.org_id,
SUM(stats_users.rdvs) rdvs,
SUM(stats_users.rdv_au_fauteuil)rdv_au_fauteuil,
SUM(stats_users.rdv_processed)rdv_processed,
SUM(stats_users.rdv_presented)rdv_presented,
SUM(stats_users.rdv_confirmed)rdv_confirmed,
SUM(stats_users.rdv_unconfirmed)rdv_unconfirmed,
SUM(stats_users.rdv_cancelled)rdv_cancelled,
SUM(stats_users.rdv_current_01)rdv_current_01,
SUM(stats_users.rdv_current_02)rdv_current_02,
SUM(stats_users.rdv_current_03)rdv_current_03,
SUM(stats_users.rdv_current_04)rdv_current_04,
SUM(stats_users.rdv_current_05)rdv_current_05,
SUM(stats_users.rdv_current_06)rdv_current_06,
SUM(stats_users.rdv_current_07)rdv_current_07,
SUM(stats_users.rdv_current_08)rdv_current_08,
SUM(stats_users.rdv_current_09)rdv_current_09,
SUM(stats_users.rdv_current_10)rdv_current_10,
SUM(stats_users.rdv_current_11)rdv_current_11,
SUM(stats_users.rdv_current_12)rdv_current_12,
SUM(stats_users.rdv_last_01)rdv_last_01,
SUM(stats_users.rdv_last_02)rdv_last_02,
SUM(stats_users.rdv_last_03)rdv_last_03,
SUM(stats_users.rdv_last_04)rdv_last_04,
SUM(stats_users.rdv_last_05)rdv_last_05,
SUM(stats_users.rdv_last_06)rdv_last_06,
SUM(stats_users.rdv_last_07)rdv_last_07,
SUM(stats_users.rdv_last_08)rdv_last_08,
SUM(stats_users.rdv_last_09)rdv_last_09,
SUM(stats_users.rdv_last_10)rdv_last_10,
SUM(stats_users.rdv_last_11)rdv_last_11,
SUM(stats_users.rdv_last_12)rdv_last_12 
FROM public.statistiques_rdvs_by_users(p_org_id,p_date_du::date,p_date_au::date) stats_users
WHERE stats_users.org_id = p_org_id 
GROUP BY stats_users.org_id;
END;
$$;


ALTER FUNCTION public.statistiques_rdvs_by_org(p_org_id integer, p_date_du date, p_date_au date) OWNER TO postgres;

--
-- Name: statistiques_rdvs_by_users(integer, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.statistiques_rdvs_by_users(p_org_id integer, p_date_du date, p_date_au date) RETURNS TABLE(org_id integer, org character varying, user_id integer, user_name character varying, rdvs bigint, rdv_au_fauteuil bigint, rdv_processed bigint, rdv_presented bigint, rdv_confirmed bigint, rdv_unconfirmed bigint, rdv_cancelled bigint, rdv_current_01 bigint, rdv_current_02 bigint, rdv_current_03 bigint, rdv_current_04 bigint, rdv_current_05 bigint, rdv_current_06 bigint, rdv_current_07 bigint, rdv_current_08 bigint, rdv_current_09 bigint, rdv_current_10 bigint, rdv_current_11 bigint, rdv_current_12 bigint, rdv_last_01 bigint, rdv_last_02 bigint, rdv_last_03 bigint, rdv_last_04 bigint, rdv_last_05 bigint, rdv_last_06 bigint, rdv_last_07 bigint, rdv_last_08 bigint, rdv_last_09 bigint, rdv_last_10 bigint, rdv_last_11 bigint, rdv_last_12 bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
 
return query 
    SELECT org.id AS org_id,
    org.designation AS org,
    users.id AS user_id,
    users.lib AS user_name,

    COALESCE(rdvs.nb, (0)::bigint) AS rdvs,
    COALESCE(rdv_au_fauteuil.nb, (0)::bigint) AS rdv_au_fauteuil,
    COALESCE(rdv_processed.nb, (0)::bigint) AS rdv_processed,
    COALESCE(rdv_presented.nb, (0)::bigint) AS rdv_presented,

    COALESCE(rdv_confirmed.nb, (0)::bigint) AS rdv_confirmed,
    COALESCE(rdv_unconfirmed.nb, (0)::bigint) AS rdv_unconfirmed,
    COALESCE(rdv_cancelled.nb, (0)::bigint) AS rdv_cancelled,

    COALESCE(rdv_current_01.nb, (0)::bigint) AS rdv_current_01,
    COALESCE(rdv_current_02.nb, (0)::bigint) AS rdv_current_02,
    COALESCE(rdv_current_03.nb, (0)::bigint) AS rdv_current_03,
    COALESCE(rdv_current_04.nb, (0)::bigint) AS rdv_current_04,
    COALESCE(rdv_current_05.nb, (0)::bigint) AS rdv_current_05,
    COALESCE(rdv_current_06.nb, (0)::bigint) AS rdv_current_06,
    COALESCE(rdv_current_07.nb, (0)::bigint) AS rdv_current_07,
    COALESCE(rdv_current_08.nb, (0)::bigint) AS rdv_current_08,
    COALESCE(rdv_current_09.nb, (0)::bigint) AS rdv_current_09,
    COALESCE(rdv_current_10.nb, (0)::bigint) AS rdv_current_10,
    COALESCE(rdv_current_11.nb, (0)::bigint) AS rdv_current_11,
    COALESCE(rdv_current_12.nb, (0)::bigint) AS rdv_current_12,
    COALESCE(rdv_last_01.nb, (0)::bigint) AS rdv_last_01,
    COALESCE(rdv_last_02.nb, (0)::bigint) AS rdv_last_02,
    COALESCE(rdv_last_03.nb, (0)::bigint) AS rdv_last_03,
    COALESCE(rdv_last_04.nb, (0)::bigint) AS rdv_last_04,
    COALESCE(rdv_last_05.nb, (0)::bigint) AS rdv_last_05,
    COALESCE(rdv_last_06.nb, (0)::bigint) AS rdv_last_06,
    COALESCE(rdv_last_07.nb, (0)::bigint) AS rdv_last_07,
    COALESCE(rdv_last_08.nb, (0)::bigint) AS rdv_last_08,
    COALESCE(rdv_last_09.nb, (0)::bigint) AS rdv_last_09,
    COALESCE(rdv_last_10.nb, (0)::bigint) AS rdv_last_10,
    COALESCE(rdv_last_11.nb, (0)::bigint) AS rdv_last_11,
    COALESCE(rdv_last_12.nb, (0)::bigint) AS rdv_last_12
  
   FROM org
     JOIN users ON ((org.id = users.org_id))
     
     LEFT JOIN ( SELECT rdv_temp.createdby,
      count(*) AS nb
     FROM patient_rdvs rdv_temp 
      WHERE (startsat >= p_date_du AND startsat <= p_date_Au) 
    GROUP BY rdv_temp.createdby) rdvs ON ((rdvs.createdby = users.id))
      
      LEFT JOIN ( SELECT rdv_temp.createdby,
      count(*) AS nb
     FROM patient_rdvs rdv_temp
    WHERE (startsat >= p_date_du AND startsat <= p_date_Au) 
    AND etat_id = 0
    GROUP BY rdv_temp.createdby) rdv_au_fauteuil ON ((rdv_au_fauteuil.createdby = users.id))

     LEFT JOIN ( SELECT rdv_temp.createdby,
      count(*) AS nb
     FROM patient_rdvs rdv_temp
    WHERE (startsat >= p_date_du AND startsat <= p_date_Au) 
    AND etat_id = 1
    GROUP BY rdv_temp.createdby) rdv_processed ON ((rdv_processed.createdby = users.id))

     LEFT JOIN ( SELECT rdv_temp.createdby,
      count(*) AS nb
     FROM patient_rdvs rdv_temp
    WHERE (startsat >= p_date_du AND startsat <= p_date_Au) 
    AND etat_id = 2
    GROUP BY rdv_temp.createdby) rdv_presented ON ((rdv_presented.createdby = users.id))

     LEFT JOIN ( SELECT rdv_temp.createdby,
      count(*) AS nb
     FROM patient_rdvs rdv_temp
     WHERE (startsat >= p_date_du AND startsat <= p_date_Au) 
     AND etat_id = 3
    GROUP BY rdv_temp.createdby) rdv_confirmed ON ((rdv_confirmed.createdby = users.id))
    
     LEFT JOIN ( SELECT rdv_temp.createdby,
      count(*) AS nb
     FROM patient_rdvs rdv_temp
       WHERE (startsat >= p_date_du AND startsat <= p_date_Au) 
       AND etat_id = 4
   GROUP BY rdv_temp.createdby) rdv_unconfirmed ON ((rdv_unconfirmed.createdby = users.id))

     LEFT JOIN ( SELECT rdv_temp.createdby,
      count(*) AS nb
     FROM patient_rdvs rdv_temp
    WHERE (startsat >= p_date_du AND startsat <= p_date_Au) 
    AND etat_id = 5
    GROUP BY rdv_temp.createdby) rdv_cancelled ON ((rdv_cancelled.createdby = users.id))

    
  
  LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (1)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = date_part('year'::text, p_date_Au))
  GROUP BY  rdv_temp. createdby) rdv_current_01 ON ((rdv_current_01. createdby = users.id))

LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (2)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = date_part('year'::text, p_date_Au))
 GROUP BY  rdv_temp. createdby) rdv_current_02 ON ((rdv_current_02. createdby = users.id))

LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (3)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = date_part('year'::text, p_date_Au))
  GROUP BY  rdv_temp. createdby) rdv_current_03 ON ((rdv_current_03. createdby = users.id))
LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (4)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = date_part('year'::text, p_date_Au))
  GROUP BY  rdv_temp. createdby) rdv_current_04 ON ((rdv_current_04. createdby = users.id))
LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (5)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = date_part('year'::text, p_date_Au))
  GROUP BY  rdv_temp. createdby) rdv_current_05 ON ((rdv_current_05. createdby = users.id))
LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (6)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = date_part('year'::text, p_date_Au))
  GROUP BY  rdv_temp. createdby) rdv_current_06 ON ((rdv_current_06. createdby = users.id))
LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (7)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = date_part('year'::text, p_date_Au))
  GROUP BY  rdv_temp. createdby) rdv_current_07 ON ((rdv_current_07. createdby = users.id))
LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (8)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = date_part('year'::text, p_date_Au))
  GROUP BY  rdv_temp. createdby) rdv_current_08 ON ((rdv_current_08. createdby = users.id))
LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (9)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = date_part('year'::text, p_date_Au))
 GROUP BY  rdv_temp. createdby) rdv_current_09 ON ((rdv_current_09. createdby = users.id))
LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (10)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = date_part('year'::text, p_date_Au))
  GROUP BY  rdv_temp. createdby) rdv_current_10 ON ((rdv_current_10. createdby = users.id))
LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (11)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = date_part('year'::text, p_date_Au))
 GROUP BY  rdv_temp. createdby) rdv_current_11 ON ((rdv_current_11. createdby = users.id))
LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (12)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = date_part('year'::text, p_date_Au))
 GROUP BY  rdv_temp. createdby) rdv_current_12 ON ((rdv_current_12. createdby = users.id))
LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (1)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = (date_part('year'::text, p_date_Au) - (1)::double precision))
  GROUP BY  rdv_temp. createdby) rdv_last_01 ON ((rdv_last_01. createdby = users.id))
LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (2)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = (date_part('year'::text, p_date_Au) - (1)::double precision))
  GROUP BY  rdv_temp. createdby) rdv_last_02 ON ((rdv_last_02. createdby = users.id))
LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (3)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = (date_part('year'::text, p_date_Au) - (1)::double precision))
 GROUP BY  rdv_temp. createdby) rdv_last_03 ON ((rdv_last_03. createdby = users.id))
LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (4)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = (date_part('year'::text, p_date_Au) - (1)::double precision))
  GROUP BY  rdv_temp. createdby) rdv_last_04 ON ((rdv_last_04. createdby = users.id))
LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (5)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = (date_part('year'::text, p_date_Au) - (1)::double precision))
  GROUP BY  rdv_temp. createdby) rdv_last_05 ON ((rdv_last_05. createdby = users.id))
LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (6)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = (date_part('year'::text, p_date_Au) - (1)::double precision))
  GROUP BY  rdv_temp. createdby) rdv_last_06 ON ((rdv_last_06. createdby = users.id))
LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (7)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = (date_part('year'::text, p_date_Au) - (1)::double precision))
 GROUP BY  rdv_temp. createdby) rdv_last_07 ON ((rdv_last_07. createdby = users.id))
LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (8)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = (date_part('year'::text, p_date_Au) - (1)::double precision))
  GROUP BY  rdv_temp. createdby) rdv_last_08 ON ((rdv_last_08. createdby = users.id))
LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (9)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = (date_part('year'::text, p_date_Au) - (1)::double precision))
 GROUP BY  rdv_temp. createdby) rdv_last_09 ON ((rdv_last_09. createdby = users.id))
LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (10)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = (date_part('year'::text, p_date_Au) - (1)::double precision))
 GROUP BY  rdv_temp. createdby) rdv_last_10 ON ((rdv_last_10. createdby = users.id))
LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (11)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = (date_part('year'::text, p_date_Au) - (1)::double precision))
 GROUP BY  rdv_temp. createdby) rdv_last_11 ON ((rdv_last_11. createdby = users.id))
LEFT JOIN ( SELECT  rdv_temp. createdby,
count(*) AS nb
   FROM patient_rdvs   rdv_temp
  WHERE (date_part('month'::text,  rdv_temp.startsat) = (12)::double precision) AND (date_part('year'::text,  rdv_temp.startsat) = (date_part('year'::text, p_date_Au) - (1)::double precision))
 GROUP BY  rdv_temp. createdby) rdv_last_12 ON ((rdv_last_12. createdby = users.id))

 
   WHERE org.id = p_org_id 
   
;
END;
$$;


ALTER FUNCTION public.statistiques_rdvs_by_users(p_org_id integer, p_date_du date, p_date_au date) OWNER TO postgres;

--
-- Name: statistiques_transactions_by_orgs(integer, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.statistiques_transactions_by_orgs(p_org_id integer, p_date_du date, p_date_au date) RETURNS TABLE(org_id integer, nb_credits double precision, montant_credits double precision, nb_debits double precision, montant_debits double precision, recettes_01 double precision, recettes_02 double precision, recettes_03 double precision, recettes_04 double precision, recettes_05 double precision, recettes_06 double precision, recettes_07 double precision, recettes_08 double precision, recettes_09 double precision, recettes_10 double precision, recettes_11 double precision, recettes_12 double precision, depenses_01 double precision, depenses_02 double precision, depenses_03 double precision, depenses_04 double precision, depenses_05 double precision, depenses_06 double precision, depenses_07 double precision, depenses_08 double precision, depenses_09 double precision, depenses_10 double precision, depenses_11 double precision, depenses_12 double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
 
return query 
SELECT org.id AS org_id,
COALESCE(credit_transaction.nb, (0)::double precision) AS nb_credits,
COALESCE(credit_transaction.montant, (0)::double precision) AS montant_credits,
COALESCE(debit_transaction.nb, (0)::double precision) AS nb_debits,
COALESCE(debit_transaction.montant, (0)::double precision) AS montant_debits,

COALESCE(recettes_01.montant, (0)::double precision) AS recettes_01,
COALESCE(recettes_02.montant, (0)::double precision) AS recettes_02,
COALESCE(recettes_03.montant, (0)::double precision) AS recettes_03,
COALESCE(recettes_04.montant, (0)::double precision) AS recettes_04,
COALESCE(recettes_05.montant, (0)::double precision) AS recettes_05,
COALESCE(recettes_06.montant, (0)::double precision) AS recettes_06,
COALESCE(recettes_07.montant, (0)::double precision) AS recettes_07,
COALESCE(recettes_08.montant, (0)::double precision) AS recettes_08,
COALESCE(recettes_09.montant, (0)::double precision) AS recettes_09,
COALESCE(recettes_10.montant, (0)::double precision) AS recettes_10,
COALESCE(recettes_11.montant, (0)::double precision) AS recettes_11,
COALESCE(recettes_12.montant, (0)::double precision) AS recettes_12,
COALESCE(depenses_01.montant, (0)::double precision) AS depenses_01,
COALESCE(depenses_02.montant, (0)::double precision) AS depenses_02,
COALESCE(depenses_03.montant, (0)::double precision) AS depenses_03,
COALESCE(depenses_04.montant, (0)::double precision) AS depenses_04,
COALESCE(depenses_05.montant, (0)::double precision) AS depenses_05,
COALESCE(depenses_06.montant, (0)::double precision) AS depenses_06,
COALESCE(depenses_07.montant, (0)::double precision) AS depenses_07,
COALESCE(depenses_08.montant, (0)::double precision) AS depenses_08,
COALESCE(depenses_09.montant, (0)::double precision) AS depenses_09,
COALESCE(depenses_10.montant, (0)::double precision) AS depenses_10,
COALESCE(depenses_11.montant, (0)::double precision) AS depenses_11,
COALESCE(depenses_12.montant, (0)::double precision) AS depenses_12

FROM org

LEFT JOIN ( 
SELECT  vue_orgs_transactions.org_id,COUNT(*) nb,SUM(montant) montant  
FROM public.vue_orgs_transactions  
WHERE  (date_transaction >= p_date_du AND date_transaction <= p_date_Au) 
AND operation='credit'
GROUP BY vue_orgs_transactions.org_id) credit_transaction ON (credit_transaction.org_id = org.id)

LEFT JOIN ( 
SELECT  vue_orgs_transactions.org_id,COUNT(*) nb,SUM(montant) montant  
FROM public.vue_orgs_transactions  
WHERE  (date_transaction >= p_date_du AND date_transaction <= p_date_Au) 
AND operation='debit'
GROUP BY vue_orgs_transactions.org_id) debit_transaction ON (debit_transaction.org_id = org.id)

LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='credit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (1)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
  GROUP BY  transaction_temp.org_id) recettes_01 ON ((recettes_01.org_id = org.id))

LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='credit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (2)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
 GROUP BY  transaction_temp.org_id) recettes_02 ON ((recettes_02.org_id = org.id))

LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='credit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (3)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
  GROUP BY  transaction_temp.org_id) recettes_03 ON ((recettes_03.org_id = org.id))
LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='credit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (4)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
  GROUP BY  transaction_temp.org_id) recettes_04 ON ((recettes_04.org_id = org.id))
LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='credit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (5)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
  GROUP BY  transaction_temp.org_id) recettes_05 ON ((recettes_05.org_id = org.id))
LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='credit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (6)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
  GROUP BY  transaction_temp.org_id) recettes_06 ON ((recettes_06.org_id = org.id))
LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='credit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (7)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
  GROUP BY  transaction_temp.org_id) recettes_07 ON ((recettes_07.org_id = org.id))
LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='credit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (8)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
  GROUP BY  transaction_temp.org_id) recettes_08 ON ((recettes_08.org_id = org.id))
LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='credit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (9)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
 GROUP BY  transaction_temp.org_id) recettes_09 ON ((recettes_09.org_id = org.id))
LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='credit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (10)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
  GROUP BY  transaction_temp.org_id) recettes_10 ON ((recettes_10.org_id = org.id))
LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='credit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (11)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
 GROUP BY  transaction_temp.org_id) recettes_11 ON ((recettes_11.org_id = org.id))
LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='credit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (12)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
 GROUP BY  transaction_temp.org_id) recettes_12 ON ((recettes_12.org_id = org.id))

 LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='debit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (1)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
  GROUP BY  transaction_temp.org_id) depenses_01 ON ((depenses_01.org_id = org.id))
LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='debit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (2)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
  GROUP BY  transaction_temp.org_id) depenses_02 ON ((depenses_02.org_id = org.id))
LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='debit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (3)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
 GROUP BY  transaction_temp.org_id) depenses_03 ON ((depenses_03.org_id = org.id))
LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='debit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (4)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
  GROUP BY  transaction_temp.org_id) depenses_04 ON ((depenses_04.org_id = org.id))
LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='debit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (5)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
  GROUP BY  transaction_temp.org_id) depenses_05 ON ((depenses_05.org_id = org.id))
LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='debit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (6)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
  GROUP BY  transaction_temp.org_id) depenses_06 ON ((depenses_06.org_id = org.id))
LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='debit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (7)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
 GROUP BY  transaction_temp.org_id) depenses_07 ON ((depenses_07.org_id = org.id))
LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='debit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (8)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
  GROUP BY  transaction_temp.org_id) depenses_08 ON ((depenses_08.org_id = org.id))
LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='debit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (9)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
 GROUP BY  transaction_temp.org_id) depenses_09 ON ((depenses_09.org_id = org.id))
LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='debit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (10)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
 GROUP BY  transaction_temp.org_id) depenses_10 ON ((depenses_10.org_id = org.id))
LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='debit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (11)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
 GROUP BY  transaction_temp.org_id) depenses_11 ON ((depenses_11.org_id = org.id))
LEFT JOIN ( SELECT  transaction_temp.org_id,
count(*) AS nb, SUM(montant) montant
FROM vue_orgs_transactions   transaction_temp
  WHERE  operation='debit' AND (date_part('month'::text,  transaction_temp.date_transaction) = (12)::double precision) AND (date_part('year'::text,  transaction_temp.date_transaction) = date_part('year'::text, p_date_Au))
 GROUP BY  transaction_temp.org_id) depenses_12 ON ((depenses_12.org_id = org.id))

 
WHERE org.id = p_org_id ;
END;
$$;


ALTER FUNCTION public.statistiques_transactions_by_orgs(p_org_id integer, p_date_du date, p_date_au date) OWNER TO postgres;

--
-- Name: users_after_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.users_after_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

 BEGIN
      NEW.fname= initcap(NEW.fname);
      NEW.lname= initcap(NEW.lname);
      NEW.gender= CASE WHEN (UPPER(NEW.gender)='F') THEN 'F' ELSE 'M' END;
      NEW.lib = NEW.fname ||' '||NEW.lname;

      --IF(admin) insert into ,
      --IF(user) insert
 
	INSERT INTO public.users_roles_access_control(
	user_id, table_name, can_create, can_read, can_update, can_delete, createdby, updatedby, active, created, updated, org_id)
VALUES 
(NEW.id,'patients', false, false, false, false, 0, 0, true, now(), now(), NEW.org_id),
(NEW.id,'patients_vitals', false, false, false, false, 0, 0, true, now(), now(), NEW.org_id),
(NEW.id,'patients_pathologies', false, false, false, false, 0, 0, true, now(), now(), NEW.org_id),
(NEW.id,'patients_radiographies', false, false, false, false, 0, 0, true, now(), now(), NEW.org_id),
(NEW.id,'patients_traitements', false, false, false, false, 0, 0, true, now(), now(), NEW.org_id),
(NEW.id,'patients_ordonnances', false, false, false, false, 0, 0, true, now(), now(), NEW.org_id),
(NEW.id,'patients_certificats', false, false, false, false, 0, 0, true, now(), now(), NEW.org_id),
(NEW.id,'patients_rdvs', false, false, false, false, 0, 0, true, now(), now(), NEW.org_id),
(NEW.id,'patients_versements', false, false, false, false, 0, 0, true, now(), now(), NEW.org_id),
(NEW.id,'patients_transactions', false, false, false, false, 0, 0, true, now(), now(), NEW.org_id),
(NEW.id,'static_tables', false, false, false, false, 0, 0, true, now(), now(), NEW.org_id),
(NEW.id,'reports', false, false, false, false, 0, 0, true, now(), now(), NEW.org_id),
(NEW.id,'annuaire', false, false, false, false, 0, 0, true, now(), now(), NEW.org_id),
(NEW.id,'compte', false, false, false, false, 0, 0, true, now(), now(), NEW.org_id),
(NEW.id,'clinique', false, false, false, false, 0, 0, true, now(), now(), NEW.org_id),
(NEW.id,'utilisateurs', false, false, false, false, 0, 0, true, now(), now(), NEW.org_id);
 RETURN NEW;

 END;
$$;


ALTER FUNCTION public.users_after_insert() OWNER TO postgres;

--
-- Name: users_before_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.users_before_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

 BEGIN
      NEW.fname= initcap(NEW.fname);
      NEW.lname= initcap(NEW.lname);
      NEW.gender= CASE WHEN (UPPER(NEW.gender)='F') THEN 'F' ELSE 'M' END;
      NEW.lib = NEW.fname ||' '||NEW.lname;
--INSERT INTO users_roles(user_id) VALUES (new.id);

 RETURN NEW;

 END;
$$;


ALTER FUNCTION public.users_before_insert() OWNER TO postgres;

--
-- Name: users_before_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.users_before_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

 BEGIN
      NEW.fname= initcap(NEW.fname);
      NEW.lname= initcap(NEW.lname);
      NEW.gender= CASE WHEN (UPPER(NEW.gender)='F') THEN 'F' ELSE 'M' END;
      NEW.lib = NEW.fname ||' '||NEW.lname;

      --IF(admin) insert into ,
      --IF(user) insert
  RETURN NEW;
	
 END;
$$;


ALTER FUNCTION public.users_before_update() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: actes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.actes (
    id integer NOT NULL,
    designation character varying(100),
    definition character varying(500),
    procedure_id integer,
    created timestamp without time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true,
    code character varying,
    montant numeric(10,2)
);


ALTER TABLE public.actes OWNER TO postgres;

--
-- Name: actes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.actes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.actes_id_seq OWNER TO postgres;

--
-- Name: actes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.actes_id_seq OWNED BY public.actes.id;


--
-- Name: certificat_motifs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.certificat_motifs (
    id integer NOT NULL,
    designation character varying(100),
    created timestamp without time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true,
    model character varying(2000)
);


ALTER TABLE public.certificat_motifs OWNER TO postgres;

--
-- Name: certificat_motifs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.certificat_motifs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.certificat_motifs_id_seq OWNER TO postgres;

--
-- Name: certificat_motifs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.certificat_motifs_id_seq OWNED BY public.certificat_motifs.id;


--
-- Name: commune; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commune (
    id integer NOT NULL,
    wilaya_id integer NOT NULL,
    code character varying(4),
    designation character varying(100),
    created time with time zone DEFAULT now(),
    createdby integer,
    updated time with time zone DEFAULT now(),
    updatedby integer,
    active boolean DEFAULT true
);


ALTER TABLE public.commune OWNER TO postgres;

--
-- Name: commune_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commune_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.commune_id_seq OWNER TO postgres;

--
-- Name: commune_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commune_id_seq OWNED BY public.commune.id;


--
-- Name: commune_wilaya_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commune_wilaya_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.commune_wilaya_id_seq OWNER TO postgres;

--
-- Name: commune_wilaya_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commune_wilaya_id_seq OWNED BY public.commune.wilaya_id;


--
-- Name: dents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dents (
    num character varying NOT NULL,
    adult boolean DEFAULT true,
    designation character varying(100),
    created timestamp without time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true
);


ALTER TABLE public.dents OWNER TO postgres;

--
-- Name: org; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.org (
    id integer NOT NULL,
    designation character varying(100),
    tel character varying(100),
    email character varying(100) DEFAULT 'dentise@dzental.dz'::character varying,
    site_internet character varying(100),
    adresse character varying(100),
    created time with time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated time with time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true,
    file_name character varying DEFAULT 'Dzental_logo.png'::character varying,
    file_name_background character varying DEFAULT 'B3.jpg'::character varying,
    fax character varying(100),
    wilaya_id integer,
    reminder_delay integer DEFAULT 24,
    is_rappel_rdv_automatique boolean DEFAULT true
);


ALTER TABLE public.org OWNER TO postgres;

--
-- Name: org_directions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.org_directions (
    id integer NOT NULL,
    org_id integer,
    designation character varying(100),
    created time with time zone DEFAULT now(),
    createdby integer,
    updated time with time zone DEFAULT now(),
    updatedby integer,
    active boolean DEFAULT true
);


ALTER TABLE public.org_directions OWNER TO postgres;

--
-- Name: org_professions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.org_professions (
    id integer NOT NULL,
    org_id integer,
    designation character varying(100),
    created time with time zone DEFAULT now(),
    createdby integer,
    updated time with time zone DEFAULT now(),
    updatedby integer,
    active boolean DEFAULT true
);


ALTER TABLE public.org_professions OWNER TO postgres;

--
-- Name: role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role (
    id integer NOT NULL,
    designation character varying(100),
    created time with time zone DEFAULT now(),
    createdby integer,
    updated time with time zone DEFAULT now(),
    updatedby integer,
    active boolean DEFAULT true
);


ALTER TABLE public.role OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    fname character varying(100),
    lname character varying(100),
    gender character varying(1),
    address text,
    email character varying(50),
    password character varying(20),
    createdby integer,
    updatedby integer,
    active boolean DEFAULT true,
    token character varying,
    wilaya_id integer,
    org_id integer,
    org_directions_id integer,
    first_visit boolean DEFAULT true,
    created timestamp without time zone DEFAULT now(),
    updated timestamp without time zone DEFAULT now(),
    lib character varying,
    org_profession_id integer,
    file_name character varying
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_roles (
    id integer NOT NULL,
    user_id integer,
    role_id integer,
    createdby integer DEFAULT 0,
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true,
    created timestamp without time zone DEFAULT now(),
    updated timestamp without time zone DEFAULT now()
);


ALTER TABLE public.users_roles OWNER TO postgres;

--
-- Name: wilaya; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wilaya (
    id integer NOT NULL,
    code character varying(4),
    designation character varying(100),
    createdby integer,
    updatedby integer,
    active boolean DEFAULT true,
    created timestamp without time zone DEFAULT now(),
    updated timestamp without time zone DEFAULT now()
);


ALTER TABLE public.wilaya OWNER TO postgres;

--
-- Name: dzental_users; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.dzental_users AS
 SELECT users.id,
    users.org_id,
    org.designation AS org,
    users.org_directions_id,
    org_directions.designation AS direction,
    users.org_profession_id,
    org_professions.designation AS profession,
    org.tel AS org_tel,
    org.fax AS org_fax,
    org.email AS org_email,
    org.site_internet AS org_site_internet,
    org.adresse AS org_adresse,
    org.wilaya_id AS org_wilaya_id,
    orgwilaya.designation AS org_wilaya,
    org.file_name AS org_logo,
    org.file_name_background AS org_background,
    org.is_rappel_rdv_automatique,
    org.reminder_delay,
    users.wilaya_id,
    wilaya.designation AS wilaya,
    users_roles.role_id,
    role.designation AS user_role,
    users.lname,
    users.fname,
    users.gender,
    users.email,
    users.password,
    users.password AS repassword,
    users.token,
    users.file_name AS avatar,
    COALESCE(users.first_visit, false) AS first_visit,
    COALESCE(users.active, false) AS active,
    users.created,
    users.createdby
   FROM (((((((public.users
     LEFT JOIN public.org ON ((users.org_id = org.id)))
     LEFT JOIN public.org_directions ON ((users.org_directions_id = org_directions.id)))
     LEFT JOIN public.org_professions ON ((users.org_profession_id = org_professions.id)))
     LEFT JOIN public.wilaya orgwilaya ON ((org.wilaya_id = orgwilaya.id)))
     LEFT JOIN public.wilaya ON ((users.wilaya_id = wilaya.id)))
     LEFT JOIN public.users_roles ON ((users.id = users_roles.user_id)))
     LEFT JOIN public.role ON ((role.id = users_roles.role_id)))
  ORDER BY users.id;


ALTER TABLE public.dzental_users OWNER TO postgres;

--
-- Name: etats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.etats (
    id integer NOT NULL,
    designation character varying(100),
    created timestamp without time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true
);


ALTER TABLE public.etats OWNER TO postgres;

--
-- Name: etats_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.etats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.etats_id_seq OWNER TO postgres;

--
-- Name: etats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.etats_id_seq OWNED BY public.etats.id;


--
-- Name: medicaments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medicaments (
    id integer NOT NULL,
    designation character varying(100),
    definition character varying(500),
    created timestamp without time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true,
    code character varying,
    montant numeric(10,2)
);


ALTER TABLE public.medicaments OWNER TO postgres;

--
-- Name: medicaments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.medicaments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.medicaments_id_seq OWNER TO postgres;

--
-- Name: medicaments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.medicaments_id_seq OWNED BY public.medicaments.id;


--
-- Name: motifs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.motifs (
    id integer NOT NULL,
    designation character varying(100),
    created timestamp without time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true
);


ALTER TABLE public.motifs OWNER TO postgres;

--
-- Name: motifs_rdv_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.motifs_rdv_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.motifs_rdv_id_seq OWNER TO postgres;

--
-- Name: motifs_rdv_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.motifs_rdv_id_seq OWNED BY public.motifs.id;


--
-- Name: ordonnance_posologies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ordonnance_posologies (
    id integer NOT NULL,
    designation character varying(100),
    created timestamp without time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true
);


ALTER TABLE public.ordonnance_posologies OWNER TO postgres;

--
-- Name: ordonnance_posologies_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ordonnance_posologies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ordonnance_posologies_id_seq OWNER TO postgres;

--
-- Name: ordonnance_posologies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ordonnance_posologies_id_seq OWNED BY public.ordonnance_posologies.id;


--
-- Name: partenaires; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.partenaires (
    id integer NOT NULL,
    org_id integer,
    designation character varying(100),
    adresse character varying(100),
    email character varying(100),
    tel character varying(100),
    fax character varying(100),
    created timestamp without time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true,
    color character varying DEFAULT 'bisque'::character varying
);


ALTER TABLE public.partenaires OWNER TO postgres;

--
-- Name: org_annuaire_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.org_annuaire_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.org_annuaire_id_seq OWNER TO postgres;

--
-- Name: org_annuaire_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.org_annuaire_id_seq OWNED BY public.partenaires.id;


--
-- Name: org_directions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.org_directions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.org_directions_id_seq OWNER TO postgres;

--
-- Name: org_directions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.org_directions_id_seq OWNED BY public.org_directions.id;


--
-- Name: org_horraires; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.org_horraires (
    id integer NOT NULL,
    org_id integer,
    jour character varying(100),
    heure_de character varying(100),
    heure_a character varying(100),
    created timestamp without time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true
);


ALTER TABLE public.org_horraires OWNER TO postgres;

--
-- Name: org_horraires_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.org_horraires_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.org_horraires_id_seq OWNER TO postgres;

--
-- Name: org_horraires_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.org_horraires_id_seq OWNED BY public.org_horraires.id;


--
-- Name: org_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.org_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.org_id_seq OWNER TO postgres;

--
-- Name: org_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.org_id_seq OWNED BY public.org.id;


--
-- Name: org_produits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.org_produits (
    id integer NOT NULL,
    org_id integer,
    produit_id character varying(100),
    created timestamp without time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true
);


ALTER TABLE public.org_produits OWNER TO postgres;

--
-- Name: org_produits_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.org_produits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.org_produits_id_seq OWNER TO postgres;

--
-- Name: org_produits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.org_produits_id_seq OWNED BY public.org_produits.id;


--
-- Name: org_professions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.org_professions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.org_professions_id_seq OWNER TO postgres;

--
-- Name: org_professions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.org_professions_id_seq OWNED BY public.org_professions.id;


--
-- Name: org_sales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.org_sales (
    id integer NOT NULL,
    org_id integer,
    designation character varying(100),
    created timestamp without time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true
);


ALTER TABLE public.org_sales OWNER TO postgres;

--
-- Name: org_sales_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.org_sales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.org_sales_id_seq OWNER TO postgres;

--
-- Name: org_sales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.org_sales_id_seq OWNED BY public.org_sales.id;


--
-- Name: org_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.org_transactions (
    id integer NOT NULL,
    org_id integer,
    type_transaction_id integer,
    patient_id integer,
    date_transaction timestamp without time zone DEFAULT now(),
    montant double precision,
    observation character varying(500),
    created timestamp without time zone DEFAULT now(),
    createdby integer,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer,
    active boolean DEFAULT true,
    type_paiement_id integer,
    partenaire_id integer
);


ALTER TABLE public.org_transactions OWNER TO postgres;

--
-- Name: org_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.org_transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.org_transactions_id_seq OWNER TO postgres;

--
-- Name: org_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.org_transactions_id_seq OWNED BY public.org_transactions.id;


--
-- Name: pathologies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pathologies (
    id integer NOT NULL,
    designation character varying(100),
    definition character varying(100),
    created timestamp without time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true,
    code character varying
);


ALTER TABLE public.pathologies OWNER TO postgres;

--
-- Name: pathologies_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pathologies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pathologies_id_seq OWNER TO postgres;

--
-- Name: pathologies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pathologies_id_seq OWNED BY public.pathologies.id;


--
-- Name: patient_certificats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_certificats (
    id integer NOT NULL,
    patient_id integer,
    numero_certificat character varying(500),
    date_certificat timestamp without time zone DEFAULT now(),
    observation character varying(500),
    created timestamp without time zone DEFAULT now(),
    createdby integer,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer,
    active boolean DEFAULT true,
    certificat_motifs_id integer
);


ALTER TABLE public.patient_certificats OWNER TO postgres;

--
-- Name: patient_certificats_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.patient_certificats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.patient_certificats_id_seq OWNER TO postgres;

--
-- Name: patient_certificats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.patient_certificats_id_seq OWNED BY public.patient_certificats.id;


--
-- Name: patient_consultations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_consultations (
    id integer NOT NULL,
    patient_id integer,
    date_consultation timestamp without time zone DEFAULT now(),
    duree double precision,
    observation character varying(500),
    created timestamp without time zone DEFAULT now(),
    createdby integer,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer,
    active boolean DEFAULT true,
    consulte_par integer,
    startsat timestamp without time zone,
    endsat timestamp without time zone
);


ALTER TABLE public.patient_consultations OWNER TO postgres;

--
-- Name: patient_consultations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.patient_consultations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.patient_consultations_id_seq OWNER TO postgres;

--
-- Name: patient_consultations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.patient_consultations_id_seq OWNED BY public.patient_consultations.id;


--
-- Name: patients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patients (
    id integer NOT NULL,
    nin character(18),
    nom character varying(100),
    nom_jeune_fille character varying,
    prenom character varying(100),
    sexe character(1),
    date_naiss date DEFAULT now(),
    type_date_naiss character varying,
    lieu_naiss character varying,
    adresse character varying,
    commune_id integer,
    wilaya_id integer,
    situation_familiale character varying,
    ppere character varying,
    nmere character varying,
    pmere character varying,
    lib character varying(200),
    created timestamp without time zone DEFAULT now(),
    createdby integer,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer,
    active boolean DEFAULT true,
    uuid character varying,
    tel character varying,
    email character varying,
    org_id integer
);


ALTER TABLE public.patients OWNER TO postgres;

--
-- Name: patient_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.patient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.patient_id_seq OWNER TO postgres;

--
-- Name: patient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.patient_id_seq OWNED BY public.patients.id;


--
-- Name: patient_ordonnances; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_ordonnances (
    id integer NOT NULL,
    patient_id integer,
    numero_ordonnance character varying(500),
    date_ordonnance timestamp without time zone DEFAULT now(),
    observation character varying(500),
    created timestamp without time zone DEFAULT now(),
    createdby integer,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer,
    active boolean DEFAULT true
);


ALTER TABLE public.patient_ordonnances OWNER TO postgres;

--
-- Name: patient_ordonnances_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_ordonnances_details (
    id integer NOT NULL,
    ordonnance_id integer,
    medicament_id integer,
    observation character varying(500),
    created timestamp without time zone DEFAULT now(),
    createdby integer,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer,
    active boolean DEFAULT true,
    ordonnance_posologies_id integer
);


ALTER TABLE public.patient_ordonnances_details OWNER TO postgres;

--
-- Name: patient_ordonnances_details_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.patient_ordonnances_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.patient_ordonnances_details_id_seq OWNER TO postgres;

--
-- Name: patient_ordonnances_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.patient_ordonnances_details_id_seq OWNED BY public.patient_ordonnances_details.id;


--
-- Name: patient_ordonnances_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.patient_ordonnances_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.patient_ordonnances_id_seq OWNER TO postgres;

--
-- Name: patient_ordonnances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.patient_ordonnances_id_seq OWNED BY public.patient_ordonnances.id;


--
-- Name: patient_pathologies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_pathologies (
    id integer NOT NULL,
    patient_id integer,
    pathologie_id integer,
    gravite character varying(100),
    explicatif character varying(100),
    created timestamp without time zone DEFAULT now(),
    createdby integer,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer,
    active boolean DEFAULT true,
    severite_id integer
);


ALTER TABLE public.patient_pathologies OWNER TO postgres;

--
-- Name: patient_pathologies_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.patient_pathologies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.patient_pathologies_id_seq OWNER TO postgres;

--
-- Name: patient_pathologies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.patient_pathologies_id_seq OWNED BY public.patient_pathologies.id;


--
-- Name: patient_radiographies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_radiographies (
    id integer NOT NULL,
    patient_id integer,
    radiographie_id integer,
    gravite character varying(100),
    explicatif character varying(100),
    created timestamp without time zone DEFAULT now(),
    createdby integer,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer,
    active boolean DEFAULT true,
    file_name character varying
);


ALTER TABLE public.patient_radiographies OWNER TO postgres;

--
-- Name: patient_radiographies_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.patient_radiographies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.patient_radiographies_id_seq OWNER TO postgres;

--
-- Name: patient_radiographies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.patient_radiographies_id_seq OWNED BY public.patient_radiographies.id;


--
-- Name: patient_rdvs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_rdvs (
    id integer NOT NULL,
    patient_id integer,
    etat_id integer DEFAULT 1,
    title character varying(100),
    color character varying(100),
    startsat timestamp without time zone DEFAULT now(),
    endsat timestamp without time zone DEFAULT now(),
    draggable boolean DEFAULT true,
    resizable boolean DEFAULT true,
    created timestamp without time zone DEFAULT now(),
    createdby integer,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer,
    active boolean DEFAULT true,
    motif_id integer,
    reminder_sent boolean DEFAULT false
);


ALTER TABLE public.patient_rdvs OWNER TO postgres;

--
-- Name: patient_rdv_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.patient_rdv_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.patient_rdv_id_seq OWNER TO postgres;

--
-- Name: patient_rdv_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.patient_rdv_id_seq OWNED BY public.patient_rdvs.id;


--
-- Name: patient_traitements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_traitements (
    id integer NOT NULL,
    patient_id integer,
    date_traitement timestamp without time zone DEFAULT now(),
    dent_num character varying,
    procedure_id integer,
    acte_id integer,
    montant double precision DEFAULT 0,
    observation character varying(500),
    created timestamp without time zone DEFAULT now(),
    createdby integer,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer,
    active boolean DEFAULT true
);


ALTER TABLE public.patient_traitements OWNER TO postgres;

--
-- Name: patient_traitements_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.patient_traitements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.patient_traitements_id_seq OWNER TO postgres;

--
-- Name: patient_traitements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.patient_traitements_id_seq OWNED BY public.patient_traitements.id;


--
-- Name: patient_vitals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_vitals (
    id integer NOT NULL,
    patient_id integer,
    vital_id integer,
    valeur character varying,
    created timestamp without time zone DEFAULT now(),
    createdby integer,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer,
    active boolean DEFAULT true
);


ALTER TABLE public.patient_vitals OWNER TO postgres;

--
-- Name: patient_vitals_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.patient_vitals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.patient_vitals_id_seq OWNER TO postgres;

--
-- Name: patient_vitals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.patient_vitals_id_seq OWNED BY public.patient_vitals.id;


--
-- Name: procedures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.procedures (
    id integer NOT NULL,
    designation character varying(100),
    definition character varying(500),
    created timestamp without time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true,
    code character varying
);


ALTER TABLE public.procedures OWNER TO postgres;

--
-- Name: procedures_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.procedures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.procedures_id_seq OWNER TO postgres;

--
-- Name: procedures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.procedures_id_seq OWNED BY public.procedures.id;


--
-- Name: produit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.produit (
    id character varying(100) NOT NULL,
    designation character varying(100),
    created timestamp without time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true,
    code character varying
);


ALTER TABLE public.produit OWNER TO postgres;

--
-- Name: radiographies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.radiographies (
    id integer NOT NULL,
    designation character varying(100),
    definition character varying(500),
    created timestamp without time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true,
    code character varying
);


ALTER TABLE public.radiographies OWNER TO postgres;

--
-- Name: radiographies_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.radiographies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.radiographies_id_seq OWNER TO postgres;

--
-- Name: radiographies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.radiographies_id_seq OWNED BY public.radiographies.id;


--
-- Name: resultat_controle_cnas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.resultat_controle_cnas (
    id integer NOT NULL,
    demande_controle_id integer,
    postulant_id integer,
    result_cnas character varying,
    result_cnas_cjt character varying,
    created timestamp without time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true
);


ALTER TABLE public.resultat_controle_cnas OWNER TO postgres;

--
-- Name: resultat_controle_cnas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.resultat_controle_cnas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.resultat_controle_cnas_id_seq OWNER TO postgres;

--
-- Name: resultat_controle_cnas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.resultat_controle_cnas_id_seq OWNED BY public.resultat_controle_cnas.id;


--
-- Name: resultat_controle_cnr; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.resultat_controle_cnr (
    id integer NOT NULL,
    demande_controle_id integer,
    postulant_id integer,
    result_cnr character varying,
    result_cnr_cjt character varying,
    created timestamp without time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true
);


ALTER TABLE public.resultat_controle_cnr OWNER TO postgres;

--
-- Name: resultat_controle_cnr_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.resultat_controle_cnr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.resultat_controle_cnr_id_seq OWNER TO postgres;

--
-- Name: resultat_controle_cnr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.resultat_controle_cnr_id_seq OWNED BY public.resultat_controle_cnr.id;


--
-- Name: role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.role_id_seq OWNER TO postgres;

--
-- Name: role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.role_id_seq OWNED BY public.role.id;


--
-- Name: severites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.severites (
    id integer NOT NULL,
    designation character varying(100),
    created timestamp without time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true
);


ALTER TABLE public.severites OWNER TO postgres;

--
-- Name: severites_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.severites_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.severites_id_seq OWNER TO postgres;

--
-- Name: severites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.severites_id_seq OWNED BY public.severites.id;


--
-- Name: statistiques_patients_sexes_ages; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.statistiques_patients_sexes_ages AS
 SELECT org.id AS org_id,
    org.designation AS org,
    users.id AS user_id,
    users.lib AS user_name,
    COALESCE(patients.nb, (0)::bigint) AS patients,
    COALESCE(patient_masculin.nb, (0)::bigint) AS patients_masculin,
    COALESCE(patient_feminin.nb, (0)::bigint) AS patients_feminin,
    COALESCE(patient_0_18.nb, (0)::bigint) AS patients_inf_18,
    COALESCE(patient_18_30.nb, (0)::bigint) AS patients_18_30,
    COALESCE(patient_30_40.nb, (0)::bigint) AS patients_30_40,
    COALESCE(patient_40_50.nb, (0)::bigint) AS patients_40_50,
    COALESCE(patient_50_60.nb, (0)::bigint) AS patients_50_60,
    COALESCE(patient_60.nb, (0)::bigint) AS patients_sup_60,
    COALESCE(patient_current_01.nb, (0)::bigint) AS patient_consultation_current_01,
    COALESCE(patient_current_02.nb, (0)::bigint) AS patient_consultation_current_02,
    COALESCE(patient_current_03.nb, (0)::bigint) AS patient_consultation_current_03,
    COALESCE(patient_current_04.nb, (0)::bigint) AS patient_consultation_current_04,
    COALESCE(patient_current_05.nb, (0)::bigint) AS patient_consultation_current_05,
    COALESCE(patient_current_06.nb, (0)::bigint) AS patient_consultation_current_06,
    COALESCE(patient_current_07.nb, (0)::bigint) AS patient_consultation_current_07,
    COALESCE(patient_current_08.nb, (0)::bigint) AS patient_consultation_current_08,
    COALESCE(patient_current_09.nb, (0)::bigint) AS patient_consultation_current_09,
    COALESCE(patient_current_10.nb, (0)::bigint) AS patient_consultation_current_10,
    COALESCE(patient_current_11.nb, (0)::bigint) AS patient_consultation_current_11,
    COALESCE(patient_current_12.nb, (0)::bigint) AS patient_consultation_current_12,
    COALESCE(patient_last_01.nb, (0)::bigint) AS patient_consultation_last_01,
    COALESCE(patient_last_02.nb, (0)::bigint) AS patient_consultation_last_02,
    COALESCE(patient_last_03.nb, (0)::bigint) AS patient_consultation_last_03,
    COALESCE(patient_last_04.nb, (0)::bigint) AS patient_consultation_last_04,
    COALESCE(patient_last_05.nb, (0)::bigint) AS patient_consultation_last_05,
    COALESCE(patient_last_06.nb, (0)::bigint) AS patient_consultation_last_06,
    COALESCE(patient_last_07.nb, (0)::bigint) AS patient_consultation_last_07,
    COALESCE(patient_last_08.nb, (0)::bigint) AS patient_consultation_last_08,
    COALESCE(patient_last_09.nb, (0)::bigint) AS patient_consultation_last_09,
    COALESCE(patient_last_10.nb, (0)::bigint) AS patient_consultation_last_10,
    COALESCE(patient_last_11.nb, (0)::bigint) AS patient_consultation_last_11,
    COALESCE(patient_last_12.nb, (0)::bigint) AS patient_consultation_last_12
   FROM ((((((((((((((((((((((((((((((((((public.org
     JOIN public.users ON ((org.id = users.org_id)))
     LEFT JOIN ( SELECT patient_temp.createdby,
            count(*) AS nb
           FROM public.patients patient_temp
          GROUP BY patient_temp.createdby) patients ON ((patients.createdby = users.id)))
     LEFT JOIN ( SELECT patient_temp.createdby,
            count(*) AS nb
           FROM public.patients patient_temp
          WHERE (patient_temp.sexe = 'M'::bpchar)
          GROUP BY patient_temp.createdby) patient_masculin ON ((patient_masculin.createdby = users.id)))
     LEFT JOIN ( SELECT patient_temp.createdby,
            count(*) AS nb
           FROM public.patients patient_temp
          WHERE (patient_temp.sexe = 'F'::bpchar)
          GROUP BY patient_temp.createdby) patient_feminin ON ((patient_feminin.createdby = users.id)))
     LEFT JOIN ( SELECT patient_temp.createdby,
            count(*) AS nb
           FROM public.patients patient_temp
          WHERE (date_part('year'::text, age((patient_temp.date_naiss)::timestamp with time zone)) < (18)::double precision)
          GROUP BY patient_temp.createdby) patient_0_18 ON ((patient_0_18.createdby = users.id)))
     LEFT JOIN ( SELECT patient_temp.createdby,
            count(*) AS nb
           FROM public.patients patient_temp
          WHERE ((date_part('year'::text, age((patient_temp.date_naiss)::timestamp with time zone)) >= (18)::double precision) AND (date_part('year'::text, age((patient_temp.date_naiss)::timestamp with time zone)) < (30)::double precision))
          GROUP BY patient_temp.createdby) patient_18_30 ON ((patient_18_30.createdby = users.id)))
     LEFT JOIN ( SELECT patient_temp.createdby,
            count(*) AS nb
           FROM public.patients patient_temp
          WHERE ((date_part('year'::text, age((patient_temp.date_naiss)::timestamp with time zone)) >= (30)::double precision) AND (date_part('year'::text, age((patient_temp.date_naiss)::timestamp with time zone)) < (40)::double precision))
          GROUP BY patient_temp.createdby) patient_30_40 ON ((patient_30_40.createdby = users.id)))
     LEFT JOIN ( SELECT patient_temp.createdby,
            count(*) AS nb
           FROM public.patients patient_temp
          WHERE ((date_part('year'::text, age((patient_temp.date_naiss)::timestamp with time zone)) >= (40)::double precision) AND (date_part('year'::text, age((patient_temp.date_naiss)::timestamp with time zone)) < (50)::double precision))
          GROUP BY patient_temp.createdby) patient_40_50 ON ((patient_40_50.createdby = users.id)))
     LEFT JOIN ( SELECT patient_temp.createdby,
            count(*) AS nb
           FROM public.patients patient_temp
          WHERE ((date_part('year'::text, age((patient_temp.date_naiss)::timestamp with time zone)) >= (50)::double precision) AND (date_part('year'::text, age((patient_temp.date_naiss)::timestamp with time zone)) < (60)::double precision))
          GROUP BY patient_temp.createdby) patient_50_60 ON ((patient_50_60.createdby = users.id)))
     LEFT JOIN ( SELECT patient_temp.createdby,
            count(*) AS nb
           FROM public.patients patient_temp
          WHERE (date_part('year'::text, age((patient_temp.date_naiss)::timestamp with time zone)) >= (60)::double precision)
          GROUP BY patient_temp.createdby) patient_60 ON ((patient_60.createdby = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (1)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, now())))
          GROUP BY consultation_temp.consulte_par) patient_current_01 ON ((patient_current_01.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (2)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, now())))
          GROUP BY consultation_temp.consulte_par) patient_current_02 ON ((patient_current_02.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (3)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, now())))
          GROUP BY consultation_temp.consulte_par) patient_current_03 ON ((patient_current_03.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (4)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, now())))
          GROUP BY consultation_temp.consulte_par) patient_current_04 ON ((patient_current_04.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (5)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, now())))
          GROUP BY consultation_temp.consulte_par) patient_current_05 ON ((patient_current_05.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (6)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, now())))
          GROUP BY consultation_temp.consulte_par) patient_current_06 ON ((patient_current_06.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (7)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, now())))
          GROUP BY consultation_temp.consulte_par) patient_current_07 ON ((patient_current_07.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (8)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, now())))
          GROUP BY consultation_temp.consulte_par) patient_current_08 ON ((patient_current_08.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (9)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, now())))
          GROUP BY consultation_temp.consulte_par) patient_current_09 ON ((patient_current_09.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (10)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, now())))
          GROUP BY consultation_temp.consulte_par) patient_current_10 ON ((patient_current_10.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (11)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, now())))
          GROUP BY consultation_temp.consulte_par) patient_current_11 ON ((patient_current_11.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (12)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = date_part('year'::text, now())))
          GROUP BY consultation_temp.consulte_par) patient_current_12 ON ((patient_current_12.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (1)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, now()) - (1)::double precision)))
          GROUP BY consultation_temp.consulte_par) patient_last_01 ON ((patient_last_01.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (2)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, now()) - (1)::double precision)))
          GROUP BY consultation_temp.consulte_par) patient_last_02 ON ((patient_last_02.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (3)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, now()) - (1)::double precision)))
          GROUP BY consultation_temp.consulte_par) patient_last_03 ON ((patient_last_03.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (4)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, now()) - (1)::double precision)))
          GROUP BY consultation_temp.consulte_par) patient_last_04 ON ((patient_last_04.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (5)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, now()) - (1)::double precision)))
          GROUP BY consultation_temp.consulte_par) patient_last_05 ON ((patient_last_05.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (6)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, now()) - (1)::double precision)))
          GROUP BY consultation_temp.consulte_par) patient_last_06 ON ((patient_last_06.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (7)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, now()) - (1)::double precision)))
          GROUP BY consultation_temp.consulte_par) patient_last_07 ON ((patient_last_07.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (8)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, now()) - (1)::double precision)))
          GROUP BY consultation_temp.consulte_par) patient_last_08 ON ((patient_last_08.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (9)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, now()) - (1)::double precision)))
          GROUP BY consultation_temp.consulte_par) patient_last_09 ON ((patient_last_09.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (10)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, now()) - (1)::double precision)))
          GROUP BY consultation_temp.consulte_par) patient_last_10 ON ((patient_last_10.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (11)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, now()) - (1)::double precision)))
          GROUP BY consultation_temp.consulte_par) patient_last_11 ON ((patient_last_11.consulte_par = users.id)))
     LEFT JOIN ( SELECT consultation_temp.consulte_par,
            count(*) AS nb
           FROM public.patient_consultations consultation_temp
          WHERE ((date_part('month'::text, consultation_temp.date_consultation) = (12)::double precision) AND (date_part('year'::text, consultation_temp.date_consultation) = (date_part('year'::text, now()) - (1)::double precision)))
          GROUP BY consultation_temp.consulte_par) patient_last_12 ON ((patient_last_12.consulte_par = users.id)));


ALTER TABLE public.statistiques_patients_sexes_ages OWNER TO postgres;

--
-- Name: types_paiements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.types_paiements (
    id integer NOT NULL,
    designation character varying(100),
    created timestamp without time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true
);


ALTER TABLE public.types_paiements OWNER TO postgres;

--
-- Name: types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.types_id_seq OWNER TO postgres;

--
-- Name: types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.types_id_seq OWNED BY public.types_paiements.id;


--
-- Name: types_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.types_transactions (
    id integer NOT NULL,
    designation character varying(100),
    created timestamp without time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true,
    operation character varying,
    cible character varying
);


ALTER TABLE public.types_transactions OWNER TO postgres;

--
-- Name: types_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.types_transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.types_transactions_id_seq OWNER TO postgres;

--
-- Name: types_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.types_transactions_id_seq OWNED BY public.types_transactions.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_messages (
    id integer NOT NULL,
    read boolean DEFAULT false,
    created timestamp without time zone DEFAULT now(),
    createdby integer,
    to_user_id integer,
    message character varying,
    updatedby integer,
    active boolean DEFAULT true,
    updated timestamp without time zone DEFAULT now()
);


ALTER TABLE public.users_messages OWNER TO postgres;

--
-- Name: users_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_messages_id_seq OWNER TO postgres;

--
-- Name: users_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_messages_id_seq OWNED BY public.users_messages.id;


--
-- Name: users_notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_notifications (
    id integer NOT NULL,
    user_id integer,
    broadcast boolean DEFAULT false,
    expiration_date timestamp with time zone,
    message character varying,
    createdby integer,
    updatedby integer,
    active boolean DEFAULT true,
    read boolean DEFAULT false,
    header character varying,
    created timestamp without time zone DEFAULT now(),
    updated timestamp without time zone DEFAULT now(),
    org_id integer
);


ALTER TABLE public.users_notifications OWNER TO postgres;

--
-- Name: users_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_notifications_id_seq OWNER TO postgres;

--
-- Name: users_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_notifications_id_seq OWNED BY public.users_notifications.id;


--
-- Name: users_produits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_produits (
    id integer NOT NULL,
    user_id integer,
    produit_id character varying(100),
    createdby integer DEFAULT 0,
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true,
    created timestamp without time zone DEFAULT now(),
    updated timestamp without time zone DEFAULT now()
);


ALTER TABLE public.users_produits OWNER TO postgres;

--
-- Name: users_produits_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_produits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_produits_id_seq OWNER TO postgres;

--
-- Name: users_produits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_produits_id_seq OWNED BY public.users_produits.id;


--
-- Name: users_roles_access_control; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_roles_access_control (
    id integer NOT NULL,
    user_id integer,
    role_id integer,
    table_name character varying(100),
    can_create boolean DEFAULT true,
    can_read boolean DEFAULT true,
    can_update boolean DEFAULT true,
    can_delete boolean DEFAULT false,
    createdby integer,
    updatedby integer,
    active boolean DEFAULT true,
    created timestamp without time zone DEFAULT now(),
    updated timestamp without time zone DEFAULT now(),
    org_id integer DEFAULT 1
);


ALTER TABLE public.users_roles_access_control OWNER TO postgres;

--
-- Name: users_roles_access_control_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_roles_access_control_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_roles_access_control_id_seq OWNER TO postgres;

--
-- Name: users_roles_access_control_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_roles_access_control_id_seq OWNED BY public.users_roles_access_control.id;


--
-- Name: users_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_roles_id_seq OWNER TO postgres;

--
-- Name: users_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_roles_id_seq OWNED BY public.users_roles.id;


--
-- Name: users_session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_session (
    id integer NOT NULL,
    user_id integer,
    email character varying(50),
    hostname character varying(100),
    remote_adresse character varying(100),
    remote_port character varying(100),
    localisation character varying(100),
    browser_name character varying(100),
    browser_version character varying(100),
    os_name character varying(100),
    os_version character varying(100),
    devise_name character varying(100),
    devise_version character varying(100),
    token character varying,
    date_online timestamp without time zone DEFAULT now(),
    date_exit timestamp without time zone,
    online boolean DEFAULT true,
    createdby integer,
    updatedby integer,
    active boolean DEFAULT true,
    created timestamp without time zone DEFAULT now(),
    updated timestamp without time zone DEFAULT now()
);


ALTER TABLE public.users_session OWNER TO postgres;

--
-- Name: users_session_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_session_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_session_id_seq OWNER TO postgres;

--
-- Name: users_session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_session_id_seq OWNED BY public.users_session.id;


--
-- Name: vitals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vitals (
    id integer NOT NULL,
    designation character varying(100),
    definition character varying(500),
    created timestamp without time zone DEFAULT now(),
    createdby integer DEFAULT 0,
    updated timestamp without time zone DEFAULT now(),
    updatedby integer DEFAULT 0,
    active boolean DEFAULT true,
    code character varying
);


ALTER TABLE public.vitals OWNER TO postgres;

--
-- Name: vitals_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vitals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vitals_id_seq OWNER TO postgres;

--
-- Name: vitals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vitals_id_seq OWNED BY public.vitals.id;


--
-- Name: vue_org_produits; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vue_org_produits AS
 SELECT org.designation AS org,
    produit.designation,
    produit.id,
    org.id AS org_id,
    produit.created,
    produit.createdby,
    produit.updated,
    produit.updatedby,
    produit.active
   FROM public.org,
    public.org_produits,
    public.produit
  WHERE ((org.id = org_produits.org_id) AND ((org_produits.produit_id)::text = (produit.id)::text))
  ORDER BY org.designation, produit.designation;


ALTER TABLE public.vue_org_produits OWNER TO postgres;

--
-- Name: vue_orgs_transactions; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vue_orgs_transactions AS
 SELECT org_transactions.id,
    org_transactions.org_id,
    org.designation AS org,
    types_transactions.operation,
    org_transactions.type_transaction_id,
    types_transactions.designation AS type_transaction,
    org_transactions.type_paiement_id,
    types_paiements.designation AS type_paiement,
    org_transactions.patient_id,
    patients.lib AS patient,
    org_transactions.partenaire_id,
    partenaires.designation AS partenaire,
    COALESCE(patients.lib, partenaires.designation) AS tiers,
    org_transactions.date_transaction,
        CASE
            WHEN ((types_transactions.operation)::text = 'debit'::text) THEN (('-1'::integer)::double precision * org_transactions.montant)
            ELSE ((1)::double precision * org_transactions.montant)
        END AS montant,
    org_transactions.observation,
    org_transactions.created,
    (((users.fname)::text || ' '::text) || (users.lname)::text) AS createdby,
    org_transactions.updated,
    org_transactions.updatedby,
    org_transactions.active
   FROM ((((((public.org_transactions
     LEFT JOIN public.org ON ((org.id = org_transactions.org_id)))
     LEFT JOIN public.types_transactions ON ((types_transactions.id = org_transactions.type_transaction_id)))
     LEFT JOIN public.types_paiements ON ((types_paiements.id = org_transactions.type_paiement_id)))
     LEFT JOIN public.patients ON ((patients.id = org_transactions.patient_id)))
     LEFT JOIN public.partenaires ON ((partenaires.id = org_transactions.partenaire_id)))
     LEFT JOIN public.users ON ((users.id = org_transactions.createdby)));


ALTER TABLE public.vue_orgs_transactions OWNER TO postgres;

--
-- Name: vue_orgs_transactions_totaux; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vue_orgs_transactions_totaux AS
 SELECT org.id,
    COALESCE(temp_org_transactions_versements.nb, (0)::bigint) AS nb_versements,
    COALESCE(temp_org_transactions_versements.total, (0.0)::double precision) AS montant_versements,
    COALESCE(temp_org_transactions_versements.nb, (0)::bigint) AS nb_paiements,
    (COALESCE(temp_org_transactions_versements.total, (0.0)::double precision) * ('-1'::integer)::double precision) AS montant_paiements
   FROM ((public.org
     LEFT JOIN ( SELECT org_transactions.org_id,
            count(org_transactions.*) AS nb,
            sum(org_transactions.montant) AS total
           FROM public.org_transactions
          GROUP BY org_transactions.org_id) temp_org_transactions_versements ON ((temp_org_transactions_versements.org_id = org.id)))
     LEFT JOIN ( SELECT org_transactions.org_id,
            count(org_transactions.*) AS nb,
            sum(org_transactions.montant) AS total
           FROM public.org_transactions
          GROUP BY org_transactions.org_id) temp_org_transactions_paiements ON ((temp_org_transactions_paiements.org_id = org.id)));


ALTER TABLE public.vue_orgs_transactions_totaux OWNER TO postgres;

--
-- Name: vue_patients; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vue_patients AS
 SELECT patients.id,
    patients.nin,
    patients.nom,
    patients.nom_jeune_fille,
    patients.prenom,
    patients.sexe,
    patients.date_naiss,
    patients.type_date_naiss,
    patients.lieu_naiss,
    patients.adresse,
    patients.situation_familiale,
    patients.ppere,
    patients.nmere,
    patients.pmere,
    patients.lib,
    patients.tel,
    patients.email,
    patients.created,
    patients.createdby,
    patients.updated,
    patients.updatedby,
    patients.active,
    patients.uuid,
    patients.wilaya_id,
    wilaya.designation AS wilaya,
    patients.commune_id,
    commune.designation AS commune,
    users.id AS users_id,
    (((users.lname)::text || ' '::text) || (users.fname)::text) AS cree_par,
    users.org_id,
    org.designation AS org,
    temp_patient_vitals.nb AS nb_vitals,
    temp_patient_pathologies.nb AS nb_pathologies,
    temp_patient_radiographies.nb AS nb_radiographies,
    temp_patient_traitements.nb AS nb_traitements,
    temp_patient_ordonnances.nb AS nb_ordonnances,
    temp_patient_certificats.nb AS nb_certificats,
    temp_patient_rdvs.nb AS nb_rdvs,
    temp_org_transactions.nb AS nb_versements,
    temp_patient_traitements.total AS total_montant_actes,
    temp_org_transactions.total AS total_montant_verse
   FROM ((((((((((((public.patients
     LEFT JOIN public.users ON ((users.id = patients.createdby)))
     LEFT JOIN public.org ON ((users.org_id = org.id)))
     LEFT JOIN public.wilaya ON ((patients.wilaya_id = wilaya.id)))
     LEFT JOIN public.commune ON ((patients.commune_id = commune.id)))
     LEFT JOIN ( SELECT patient_vitals.patient_id,
            count(patient_vitals.*) AS nb
           FROM public.patient_vitals
          GROUP BY patient_vitals.patient_id) temp_patient_vitals ON ((temp_patient_vitals.patient_id = patients.id)))
     LEFT JOIN ( SELECT patient_pathologies.patient_id,
            count(patient_pathologies.*) AS nb
           FROM public.patient_pathologies
          GROUP BY patient_pathologies.patient_id) temp_patient_pathologies ON ((temp_patient_pathologies.patient_id = patients.id)))
     LEFT JOIN ( SELECT patient_radiographies.patient_id,
            count(patient_radiographies.*) AS nb
           FROM public.patient_radiographies
          GROUP BY patient_radiographies.patient_id) temp_patient_radiographies ON ((temp_patient_radiographies.patient_id = patients.id)))
     LEFT JOIN ( SELECT patient_traitements.patient_id,
            count(patient_traitements.*) AS nb,
            sum(patient_traitements.montant) AS total
           FROM public.patient_traitements
          GROUP BY patient_traitements.patient_id) temp_patient_traitements ON ((temp_patient_traitements.patient_id = patients.id)))
     LEFT JOIN ( SELECT patient_ordonnances.patient_id,
            count(patient_ordonnances.*) AS nb
           FROM public.patient_ordonnances
          GROUP BY patient_ordonnances.patient_id) temp_patient_ordonnances ON ((temp_patient_ordonnances.patient_id = patients.id)))
     LEFT JOIN ( SELECT patient_certificats.patient_id,
            count(patient_certificats.*) AS nb
           FROM public.patient_certificats
          GROUP BY patient_certificats.patient_id) temp_patient_certificats ON ((temp_patient_certificats.patient_id = patients.id)))
     LEFT JOIN ( SELECT patient_rdvs.patient_id,
            count(patient_rdvs.*) AS nb
           FROM public.patient_rdvs
          GROUP BY patient_rdvs.patient_id) temp_patient_rdvs ON ((temp_patient_rdvs.patient_id = patients.id)))
     LEFT JOIN ( SELECT vue_orgs_transactions.patient_id,
            count(vue_orgs_transactions.*) AS nb,
            sum(vue_orgs_transactions.montant) AS total
           FROM public.vue_orgs_transactions
          GROUP BY vue_orgs_transactions.patient_id) temp_org_transactions ON ((temp_org_transactions.patient_id = patients.id)))
  WHERE patients.active;


ALTER TABLE public.vue_patients OWNER TO postgres;

--
-- Name: vue_patients_ordonnances; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vue_patients_ordonnances AS
 SELECT patient_ordonnances.patient_id,
    patient_ordonnances.id,
    patient_ordonnances.numero_ordonnance,
    patient_ordonnances.date_ordonnance,
    patient_ordonnances.observation,
    replace(replace(array_to_string(ordonnances_details.details, ','::text, '*'::text), ','::text, '<br>'::text), '()'::text, ''::text) AS details
   FROM (public.patient_ordonnances
     LEFT JOIN ( SELECT patient_ordonnances_details.ordonnance_id,
            array_agg((((((('- <b class="text-spacing">'::text || (medicaments.designation)::text) || '</b> <span class="float-right">('::text) || (patient_ordonnances_details.observation)::text) || ')</span> <br><b>'::text) || (ordonnance_posologies.designation)::text) || '</b>'::text)) AS details
           FROM ((public.patient_ordonnances_details
             JOIN public.medicaments ON ((patient_ordonnances_details.medicament_id = medicaments.id)))
             JOIN public.ordonnance_posologies ON ((patient_ordonnances_details.ordonnance_posologies_id = ordonnance_posologies.id)))
          GROUP BY patient_ordonnances_details.ordonnance_id) ordonnances_details ON ((ordonnances_details.ordonnance_id = patient_ordonnances.id)));


ALTER TABLE public.vue_patients_ordonnances OWNER TO postgres;

--
-- Name: vue_users_messages; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vue_users_messages AS
 SELECT users_messages.id,
    users_messages.read,
    users_messages.created,
    users_messages.createdby,
    sender.lib AS sender_name,
    sender.file_name AS sender_avatar,
    users_messages.to_user_id,
    receiver.lib AS receiver_name,
    users_messages.message,
    users_messages.updatedby,
    users_messages.updated,
    users_messages.active
   FROM ((public.users_messages
     JOIN public.users sender ON ((users_messages.createdby = sender.id)))
     JOIN public.users receiver ON ((users_messages.to_user_id = receiver.id)))
  ORDER BY users_messages.id;


ALTER TABLE public.vue_users_messages OWNER TO postgres;

--
-- Name: vue_users_produits; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vue_users_produits AS
 SELECT users.id AS users_id,
    (((users.fname)::text || ' '::text) || (users.lname)::text) AS utilisateur,
    produit.id,
    produit.designation,
    produit.created,
    produit.createdby,
    produit.updated,
    produit.updatedby,
    produit.active
   FROM public.users,
    public.users_produits,
    public.produit
  WHERE ((users.id = users_produits.user_id) AND ((users_produits.produit_id)::text = (produit.id)::text))
  ORDER BY users.id;


ALTER TABLE public.vue_users_produits OWNER TO postgres;

--
-- Name: vue_users_sessions_age; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vue_users_sessions_age AS
 SELECT users_session.id AS session_id,
    users_session.user_id,
    users_session.created,
    users_session.token,
    age(now(), (users_session.created)::timestamp with time zone) AS age,
    ((((((date_part('years'::text, age(now(), (users_session.created)::timestamp with time zone)) * (24)::double precision) * (30)::double precision) * (12)::double precision) + ((date_part('month'::text, age(now(), (users_session.created)::timestamp with time zone)) * (24)::double precision) * (30)::double precision)) + (date_part('day'::text, age(now(), (users_session.created)::timestamp with time zone)) * (24)::double precision)) + date_part('hour'::text, age(now(), (users_session.created)::timestamp with time zone))) AS age_hours
   FROM (public.users_session
     JOIN public.users ON ((users_session.user_id = users.id)))
  WHERE (users_session.online AND (users.active = true));


ALTER TABLE public.vue_users_sessions_age OWNER TO postgres;

--
-- Name: wilaya_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wilaya_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.wilaya_id_seq OWNER TO postgres;

--
-- Name: wilaya_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wilaya_id_seq OWNED BY public.wilaya.id;


--
-- Name: actes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actes ALTER COLUMN id SET DEFAULT nextval('public.actes_id_seq'::regclass);


--
-- Name: certificat_motifs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.certificat_motifs ALTER COLUMN id SET DEFAULT nextval('public.certificat_motifs_id_seq'::regclass);


--
-- Name: commune id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commune ALTER COLUMN id SET DEFAULT nextval('public.commune_id_seq'::regclass);


--
-- Name: commune wilaya_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commune ALTER COLUMN wilaya_id SET DEFAULT nextval('public.commune_wilaya_id_seq'::regclass);


--
-- Name: etats id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.etats ALTER COLUMN id SET DEFAULT nextval('public.etats_id_seq'::regclass);


--
-- Name: medicaments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicaments ALTER COLUMN id SET DEFAULT nextval('public.medicaments_id_seq'::regclass);


--
-- Name: motifs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.motifs ALTER COLUMN id SET DEFAULT nextval('public.motifs_rdv_id_seq'::regclass);


--
-- Name: ordonnance_posologies id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ordonnance_posologies ALTER COLUMN id SET DEFAULT nextval('public.ordonnance_posologies_id_seq'::regclass);


--
-- Name: org id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.org ALTER COLUMN id SET DEFAULT nextval('public.org_id_seq'::regclass);


--
-- Name: org_directions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.org_directions ALTER COLUMN id SET DEFAULT nextval('public.org_directions_id_seq'::regclass);


--
-- Name: org_horraires id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.org_horraires ALTER COLUMN id SET DEFAULT nextval('public.org_horraires_id_seq'::regclass);


--
-- Name: org_produits id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.org_produits ALTER COLUMN id SET DEFAULT nextval('public.org_produits_id_seq'::regclass);


--
-- Name: org_professions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.org_professions ALTER COLUMN id SET DEFAULT nextval('public.org_professions_id_seq'::regclass);


--
-- Name: org_sales id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.org_sales ALTER COLUMN id SET DEFAULT nextval('public.org_sales_id_seq'::regclass);


--
-- Name: org_transactions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.org_transactions ALTER COLUMN id SET DEFAULT nextval('public.org_transactions_id_seq'::regclass);


--
-- Name: partenaires id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.partenaires ALTER COLUMN id SET DEFAULT nextval('public.org_annuaire_id_seq'::regclass);


--
-- Name: pathologies id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pathologies ALTER COLUMN id SET DEFAULT nextval('public.pathologies_id_seq'::regclass);


--
-- Name: patient_certificats id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_certificats ALTER COLUMN id SET DEFAULT nextval('public.patient_certificats_id_seq'::regclass);


--
-- Name: patient_consultations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_consultations ALTER COLUMN id SET DEFAULT nextval('public.patient_consultations_id_seq'::regclass);


--
-- Name: patient_ordonnances id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_ordonnances ALTER COLUMN id SET DEFAULT nextval('public.patient_ordonnances_id_seq'::regclass);


--
-- Name: patient_ordonnances_details id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_ordonnances_details ALTER COLUMN id SET DEFAULT nextval('public.patient_ordonnances_details_id_seq'::regclass);


--
-- Name: patient_pathologies id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_pathologies ALTER COLUMN id SET DEFAULT nextval('public.patient_pathologies_id_seq'::regclass);


--
-- Name: patient_radiographies id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_radiographies ALTER COLUMN id SET DEFAULT nextval('public.patient_radiographies_id_seq'::regclass);


--
-- Name: patient_rdvs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_rdvs ALTER COLUMN id SET DEFAULT nextval('public.patient_rdv_id_seq'::regclass);


--
-- Name: patient_traitements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_traitements ALTER COLUMN id SET DEFAULT nextval('public.patient_traitements_id_seq'::regclass);


--
-- Name: patient_vitals id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_vitals ALTER COLUMN id SET DEFAULT nextval('public.patient_vitals_id_seq'::regclass);


--
-- Name: patients id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients ALTER COLUMN id SET DEFAULT nextval('public.patient_id_seq'::regclass);


--
-- Name: procedures id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.procedures ALTER COLUMN id SET DEFAULT nextval('public.procedures_id_seq'::regclass);


--
-- Name: radiographies id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.radiographies ALTER COLUMN id SET DEFAULT nextval('public.radiographies_id_seq'::regclass);


--
-- Name: resultat_controle_cnas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resultat_controle_cnas ALTER COLUMN id SET DEFAULT nextval('public.resultat_controle_cnas_id_seq'::regclass);


--
-- Name: resultat_controle_cnr id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resultat_controle_cnr ALTER COLUMN id SET DEFAULT nextval('public.resultat_controle_cnr_id_seq'::regclass);


--
-- Name: role id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role ALTER COLUMN id SET DEFAULT nextval('public.role_id_seq'::regclass);


--
-- Name: severites id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.severites ALTER COLUMN id SET DEFAULT nextval('public.severites_id_seq'::regclass);


--
-- Name: types_paiements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.types_paiements ALTER COLUMN id SET DEFAULT nextval('public.types_id_seq'::regclass);


--
-- Name: types_transactions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.types_transactions ALTER COLUMN id SET DEFAULT nextval('public.types_transactions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_messages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_messages ALTER COLUMN id SET DEFAULT nextval('public.users_messages_id_seq'::regclass);


--
-- Name: users_notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_notifications ALTER COLUMN id SET DEFAULT nextval('public.users_notifications_id_seq'::regclass);


--
-- Name: users_produits id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_produits ALTER COLUMN id SET DEFAULT nextval('public.users_produits_id_seq'::regclass);


--
-- Name: users_roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_roles ALTER COLUMN id SET DEFAULT nextval('public.users_roles_id_seq'::regclass);


--
-- Name: users_roles_access_control id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_roles_access_control ALTER COLUMN id SET DEFAULT nextval('public.users_roles_access_control_id_seq'::regclass);


--
-- Name: users_session id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_session ALTER COLUMN id SET DEFAULT nextval('public.users_session_id_seq'::regclass);


--
-- Name: vitals id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vitals ALTER COLUMN id SET DEFAULT nextval('public.vitals_id_seq'::regclass);


--
-- Name: wilaya id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wilaya ALTER COLUMN id SET DEFAULT nextval('public.wilaya_id_seq'::regclass);


--
-- Data for Name: actes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.actes (id, designation, definition, procedure_id, created, createdby, updated, updatedby, active, code, montant) FROM stdin;
3	Intraoral - Série complète d'images radiographiques.	\N	3	2020-11-17 14:13:34.440336	0	2020-11-17 14:13:34.440336	0	t	\N	4000.00
6	Amputation de racine - par racine\n	\N	6	2020-11-17 14:14:57.956944	0	2020-11-17 14:14:57.956944	0	t	\N	2000.00
4	Inhalation d'oxyde nitreux / analgésie, anxiolyse	\N	4	2020-11-17 14:13:53.833634	0	2020-11-17 14:13:53.833634	0	t	\N	400.00
5	Composite à base de résine - une surface, antérieure\n	\N	5	2020-11-17 14:14:41.665925	0	2020-11-17 14:14:41.665925	0	t	\N	3000.00
7	Scellant - par dent	\N	7	2020-11-17 14:15:37.201913	0	2020-11-17 14:15:37.201913	0	t	\N	1000.00
8	Blanchiment de la dent décolorée	\N	8	2020-11-17 14:16:03.438839	0	2020-11-17 14:16:03.438839	0	t	\N	5500.00
9	Couronne: porcelaine fusionnée à un métal noble	\N	9	2020-11-17 14:16:33.593489	0	2020-11-17 14:16:33.593489	0	t	\N	15000.00
10	Dispositif de retenue supporté par pilier pour porcelaine fusionnée au métal FPD (high noble metal)	\N	10	2020-11-17 14:17:06.543737	0	2020-11-17 14:17:06.543737	0	t	\N	200000.00
11	Traitement orthodontique complet de la dentition adolescente	\N	11	2020-11-17 14:18:48.669885	0	2020-11-17 14:18:48.669885	0	t	\N	6000.00
12	Retrait de la dent incluse - complètement osseuse	\N	12	2020-11-17 14:19:11.656289	0	2020-11-17 14:19:11.656289	0	t	\N	3500.00
1	Évaluation orale, patient de moins de trois ans et counseling avec le principal soignant.	\N	1	2020-11-17 14:11:37.043015	0	2020-11-17 14:11:37.043015	0	t	\N	1000.00
2	Prophylaxie - Adulte	\N	2	2020-11-17 14:12:55.546413	0	2020-11-17 14:12:55.546413	0	t	\N	1500.12
\.


--
-- Data for Name: certificat_motifs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.certificat_motifs (id, designation, created, createdby, updated, updatedby, active, model) FROM stdin;
1	Maladie de 3 jours	2020-12-26 15:41:37.869704	1	2021-01-15 15:55:28.552692	1	t	JE SOUSSIGNE (E)………………………………………………………………………………..\nDOCTEUR EN MEDECINE, CERTIFIE\nAVOIR EXAMINE AUJOURD’HUI M. / Mme………………………………………………..\nLE/LA PATIENT(E) EST EN BONNE SANTE PHYSIQUE ET NE SOUFFRE PAS DE GRAVES MALADIES\nCHRONIQUES OU VENERIENNES, DE TUBERCULOSE NI D’AUTRE MALADIE MORTELLE.\nLES ANALYSES SEROLOGIQUES HIV : NEGATIVES\nLE PRESENT CERTIFICAT EST DELIVRE AU PROFIT DE M. /Mme ………………..…..\nEN VUE D’UNE ADOPTION INTERNATIONALE.&nbsp;&nbsp;<br>
2	Maladie	2020-12-26 15:47:32.056463	1	2021-01-15 15:58:11.279218	1	t	bla vojfiojsifjsdoi fjsdiofj sdiofj sdiofj siojf sidjf siodjf iosdjf iosjfizejfizej fijfio jzeifj sdij oifjzeoi fzoiejzioej ioz j ij&nbsp;
\.


--
-- Data for Name: commune; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.commune (id, wilaya_id, code, designation, created, createdby, updated, updatedby, active) FROM stdin;
1	0	01	ETRANGER	23:53:21.216+02	0	23:53:21.216+02	0	t
2	0	02	NON DEFINIE	23:53:21.216+02	0	23:53:21.216+02	0	t
3	1	0111	Zaouiet-Kounta	23:53:21.216+02	0	23:53:21.216+02	0	t
4	1	0112	Aoulef	23:53:21.216+02	0	23:53:21.216+02	0	t
5	1	0113	Timekten	23:53:21.216+02	0	23:53:21.216+02	0	t
6	1	0114	Tamantit	23:53:21.216+02	0	23:53:21.216+02	0	t
7	1	0115	Fenoughil	23:53:21.216+02	0	23:53:21.216+02	0	t
8	1	0116	Tinerkouk	23:53:21.216+02	0	23:53:21.216+02	0	t
9	1	0117	Deldoul	23:53:21.216+02	0	23:53:21.216+02	0	t
10	1	0118	Sali	23:53:21.216+02	0	23:53:21.216+02	0	t
11	1	0119	Akabli	23:53:21.216+02	0	23:53:21.216+02	0	t
12	1	0120	Metarfa	23:53:21.216+02	0	23:53:21.216+02	0	t
13	1	0121	Ouled Ahmed Timmi	23:53:21.216+02	0	23:53:21.216+02	0	t
14	1	0122	Bouda	23:53:21.216+02	0	23:53:21.216+02	0	t
15	1	0123	Aougrout	23:53:21.216+02	0	23:53:21.216+02	0	t
16	1	0124	Talmine	23:53:21.216+02	0	23:53:21.216+02	0	t
17	1	0125	Bordj Badji Mokhtar	23:53:21.216+02	0	23:53:21.216+02	0	t
18	1	0127	Ouled Aissa	23:53:21.216+02	0	23:53:21.216+02	0	t
19	1	0128	Timiaouine	23:53:21.216+02	0	23:53:21.216+02	0	t
20	1	0110	Ouled Said	23:53:21.216+02	0	23:53:21.216+02	0	t
21	1	0126	Sbaa	23:53:21.216+02	0	23:53:21.216+02	0	t
22	1	0102	Tamest	23:53:21.216+02	0	23:53:21.216+02	0	t
23	1	0103	Charouine	23:53:21.216+02	0	23:53:21.216+02	0	t
24	1	0104	Reggane	23:53:21.216+02	0	23:53:21.216+02	0	t
25	1	0105	In Zghmir	23:53:21.216+02	0	23:53:21.216+02	0	t
26	1	0106	Tit	23:53:21.216+02	0	23:53:21.216+02	0	t
27	1	0107	Ksar Kaddour	23:53:21.216+02	0	23:53:21.216+02	0	t
28	1	0108	Tsabit	23:53:21.216+02	0	23:53:21.216+02	0	t
29	1	0109	Timimoun	23:53:21.216+02	0	23:53:21.216+02	0	t
30	1	0101	Adrar	23:53:21.216+02	0	23:53:21.216+02	0	t
31	2	0202	Tenes	23:53:21.216+02	0	23:53:21.216+02	0	t
32	2	0203	Benairia	23:53:21.216+02	0	23:53:21.216+02	0	t
33	2	0204	El Karimia	23:53:21.216+02	0	23:53:21.216+02	0	t
34	2	0205	Tadjena	23:53:21.216+02	0	23:53:21.216+02	0	t
35	2	0206	Taougrite	23:53:21.216+02	0	23:53:21.216+02	0	t
36	2	0207	Beni Haoua	23:53:21.216+02	0	23:53:21.216+02	0	t
37	2	0208	Sobha	23:53:21.216+02	0	23:53:21.216+02	0	t
38	2	0209	Harchoun	23:53:21.216+02	0	23:53:21.216+02	0	t
39	2	0210	Ouled Fares	23:53:21.216+02	0	23:53:21.216+02	0	t
40	2	0217	Dahra	23:53:21.216+02	0	23:53:21.216+02	0	t
41	2	0211	Sidi Akkacha	23:53:21.216+02	0	23:53:21.216+02	0	t
42	2	0212	Boukadir	23:53:21.216+02	0	23:53:21.216+02	0	t
43	2	0213	Beni Rached	23:53:21.216+02	0	23:53:21.216+02	0	t
44	2	0214	Talassa	23:53:21.216+02	0	23:53:21.216+02	0	t
45	2	0215	Harenfa	23:53:21.216+02	0	23:53:21.216+02	0	t
46	2	0216	Oued Goussine	23:53:21.216+02	0	23:53:21.216+02	0	t
47	2	0218	Ouled Abbes	23:53:21.216+02	0	23:53:21.216+02	0	t
48	2	0219	Sendjas	23:53:21.216+02	0	23:53:21.216+02	0	t
49	2	0220	Zeboudja	23:53:21.216+02	0	23:53:21.216+02	0	t
50	2	0221	Oued Sly	23:53:21.216+02	0	23:53:21.216+02	0	t
51	2	0222	Abou El Hassen	23:53:21.216+02	0	23:53:21.216+02	0	t
52	2	0223	El Marsa	23:53:21.216+02	0	23:53:21.216+02	0	t
53	2	0224	Chettia	23:53:21.216+02	0	23:53:21.216+02	0	t
54	2	0225	Sidi Abderrahmane	23:53:21.216+02	0	23:53:21.216+02	0	t
55	2	0226	Moussadek	23:53:21.216+02	0	23:53:21.216+02	0	t
56	2	0227	El Hadjadj	23:53:21.216+02	0	23:53:21.216+02	0	t
57	2	0228	Labiodh Medjadja	23:53:21.216+02	0	23:53:21.216+02	0	t
58	2	0229	Oued Fodda	23:53:21.216+02	0	23:53:21.216+02	0	t
59	2	0230	Ouled Ben AEK	23:53:21.216+02	0	23:53:21.216+02	0	t
60	2	0231	Bouzghaia	23:53:21.216+02	0	23:53:21.216+02	0	t
61	2	0232	Ain Merane	23:53:21.216+02	0	23:53:21.216+02	0	t
62	2	0233	Oum Drou	23:53:21.216+02	0	23:53:21.216+02	0	t
63	2	0234	Breira	23:53:21.216+02	0	23:53:21.216+02	0	t
64	2	0235	Beni Bouateb	23:53:21.216+02	0	23:53:21.216+02	0	t
65	2	0201	Chlef	23:53:21.216+02	0	23:53:21.216+02	0	t
66	3	0320	El Assafia	23:53:21.216+02	0	23:53:21.216+02	0	t
67	3	0321	Oued Morra	23:53:21.216+02	0	23:53:21.216+02	0	t
68	3	0322	Oued M'Zi	23:53:21.216+02	0	23:53:21.216+02	0	t
69	3	0323	El Houita	23:53:21.216+02	0	23:53:21.216+02	0	t
70	3	0324	Sidi Bouzid	23:53:21.216+02	0	23:53:21.216+02	0	t
71	3	0301	Laghouat	23:53:21.216+02	0	23:53:21.216+02	0	t
72	3	0302	Ksar.Hirane	23:53:21.216+02	0	23:53:21.216+02	0	t
73	3	0303	Bennaceur Benchohra	23:53:21.216+02	0	23:53:21.216+02	0	t
74	3	0304	Sidi Makhlouf	23:53:21.216+02	0	23:53:21.216+02	0	t
75	3	0305	Hassi Dalaa	23:53:21.216+02	0	23:53:21.216+02	0	t
76	3	0306	Hassi R'mel	23:53:21.216+02	0	23:53:21.216+02	0	t
77	3	0307	Ain Mahdi	23:53:21.216+02	0	23:53:21.216+02	0	t
78	3	0308	Tadjemount	23:53:21.216+02	0	23:53:21.216+02	0	t
79	3	0309	Khenneg	23:53:21.216+02	0	23:53:21.216+02	0	t
80	3	0310	Gueltat Sidi Saad	23:53:21.216+02	0	23:53:21.216+02	0	t
81	3	0311	Ain Sidi Ali	23:53:21.216+02	0	23:53:21.216+02	0	t
82	3	0312	Beidha	23:53:21.216+02	0	23:53:21.216+02	0	t
83	3	0313	Brida	23:53:21.216+02	0	23:53:21.216+02	0	t
84	3	0314	El Ghicha	23:53:21.216+02	0	23:53:21.216+02	0	t
85	3	0315	Hadj Mecheri	23:53:21.216+02	0	23:53:21.216+02	0	t
86	3	0316	Sebgag	23:53:21.216+02	0	23:53:21.216+02	0	t
87	3	0317	Taouila	23:53:21.216+02	0	23:53:21.216+02	0	t
88	3	0318	Tajrouna	23:53:21.216+02	0	23:53:21.216+02	0	t
89	3	0319	Aflou	23:53:21.216+02	0	23:53:21.216+02	0	t
90	4	0419	El Fedjoudj B.Si	23:53:21.216+02	0	23:53:21.216+02	0	t
91	4	0420	Ouled Zouai	23:53:21.216+02	0	23:53:21.216+02	0	t
92	4	0403	Ain M'lila	23:53:21.216+02	0	23:53:21.216+02	0	t
93	4	0404	Behir Chergui	23:53:21.216+02	0	23:53:21.216+02	0	t
94	4	0405	El Amiria	23:53:21.216+02	0	23:53:21.216+02	0	t
95	4	0406	Sigus	23:53:21.216+02	0	23:53:21.216+02	0	t
96	4	0407	El Belala	23:53:21.216+02	0	23:53:21.216+02	0	t
97	4	0408	Ain Babouche	23:53:21.216+02	0	23:53:21.216+02	0	t
98	4	0409	Berriche	23:53:21.216+02	0	23:53:21.216+02	0	t
99	4	0410	Ouled Hamla	23:53:21.216+02	0	23:53:21.216+02	0	t
100	4	0411	Dhala	23:53:21.216+02	0	23:53:21.216+02	0	t
101	4	0412	Ain Kercha	23:53:21.216+02	0	23:53:21.216+02	0	t
102	4	0413	Hanchir Toumghani	23:53:21.216+02	0	23:53:21.216+02	0	t
103	4	0414	El Djazia	23:53:21.216+02	0	23:53:21.216+02	0	t
104	4	0415	Ain Diss	23:53:21.216+02	0	23:53:21.216+02	0	t
105	4	0416	F'kirina	23:53:21.216+02	0	23:53:21.216+02	0	t
106	4	0421	Bir Chouahada	23:53:21.216+02	0	23:53:21.216+02	0	t
107	4	0422	Ksar Sbahi	23:53:21.216+02	0	23:53:21.216+02	0	t
108	4	0423	Oued Nini	23:53:21.216+02	0	23:53:21.216+02	0	t
109	4	0424	Meskiana	23:53:21.216+02	0	23:53:21.216+02	0	t
110	4	0425	Ain Fakroun	23:53:21.216+02	0	23:53:21.216+02	0	t
111	4	0426	Rahia	23:53:21.216+02	0	23:53:21.216+02	0	t
112	4	0427	Ain Zitoun	23:53:21.216+02	0	23:53:21.216+02	0	t
113	4	0428	Ouled Gacem	23:53:21.216+02	0	23:53:21.216+02	0	t
114	4	0429	El Harmalia	23:53:21.216+02	0	23:53:21.216+02	0	t
115	4	0417	Souk Naamane	23:53:21.216+02	0	23:53:21.216+02	0	t
116	4	0418	Zorg	23:53:21.216+02	0	23:53:21.216+02	0	t
117	4	0402	Ain Beida	23:53:21.216+02	0	23:53:21.216+02	0	t
118	4	0401	Oum Bouaghi	23:53:21.216+02	0	23:53:21.216+02	0	t
119	5	0532	Beni F. El Hakania	23:53:21.216+02	0	23:53:21.216+02	0	t
120	5	0533	Oued El Ma	23:53:21.216+02	0	23:53:21.216+02	0	t
121	5	0534	Talakhamet	23:53:21.216+02	0	23:53:21.216+02	0	t
122	5	0535	Bouzina	23:53:21.216+02	0	23:53:21.216+02	0	t
123	5	0536	Chemora	23:53:21.216+02	0	23:53:21.216+02	0	t
124	5	0537	Oued Chaaba	23:53:21.216+02	0	23:53:21.216+02	0	t
125	5	0538	Taxlent	23:53:21.216+02	0	23:53:21.216+02	0	t
126	5	0539	Gosbat	23:53:21.216+02	0	23:53:21.216+02	0	t
127	5	0540	Ouled Aouf	23:53:21.216+02	0	23:53:21.216+02	0	t
128	5	0541	Boumagueur	23:53:21.216+02	0	23:53:21.216+02	0	t
129	5	0542	Barika	23:53:21.216+02	0	23:53:21.216+02	0	t
130	5	0543	Djezar	23:53:21.216+02	0	23:53:21.216+02	0	t
131	5	0544	T'kout	23:53:21.216+02	0	23:53:21.216+02	0	t
132	5	0545	Ain Touta	23:53:21.216+02	0	23:53:21.216+02	0	t
133	5	0546	Hidoussa	23:53:21.216+02	0	23:53:21.216+02	0	t
134	5	0547	Teniet El Abed	23:53:21.216+02	0	23:53:21.216+02	0	t
135	5	0548	Oued Taga	23:53:21.216+02	0	23:53:21.216+02	0	t
136	5	0549	Ouled Fadhel	23:53:21.216+02	0	23:53:21.216+02	0	t
137	5	0550	Timgad	23:53:21.216+02	0	23:53:21.216+02	0	t
138	5	0551	Ras El Aioun	23:53:21.216+02	0	23:53:21.216+02	0	t
139	5	0552	Chir	23:53:21.216+02	0	23:53:21.216+02	0	t
140	5	0553	Ouled Si Slimane	23:53:21.216+02	0	23:53:21.216+02	0	t
141	5	0554	Zanet El Beida	23:53:21.216+02	0	23:53:21.216+02	0	t
142	5	0502	Ghassira	23:53:21.216+02	0	23:53:21.216+02	0	t
143	5	0503	Maafa	23:53:21.216+02	0	23:53:21.216+02	0	t
144	5	0504	Merouana	23:53:21.216+02	0	23:53:21.216+02	0	t
145	5	0505	Seriana	23:53:21.216+02	0	23:53:21.216+02	0	t
146	5	0506	Menaa	23:53:21.216+02	0	23:53:21.216+02	0	t
147	5	0507	El Madher	23:53:21.216+02	0	23:53:21.216+02	0	t
148	5	0508	Tazoult	23:53:21.216+02	0	23:53:21.216+02	0	t
149	5	0509	N'gaous	23:53:21.216+02	0	23:53:21.216+02	0	t
150	5	0510	Guigba	23:53:21.216+02	0	23:53:21.216+02	0	t
151	5	0511	Inoughissene	23:53:21.216+02	0	23:53:21.216+02	0	t
152	5	0515	Azil Abdelkader	23:53:21.216+02	0	23:53:21.216+02	0	t
153	5	0512	Ouyoun El Assafir	23:53:21.216+02	0	23:53:21.216+02	0	t
154	5	0513	Djerma	23:53:21.216+02	0	23:53:21.216+02	0	t
155	5	0514	Bitam	23:53:21.216+02	0	23:53:21.216+02	0	t
156	5	0516	Arris	23:53:21.216+02	0	23:53:21.216+02	0	t
157	5	0517	Kimmel	23:53:21.216+02	0	23:53:21.216+02	0	t
158	5	0518	Tilatou	23:53:21.216+02	0	23:53:21.216+02	0	t
159	5	0519	Ain Djasser	23:53:21.216+02	0	23:53:21.216+02	0	t
160	5	0520	Ouled Selam	23:53:21.216+02	0	23:53:21.216+02	0	t
161	5	0521	Tigherghar	23:53:21.216+02	0	23:53:21.216+02	0	t
162	5	0522	Ain Yagout	23:53:21.216+02	0	23:53:21.216+02	0	t
163	5	0523	Fesdis	23:53:21.216+02	0	23:53:21.216+02	0	t
164	5	0524	Sefiane	23:53:21.216+02	0	23:53:21.216+02	0	t
165	5	0525	Rahbat	23:53:21.216+02	0	23:53:21.216+02	0	t
166	5	0526	Tighanimine	23:53:21.216+02	0	23:53:21.216+02	0	t
167	5	0527	Lemsane	23:53:21.216+02	0	23:53:21.216+02	0	t
168	5	0528	Ksar Belezma	23:53:21.216+02	0	23:53:21.216+02	0	t
169	5	0529	Seggana	23:53:21.216+02	0	23:53:21.216+02	0	t
170	5	0530	Ichmoul	23:53:21.216+02	0	23:53:21.216+02	0	t
171	5	0531	Foum Toub	23:53:21.216+02	0	23:53:21.216+02	0	t
172	5	0555	M'doukel	23:53:21.216+02	0	23:53:21.216+02	0	t
173	5	0556	Ouled Ammar	23:53:21.216+02	0	23:53:21.216+02	0	t
174	5	0557	El Hassi	23:53:21.216+02	0	23:53:21.216+02	0	t
175	5	0558	Lazrou	23:53:21.216+02	0	23:53:21.216+02	0	t
176	5	0559	Boumia	23:53:21.216+02	0	23:53:21.216+02	0	t
177	5	0560	Boulhilet	23:53:21.216+02	0	23:53:21.216+02	0	t
179	5	0501	Batna	23:53:21.216+02	0	23:53:21.216+02	0	t
180	6	0625	Akbou	23:53:21.216+02	0	23:53:21.216+02	0	t
181	6	0626	Seddouk	23:53:21.216+02	0	23:53:21.216+02	0	t
182	6	0627	Tazmalt	23:53:21.216+02	0	23:53:21.216+02	0	t
183	6	0643	El Flaye	23:53:21.216+02	0	23:53:21.216+02	0	t
184	6	0644	Kherrata	23:53:21.216+02	0	23:53:21.216+02	0	t
185	6	0645	Draa El Kaid	23:53:21.216+02	0	23:53:21.216+02	0	t
186	6	0646	Tamridjet	23:53:21.216+02	0	23:53:21.216+02	0	t
187	6	0624	Adekar	23:53:21.216+02	0	23:53:21.216+02	0	t
188	6	0602	Amizour	23:53:21.216+02	0	23:53:21.216+02	0	t
189	6	0603	Ferraoun	23:53:21.216+02	0	23:53:21.216+02	0	t
190	6	0604	Taourirt Ighil	23:53:21.216+02	0	23:53:21.216+02	0	t
191	6	0605	Chellata	23:53:21.216+02	0	23:53:21.216+02	0	t
192	6	0606	Tamokra	23:53:21.216+02	0	23:53:21.216+02	0	t
193	6	0607	Timezrit	23:53:21.216+02	0	23:53:21.216+02	0	t
194	6	0608	Souk El Tenine	23:53:21.216+02	0	23:53:21.216+02	0	t
195	6	0609	M'cisna	23:53:21.216+02	0	23:53:21.216+02	0	t
196	6	0610	Tinebdar	23:53:21.216+02	0	23:53:21.216+02	0	t
197	6	0611	Tichy	23:53:21.216+02	0	23:53:21.216+02	0	t
198	6	0612	Semaoun	23:53:21.216+02	0	23:53:21.216+02	0	t
199	6	0613	Kendira	23:53:21.216+02	0	23:53:21.216+02	0	t
200	6	0614	Tifra	23:53:21.216+02	0	23:53:21.216+02	0	t
201	6	0615	Ighram	23:53:21.216+02	0	23:53:21.216+02	0	t
202	6	0616	Amalou	23:53:21.216+02	0	23:53:21.216+02	0	t
203	6	0617	Ighil Ali	23:53:21.216+02	0	23:53:21.216+02	0	t
204	6	0618	Fenaia	23:53:21.216+02	0	23:53:21.216+02	0	t
205	6	0619	Toudja	23:53:21.216+02	0	23:53:21.216+02	0	t
206	6	0620	Darguina	23:53:21.216+02	0	23:53:21.216+02	0	t
207	6	0621	Sidi Ayad	23:53:21.216+02	0	23:53:21.216+02	0	t
208	6	0622	Aokas	23:53:21.216+02	0	23:53:21.216+02	0	t
209	6	0623	Beni Djellil	23:53:21.216+02	0	23:53:21.216+02	0	t
210	6	0628	Ait R'zine	23:53:21.216+02	0	23:53:21.216+02	0	t
211	6	0629	Chemini	23:53:21.216+02	0	23:53:21.216+02	0	t
212	6	0630	Souk Oufella	23:53:21.216+02	0	23:53:21.216+02	0	t
213	6	0631	Taskriout	23:53:21.216+02	0	23:53:21.216+02	0	t
214	6	0632	Tibane	23:53:21.216+02	0	23:53:21.216+02	0	t
215	6	0633	Tala Hamza	23:53:21.216+02	0	23:53:21.216+02	0	t
216	6	0634	Barbacha	23:53:21.216+02	0	23:53:21.216+02	0	t
217	6	0635	Beni K'sila	23:53:21.216+02	0	23:53:21.216+02	0	t
218	6	0636	Ouzelaguen	23:53:21.216+02	0	23:53:21.216+02	0	t
219	6	0637	Bouhamza	23:53:21.216+02	0	23:53:21.216+02	0	t
220	6	0638	Beni Melikeche	23:53:21.216+02	0	23:53:21.216+02	0	t
221	6	0639	Sidi Aich	23:53:21.216+02	0	23:53:21.216+02	0	t
222	6	0640	El Kseur	23:53:21.216+02	0	23:53:21.216+02	0	t
223	6	0641	Melbou	23:53:21.216+02	0	23:53:21.216+02	0	t
224	6	0642	Akfadou	23:53:21.216+02	0	23:53:21.216+02	0	t
225	6	0647	Ait Smail	23:53:21.216+02	0	23:53:21.216+02	0	t
226	6	0648	Boukhlifa	23:53:21.216+02	0	23:53:21.216+02	0	t
227	6	0649	Tizi N'berber	23:53:21.216+02	0	23:53:21.216+02	0	t
228	6	0650	Beni Maouche	23:53:21.216+02	0	23:53:21.216+02	0	t
229	6	0651	Oued Ghir	23:53:21.216+02	0	23:53:21.216+02	0	t
230	6	0652	Boudjellil	23:53:21.216+02	0	23:53:21.216+02	0	t
231	6	0601	Bejaia	23:53:21.216+02	0	23:53:21.216+02	0	t
232	7	0712	M'chouneche	23:53:21.216+02	0	23:53:21.216+02	0	t
233	7	0713	El Haouche	23:53:21.216+02	0	23:53:21.216+02	0	t
234	7	0714	Ain Naga	23:53:21.216+02	0	23:53:21.216+02	0	t
235	7	0715	Zeribet El Oued	23:53:21.216+02	0	23:53:21.216+02	0	t
236	7	0716	El Feidh	23:53:21.216+02	0	23:53:21.216+02	0	t
237	7	0717	El Kantara	23:53:21.216+02	0	23:53:21.216+02	0	t
238	7	0718	Ain Zaatout	23:53:21.216+02	0	23:53:21.216+02	0	t
239	7	0719	El Outaya	23:53:21.216+02	0	23:53:21.216+02	0	t
240	7	0720	Djemorah	23:53:21.216+02	0	23:53:21.216+02	0	t
241	7	0721	Tolga	23:53:21.216+02	0	23:53:21.216+02	0	t
242	7	0722	Lioua	23:53:21.216+02	0	23:53:21.216+02	0	t
243	7	0723	Lichana	23:53:21.216+02	0	23:53:21.216+02	0	t
244	7	0724	Ourlal	23:53:21.216+02	0	23:53:21.216+02	0	t
245	7	0725	M'lili	23:53:21.216+02	0	23:53:21.216+02	0	t
246	7	0726	Foughala	23:53:21.216+02	0	23:53:21.216+02	0	t
247	7	0727	Bordj Benazzouz	23:53:21.216+02	0	23:53:21.216+02	0	t
248	7	0728	Meziraa	23:53:21.216+02	0	23:53:21.216+02	0	t
249	7	0729	Bouchagroun	23:53:21.216+02	0	23:53:21.216+02	0	t
250	7	0730	Mekhadma	23:53:21.216+02	0	23:53:21.216+02	0	t
251	7	0731	El Ghrous	23:53:21.216+02	0	23:53:21.216+02	0	t
252	7	0732	El Hadjab	23:53:21.216+02	0	23:53:21.216+02	0	t
253	7	0733	Khenghet Sidi Naji	23:53:21.216+02	0	23:53:21.216+02	0	t
254	7	0702	Oumache	23:53:21.216+02	0	23:53:21.216+02	0	t
255	7	0703	Branis	23:53:21.216+02	0	23:53:21.216+02	0	t
256	7	0704	Chetma	23:53:21.216+02	0	23:53:21.216+02	0	t
257	7	0705	Ouled Djellal	23:53:21.216+02	0	23:53:21.216+02	0	t
258	7	0706	Ras El Miad	23:53:21.216+02	0	23:53:21.216+02	0	t
259	7	0707	Besbes	23:53:21.216+02	0	23:53:21.216+02	0	t
260	7	0708	Sidi Khaled	23:53:21.216+02	0	23:53:21.216+02	0	t
261	7	0709	Doucen	23:53:21.216+02	0	23:53:21.216+02	0	t
262	7	0710	Ech Chaiba	23:53:21.216+02	0	23:53:21.216+02	0	t
263	7	0711	Sidi Okba	23:53:21.216+02	0	23:53:21.216+02	0	t
264	7	0701	Biskra	23:53:21.216+02	0	23:53:21.216+02	0	t
265	8	0802	Erg Ferradj	23:53:21.216+02	0	23:53:21.216+02	0	t
266	8	0803	Ouled Khoudir	23:53:21.216+02	0	23:53:21.216+02	0	t
267	8	0804	Meridja	23:53:21.216+02	0	23:53:21.216+02	0	t
268	8	0805	Timoudi	23:53:21.216+02	0	23:53:21.216+02	0	t
269	8	0806	Lahmar	23:53:21.216+02	0	23:53:21.216+02	0	t
270	8	0807	Beni Abbes	23:53:21.216+02	0	23:53:21.216+02	0	t
271	8	0808	Beni Ikhlef	23:53:21.216+02	0	23:53:21.216+02	0	t
272	8	0801	Bechar	23:53:21.216+02	0	23:53:21.216+02	0	t
274	8	0810	Kenadsa	23:53:21.216+02	0	23:53:21.216+02	0	t
275	8	0811	Igli	23:53:21.216+02	0	23:53:21.216+02	0	t
276	8	0812	Tabalbala	23:53:21.216+02	0	23:53:21.216+02	0	t
277	8	0813	Taghit	23:53:21.216+02	0	23:53:21.216+02	0	t
278	8	0814	El Ouata	23:53:21.216+02	0	23:53:21.216+02	0	t
279	8	0815	Boukais	23:53:21.216+02	0	23:53:21.216+02	0	t
280	8	0816	Moghueul	23:53:21.216+02	0	23:53:21.216+02	0	t
281	8	0817	Abadla	23:53:21.216+02	0	23:53:21.216+02	0	t
282	8	0818	Kerzaz	23:53:21.216+02	0	23:53:21.216+02	0	t
283	8	0819	Ksabi	23:53:21.216+02	0	23:53:21.216+02	0	t
284	8	0820	Tamert	23:53:21.216+02	0	23:53:21.216+02	0	t
285	8	0821	Beni Ounif	23:53:21.216+02	0	23:53:21.216+02	0	t
286	9	0904	Oued Alleug	23:53:21.216+02	0	23:53:21.216+02	0	t
287	9	0907	Ouled Yaich	23:53:21.216+02	0	23:53:21.216+02	0	t
288	9	0910	El Affroun	23:53:21.216+02	0	23:53:21.216+02	0	t
289	9	0911	Chiffa	23:53:21.216+02	0	23:53:21.216+02	0	t
290	9	0912	Hammam Melouane	23:53:21.216+02	0	23:53:21.216+02	0	t
291	9	0913	Benkhelil	23:53:21.216+02	0	23:53:21.216+02	0	t
292	9	0916	Mouzaia	23:53:21.216+02	0	23:53:21.216+02	0	t
293	9	0917	Souhane	23:53:21.216+02	0	23:53:21.216+02	0	t
294	9	0918	Meftah	23:53:21.216+02	0	23:53:21.216+02	0	t
295	9	0919	Ouled Slama	23:53:21.216+02	0	23:53:21.216+02	0	t
296	9	0920	Boufarik	23:53:21.216+02	0	23:53:21.216+02	0	t
297	9	0921	Larbaa	23:53:21.216+02	0	23:53:21.216+02	0	t
298	9	0922	Oued Djer	23:53:21.216+02	0	23:53:21.216+02	0	t
299	9	0923	Beni Tamou	23:53:21.216+02	0	23:53:21.216+02	0	t
300	9	0924	Bouarfa	23:53:21.216+02	0	23:53:21.216+02	0	t
301	9	0925	Beni Mered	23:53:21.216+02	0	23:53:21.216+02	0	t
302	9	0926	Bougara	23:53:21.216+02	0	23:53:21.216+02	0	t
303	9	0927	Guerouaou	23:53:21.216+02	0	23:53:21.216+02	0	t
304	9	0928	Ain Romana	23:53:21.216+02	0	23:53:21.216+02	0	t
305	9	0929	Djebabra	23:53:21.216+02	0	23:53:21.216+02	0	t
306	9	0914	Soumaa	23:53:21.216+02	0	23:53:21.216+02	0	t
307	9	0902	Chebli	23:53:21.216+02	0	23:53:21.216+02	0	t
308	9	0903	Bouinan	23:53:21.216+02	0	23:53:21.216+02	0	t
309	9	0908	Chrea	23:53:21.216+02	0	23:53:21.216+02	0	t
310	9	0901	Blida	23:53:21.216+02	0	23:53:21.216+02	0	t
311	10	1001	Bouira	23:58:28.581+02	0	23:58:28.581+02	0	t
312	10	1002	El Asnam	23:58:28.581+02	0	23:58:28.581+02	0	t
313	10	1003	Guerrouma	23:58:28.581+02	0	23:58:28.581+02	0	t
314	10	1004	Souk El Khemis	23:58:28.581+02	0	23:58:28.581+02	0	t
315	10	1005	Kadiria	23:58:28.581+02	0	23:58:28.581+02	0	t
316	10	1006	Hanif	23:58:28.581+02	0	23:58:28.581+02	0	t
317	10	1007	Dirah	23:58:28.581+02	0	23:58:28.581+02	0	t
318	10	1008	Ait Laaziz	23:58:28.581+02	0	23:58:28.581+02	0	t
319	10	1009	Taghzout	23:58:28.581+02	0	23:58:28.581+02	0	t
320	10	1010	Raouraoua	23:58:28.581+02	0	23:58:28.581+02	0	t
321	10	1011	Mezdour	23:58:28.581+02	0	23:58:28.581+02	0	t
322	10	1012	Haizer	23:58:28.581+02	0	23:58:28.581+02	0	t
323	10	1013	Lakhdaria	23:58:28.581+02	0	23:58:28.581+02	0	t
324	10	1014	Maala	23:58:28.581+02	0	23:58:28.581+02	0	t
325	10	1015	El Hachimia	23:58:28.581+02	0	23:58:28.581+02	0	t
326	10	1016	Aomar	23:58:28.581+02	0	23:58:28.581+02	0	t
327	10	1017	Chorfa	23:58:28.581+02	0	23:58:28.581+02	0	t
328	10	1018	Bordj Oukhriss	23:58:28.581+02	0	23:58:28.581+02	0	t
329	10	1019	El Adjiba	23:58:28.581+02	0	23:58:28.581+02	0	t
330	10	1020	El Hakimia	23:58:28.581+02	0	23:58:28.581+02	0	t
331	10	1021	El Khebouzia	23:58:28.581+02	0	23:58:28.581+02	0	t
332	10	1022	Ahl El Ksar	23:58:28.581+02	0	23:58:28.581+02	0	t
333	10	1023	Bouderbala	23:58:28.581+02	0	23:58:28.581+02	0	t
334	10	1024	Z'barbar	23:58:28.581+02	0	23:58:28.581+02	0	t
335	10	1025	Ain El Hadjar	23:58:28.581+02	0	23:58:28.581+02	0	t
336	10	1026	Djebahia	23:58:28.581+02	0	23:58:28.581+02	0	t
337	10	1027	Aghbalou	23:58:28.581+02	0	23:58:28.581+02	0	t
338	10	1028	Taguedit	23:58:28.581+02	0	23:58:28.581+02	0	t
339	10	1029	Ain Turk	23:58:28.581+02	0	23:58:28.581+02	0	t
340	10	1030	Saharidj	23:58:28.581+02	0	23:58:28.581+02	0	t
341	10	1031	Dechmia	23:58:28.581+02	0	23:58:28.581+02	0	t
342	10	1032	Ridane	23:58:28.581+02	0	23:58:28.581+02	0	t
343	10	1033	Bechloul	23:58:28.581+02	0	23:58:28.581+02	0	t
344	10	1034	Boukram	23:58:28.581+02	0	23:58:28.581+02	0	t
345	10	1035	Ain Bessam	23:58:28.581+02	0	23:58:28.581+02	0	t
346	10	1036	Bir Ghbalou	23:58:28.581+02	0	23:58:28.581+02	0	t
347	10	1037	M'chedallah	23:58:28.581+02	0	23:58:28.581+02	0	t
348	10	1038	Sour El Ghozlane	23:58:28.581+02	0	23:58:28.581+02	0	t
349	10	1039	Maamora	23:58:28.581+02	0	23:58:28.581+02	0	t
350	10	1040	Ouled Rached	23:58:28.581+02	0	23:58:28.581+02	0	t
351	10	1041	Ain Laloui	23:58:28.581+02	0	23:58:28.581+02	0	t
352	10	1042	Hadjera Zerga	23:58:28.581+02	0	23:58:28.581+02	0	t
353	10	1043	Ath Mansour	23:58:28.581+02	0	23:58:28.581+02	0	t
354	10	1044	El Mokrani	23:58:28.581+02	0	23:58:28.581+02	0	t
355	10	1045	Oued El Berdi	23:58:28.581+02	0	23:58:28.581+02	0	t
356	11	1101	Tamanrasset	23:58:28.581+02	0	23:58:28.581+02	0	t
357	11	1102	Abalessa	23:58:28.581+02	0	23:58:28.581+02	0	t
358	11	1103	In Ghar	23:58:28.581+02	0	23:58:28.581+02	0	t
359	11	1104	In Guezzam	23:58:28.581+02	0	23:58:28.581+02	0	t
360	11	1105	Idles	23:58:28.581+02	0	23:58:28.581+02	0	t
361	11	1106	Tazrouk	23:58:28.581+02	0	23:58:28.581+02	0	t
362	11	1107	Tin Zouatine	23:58:28.581+02	0	23:58:28.581+02	0	t
363	11	1108	In Salah	23:58:28.581+02	0	23:58:28.581+02	0	t
364	11	1109	In Amguel	23:58:28.581+02	0	23:58:28.581+02	0	t
365	11	1110	Foggaret Ezzaouia	23:58:28.581+02	0	23:58:28.581+02	0	t
366	12	1201	Tebessa	23:58:28.581+02	0	23:58:28.581+02	0	t
367	12	1202	Bir El Ater	23:58:28.581+02	0	23:58:28.581+02	0	t
368	12	1203	Cheria	23:58:28.581+02	0	23:58:28.581+02	0	t
369	12	1204	Stah Guentis	23:58:28.581+02	0	23:58:28.581+02	0	t
370	12	1205	El Aouinet	23:58:28.581+02	0	23:58:28.581+02	0	t
371	12	1206	Lhaouidjbet	23:58:28.581+02	0	23:58:28.581+02	0	t
372	12	1207	Safsaf Ouesra	23:58:28.581+02	0	23:58:28.581+02	0	t
373	12	1208	Hammamet	23:58:28.581+02	0	23:58:28.581+02	0	t
374	12	1209	Negrine	23:58:28.581+02	0	23:58:28.581+02	0	t
375	12	1210	Bir Mokadem	23:58:28.581+02	0	23:58:28.581+02	0	t
376	12	1211	El Kouif	23:58:28.581+02	0	23:58:28.581+02	0	t
377	12	1212	Morsott	23:58:28.581+02	0	23:58:28.581+02	0	t
378	12	1213	El Ogla	23:58:28.581+02	0	23:58:28.581+02	0	t
379	12	1214	Bir Dheheb	23:58:28.581+02	0	23:58:28.581+02	0	t
380	12	1215	El Ogla Malha	23:58:28.581+02	0	23:58:28.581+02	0	t
381	12	1216	Guorriguer	23:58:28.581+02	0	23:58:28.581+02	0	t
382	12	1217	Bekkaria	23:58:28.581+02	0	23:58:28.581+02	0	t
383	12	1218	Boukhadra	23:58:28.581+02	0	23:58:28.581+02	0	t
384	12	1219	Ouenza	23:58:28.581+02	0	23:58:28.581+02	0	t
385	12	1220	El Ma El Biod	23:58:28.581+02	0	23:58:28.581+02	0	t
386	12	1221	Oum Ali	23:58:28.581+02	0	23:58:28.581+02	0	t
387	12	1222	Tlidjen	23:58:28.581+02	0	23:58:28.581+02	0	t
388	12	1223	Ain Zerga	23:58:28.581+02	0	23:58:28.581+02	0	t
389	12	1224	El Meridj	23:58:28.581+02	0	23:58:28.581+02	0	t
390	12	1225	Boulhaf Dir	23:58:28.581+02	0	23:58:28.581+02	0	t
391	12	1226	Bedjene	23:58:28.581+02	0	23:58:28.581+02	0	t
392	12	1227	El Mezeraa	23:58:28.581+02	0	23:58:28.581+02	0	t
393	12	1228	Ferkane	23:58:28.581+02	0	23:58:28.581+02	0	t
394	13	1301	Tlemcen	23:58:28.581+02	0	23:58:28.581+02	0	t
395	13	1302	Beni Mester	23:58:28.581+02	0	23:58:28.581+02	0	t
396	13	1303	Ain Tellout	23:58:28.581+02	0	23:58:28.581+02	0	t
397	13	1304	Remchi	23:58:28.581+02	0	23:58:28.581+02	0	t
398	13	1305	El Fehoul	23:58:28.581+02	0	23:58:28.581+02	0	t
399	13	1306	Sabra	23:58:28.581+02	0	23:58:28.581+02	0	t
400	13	1307	Ghazaouet	23:58:28.581+02	0	23:58:28.581+02	0	t
401	13	1308	Souani	23:58:28.581+02	0	23:58:28.581+02	0	t
402	13	1309	Djebala	23:58:28.581+02	0	23:58:28.581+02	0	t
403	13	1310	El Gor	23:58:28.581+02	0	23:58:28.581+02	0	t
404	13	1311	Oued Lakhdar	23:58:28.581+02	0	23:58:28.581+02	0	t
405	13	1312	Ain Fezza	23:58:28.581+02	0	23:58:28.581+02	0	t
406	13	1313	Ouled Mimoun	23:58:28.581+02	0	23:58:28.581+02	0	t
407	13	1314	Amieur	23:58:28.581+02	0	23:58:28.581+02	0	t
408	13	1315	Ain Youcef	23:58:28.581+02	0	23:58:28.581+02	0	t
409	13	1316	Zenata	23:58:28.581+02	0	23:58:28.581+02	0	t
410	13	1317	Beni Snous	23:58:28.581+02	0	23:58:28.581+02	0	t
411	13	1318	Bab El Assa	23:58:28.581+02	0	23:58:28.581+02	0	t
412	13	1319	Dar Yaghmoricene	23:58:28.581+02	0	23:58:28.581+02	0	t
413	13	1320	Fellaoucene	23:58:28.581+02	0	23:58:28.581+02	0	t
414	13	1321	Azails	23:58:28.581+02	0	23:58:28.581+02	0	t
415	13	1322	Sebaa Chioukh	23:58:28.581+02	0	23:58:28.581+02	0	t
416	13	1323	Terni Beni Hediel	23:58:28.581+02	0	23:58:28.581+02	0	t
417	13	1324	Bensekrane	23:58:28.581+02	0	23:58:28.581+02	0	t
418	13	1325	Ain Nehala	23:58:28.581+02	0	23:58:28.581+02	0	t
419	13	1326	Hennaya	23:58:28.581+02	0	23:58:28.581+02	0	t
420	13	1327	Maghnia	23:58:28.581+02	0	23:58:28.581+02	0	t
421	13	1328	H, Boughrara	23:58:28.581+02	0	23:58:28.581+02	0	t
422	13	1329	Souahlia	23:58:28.581+02	0	23:58:28.581+02	0	t
423	13	1330	Msirda Fouaga	23:58:28.581+02	0	23:58:28.581+02	0	t
424	13	1331	Ain Fetah	23:58:28.581+02	0	23:58:28.581+02	0	t
425	13	1332	El Aricha	23:58:28.581+02	0	23:58:28.581+02	0	t
426	13	1333	Souk Thlata	23:58:28.581+02	0	23:58:28.581+02	0	t
427	13	1334	Sidi Abdelli	23:58:28.581+02	0	23:58:28.581+02	0	t
428	13	1335	Sebdou	23:58:28.581+02	0	23:58:28.581+02	0	t
429	13	1336	Beni Ouarsous	23:58:28.581+02	0	23:58:28.581+02	0	t
430	13	1337	Sidi Medjahed	23:58:28.581+02	0	23:58:28.581+02	0	t
431	13	1338	Beni Boussaid	23:58:28.581+02	0	23:58:28.581+02	0	t
432	13	1339	Marsa Ben Mhidi	23:58:28.581+02	0	23:58:28.581+02	0	t
433	13	1340	Nedroma	23:58:28.581+02	0	23:58:28.581+02	0	t
434	13	1341	Sidi Djilali	23:58:28.581+02	0	23:58:28.581+02	0	t
435	13	1342	Beni Bahdel	23:58:28.581+02	0	23:58:28.581+02	0	t
436	13	1343	El Bouihi	23:58:28.581+02	0	23:58:28.581+02	0	t
437	13	1344	Honaine	23:58:28.581+02	0	23:58:28.581+02	0	t
438	13	1345	Tianet	23:58:28.581+02	0	23:58:28.581+02	0	t
439	13	1346	Ouled Riyah	23:58:28.581+02	0	23:58:28.581+02	0	t
440	13	1347	Bouhlou	23:58:28.581+02	0	23:58:28.581+02	0	t
441	13	1348	Beni Khelllad	23:58:28.581+02	0	23:58:28.581+02	0	t
442	13	1349	Ain Ghoraba	23:58:28.581+02	0	23:58:28.581+02	0	t
443	13	1350	Chetouane	23:58:28.581+02	0	23:58:28.581+02	0	t
444	13	1351	Mansourah	23:58:28.581+02	0	23:58:28.581+02	0	t
445	13	1352	Beni Smiel	23:58:28.581+02	0	23:58:28.581+02	0	t
446	13	1353	Ain Kebira	23:58:28.581+02	0	23:58:28.581+02	0	t
447	14	1401	Tiaret	23:58:28.581+02	0	23:58:28.581+02	0	t
448	14	1402	Medroussa	23:58:28.581+02	0	23:58:28.581+02	0	t
449	14	1403	Ain Bouchekif	23:58:28.581+02	0	23:58:28.581+02	0	t
450	14	1404	Sidi Ali Mellal	23:58:28.581+02	0	23:58:28.581+02	0	t
451	14	1405	Ain Zairit	23:58:28.581+02	0	23:58:28.581+02	0	t
452	14	1406	Ain Deheb	23:58:28.581+02	0	23:58:28.581+02	0	t
453	14	1407	Sidi Bakhti	23:58:28.581+02	0	23:58:28.581+02	0	t
454	14	1408	Medrissa	23:58:28.581+02	0	23:58:28.581+02	0	t
455	14	1409	Zmalet Emir Aek	23:58:28.581+02	0	23:58:28.581+02	0	t
456	14	1410	Madna	23:58:28.581+02	0	23:58:28.581+02	0	t
457	14	1411	Sebt	23:58:28.581+02	0	23:58:28.581+02	0	t
458	14	1412	Mellakou	23:58:28.581+02	0	23:58:28.581+02	0	t
459	14	1413	Dahmouni	23:58:28.581+02	0	23:58:28.581+02	0	t
460	14	1414	Rahouia	23:58:28.581+02	0	23:58:28.581+02	0	t
461	14	1415	Mahdia	23:58:28.581+02	0	23:58:28.581+02	0	t
462	14	1416	Sougueur	23:58:28.581+02	0	23:58:28.581+02	0	t
463	14	1417	Si Abdelghani	23:58:28.581+02	0	23:58:28.581+02	0	t
464	14	1418	Ain El Hadid	23:58:28.581+02	0	23:58:28.581+02	0	t
465	14	1419	Djebilet Rosfa	23:58:28.581+02	0	23:58:28.581+02	0	t
466	14	1420	Naima	23:58:28.581+02	0	23:58:28.581+02	0	t
467	14	1421	Meghila	23:58:28.581+02	0	23:58:28.581+02	0	t
468	14	1422	Guertoufa	23:58:28.581+02	0	23:58:28.581+02	0	t
469	14	1423	Sidi Hosni	23:58:28.581+02	0	23:58:28.581+02	0	t
470	14	1424	Djillali Ben Amar	23:58:28.581+02	0	23:58:28.581+02	0	t
471	14	1425	Sebaine	23:58:28.581+02	0	23:58:28.581+02	0	t
472	14	1426	Tousnina	23:58:28.581+02	0	23:58:28.581+02	0	t
473	14	1427	Frenda	23:58:28.581+02	0	23:58:28.581+02	0	t
474	14	1428	Ain Kermes	23:58:28.581+02	0	23:58:28.581+02	0	t
475	14	1429	Ksar Chellala	23:58:28.581+02	0	23:58:28.581+02	0	t
476	14	1430	Rechaiga	23:58:28.581+02	0	23:58:28.581+02	0	t
477	14	1431	Nadorah	23:58:28.581+02	0	23:58:28.581+02	0	t
478	14	1432	Tagdemt	23:58:28.581+02	0	23:58:28.581+02	0	t
479	14	1433	Oued Lilli	23:58:28.581+02	0	23:58:28.581+02	0	t
480	14	1434	Mechraa Safa	23:58:28.581+02	0	23:58:28.581+02	0	t
481	14	1435	Hamadia	23:58:28.581+02	0	23:58:28.581+02	0	t
482	14	1436	Chehaima	23:58:28.581+02	0	23:58:28.581+02	0	t
483	14	1437	Takhemaret	23:58:28.581+02	0	23:58:28.581+02	0	t
484	14	1438	S,Abderrahmane	23:58:28.581+02	0	23:58:28.581+02	0	t
485	14	1439	Serghine	23:58:28.581+02	0	23:58:28.581+02	0	t
486	14	1440	Bougara	23:58:28.581+02	0	23:58:28.581+02	0	t
487	14	1441	Faidja	23:58:28.581+02	0	23:58:28.581+02	0	t
488	14	1442	Tidda	23:58:28.581+02	0	23:58:28.581+02	0	t
489	15	1501	Tizi Ouzou	23:58:28.581+02	0	23:58:28.581+02	0	t
490	15	1502	Ain El Hammam	23:58:28.581+02	0	23:58:28.581+02	0	t
491	15	1503	Akbil	23:58:28.581+02	0	23:58:28.581+02	0	t
492	15	1504	Freha	23:58:28.581+02	0	23:58:28.581+02	0	t
493	15	1505	Souamaa	23:58:28.581+02	0	23:58:28.581+02	0	t
494	15	1506	Mechtrass	23:58:28.581+02	0	23:58:28.581+02	0	t
495	15	1507	Irdjen	23:58:28.581+02	0	23:58:28.581+02	0	t
496	15	1508	Timizart	23:58:28.581+02	0	23:58:28.581+02	0	t
497	15	1509	Makouda	23:58:28.581+02	0	23:58:28.581+02	0	t
498	15	1510	Draa El Mizan	23:58:28.581+02	0	23:58:28.581+02	0	t
499	15	1511	Tizi Ghenif	23:58:28.581+02	0	23:58:28.581+02	0	t
500	15	1512	Bounouh	23:58:28.581+02	0	23:58:28.581+02	0	t
501	15	1513	Ait Chaffaa	23:58:28.581+02	0	23:58:28.581+02	0	t
502	15	1514	Frikat	23:58:28.581+02	0	23:58:28.581+02	0	t
503	15	1515	Beni Aissi	23:58:28.581+02	0	23:58:28.581+02	0	t
504	15	1516	Beni Zmenzer	23:58:28.581+02	0	23:58:28.581+02	0	t
505	15	1517	Iferhounene	23:58:28.581+02	0	23:58:28.581+02	0	t
506	15	1518	Azazga	23:58:28.581+02	0	23:58:28.581+02	0	t
507	15	1519	Iloula Oumalou	23:58:28.581+02	0	23:58:28.581+02	0	t
508	15	1520	Yakouren	23:58:28.581+02	0	23:58:28.581+02	0	t
509	15	1521	Larba Nait Irathen	23:58:28.581+02	0	23:58:28.581+02	0	t
510	15	1522	Tizi Rached	23:58:28.581+02	0	23:58:28.581+02	0	t
511	15	1523	Zekri	23:58:28.581+02	0	23:58:28.581+02	0	t
512	15	1524	Ouaguenoun	23:58:28.581+02	0	23:58:28.581+02	0	t
513	15	1525	Ain Zaouia	23:58:28.581+02	0	23:58:28.581+02	0	t
514	15	1526	M'kira	23:58:28.581+02	0	23:58:28.581+02	0	t
515	15	1527	Ait Yahia	23:58:28.581+02	0	23:58:28.581+02	0	t
516	15	1528	Ait Mahmoud	23:58:28.581+02	0	23:58:28.581+02	0	t
517	15	1529	Maatka	23:58:28.581+02	0	23:58:28.581+02	0	t
518	15	1530	Ait Boumehdi	23:58:28.581+02	0	23:58:28.581+02	0	t
519	15	1531	Abi Youcef	23:58:28.581+02	0	23:58:28.581+02	0	t
520	15	1532	Beni Douala	23:58:28.581+02	0	23:58:28.581+02	0	t
521	15	1533	Illilten	23:58:28.581+02	0	23:58:28.581+02	0	t
522	15	1534	Bouzguen	23:58:28.581+02	0	23:58:28.581+02	0	t
523	15	1535	Ait Aggouacha	23:58:28.581+02	0	23:58:28.581+02	0	t
524	15	1536	Ouadhia	23:58:28.581+02	0	23:58:28.581+02	0	t
525	15	1537	Azzefoun	23:58:28.581+02	0	23:58:28.581+02	0	t
526	15	1538	Tigzirt	23:58:28.581+02	0	23:58:28.581+02	0	t
527	15	1539	Djebel Aissa Mimoun	23:58:28.581+02	0	23:58:28.581+02	0	t
528	15	1540	Boghni	23:58:28.581+02	0	23:58:28.581+02	0	t
529	15	1541	Ifigha	23:58:28.581+02	0	23:58:28.581+02	0	t
530	15	1542	Ait Oumalou	23:58:28.581+02	0	23:58:28.581+02	0	t
531	15	1543	Tirmirtine	23:58:28.581+02	0	23:58:28.581+02	0	t
532	15	1544	Akerrou	23:58:28.581+02	0	23:58:28.581+02	0	t
533	15	1545	Yatafene	23:58:28.581+02	0	23:58:28.581+02	0	t
534	15	1546	Beni Ziki	23:58:28.581+02	0	23:58:28.581+02	0	t
535	15	1547	Draa Ben Kheda	23:58:28.581+02	0	23:58:28.581+02	0	t
536	15	1548	Ouacif	23:58:28.581+02	0	23:58:28.581+02	0	t
537	15	1549	Idjeur	23:58:28.581+02	0	23:58:28.581+02	0	t
538	15	1550	Mekla	23:58:28.581+02	0	23:58:28.581+02	0	t
539	15	1551	Tizi N'thlata	23:58:28.581+02	0	23:58:28.581+02	0	t
540	15	1552	Beni Yenni	23:58:28.581+02	0	23:58:28.581+02	0	t
541	15	1553	Aghrib	23:58:28.581+02	0	23:58:28.581+02	0	t
542	15	1554	Iflissen	23:58:28.581+02	0	23:58:28.581+02	0	t
543	15	1555	Boudjima	23:58:28.581+02	0	23:58:28.581+02	0	t
544	15	1556	Ait Yahia Mou,	23:58:28.581+02	0	23:58:28.581+02	0	t
545	15	1557	Souk El Tenine	23:58:28.581+02	0	23:58:28.581+02	0	t
546	15	1558	Ait Khelili	23:58:28.581+02	0	23:58:28.581+02	0	t
547	15	1559	Sidi Naamane	23:58:28.581+02	0	23:58:28.581+02	0	t
548	15	1560	Iboudraren	23:58:28.581+02	0	23:58:28.581+02	0	t
549	15	1561	Aghni Goughran	23:58:28.581+02	0	23:58:28.581+02	0	t
550	15	1562	Mizrana	23:58:28.581+02	0	23:58:28.581+02	0	t
551	15	1563	Imsouhal	23:58:28.581+02	0	23:58:28.581+02	0	t
552	15	1564	Tadmait	23:58:28.581+02	0	23:58:28.581+02	0	t
553	15	1565	Ait Bouaddou	23:58:28.581+02	0	23:58:28.581+02	0	t
554	15	1566	Assi Youcef	23:58:28.581+02	0	23:58:28.581+02	0	t
555	15	1567	Ait Toudert	23:58:28.581+02	0	23:58:28.581+02	0	t
556	16	1601	Alger-Centre	23:58:28.581+02	0	23:58:28.581+02	0	t
557	16	1602	Sidi M'hamed	23:58:28.581+02	0	23:58:28.581+02	0	t
558	16	1603	El Madania	23:58:28.581+02	0	23:58:28.581+02	0	t
559	16	1604	Hamma Annassers	23:58:28.581+02	0	23:58:28.581+02	0	t
560	16	1605	Bab El Oued	23:58:28.581+02	0	23:58:28.581+02	0	t
561	16	1606	Bologhine	23:58:28.581+02	0	23:58:28.581+02	0	t
562	16	1607	Casbah	23:58:28.581+02	0	23:58:28.581+02	0	t
563	16	1608	Oued Koreiche	23:58:28.581+02	0	23:58:28.581+02	0	t
564	16	1609	Bir Mourad Rais	23:58:28.581+02	0	23:58:28.581+02	0	t
565	16	1610	El Biar	23:58:28.581+02	0	23:58:28.581+02	0	t
566	16	1611	Bouzereah	23:58:28.581+02	0	23:58:28.581+02	0	t
567	16	1612	Birkhadem	23:58:28.581+02	0	23:58:28.581+02	0	t
568	16	1613	El Harrach	23:58:28.581+02	0	23:58:28.581+02	0	t
569	16	1614	Baraki	23:58:28.581+02	0	23:58:28.581+02	0	t
570	16	1615	Oued Smar	23:58:28.581+02	0	23:58:28.581+02	0	t
571	16	1616	Bourouba	23:58:28.581+02	0	23:58:28.581+02	0	t
572	16	1617	Hussein Dey	23:58:28.581+02	0	23:58:28.581+02	0	t
573	16	1618	Kouba	23:58:28.581+02	0	23:58:28.581+02	0	t
574	16	1619	Bachdjarah	23:58:28.581+02	0	23:58:28.581+02	0	t
575	16	1620	Dar El Beida	23:58:28.581+02	0	23:58:28.581+02	0	t
576	16	1621	Bab Ezzouar	23:58:28.581+02	0	23:58:28.581+02	0	t
577	16	1622	Ben Aknoun	23:58:28.581+02	0	23:58:28.581+02	0	t
578	16	1623	Dely Ibrahim	23:58:28.581+02	0	23:58:28.581+02	0	t
579	16	1624	Hammamet	23:58:28.581+02	0	23:58:28.581+02	0	t
580	16	1625	Rais Hamidou	23:58:28.581+02	0	23:58:28.581+02	0	t
581	16	1626	Djasr Kasentina	23:58:28.581+02	0	23:58:28.581+02	0	t
582	16	1627	El Mouradia	23:58:28.581+02	0	23:58:28.581+02	0	t
583	16	1628	Hydra	23:58:28.581+02	0	23:58:28.581+02	0	t
584	16	1629	Mohammadia	23:58:28.581+02	0	23:58:28.581+02	0	t
585	16	1630	Bordj El Kiffan	23:58:28.581+02	0	23:58:28.581+02	0	t
586	16	1631	El Magharia	23:58:28.581+02	0	23:58:28.581+02	0	t
587	16	1632	Beni Messous	23:58:28.581+02	0	23:58:28.581+02	0	t
588	16	1633	Eucalyptus	23:58:28.581+02	0	23:58:28.581+02	0	t
589	16	1634	Birtouta	23:58:28.581+02	0	23:58:28.581+02	0	t
590	16	1635	Tessala El Merdja	23:58:28.581+02	0	23:58:28.581+02	0	t
591	16	1636	Ouled Chebel	23:58:28.581+02	0	23:58:28.581+02	0	t
592	16	1637	Sidi Moussa	23:58:28.581+02	0	23:58:28.581+02	0	t
593	16	1638	Ain Taya	23:58:28.581+02	0	23:58:28.581+02	0	t
594	16	1639	Bordj El Bahri	23:58:28.581+02	0	23:58:28.581+02	0	t
595	16	1640	El Marsa	23:58:28.581+02	0	23:58:28.581+02	0	t
596	16	1641	Harraoua	23:58:28.581+02	0	23:58:28.581+02	0	t
597	16	1642	Rouiba	23:58:28.581+02	0	23:58:28.581+02	0	t
598	16	1643	Reghaia	23:58:28.581+02	0	23:58:28.581+02	0	t
599	16	1644	Ain Benian	23:58:28.581+02	0	23:58:28.581+02	0	t
600	16	1645	Staoueli	23:58:28.581+02	0	23:58:28.581+02	0	t
601	16	1646	Zeralda	23:58:28.581+02	0	23:58:28.581+02	0	t
602	16	1647	Mahelma	23:58:28.581+02	0	23:58:28.581+02	0	t
603	16	1648	Rahmania	23:58:28.581+02	0	23:58:28.581+02	0	t
604	16	1649	Souidania	23:58:28.581+02	0	23:58:28.581+02	0	t
605	16	1650	Cheraga	23:58:28.581+02	0	23:58:28.581+02	0	t
606	16	1651	Ouled Fayet	23:58:28.581+02	0	23:58:28.581+02	0	t
607	16	1652	El Achour	23:58:28.581+02	0	23:58:28.581+02	0	t
608	16	1653	Draria	23:58:28.581+02	0	23:58:28.581+02	0	t
609	16	1654	Douera	23:58:28.581+02	0	23:58:28.581+02	0	t
610	16	1655	Baba Hassen	23:58:28.581+02	0	23:58:28.581+02	0	t
611	16	1656	Khraicia	23:58:28.581+02	0	23:58:28.581+02	0	t
612	16	1657	Saoula	23:58:28.581+02	0	23:58:28.581+02	0	t
613	17	1701	Djelfa	23:58:28.581+02	0	23:58:28.581+02	0	t
614	17	1702	Moudjebara	23:58:28.581+02	0	23:58:28.581+02	0	t
615	17	1703	El Guedid	23:58:28.581+02	0	23:58:28.581+02	0	t
616	17	1704	Hassi Bahbah	23:58:28.581+02	0	23:58:28.581+02	0	t
617	17	1705	Ain Maabed	23:58:28.581+02	0	23:58:28.581+02	0	t
618	17	1706	Sed Rahal	23:58:28.581+02	0	23:58:28.581+02	0	t
619	17	1707	Feidh El Botma	23:58:28.581+02	0	23:58:28.581+02	0	t
620	17	1708	Birine	23:58:28.581+02	0	23:58:28.581+02	0	t
621	17	1709	Bouira Lahdeb	23:58:28.581+02	0	23:58:28.581+02	0	t
622	17	1710	Zaccar	23:58:28.581+02	0	23:58:28.581+02	0	t
623	17	1711	El Khemis	23:58:28.581+02	0	23:58:28.581+02	0	t
624	17	1712	Sidi Baizid	23:58:28.581+02	0	23:58:28.581+02	0	t
625	17	1713	Mliliha	23:58:28.581+02	0	23:58:28.581+02	0	t
626	17	1714	El Idrissia	23:58:28.581+02	0	23:58:28.581+02	0	t
627	17	1715	Douis	23:58:28.581+02	0	23:58:28.581+02	0	t
628	17	1716	Hassi El Euch	23:58:28.581+02	0	23:58:28.581+02	0	t
629	17	1717	Messaad	23:58:28.581+02	0	23:58:28.581+02	0	t
630	17	1718	Guettara	23:58:28.581+02	0	23:58:28.581+02	0	t
631	17	1719	Sidi Ladjel	23:58:28.581+02	0	23:58:28.581+02	0	t
632	17	1720	Had Sahary	23:58:28.581+02	0	23:58:28.581+02	0	t
633	17	1721	Guernini	23:58:28.581+02	0	23:58:28.581+02	0	t
634	17	1722	Selmana	23:58:28.581+02	0	23:58:28.581+02	0	t
635	17	1723	Ain Chouhada	23:58:28.581+02	0	23:58:28.581+02	0	t
636	17	1724	Oum Laadham	23:58:28.581+02	0	23:58:28.581+02	0	t
637	17	1725	Dar Chioukh	23:58:28.581+02	0	23:58:28.581+02	0	t
638	17	1726	Charef	23:58:28.581+02	0	23:58:28.581+02	0	t
639	17	1727	Beniyagoub	23:58:28.581+02	0	23:58:28.581+02	0	t
640	17	1728	Zaafrane	23:58:28.581+02	0	23:58:28.581+02	0	t
641	17	1729	Deldoul	23:58:28.581+02	0	23:58:28.581+02	0	t
642	17	1730	Ain El Ibel	23:58:28.581+02	0	23:58:28.581+02	0	t
643	17	1731	Ain Oussera	23:58:28.581+02	0	23:58:28.581+02	0	t
644	17	1732	Benhar	23:58:28.581+02	0	23:58:28.581+02	0	t
645	17	1733	Hassi Fedoul	23:58:28.581+02	0	23:58:28.581+02	0	t
646	17	1734	Amourah	23:58:28.581+02	0	23:58:28.581+02	0	t
647	17	1735	Ain Fekka	23:58:28.581+02	0	23:58:28.581+02	0	t
648	17	1736	Tadmit	23:58:28.581+02	0	23:58:28.581+02	0	t
649	18	1801	Jijel	23:58:28.581+02	0	23:58:28.581+02	0	t
650	18	1802	Erraguene	23:58:28.581+02	0	23:58:28.581+02	0	t
651	18	1803	El Aouana	23:58:28.581+02	0	23:58:28.581+02	0	t
652	18	1804	Ziama Mansouriah	23:58:28.581+02	0	23:58:28.581+02	0	t
653	18	1805	Taher	23:58:28.581+02	0	23:58:28.581+02	0	t
654	18	1806	Emir Abdelkader	23:58:28.581+02	0	23:58:28.581+02	0	t
655	18	1807	Chekfa	23:58:28.581+02	0	23:58:28.581+02	0	t
656	18	1808	Chahna 	23:58:28.581+02	0	23:58:28.581+02	0	t
657	18	1809	El Milia	23:58:28.581+02	0	23:58:28.581+02	0	t
658	18	1810	Sidi Maarouf	23:58:28.581+02	0	23:58:28.581+02	0	t
659	18	1811	Settara	23:58:28.581+02	0	23:58:28.581+02	0	t
660	18	1812	El Ancer	23:58:28.581+02	0	23:58:28.581+02	0	t
661	18	1813	Sidi Abdelaziz	23:58:28.581+02	0	23:58:28.581+02	0	t
662	18	1814	Kaous	23:58:28.581+02	0	23:58:28.581+02	0	t
663	18	1815	Ghebala	23:58:28.581+02	0	23:58:28.581+02	0	t
664	18	1816	Bouraoui Belhadef	23:58:28.581+02	0	23:58:28.581+02	0	t
665	18	1817	Djimla	23:58:28.581+02	0	23:58:28.581+02	0	t
666	18	1818	Selma Benziada	23:58:28.581+02	0	23:58:28.581+02	0	t
667	18	1819	Boussif Ouled Askeur	23:58:28.581+02	0	23:58:28.581+02	0	t
668	18	1820	El Kennar Nouchfi	23:58:28.581+02	0	23:58:28.581+02	0	t
669	18	1821	Ouled Yahia Khedrouche	23:58:28.581+02	0	23:58:28.581+02	0	t
670	18	1822	Boudria Beni Yadjis	23:58:28.581+02	0	23:58:28.581+02	0	t
671	18	1823	Kheiri Oued Adjoul	23:58:28.581+02	0	23:58:28.581+02	0	t
672	18	1824	Texena	23:58:28.581+02	0	23:58:28.581+02	0	t
673	18	1825	Djemaa Beni H'Bibi	23:58:28.581+02	0	23:58:28.581+02	0	t
674	18	1826	Bordj T'Har	23:58:28.581+02	0	23:58:28.581+02	0	t
675	18	1827	Ouled Rabah	23:58:28.581+02	0	23:58:28.581+02	0	t
676	18	1828	Ouadjana	23:58:28.581+02	0	23:58:28.581+02	0	t
677	19	1901	Setif	23:58:28.581+02	0	23:58:28.581+02	0	t
678	19	1902	Ain El Kebira	23:58:28.581+02	0	23:58:28.581+02	0	t
679	19	1903	Beni Aziz	23:58:28.581+02	0	23:58:28.581+02	0	t
680	19	1904	Ouled Si Ahmed	23:58:28.581+02	0	23:58:28.581+02	0	t
681	19	1905	Boutaleb	23:58:28.581+02	0	23:58:28.581+02	0	t
682	19	1906	Ain Roua	23:58:28.581+02	0	23:58:28.581+02	0	t
683	19	1907	Draa Kebila	23:58:28.581+02	0	23:58:28.581+02	0	t
684	19	1908	Bir El Arch	23:58:28.581+02	0	23:58:28.581+02	0	t
685	19	1909	Beni Chebana	23:58:28.581+02	0	23:58:28.581+02	0	t
686	19	1910	Ouled Tebben	23:58:28.581+02	0	23:58:28.581+02	0	t
687	19	1911	Hamma	23:58:28.581+02	0	23:58:28.581+02	0	t
688	19	1912	Maaouia	23:58:28.581+02	0	23:58:28.581+02	0	t
689	19	1913	Ain Legradj	23:58:28.581+02	0	23:58:28.581+02	0	t
690	19	1914	Ain Abessa	23:58:28.581+02	0	23:58:28.581+02	0	t
691	19	1915	Dehemcha	23:58:28.581+02	0	23:58:28.581+02	0	t
692	19	1916	Babor	23:58:28.581+02	0	23:58:28.581+02	0	t
693	19	1917	Guidjel	23:58:28.581+02	0	23:58:28.581+02	0	t
694	19	1918	Ain Lahdjar	23:58:28.581+02	0	23:58:28.581+02	0	t
695	19	1919	Bousselam	23:58:28.581+02	0	23:58:28.581+02	0	t
696	19	1920	El Eulma	23:58:28.581+02	0	23:58:28.581+02	0	t
697	19	1921	Djemila	23:58:28.581+02	0	23:58:28.581+02	0	t
698	19	1922	Beni Ourtilane	23:58:28.581+02	0	23:58:28.581+02	0	t
699	19	1923	Rosfa	23:58:28.581+02	0	23:58:28.581+02	0	t
700	19	1924	Ouled Addouane	23:58:28.581+02	0	23:58:28.581+02	0	t
701	19	1925	Bellaa	23:58:28.581+02	0	23:58:28.581+02	0	t
702	19	1926	Ain Arnat	23:58:28.581+02	0	23:58:28.581+02	0	t
703	19	1927	Amoucha	23:58:28.581+02	0	23:58:28.581+02	0	t
704	19	1928	Ain Oulmane	23:58:28.581+02	0	23:58:28.581+02	0	t
705	19	1929	Beidha Bordj	23:58:28.581+02	0	23:58:28.581+02	0	t
706	19	1930	Bouandas	23:58:28.581+02	0	23:58:28.581+02	0	t
707	19	1931	Bazer Sakra	23:58:28.581+02	0	23:58:28.581+02	0	t
708	19	1932	Hammam Essokhna	23:58:28.581+02	0	23:58:28.581+02	0	t
709	19	1933	Mezloug	23:58:28.581+02	0	23:58:28.581+02	0	t
710	19	1934	Bir Haddada	23:58:28.581+02	0	23:58:28.581+02	0	t
711	19	1935	Serdj El Ghoul	23:58:28.581+02	0	23:58:28.581+02	0	t
712	19	1936	Harbil	23:58:28.581+02	0	23:58:28.581+02	0	t
713	19	1937	El Ouricia	23:58:28.581+02	0	23:58:28.581+02	0	t
714	19	1938	Tizi N'bechar	23:58:28.581+02	0	23:58:28.581+02	0	t
715	19	1939	Salah Bey	23:58:28.581+02	0	23:58:28.581+02	0	t
716	19	1940	Ain Azal	23:58:28.581+02	0	23:58:28.581+02	0	t
717	19	1941	Guenzet	23:58:28.581+02	0	23:58:28.581+02	0	t
718	19	1942	Talaifacene	23:58:28.581+02	0	23:58:28.581+02	0	t
719	19	1943	Bougaa	23:58:28.581+02	0	23:58:28.581+02	0	t
720	19	1944	Beni Fouda	23:58:28.581+02	0	23:58:28.581+02	0	t
721	19	1945	Tachouda	23:58:28.581+02	0	23:58:28.581+02	0	t
722	19	1946	Beni Mouhli	23:58:28.581+02	0	23:58:28.581+02	0	t
723	19	1947	Ouled Sabor	23:58:28.581+02	0	23:58:28.581+02	0	t
724	19	1948	Guellal	23:58:28.581+02	0	23:58:28.581+02	0	t
725	19	1949	Ain Sebt	23:58:28.581+02	0	23:58:28.581+02	0	t
726	19	1950	Hammam Guergour	23:58:28.581+02	0	23:58:28.581+02	0	t
727	19	1951	Ait Naoual M,	23:58:28.581+02	0	23:58:28.581+02	0	t
728	19	1952	Ksar El Abtal	23:58:28.581+02	0	23:58:28.581+02	0	t
729	19	1953	Beni Hocine	23:58:28.581+02	0	23:58:28.581+02	0	t
730	19	1954	Ait Tizi	23:58:28.581+02	0	23:58:28.581+02	0	t
731	19	1955	Maouaklane	23:58:28.581+02	0	23:58:28.581+02	0	t
732	19	1956	Guelta Zerka	23:58:28.581+02	0	23:58:28.581+02	0	t
733	19	1957	Oued El Barad	23:58:28.581+02	0	23:58:28.581+02	0	t
734	19	1958	Taya	23:58:28.581+02	0	23:58:28.581+02	0	t
735	19	1959	El Ouldja	23:58:28.581+02	0	23:58:28.581+02	0	t
736	19	1960	Tella	23:58:28.581+02	0	23:58:28.581+02	0	t
737	20	2001	Saida	23:58:28.581+02	0	23:58:28.581+02	0	t
738	20	2002	Doui Thabet	23:58:28.581+02	0	23:58:28.581+02	0	t
739	20	2003	Ain Hadjar	23:58:28.581+02	0	23:58:28.581+02	0	t
740	20	2004	Ouled Khaled	23:58:28.581+02	0	23:58:28.581+02	0	t
741	20	2005	Moulay Larbi	23:58:28.581+02	0	23:58:28.581+02	0	t
742	20	2006	Youb	23:58:28.581+02	0	23:58:28.581+02	0	t
743	20	2007	Hounet	23:58:28.581+02	0	23:58:28.581+02	0	t
744	20	2008	Sidi Amar	23:58:28.581+02	0	23:58:28.581+02	0	t
745	20	2009	Sidi Boubekeur	23:58:28.581+02	0	23:58:28.581+02	0	t
746	20	2010	El Hassassna	23:58:28.581+02	0	23:58:28.581+02	0	t
747	20	2011	Maamora	23:58:28.581+02	0	23:58:28.581+02	0	t
748	20	2012	Sidi Ahmed	23:58:28.581+02	0	23:58:28.581+02	0	t
749	20	2013	Ain Skhouna	23:58:28.581+02	0	23:58:28.581+02	0	t
750	20	2014	Ouled Brahim	23:58:28.581+02	0	23:58:28.581+02	0	t
751	20	2015	Tircine	23:58:28.581+02	0	23:58:28.581+02	0	t
752	20	2016	Ain Soltane	23:58:28.581+02	0	23:58:28.581+02	0	t
753	21	2101	Skikda	23:58:28.581+02	0	23:58:28.581+02	0	t
754	21	2102	Ain Zouit	23:58:28.581+02	0	23:58:28.581+02	0	t
755	21	2103	El Hadaik	23:58:28.581+02	0	23:58:28.581+02	0	t
756	21	2104	Azzaba	23:58:28.581+02	0	23:58:28.581+02	0	t
757	21	2105	Djendel Saadi Med	23:58:28.581+02	0	23:58:28.581+02	0	t
758	21	2106	Ain Cherchar	23:58:28.581+02	0	23:58:28.581+02	0	t
759	21	2107	Bekkouche Lakhdar	23:58:28.581+02	0	23:58:28.581+02	0	t
760	21	2108	Benazouz	23:58:28.581+02	0	23:58:28.581+02	0	t
761	21	2109	Es Sebt	23:58:28.581+02	0	23:58:28.581+02	0	t
762	21	2110	Collo	23:58:28.581+02	0	23:58:28.581+02	0	t
763	21	2111	Beni Zid	23:58:28.581+02	0	23:58:28.581+02	0	t
764	21	2112	Kerkera	23:58:28.581+02	0	23:58:28.581+02	0	t
765	21	2113	Ouled Attia	23:58:28.581+02	0	23:58:28.581+02	0	t
766	21	2114	Oued Zehour	23:58:28.581+02	0	23:58:28.581+02	0	t
767	21	2115	Zitouna	23:58:28.581+02	0	23:58:28.581+02	0	t
768	21	2116	El Harrouch	23:58:28.581+02	0	23:58:28.581+02	0	t
769	21	2117	Zerdazas	23:58:28.581+02	0	23:58:28.581+02	0	t
770	21	2118	Ouled Hebaba	23:58:28.581+02	0	23:58:28.581+02	0	t
771	21	2119	Sidi Mezghiche	23:58:28.581+02	0	23:58:28.581+02	0	t
772	21	2120	Emdjez Edchich	23:58:28.581+02	0	23:58:28.581+02	0	t
773	21	2121	Beni Oulbane	23:58:28.581+02	0	23:58:28.581+02	0	t
774	21	2122	Ain Bouziane	23:58:28.581+02	0	23:58:28.581+02	0	t
775	21	2123	Ramdane Djamel	23:58:28.581+02	0	23:58:28.581+02	0	t
776	21	2124	Beni Bechir	23:58:28.581+02	0	23:58:28.581+02	0	t
777	21	2125	Salah Bouchaour	23:58:28.581+02	0	23:58:28.581+02	0	t
778	21	2126	Tamalous	23:58:28.581+02	0	23:58:28.581+02	0	t
779	21	2127	Ain Kechra	23:58:28.581+02	0	23:58:28.581+02	0	t
780	21	2128	Oum Toub	23:58:28.581+02	0	23:58:28.581+02	0	t
781	21	2129	Bir El Ouiden	23:58:28.581+02	0	23:58:28.581+02	0	t
782	21	2130	Fil Fila	23:58:28.581+02	0	23:58:28.581+02	0	t
783	21	2131	Cheraia	23:58:28.581+02	0	23:58:28.581+02	0	t
784	21	2132	Kanoua	23:58:28.581+02	0	23:58:28.581+02	0	t
785	21	2133	El Ghedir	23:58:28.581+02	0	23:58:28.581+02	0	t
786	21	2134	Bouchtata	23:58:28.581+02	0	23:58:28.581+02	0	t
787	21	2135	Ouldja Boulbalout	23:58:28.581+02	0	23:58:28.581+02	0	t
788	21	2136	Kheneg Mayoum	23:58:28.581+02	0	23:58:28.581+02	0	t
789	21	2137	Hamadi Krouma	23:58:28.581+02	0	23:58:28.581+02	0	t
790	21	2138	El Marsa	23:58:28.581+02	0	23:58:28.581+02	0	t
791	22	2201	Sidi Bel Abbes	23:58:28.581+02	0	23:58:28.581+02	0	t
792	22	2202	Tessala	23:58:28.581+02	0	23:58:28.581+02	0	t
793	22	2203	Sidi Brahim	23:58:28.581+02	0	23:58:28.581+02	0	t
794	22	2204	Mostafa Ben Brahim	23:58:28.581+02	0	23:58:28.581+02	0	t
795	22	2205	Telagh	23:58:28.581+02	0	23:58:28.581+02	0	t
796	22	2206	Mezaourou	23:58:28.581+02	0	23:58:28.581+02	0	t
797	22	2207	Boukhanifis	23:58:28.581+02	0	23:58:28.581+02	0	t
798	22	2208	Sidi Ali Boussidi	23:58:28.581+02	0	23:58:28.581+02	0	t
799	22	2209	Bedrabine El Mokrani	23:58:28.581+02	0	23:58:28.581+02	0	t
800	22	2210	Marhoum	23:58:28.581+02	0	23:58:28.581+02	0	t
801	22	2211	Tafessour	23:58:28.581+02	0	23:58:28.581+02	0	t
802	22	2212	Amarnas	23:58:28.581+02	0	23:58:28.581+02	0	t
803	22	2213	Tilmouni	23:58:28.581+02	0	23:58:28.581+02	0	t
804	22	2214	Sidi Lahcene	23:58:28.581+02	0	23:58:28.581+02	0	t
805	22	2215	Ain Thrid	23:58:28.581+02	0	23:58:28.581+02	0	t
806	22	2216	Mekadra	23:58:28.581+02	0	23:58:28.581+02	0	t
807	22	2217	Tenira	23:58:28.581+02	0	23:58:28.581+02	0	t
808	22	2218	Moulay Slissen	23:58:28.581+02	0	23:58:28.581+02	0	t
809	22	2219	El Hacaiba	23:58:28.581+02	0	23:58:28.581+02	0	t
810	22	2220	Hassi Zahana	23:58:28.581+02	0	23:58:28.581+02	0	t
811	22	2221	Tabia	23:58:28.581+02	0	23:58:28.581+02	0	t
812	22	2222	Merine	23:58:28.581+02	0	23:58:28.581+02	0	t
813	22	2223	Ras El Ma	23:58:28.581+02	0	23:58:28.581+02	0	t
814	22	2224	Ain Tindamine	23:58:28.581+02	0	23:58:28.581+02	0	t
815	22	2225	Ain Kada	23:58:28.581+02	0	23:58:28.581+02	0	t
816	22	2226	M'cid	23:58:28.581+02	0	23:58:28.581+02	0	t
817	22	2227	Sidi Khaled	23:58:28.581+02	0	23:58:28.581+02	0	t
818	22	2228	Ain El Berd	23:58:28.581+02	0	23:58:28.581+02	0	t
819	22	2229	Sfisef	23:58:28.581+02	0	23:58:28.581+02	0	t
820	22	2230	Ain Adden	23:58:28.581+02	0	23:58:28.581+02	0	t
821	22	2231	Oued Taourira	23:58:28.581+02	0	23:58:28.581+02	0	t
822	22	2232	Dhaya	23:58:28.581+02	0	23:58:28.581+02	0	t
823	22	2233	Zerouala	23:58:28.581+02	0	23:58:28.581+02	0	t
824	22	2234	Lamtar	23:58:28.581+02	0	23:58:28.581+02	0	t
825	22	2235	Sidi Chaib	23:58:28.581+02	0	23:58:28.581+02	0	t
826	22	2236	Sidi Daho De Zairs	23:58:28.581+02	0	23:58:28.581+02	0	t
827	22	2237	Oued Sebaa	23:58:28.581+02	0	23:58:28.581+02	0	t
828	22	2238	Boudjebha El Bordj	23:58:28.581+02	0	23:58:28.581+02	0	t
829	22	2239	Sehala Thaoura	23:58:28.581+02	0	23:58:28.581+02	0	t
830	22	2240	Sidi Yagoub	23:58:28.581+02	0	23:58:28.581+02	0	t
831	22	2241	Sidi Hamadouche	23:58:28.581+02	0	23:58:28.581+02	0	t
832	22	2242	Belarbi	23:58:28.581+02	0	23:58:28.581+02	0	t
833	22	2243	Oued Sefioun	23:58:28.581+02	0	23:58:28.581+02	0	t
834	22	2244	Teghelimet	23:58:28.581+02	0	23:58:28.581+02	0	t
835	22	2245	Ben Badis	23:58:28.581+02	0	23:58:28.581+02	0	t
836	22	2246	Sidi Ali Benyoub	23:58:28.581+02	0	23:58:28.581+02	0	t
837	22	2247	Chetouane	23:58:28.581+02	0	23:58:28.581+02	0	t
838	22	2248	Bir El H'mam	23:58:28.581+02	0	23:58:28.581+02	0	t
839	22	2249	Taoudmout	23:58:28.581+02	0	23:58:28.581+02	0	t
840	22	2250	Redjem Demouche	23:58:28.581+02	0	23:58:28.581+02	0	t
841	22	2251	Benachiba Chelia	23:58:28.581+02	0	23:58:28.581+02	0	t
842	22	2252	Hassi Dahou	23:58:28.581+02	0	23:58:28.581+02	0	t
843	23	2301	Annaba	23:58:28.581+02	0	23:58:28.581+02	0	t
844	23	2302	Berrahal	23:58:28.581+02	0	23:58:28.581+02	0	t
845	23	2303	El Hadjar	23:58:28.581+02	0	23:58:28.581+02	0	t
846	23	2304	Eulma	23:58:28.581+02	0	23:58:28.581+02	0	t
847	23	2305	El Bouni	23:58:28.581+02	0	23:58:28.581+02	0	t
848	23	2306	Oued El Aneb	23:58:28.581+02	0	23:58:28.581+02	0	t
849	23	2307	Cheurfa	23:58:28.581+02	0	23:58:28.581+02	0	t
850	23	2308	Seraidi	23:58:28.581+02	0	23:58:28.581+02	0	t
851	23	2309	Ain Berda	23:58:28.581+02	0	23:58:28.581+02	0	t
852	23	2310	Chetaibi	23:58:28.581+02	0	23:58:28.581+02	0	t
853	23	2311	Sidi Amer	23:58:28.581+02	0	23:58:28.581+02	0	t
854	23	2312	Treat	23:58:28.581+02	0	23:58:28.581+02	0	t
855	24	2401	Guelma	23:58:28.581+02	0	23:58:28.581+02	0	t
856	24	2402	Nechmeya	23:58:28.581+02	0	23:58:28.581+02	0	t
857	24	2403	Bouati Mahmoud	23:58:28.581+02	0	23:58:28.581+02	0	t
858	24	2404	Oued Zenati	23:58:28.581+02	0	23:58:28.581+02	0	t
859	24	2405	Tamlouka	23:58:28.581+02	0	23:58:28.581+02	0	t
860	24	2406	Oued Fragha	23:58:28.581+02	0	23:58:28.581+02	0	t
861	24	2407	Ain Sandel	23:58:28.581+02	0	23:58:28.581+02	0	t
862	24	2408	Ras El Agba	23:58:28.581+02	0	23:58:28.581+02	0	t
863	24	2409	Dahoura	23:58:28.581+02	0	23:58:28.581+02	0	t
864	24	2410	Belkhir	23:58:28.581+02	0	23:58:28.581+02	0	t
865	24	2411	Bendjarah	23:58:28.581+02	0	23:58:28.581+02	0	t
866	24	2412	Bouhamdane	23:58:28.581+02	0	23:58:28.581+02	0	t
867	24	2413	Ain Makhlouf	23:58:28.581+02	0	23:58:28.581+02	0	t
868	24	2414	Ain Ben Beida	23:58:28.581+02	0	23:58:28.581+02	0	t
869	24	2415	Khezaras	23:58:28.581+02	0	23:58:28.581+02	0	t
870	24	2416	Beni Mezline	23:58:28.581+02	0	23:58:28.581+02	0	t
871	24	2417	Bouhachana	23:58:28.581+02	0	23:58:28.581+02	0	t
872	24	2418	Guelaat Bou Sbaa	23:58:28.581+02	0	23:58:28.581+02	0	t
873	24	2419	Hammam Debagh	23:58:28.581+02	0	23:58:28.581+02	0	t
874	24	2420	El Fedjoudj	23:58:28.581+02	0	23:58:28.581+02	0	t
875	24	2421	Bordj Sabat	23:58:28.581+02	0	23:58:28.581+02	0	t
876	24	2422	Hammam N'bail	23:58:28.581+02	0	23:58:28.581+02	0	t
877	24	2423	Ain Larbi	23:58:28.581+02	0	23:58:28.581+02	0	t
878	24	2424	Medjez Amar	23:58:28.581+02	0	23:58:28.581+02	0	t
879	24	2425	Bouchegouf	23:58:28.581+02	0	23:58:28.581+02	0	t
880	24	2426	Heliopolis	23:58:28.581+02	0	23:58:28.581+02	0	t
881	24	2427	Ain Hessania	23:58:28.581+02	0	23:58:28.581+02	0	t
882	24	2428	Roknia	23:58:28.581+02	0	23:58:28.581+02	0	t
883	24	2429	Sellaoua Anouna	23:58:28.581+02	0	23:58:28.581+02	0	t
884	24	2430	Medjez Sfa	23:58:28.581+02	0	23:58:28.581+02	0	t
885	24	2431	Boumahra Ahmed	23:58:28.581+02	0	23:58:28.581+02	0	t
886	24	2432	Ain Regada	23:58:28.581+02	0	23:58:28.581+02	0	t
887	24	2433	Oued Cheham	23:58:28.581+02	0	23:58:28.581+02	0	t
888	24	2434	Djebala Khemissi	23:58:28.581+02	0	23:58:28.581+02	0	t
889	25	2501	Constantine	23:58:28.581+02	0	23:58:28.581+02	0	t
890	25	2502	Hamma Bouziane	23:58:28.581+02	0	23:58:28.581+02	0	t
891	25	2503	Ibn Badis	23:58:28.581+02	0	23:58:28.581+02	0	t
892	25	2504	Zighout Youcef	23:58:28.581+02	0	23:58:28.581+02	0	t
893	25	2505	Didouche Mourad	23:58:28.581+02	0	23:58:28.581+02	0	t
894	25	2506	El Khroub	23:58:28.581+02	0	23:58:28.581+02	0	t
895	25	2507	Ain Abid	23:58:28.581+02	0	23:58:28.581+02	0	t
896	25	2508	Beni Hamiden	23:58:28.581+02	0	23:58:28.581+02	0	t
897	25	2509	Ouled Rahmoune	23:58:28.581+02	0	23:58:28.581+02	0	t
898	25	2510	Ain Smara	23:58:28.581+02	0	23:58:28.581+02	0	t
899	25	2511	Messaoud Boujeriou	23:58:28.581+02	0	23:58:28.581+02	0	t
900	25	2512	Ibn Ziad	23:58:28.581+02	0	23:58:28.581+02	0	t
901	26	2601	Medea	23:58:28.581+02	0	23:58:28.581+02	0	t
902	26	2602	Ouzera	23:58:28.581+02	0	23:58:28.581+02	0	t
903	26	2603	Ouled Maaref	23:58:28.581+02	0	23:58:28.581+02	0	t
904	26	2604	Ain Boucif	23:58:28.581+02	0	23:58:28.581+02	0	t
905	26	2605	Aissaouia	23:58:28.581+02	0	23:58:28.581+02	0	t
906	26	2606	Ouled Deide	23:58:28.581+02	0	23:58:28.581+02	0	t
907	26	2607	El Omaria	23:58:28.581+02	0	23:58:28.581+02	0	t
908	26	2608	Derrag	23:58:28.581+02	0	23:58:28.581+02	0	t
909	26	2609	El Guelb El Kebir	23:58:28.581+02	0	23:58:28.581+02	0	t
910	26	2610	Bou Aiche	23:58:28.581+02	0	23:58:28.581+02	0	t
911	26	2611	Mezerana	23:58:28.581+02	0	23:58:28.581+02	0	t
912	26	2612	Ouled Brahim	23:58:28.581+02	0	23:58:28.581+02	0	t
913	26	2613	Tizi Mahdi	23:58:28.581+02	0	23:58:28.581+02	0	t
914	26	2614	Sidi Ziane	23:58:28.581+02	0	23:58:28.581+02	0	t
915	26	2615	Tamesguida	23:58:28.581+02	0	23:58:28.581+02	0	t
916	26	2616	El Hamdania	23:58:28.581+02	0	23:58:28.581+02	0	t
917	26	2617	Kef Lakhdar	23:58:28.581+02	0	23:58:28.581+02	0	t
918	26	2618	Chellalet Adhaoura	23:58:28.581+02	0	23:58:28.581+02	0	t
919	26	2619	Bouskene	23:58:28.581+02	0	23:58:28.581+02	0	t
920	26	2620	Rebaia	23:58:28.581+02	0	23:58:28.581+02	0	t
921	26	2621	Bouchrahil	23:58:28.581+02	0	23:58:28.581+02	0	t
922	26	2622	Ouled Hellal	23:58:28.581+02	0	23:58:28.581+02	0	t
923	26	2623	Tafraout	23:58:28.581+02	0	23:58:28.581+02	0	t
924	26	2624	Baata	23:58:28.581+02	0	23:58:28.581+02	0	t
925	26	2625	Boghar	23:58:28.581+02	0	23:58:28.581+02	0	t
926	26	2626	Sidi Naamane	23:58:28.581+02	0	23:58:28.581+02	0	t
927	26	2627	Ouled Bouachra	23:58:28.581+02	0	23:58:28.581+02	0	t
928	26	2628	Sidi Zahar	23:58:28.581+02	0	23:58:28.581+02	0	t
929	26	2629	Oued Harbil	23:58:28.581+02	0	23:58:28.581+02	0	t
930	26	2630	Benchicao	23:58:28.581+02	0	23:58:28.581+02	0	t
931	26	2631	Sidi Damed	23:58:28.581+02	0	23:58:28.581+02	0	t
932	26	2632	Aziz	23:58:28.581+02	0	23:58:28.581+02	0	t
933	26	2633	Souagui	23:58:28.581+02	0	23:58:28.581+02	0	t
934	26	2634	Zoubiria	23:58:28.581+02	0	23:58:28.581+02	0	t
935	26	2635	Ksar Boukhari	23:58:28.581+02	0	23:58:28.581+02	0	t
936	26	2636	El Azizia	23:58:28.581+02	0	23:58:28.581+02	0	t
937	26	2637	Djouab	23:58:28.581+02	0	23:58:28.581+02	0	t
938	26	2638	Chahbounia	23:58:28.581+02	0	23:58:28.581+02	0	t
939	26	2639	Meghraoua	23:58:28.581+02	0	23:58:28.581+02	0	t
940	26	2640	Cheniguel	23:58:28.581+02	0	23:58:28.581+02	0	t
941	26	2641	Ain Ouksir	23:58:28.581+02	0	23:58:28.581+02	0	t
942	26	2642	Oum Djalil	23:58:28.581+02	0	23:58:28.581+02	0	t
943	26	2643	Ouamri	23:58:28.581+02	0	23:58:28.581+02	0	t
944	26	2644	Si Mahdjoub	23:58:28.581+02	0	23:58:28.581+02	0	t
945	26	2645	Tlatet Eddouar	23:58:28.581+02	0	23:58:28.581+02	0	t
946	26	2646	Beni Slimane	23:58:28.581+02	0	23:58:28.581+02	0	t
947	26	2647	Berrouaghia	23:58:28.581+02	0	23:58:28.581+02	0	t
948	26	2648	Seghouane	23:58:28.581+02	0	23:58:28.581+02	0	t
949	26	2649	Meftaha	23:58:28.581+02	0	23:58:28.581+02	0	t
950	26	2650	Mihoub	23:58:28.581+02	0	23:58:28.581+02	0	t
951	26	2651	Boughezoul	23:58:28.581+02	0	23:58:28.581+02	0	t
952	26	2652	Tablat	23:58:28.581+02	0	23:58:28.581+02	0	t
953	26	2653	Deux Bassins	23:58:28.581+02	0	23:58:28.581+02	0	t
954	26	2654	Draa Essamar	23:58:28.581+02	0	23:58:28.581+02	0	t
955	26	2655	Sidi Errabia	23:58:28.581+02	0	23:58:28.581+02	0	t
956	26	2656	Bir Ben Laabed	23:58:28.581+02	0	23:58:28.581+02	0	t
957	26	2657	El Ouinet	23:58:28.581+02	0	23:58:28.581+02	0	t
958	26	2658	Ouled Antar	23:58:28.581+02	0	23:58:28.581+02	0	t
959	26	2659	Bouaichoune	23:58:28.581+02	0	23:58:28.581+02	0	t
960	26	2660	Hannacha	23:58:28.581+02	0	23:58:28.581+02	0	t
961	26	2661	Sedraia	23:58:28.581+02	0	23:58:28.581+02	0	t
962	26	2662	Moudjbar	23:58:28.581+02	0	23:58:28.581+02	0	t
963	26	2663	Khams Djouamaa	23:58:28.581+02	0	23:58:28.581+02	0	t
964	26	2664	Saneg	23:58:28.581+02	0	23:58:28.581+02	0	t
965	27	2701	Mostaganem	23:58:28.581+02	0	23:58:28.581+02	0	t
966	27	2702	Sayada	23:58:28.581+02	0	23:58:28.581+02	0	t
967	27	2703	Fornaka	23:58:28.581+02	0	23:58:28.581+02	0	t
968	27	2704	Stidia	23:58:28.581+02	0	23:58:28.581+02	0	t
969	27	2705	Ain Nouissy	23:58:28.581+02	0	23:58:28.581+02	0	t
970	27	2706	Hassi Mameche	23:58:28.581+02	0	23:58:28.581+02	0	t
971	27	2707	Ain Tadles	23:58:28.581+02	0	23:58:28.581+02	0	t
972	27	2708	Sour	23:58:28.581+02	0	23:58:28.581+02	0	t
973	27	2709	Oued El Kheir	23:58:28.581+02	0	23:58:28.581+02	0	t
974	27	2710	Sidi Belatar	23:58:28.581+02	0	23:58:28.581+02	0	t
975	27	2711	Kheiredine	23:58:28.581+02	0	23:58:28.581+02	0	t
976	27	2712	Sidi Ali	23:58:28.581+02	0	23:58:28.581+02	0	t
977	27	2713	Abdelmalek Ramdane	23:58:28.581+02	0	23:58:28.581+02	0	t
978	27	2714	Hadjadj	23:58:28.581+02	0	23:58:28.581+02	0	t
979	27	2715	Nekmaria	23:58:28.581+02	0	23:58:28.581+02	0	t
980	27	2716	Sidi Lakhdar	23:58:28.581+02	0	23:58:28.581+02	0	t
981	27	2717	Achaacha	23:58:28.581+02	0	23:58:28.581+02	0	t
982	27	2718	Khadra	23:58:28.581+02	0	23:58:28.581+02	0	t
983	27	2719	Bouguirat	23:58:28.581+02	0	23:58:28.581+02	0	t
984	27	2720	Sirat	23:58:28.581+02	0	23:58:28.581+02	0	t
985	27	2721	Ain Sidi Cherif	23:58:28.581+02	0	23:58:28.581+02	0	t
986	27	2722	Mesra	23:58:28.581+02	0	23:58:28.581+02	0	t
987	27	2723	Mansourah	23:58:28.581+02	0	23:58:28.581+02	0	t
988	27	2724	Souaflia	23:58:28.581+02	0	23:58:28.581+02	0	t
989	27	2725	Ouled Boughalem	23:58:28.581+02	0	23:58:28.581+02	0	t
990	27	2726	Ouled Maaleh	23:58:28.581+02	0	23:58:28.581+02	0	t
991	27	2727	Mezghrane	23:58:28.581+02	0	23:58:28.581+02	0	t
992	27	2728	Ain Boudinar	23:58:28.581+02	0	23:58:28.581+02	0	t
993	27	2729	Tazgait	23:58:28.581+02	0	23:58:28.581+02	0	t
994	27	2730	Saf Saf	23:58:28.581+02	0	23:58:28.581+02	0	t
995	27	2731	Touahria	23:58:28.581+02	0	23:58:28.581+02	0	t
996	27	2732	El Hassiane	23:58:28.581+02	0	23:58:28.581+02	0	t
997	28	2801	M'sila	23:58:28.581+02	0	23:58:28.581+02	0	t
998	28	2802	Maadid	23:58:28.581+02	0	23:58:28.581+02	0	t
999	28	2803	Hammam Dhalaa	23:58:28.581+02	0	23:58:28.581+02	0	t
1000	28	2804	Ouled Derradj	23:58:28.581+02	0	23:58:28.581+02	0	t
1001	28	2805	Tarmount	23:58:28.581+02	0	23:58:28.581+02	0	t
1002	28	2806	Mtarfa	23:58:28.581+02	0	23:58:28.581+02	0	t
1003	28	2807	Khoubana	23:58:28.581+02	0	23:58:28.581+02	0	t
1004	28	2808	M'cif	23:58:28.581+02	0	23:58:28.581+02	0	t
1005	28	2809	Chellal	23:58:28.581+02	0	23:58:28.581+02	0	t
1006	28	2810	Ouled Mahdi	23:58:28.581+02	0	23:58:28.581+02	0	t
1007	28	2811	Magra	23:58:28.581+02	0	23:58:28.581+02	0	t
1008	28	2812	Berhoum	23:58:28.581+02	0	23:58:28.581+02	0	t
1009	28	2813	Ain Khadra	23:58:28.581+02	0	23:58:28.581+02	0	t
1010	28	2814	Ouled Addi Guebala	23:58:28.581+02	0	23:58:28.581+02	0	t
1011	28	2815	Belaiba	23:58:28.581+02	0	23:58:28.581+02	0	t
1012	28	2816	Sidi Aissa	23:58:28.581+02	0	23:58:28.581+02	0	t
1013	28	2817	Ain El Hadjel	23:58:28.581+02	0	23:58:28.581+02	0	t
1014	28	2818	Sidi Hadjeres	23:58:28.581+02	0	23:58:28.581+02	0	t
1015	28	2819	Ouanougha	23:58:28.581+02	0	23:58:28.581+02	0	t
1016	28	2820	Bousaada	23:58:28.581+02	0	23:58:28.581+02	0	t
1017	28	2821	OULED SIDI BRAHIM	23:58:28.581+02	0	23:58:28.581+02	0	t
1018	28	2822	Sidi Ameur	23:58:28.581+02	0	23:58:28.581+02	0	t
1019	28	2823	Tamsa	23:58:28.581+02	0	23:58:28.581+02	0	t
1020	28	2824	Ben Srour	23:58:28.581+02	0	23:58:28.581+02	0	t
1021	28	2825	Ouled Slimane	23:58:28.581+02	0	23:58:28.581+02	0	t
1022	28	2826	El Houamed	23:58:28.581+02	0	23:58:28.581+02	0	t
1023	28	2827	El Hamel	23:58:28.581+02	0	23:58:28.581+02	0	t
1024	28	2828	Ouled Mansour	23:58:28.581+02	0	23:58:28.581+02	0	t
1025	28	2829	Maarif	23:58:28.581+02	0	23:58:28.581+02	0	t
1026	28	2830	Dehahna	23:58:28.581+02	0	23:58:28.581+02	0	t
1027	28	2831	Bouti Sayah	23:58:28.581+02	0	23:58:28.581+02	0	t
1028	28	2832	Khettouti Sed El Djir	23:58:28.581+02	0	23:58:28.581+02	0	t
1029	28	2833	Zarzour	23:58:28.581+02	0	23:58:28.581+02	0	t
1030	28	2834	Mohamed Boudiaf	23:58:28.581+02	0	23:58:28.581+02	0	t
1031	28	2835	Benzouh	23:58:28.581+02	0	23:58:28.581+02	0	t
1032	28	2836	Bir Foda	23:58:28.581+02	0	23:58:28.581+02	0	t
1033	28	2837	Ain Fares	23:58:28.581+02	0	23:58:28.581+02	0	t
1034	28	2838	Sidi M'hamed	23:58:28.581+02	0	23:58:28.581+02	0	t
1035	28	2839	Menaa	23:58:28.581+02	0	23:58:28.581+02	0	t
1036	28	2840	Souamaa	23:58:28.581+02	0	23:58:28.581+02	0	t
1037	28	2841	Ain El Melh	23:58:28.581+02	0	23:58:28.581+02	0	t
1038	28	2842	Medjedel	23:58:28.581+02	0	23:58:28.581+02	0	t
1039	28	2843	Slim	23:58:28.581+02	0	23:58:28.581+02	0	t
1040	28	2844	Ain Errich	23:58:28.581+02	0	23:58:28.581+02	0	t
1041	28	2845	Beni Ilmane	23:58:28.581+02	0	23:58:28.581+02	0	t
1042	28	2846	Oultene	23:58:28.581+02	0	23:58:28.581+02	0	t
1043	28	2847	Djebel Messaad	23:58:28.581+02	0	23:58:28.581+02	0	t
1044	29	2901	Mascara	23:58:28.581+02	0	23:58:28.581+02	0	t
1045	29	2902	Bou Hanifia	23:58:28.581+02	0	23:58:28.581+02	0	t
1046	29	2903	Tizi	23:58:28.581+02	0	23:58:28.581+02	0	t
1047	29	2904	Hacine	23:58:28.581+02	0	23:58:28.581+02	0	t
1048	29	2905	Maoussa	23:58:28.581+02	0	23:58:28.581+02	0	t
1049	29	2906	Teghenif	23:58:28.581+02	0	23:58:28.581+02	0	t
1050	29	2907	El Hachem	23:58:28.581+02	0	23:58:28.581+02	0	t
1051	29	2908	Sidi Kada	23:58:28.581+02	0	23:58:28.581+02	0	t
1052	29	2909	Zelmata	23:58:28.581+02	0	23:58:28.581+02	0	t
1053	29	2910	Oued El Abtal	23:58:28.581+02	0	23:58:28.581+02	0	t
1054	29	2911	Ain Ferah	23:58:28.581+02	0	23:58:28.581+02	0	t
1055	29	2912	Ghriss	23:58:28.581+02	0	23:58:28.581+02	0	t
1056	29	2913	Froha	23:58:28.581+02	0	23:58:28.581+02	0	t
1057	29	2914	Matemore	23:58:28.581+02	0	23:58:28.581+02	0	t
1058	29	2915	Makdha	23:58:28.581+02	0	23:58:28.581+02	0	t
1059	29	2916	Sidi Boussaid	23:58:28.581+02	0	23:58:28.581+02	0	t
1060	29	2917	El Bordj	23:58:28.581+02	0	23:58:28.581+02	0	t
1061	29	2918	Ain Fekan	23:58:28.581+02	0	23:58:28.581+02	0	t
1062	29	2919	Benian	23:58:28.581+02	0	23:58:28.581+02	0	t
1063	29	2920	Khalouia	23:58:28.581+02	0	23:58:28.581+02	0	t
1064	29	2921	El Menaouer	23:58:28.581+02	0	23:58:28.581+02	0	t
1065	29	2922	Oued Taria	23:58:28.581+02	0	23:58:28.581+02	0	t
1066	29	2923	Aouf	23:58:28.581+02	0	23:58:28.581+02	0	t
1067	29	2924	Ain Fares	23:58:28.581+02	0	23:58:28.581+02	0	t
1068	29	2925	Ain Frass	23:58:28.581+02	0	23:58:28.581+02	0	t
1069	29	2926	Sig	23:58:28.581+02	0	23:58:28.581+02	0	t
1070	29	2927	Oggaz	23:58:28.581+02	0	23:58:28.581+02	0	t
1071	29	2928	Alaimia	23:58:28.581+02	0	23:58:28.581+02	0	t
1072	29	2929	El Gaada	23:58:28.581+02	0	23:58:28.581+02	0	t
1073	29	2930	Zahana	23:58:28.581+02	0	23:58:28.581+02	0	t
1074	29	2931	Mohammadia	23:58:28.581+02	0	23:58:28.581+02	0	t
1075	29	2932	Sidi Abdelmoumene	23:58:28.581+02	0	23:58:28.581+02	0	t
1076	29	2933	Ferraguig	23:58:28.581+02	0	23:58:28.581+02	0	t
1077	29	2934	El Ghomri	23:58:28.581+02	0	23:58:28.581+02	0	t
1078	29	2935	Sedjerara	23:58:28.581+02	0	23:58:28.581+02	0	t
1079	29	2936	Mocta Douz	23:58:28.581+02	0	23:58:28.581+02	0	t
1080	29	2937	Bou Henni	23:58:28.581+02	0	23:58:28.581+02	0	t
1081	29	2938	El Guettena	23:58:28.581+02	0	23:58:28.581+02	0	t
1082	29	2939	El Mamounia	23:58:28.581+02	0	23:58:28.581+02	0	t
1083	29	2940	El Keurt	23:58:28.581+02	0	23:58:28.581+02	0	t
1084	29	2941	Gharrous	23:58:28.581+02	0	23:58:28.581+02	0	t
1085	29	2942	Guerdjoum	23:58:28.581+02	0	23:58:28.581+02	0	t
1086	29	2943	Chorfa	23:58:28.581+02	0	23:58:28.581+02	0	t
1087	29	2944	Ras Ain Amirouche	23:58:28.581+02	0	23:58:28.581+02	0	t
1088	29	2945	Nesmot	23:58:28.581+02	0	23:58:28.581+02	0	t
1089	29	2946	Sidi Abdeldjebar	23:58:28.581+02	0	23:58:28.581+02	0	t
1090	29	2947	Sehailia	23:58:28.581+02	0	23:58:28.581+02	0	t
1091	30	3001	Ouargla	23:58:28.581+02	0	23:58:28.581+02	0	t
1092	30	3002	Ain Beida	23:58:28.581+02	0	23:58:28.581+02	0	t
1093	30	3003	N'goussa	23:58:28.581+02	0	23:58:28.581+02	0	t
1094	30	3004	Hassi Messaoud	23:58:28.581+02	0	23:58:28.581+02	0	t
1095	30	3005	Rouissat	23:58:28.581+02	0	23:58:28.581+02	0	t
1096	30	3006	Balidat Ameur	23:58:28.581+02	0	23:58:28.581+02	0	t
1097	30	3007	Tebesbest	23:58:28.581+02	0	23:58:28.581+02	0	t
1098	30	3008	Nezla	23:58:28.581+02	0	23:58:28.581+02	0	t
1099	30	3009	Zaouia El Abidia	23:58:28.581+02	0	23:58:28.581+02	0	t
1100	30	3010	Sidi Slimane	23:58:28.581+02	0	23:58:28.581+02	0	t
1101	30	3011	Sidi Khouiled	23:58:28.581+02	0	23:58:28.581+02	0	t
1102	30	3012	Hassi Ben Abdellah	23:58:28.581+02	0	23:58:28.581+02	0	t
1103	30	3013	Touggourt	23:58:28.581+02	0	23:58:28.581+02	0	t
1104	30	3014	El Hadjira	23:58:28.581+02	0	23:58:28.581+02	0	t
1105	30	3015	Taibet	23:58:28.581+02	0	23:58:28.581+02	0	t
1106	30	3016	Tamacine	23:58:28.581+02	0	23:58:28.581+02	0	t
1107	30	3017	Benaceur	23:58:28.581+02	0	23:58:28.581+02	0	t
1108	30	3018	M'naguer	23:58:28.581+02	0	23:58:28.581+02	0	t
1109	30	3019	Megarine	23:58:28.581+02	0	23:58:28.581+02	0	t
1110	30	3020	El Allia	23:58:28.581+02	0	23:58:28.581+02	0	t
1111	30	3021	El Borma	23:58:28.581+02	0	23:58:28.581+02	0	t
1112	31	3101	Oran	23:58:28.581+02	0	23:58:28.581+02	0	t
1113	31	3102	Gdyel	23:58:28.581+02	0	23:58:28.581+02	0	t
1114	31	3103	Bir El Djir	23:58:28.581+02	0	23:58:28.581+02	0	t
1115	31	3104	Hassi Bounif	23:58:28.581+02	0	23:58:28.581+02	0	t
1116	31	3105	Es Senia	23:58:28.581+02	0	23:58:28.581+02	0	t
1117	31	3106	Arzew	23:58:28.581+02	0	23:58:28.581+02	0	t
1118	31	3107	Bethioua	23:58:28.581+02	0	23:58:28.581+02	0	t
1119	31	3108	Marsat El Hadjadj	23:58:28.581+02	0	23:58:28.581+02	0	t
1120	31	3109	Ain Turk	23:58:28.581+02	0	23:58:28.581+02	0	t
1121	31	3110	El Ancar	23:58:28.581+02	0	23:58:28.581+02	0	t
1122	31	3111	Oued Tlelat	23:58:28.581+02	0	23:58:28.581+02	0	t
1123	31	3112	Tafraoui	23:58:28.581+02	0	23:58:28.581+02	0	t
1124	31	3113	Sidi Chami	23:58:28.581+02	0	23:58:28.581+02	0	t
1125	31	3114	Boufatis	23:58:28.581+02	0	23:58:28.581+02	0	t
1126	31	3115	Mers El Kebir	23:58:28.581+02	0	23:58:28.581+02	0	t
1127	31	3116	Bousfer	23:58:28.581+02	0	23:58:28.581+02	0	t
1128	31	3117	El Karma	23:58:28.581+02	0	23:58:28.581+02	0	t
1129	31	3118	El Braya	23:58:28.581+02	0	23:58:28.581+02	0	t
1130	31	3119	Hassi Ben Okba	23:58:28.581+02	0	23:58:28.581+02	0	t
1131	31	3120	Benfreha	23:58:28.581+02	0	23:58:28.581+02	0	t
1132	31	3121	Hassi Mefsoukh	23:58:28.581+02	0	23:58:28.581+02	0	t
1133	31	3122	Sidi Ben Yabka	23:58:28.581+02	0	23:58:28.581+02	0	t
1134	31	3123	Misserghin	23:58:28.581+02	0	23:58:28.581+02	0	t
1135	31	3124	Boutlelis	23:58:28.581+02	0	23:58:28.581+02	0	t
1136	31	3125	Ain Kerma	23:58:28.581+02	0	23:58:28.581+02	0	t
1137	31	3126	Ain Biya	23:58:28.581+02	0	23:58:28.581+02	0	t
1138	32	3201	El Bayadh	23:58:28.581+02	0	23:58:28.581+02	0	t
1139	32	3202	Rogassa	23:58:28.581+02	0	23:58:28.581+02	0	t
1140	32	3203	Stitten	23:58:28.581+02	0	23:58:28.581+02	0	t
1141	32	3204	Brezina	23:58:28.581+02	0	23:58:28.581+02	0	t
1142	32	3205	Ghassoul	23:58:28.581+02	0	23:58:28.581+02	0	t
1143	32	3206	Boualem	23:58:28.581+02	0	23:58:28.581+02	0	t
1144	32	3207	El Abiodh Sidi Cheikh	23:58:28.581+02	0	23:58:28.581+02	0	t
1145	32	3208	Ain El Orak	23:58:28.581+02	0	23:58:28.581+02	0	t
1146	32	3209	Arbaouat	23:58:28.581+02	0	23:58:28.581+02	0	t
1147	32	3210	Bougtoub	23:58:28.581+02	0	23:58:28.581+02	0	t
1148	32	3211	El Kheither	23:58:28.581+02	0	23:58:28.581+02	0	t
1149	32	3212	Kef Lahmar	23:58:28.581+02	0	23:58:28.581+02	0	t
1150	32	3213	Boussemghoun	23:58:28.581+02	0	23:58:28.581+02	0	t
1151	32	3214	Chellala	23:58:28.581+02	0	23:58:28.581+02	0	t
1152	32	3215	Krakda	23:58:28.581+02	0	23:58:28.581+02	0	t
1153	32	3216	El Bnoud	23:58:28.581+02	0	23:58:28.581+02	0	t
1154	32	3217	Cheguig	23:58:28.581+02	0	23:58:28.581+02	0	t
1155	32	3218	Sidi Ameur	23:58:28.581+02	0	23:58:28.581+02	0	t
1156	32	3219	El Mehara	23:58:28.581+02	0	23:58:28.581+02	0	t
1157	32	3220	Tousmouline	23:58:28.581+02	0	23:58:28.581+02	0	t
1158	32	3221	Sidi Slimane	23:58:28.581+02	0	23:58:28.581+02	0	t
1159	32	3222	Sidi Tifour	23:58:28.581+02	0	23:58:28.581+02	0	t
1160	33	3301	Illizi	23:58:28.581+02	0	23:58:28.581+02	0	t
1161	33	3302	Djanet	23:58:28.581+02	0	23:58:28.581+02	0	t
1162	33	3303	Debdeb	23:58:28.581+02	0	23:58:28.581+02	0	t
1163	33	3304	Bordj Omar Driss	23:58:28.581+02	0	23:58:28.581+02	0	t
1164	33	3305	Bordj El Haouasse	23:58:28.581+02	0	23:58:28.581+02	0	t
1165	33	3306	In Amenas	23:58:28.581+02	0	23:58:28.581+02	0	t
1166	34	3401	Bordj Bou Arreridj	23:58:28.581+02	0	23:58:28.581+02	0	t
1167	34	3402	Ras El Oued	23:58:28.581+02	0	23:58:28.581+02	0	t
1168	34	3403	Bordj Zemoura	23:58:28.581+02	0	23:58:28.581+02	0	t
1169	34	3404	Mansoura	23:58:28.581+02	0	23:58:28.581+02	0	t
1170	34	3405	El M'hir	23:58:28.581+02	0	23:58:28.581+02	0	t
1171	34	3406	Ben Daoud	23:58:28.581+02	0	23:58:28.581+02	0	t
1172	34	3407	El Achir	23:58:28.581+02	0	23:58:28.581+02	0	t
1173	34	3408	Ain Taghrout	23:58:28.581+02	0	23:58:28.581+02	0	t
1174	34	3409	Bordj Ghdir	23:58:28.581+02	0	23:58:28.581+02	0	t
1175	34	3410	Sidi Embarek	23:58:28.581+02	0	23:58:28.581+02	0	t
1176	34	3411	El Hamadia	23:58:28.581+02	0	23:58:28.581+02	0	t
1177	34	3412	Belimour	23:58:28.581+02	0	23:58:28.581+02	0	t
1178	34	3413	Medjana	23:58:28.581+02	0	23:58:28.581+02	0	t
1179	34	3414	Teniet En Nasr	23:58:28.581+02	0	23:58:28.581+02	0	t
1180	34	3415	Djaafra	23:58:28.581+02	0	23:58:28.581+02	0	t
1181	34	3416	El Main	23:58:28.581+02	0	23:58:28.581+02	0	t
1182	34	3417	Ouled Brahem	23:58:28.581+02	0	23:58:28.581+02	0	t
1183	34	3418	Ouled Dahmane	23:58:28.581+02	0	23:58:28.581+02	0	t
1184	34	3419	Hasnaoua	23:58:28.581+02	0	23:58:28.581+02	0	t
1185	34	3420	Khelil	23:58:28.581+02	0	23:58:28.581+02	0	t
1186	34	3421	Taglait	23:58:28.581+02	0	23:58:28.581+02	0	t
1187	34	3422	Ksour	23:58:28.581+02	0	23:58:28.581+02	0	t
1189	34	3424	Tafreg	23:58:28.581+02	0	23:58:28.581+02	0	t
1190	34	3425	Colla	23:58:28.581+02	0	23:58:28.581+02	0	t
1191	34	3426	Tixter	23:58:28.581+02	0	23:58:28.581+02	0	t
1192	34	3427	El Ach	23:58:28.581+02	0	23:58:28.581+02	0	t
1193	34	3428	El Anseur	23:58:28.581+02	0	23:58:28.581+02	0	t
1194	34	3429	Tesmart	23:58:28.581+02	0	23:58:28.581+02	0	t
1195	34	3430	Ain Tesra	23:58:28.581+02	0	23:58:28.581+02	0	t
1196	34	3431	Bir Kasdali	23:58:28.581+02	0	23:58:28.581+02	0	t
1197	34	3432	Ghilassa	23:58:28.581+02	0	23:58:28.581+02	0	t
1198	34	3433	Rabta	23:58:28.581+02	0	23:58:28.581+02	0	t
1199	34	3434	Haraza	23:58:28.581+02	0	23:58:28.581+02	0	t
1200	35	3501	Boumerdes	23:58:28.581+02	0	23:58:28.581+02	0	t
1201	35	3502	Boudouaou	23:58:28.581+02	0	23:58:28.581+02	0	t
1202	35	3503	Afir	23:58:28.581+02	0	23:58:28.581+02	0	t
1203	35	3504	Bordj Menaiel	23:58:28.581+02	0	23:58:28.581+02	0	t
1204	35	3505	Baghlia	23:58:28.581+02	0	23:58:28.581+02	0	t
1205	35	3506	Sidi Daoud	23:58:28.581+02	0	23:58:28.581+02	0	t
1206	35	3507	Naciria	23:58:28.581+02	0	23:58:28.581+02	0	t
1207	35	3508	Djinet	23:58:28.581+02	0	23:58:28.581+02	0	t
1208	35	3509	Isser	23:58:28.581+02	0	23:58:28.581+02	0	t
1209	35	3510	Zemmouri	23:58:28.581+02	0	23:58:28.581+02	0	t
1210	35	3511	Si Mustapha	23:58:28.581+02	0	23:58:28.581+02	0	t
1211	35	3512	Tidjelabine	23:58:28.581+02	0	23:58:28.581+02	0	t
1212	35	3513	Chaabet El Ameur	23:58:28.581+02	0	23:58:28.581+02	0	t
1213	35	3514	Thenia	23:58:28.581+02	0	23:58:28.581+02	0	t
1214	35	3515	Timezrit	23:58:28.581+02	0	23:58:28.581+02	0	t
1215	35	3516	Corso	23:58:28.581+02	0	23:58:28.581+02	0	t
1216	35	3517	Ouled Moussa	23:58:28.581+02	0	23:58:28.581+02	0	t
1217	35	3518	Larbatache	23:58:28.581+02	0	23:58:28.581+02	0	t
1218	35	3519	Bouzegza Keddara	23:58:28.581+02	0	23:58:28.581+02	0	t
1219	35	3520	Taourga	23:58:28.581+02	0	23:58:28.581+02	0	t
1220	35	3521	Ouled Aissa	23:58:28.581+02	0	23:58:28.581+02	0	t
1221	35	3522	Ben Choud	23:58:28.581+02	0	23:58:28.581+02	0	t
1222	35	3523	Dellys	23:58:28.581+02	0	23:58:28.581+02	0	t
1223	35	3524	Ammal	23:58:28.581+02	0	23:58:28.581+02	0	t
1224	35	3525	Beni Amrane	23:58:28.581+02	0	23:58:28.581+02	0	t
1225	35	3526	Souk El Had	23:58:28.581+02	0	23:58:28.581+02	0	t
1226	35	3527	Boudouaou El Bahri	23:58:28.581+02	0	23:58:28.581+02	0	t
1227	35	3528	Ouled Hedadj	23:58:28.581+02	0	23:58:28.581+02	0	t
1228	35	3529	Leghata	23:58:28.581+02	0	23:58:28.581+02	0	t
1229	35	3530	Hammedi	23:58:28.581+02	0	23:58:28.581+02	0	t
1230	35	3531	Khemis El Khechna	23:58:28.581+02	0	23:58:28.581+02	0	t
1231	35	3532	El Kharrouba	23:58:28.581+02	0	23:58:28.581+02	0	t
1232	36	3601	El Tarf	23:58:28.581+02	0	23:58:28.581+02	0	t
1233	36	3602	Bou Hadjar	23:58:28.581+02	0	23:58:28.581+02	0	t
1234	36	3603	Ben M'hidi	23:58:28.581+02	0	23:58:28.581+02	0	t
1235	36	3604	Bougous	23:58:28.581+02	0	23:58:28.581+02	0	t
1236	36	3605	El Kala	23:58:28.581+02	0	23:58:28.581+02	0	t
1237	36	3606	Ain El Assel	23:58:28.581+02	0	23:58:28.581+02	0	t
1238	36	3607	El Aioun	23:58:28.581+02	0	23:58:28.581+02	0	t
1239	36	3608	Bouteldja	23:58:28.581+02	0	23:58:28.581+02	0	t
1240	36	3609	Souarekh	23:58:28.581+02	0	23:58:28.581+02	0	t
1241	36	3610	Berrihane	23:58:28.581+02	0	23:58:28.581+02	0	t
1242	36	3611	Lac des oiseaux	23:58:28.581+02	0	23:58:28.581+02	0	t
1243	36	3612	Chefia	23:58:28.581+02	0	23:58:28.581+02	0	t
1244	36	3613	Drean	23:58:28.581+02	0	23:58:28.581+02	0	t
1245	36	3614	Chihani	23:58:28.581+02	0	23:58:28.581+02	0	t
1246	36	3615	Chebaita Mokhtar	23:58:28.581+02	0	23:58:28.581+02	0	t
1247	36	3616	Besbes	23:58:28.581+02	0	23:58:28.581+02	0	t
1248	36	3617	Asfour	23:58:28.581+02	0	23:58:28.581+02	0	t
1249	36	3618	Chatt	23:58:28.581+02	0	23:58:28.581+02	0	t
1250	36	3619	Zerizer	23:58:28.581+02	0	23:58:28.581+02	0	t
1251	36	3620	Zitouna	23:58:28.581+02	0	23:58:28.581+02	0	t
1252	36	3621	Ain Kerma	23:58:28.581+02	0	23:58:28.581+02	0	t
1253	36	3622	Oued Zitoun	23:58:28.581+02	0	23:58:28.581+02	0	t
1254	36	3623	Hammam Beni Salah	23:58:28.581+02	0	23:58:28.581+02	0	t
1255	36	3624	Raml Souk	23:58:28.581+02	0	23:58:28.581+02	0	t
1256	37	3701	Tindouf	23:58:28.581+02	0	23:58:28.581+02	0	t
1257	37	3702	Oum El Assel	23:58:28.581+02	0	23:58:28.581+02	0	t
1258	38	3801	Tissemssilt	23:58:28.581+02	0	23:58:28.581+02	0	t
1259	38	3802	Bordj Bou Naama	23:58:28.581+02	0	23:58:28.581+02	0	t
1260	38	3803	Theniet El Had	23:58:28.581+02	0	23:58:28.581+02	0	t
1261	38	3804	Lazharia	23:58:28.581+02	0	23:58:28.581+02	0	t
1262	38	3805	Beni Chaib	23:58:28.581+02	0	23:58:28.581+02	0	t
1263	38	3806	Lardjem	23:58:28.581+02	0	23:58:28.581+02	0	t
1264	38	3807	Melaab	23:58:28.581+02	0	23:58:28.581+02	0	t
1265	38	3808	Sidi Lantri	23:58:28.581+02	0	23:58:28.581+02	0	t
1266	38	3809	Bordj El Emir Abdelkader	23:58:28.581+02	0	23:58:28.581+02	0	t
1267	38	3810	Layoune	23:58:28.581+02	0	23:58:28.581+02	0	t
1268	38	3811	Khemisti	23:58:28.581+02	0	23:58:28.581+02	0	t
1269	38	3812	Ouled Bessem	23:58:28.581+02	0	23:58:28.581+02	0	t
1270	38	3813	Ammari	23:58:28.581+02	0	23:58:28.581+02	0	t
1271	38	3814	Youssoufia	23:58:28.581+02	0	23:58:28.581+02	0	t
1272	38	3815	Sidi Boutouchent	23:58:28.581+02	0	23:58:28.581+02	0	t
1273	38	3816	Larbaa	23:58:28.581+02	0	23:58:28.581+02	0	t
1274	38	3817	Maassem	23:58:28.581+02	0	23:58:28.581+02	0	t
1275	38	3818	Sidi Abed	23:58:28.581+02	0	23:58:28.581+02	0	t
1276	38	3819	Tamelaht	23:58:28.581+02	0	23:58:28.581+02	0	t
1277	38	3820	Sidi Slimane	23:58:28.581+02	0	23:58:28.581+02	0	t
1278	38	3821	Boucaid	23:58:28.581+02	0	23:58:28.581+02	0	t
1279	38	3822	Beni Lahcene	23:58:28.581+02	0	23:58:28.581+02	0	t
1280	39	3901	El Oued	23:58:28.581+02	0	23:58:28.581+02	0	t
1281	39	3902	Robbah	23:58:28.581+02	0	23:58:28.581+02	0	t
1282	39	3903	Oued El Alenda	23:58:28.581+02	0	23:58:28.581+02	0	t
1283	39	3904	Bayadha	23:58:28.581+02	0	23:58:28.581+02	0	t
1284	39	3905	Nekhla	23:58:28.581+02	0	23:58:28.581+02	0	t
1285	39	3906	Guemar	23:58:28.581+02	0	23:58:28.581+02	0	t
1286	39	3907	Kouinine	23:58:28.581+02	0	23:58:28.581+02	0	t
1287	39	3908	Reguiba	23:58:28.581+02	0	23:58:28.581+02	0	t
1288	39	3909	Hamraia	23:58:28.581+02	0	23:58:28.581+02	0	t
1289	39	3910	Taghzout	23:58:28.581+02	0	23:58:28.581+02	0	t
1290	39	3911	Debila	23:58:28.581+02	0	23:58:28.581+02	0	t
1291	39	3912	Hassani Abdelkrim	23:58:28.581+02	0	23:58:28.581+02	0	t
1292	39	3913	Hassi Khelifa	23:58:28.581+02	0	23:58:28.581+02	0	t
1293	39	3914	Taleb Larbi	23:58:28.581+02	0	23:58:28.581+02	0	t
1294	39	3915	Douar El Ma	23:58:28.581+02	0	23:58:28.581+02	0	t
1295	39	3916	Sidi Aoun	23:58:28.581+02	0	23:58:28.581+02	0	t
1296	39	3917	Trifaoui	23:58:28.581+02	0	23:58:28.581+02	0	t
1297	39	3918	Magrane	23:58:28.581+02	0	23:58:28.581+02	0	t
1298	39	3919	Ben Guecha	23:58:28.581+02	0	23:58:28.581+02	0	t
1299	39	3920	Ourmes	23:58:28.581+02	0	23:58:28.581+02	0	t
1300	39	3921	Still	23:58:28.581+02	0	23:58:28.581+02	0	t
1301	39	3922	M'Rara	23:58:28.581+02	0	23:58:28.581+02	0	t
1302	39	3923	Sidi Khellil	23:58:28.581+02	0	23:58:28.581+02	0	t
1303	39	3924	Tinedla	23:58:28.581+02	0	23:58:28.581+02	0	t
1304	39	3925	El Ogla	23:58:28.581+02	0	23:58:28.581+02	0	t
1305	39	3926	Mih Ouensa	23:58:28.581+02	0	23:58:28.581+02	0	t
1307	39	3928	Djamaa	23:58:28.581+02	0	23:58:28.581+02	0	t
1308	39	3929	Oum Touyour	23:58:28.581+02	0	23:58:28.581+02	0	t
1309	39	3930	Sidi Amrane	23:58:28.581+02	0	23:58:28.581+02	0	t
1310	40	4001	Khenchela	23:58:28.581+02	0	23:58:28.581+02	0	t
1311	40	4002	M'toussa	23:58:28.581+02	0	23:58:28.581+02	0	t
1312	40	4003	Kais	23:58:28.581+02	0	23:58:28.581+02	0	t
1313	40	4004	Baghai	23:58:28.581+02	0	23:58:28.581+02	0	t
1314	40	4005	El Hamma	23:58:28.581+02	0	23:58:28.581+02	0	t
1315	40	4006	Ain Touila	23:58:28.581+02	0	23:58:28.581+02	0	t
1316	40	4007	Taouziana	23:58:28.581+02	0	23:58:28.581+02	0	t
1317	40	4008	Bouhmama	23:58:28.581+02	0	23:58:28.581+02	0	t
1318	40	4009	El Oueldja	23:58:28.581+02	0	23:58:28.581+02	0	t
1319	40	4010	Remila	23:58:28.581+02	0	23:58:28.581+02	0	t
1320	40	4011	Chechar	23:58:28.581+02	0	23:58:28.581+02	0	t
1321	40	4012	Djellal	23:58:28.581+02	0	23:58:28.581+02	0	t
1322	40	4013	Babar	23:58:28.581+02	0	23:58:28.581+02	0	t
1323	40	4014	Tamza	23:58:28.581+02	0	23:58:28.581+02	0	t
1324	40	4015	Ensigha	23:58:28.581+02	0	23:58:28.581+02	0	t
1325	40	4016	Ouled Rechache	23:58:28.581+02	0	23:58:28.581+02	0	t
1326	40	4017	El Mahmal	23:58:28.581+02	0	23:58:28.581+02	0	t
1327	40	4018	Msara	23:58:28.581+02	0	23:58:28.581+02	0	t
1328	40	4019	Yabous	23:58:28.581+02	0	23:58:28.581+02	0	t
1329	40	4020	Khirane	23:58:28.581+02	0	23:58:28.581+02	0	t
1330	40	4021	Chelia	23:58:28.581+02	0	23:58:28.581+02	0	t
1331	41	4101	Souk Ahras	23:58:28.581+02	0	23:58:28.581+02	0	t
1332	41	4102	Sedrata	23:58:28.581+02	0	23:58:28.581+02	0	t
1333	41	4103	Hanancha	23:58:28.581+02	0	23:58:28.581+02	0	t
1334	41	4104	Mechroha	23:58:28.581+02	0	23:58:28.581+02	0	t
1335	41	4105	Ouled Driss	23:58:28.581+02	0	23:58:28.581+02	0	t
1336	41	4106	Tiffech	23:58:28.581+02	0	23:58:28.581+02	0	t
1337	41	4107	Zaarouria	23:58:28.581+02	0	23:58:28.581+02	0	t
1338	41	4108	Taoura	23:58:28.581+02	0	23:58:28.581+02	0	t
1339	41	4109	Drea	23:58:28.581+02	0	23:58:28.581+02	0	t
1340	41	4110	Haddada	23:58:28.581+02	0	23:58:28.581+02	0	t
1341	41	4111	Kheddara	23:58:28.581+02	0	23:58:28.581+02	0	t
1342	41	4112	Merahna	23:58:28.581+02	0	23:58:28.581+02	0	t
1343	41	4113	Ouled Moumen	23:58:28.581+02	0	23:58:28.581+02	0	t
1344	41	4114	Bir Bouhouche	23:58:28.581+02	0	23:58:28.581+02	0	t
1345	41	4115	M'daourouch	23:58:28.581+02	0	23:58:28.581+02	0	t
1346	41	4116	Oum El Adhaim	23:58:28.581+02	0	23:58:28.581+02	0	t
1347	41	4117	Ain Zana	23:58:28.581+02	0	23:58:28.581+02	0	t
1348	41	4118	Ain Soltane	23:58:28.581+02	0	23:58:28.581+02	0	t
1349	41	4119	Ouillen	23:58:28.581+02	0	23:58:28.581+02	0	t
1350	41	4120	Sidi Fredj	23:58:28.581+02	0	23:58:28.581+02	0	t
1351	41	4121	Safel El Ouiden	23:58:28.581+02	0	23:58:28.581+02	0	t
1352	41	4122	Ragouba	23:58:28.581+02	0	23:58:28.581+02	0	t
1353	41	4123	Khemissa	23:58:28.581+02	0	23:58:28.581+02	0	t
1354	41	4124	Oued Kebrit	23:58:28.581+02	0	23:58:28.581+02	0	t
1355	41	4125	Terraguelt	23:58:28.581+02	0	23:58:28.581+02	0	t
1356	41	4126	Zouabi	23:58:28.581+02	0	23:58:28.581+02	0	t
1357	42	4201	Tipaza	23:58:28.581+02	0	23:58:28.581+02	0	t
1358	42	4202	Menaceur	23:58:28.581+02	0	23:58:28.581+02	0	t
1359	42	4203	Larhat	23:58:28.581+02	0	23:58:28.581+02	0	t
1360	42	4204	Douaouda	23:58:28.581+02	0	23:58:28.581+02	0	t
1361	42	4205	Bourkika	23:58:28.581+02	0	23:58:28.581+02	0	t
1362	42	4206	Khemisti	23:58:28.581+02	0	23:58:28.581+02	0	t
1363	42	4210	Aghbal	23:58:28.581+02	0	23:58:28.581+02	0	t
1364	42	4212	Hadjout	23:58:28.581+02	0	23:58:28.581+02	0	t
1365	42	4213	Sidi Amar	23:58:28.581+02	0	23:58:28.581+02	0	t
1366	42	4214	Gouraya	23:58:28.581+02	0	23:58:28.581+02	0	t
1367	42	4215	Nador	23:58:28.581+02	0	23:58:28.581+02	0	t
1368	42	4216	Chaiba	23:58:28.581+02	0	23:58:28.581+02	0	t
1369	42	4217	Ain Tagourait	23:58:28.581+02	0	23:58:28.581+02	0	t
1370	42	4222	Cherchell	23:58:28.581+02	0	23:58:28.581+02	0	t
1371	42	4223	Damous	23:58:28.581+02	0	23:58:28.581+02	0	t
1372	42	4224	Merad	23:58:28.581+02	0	23:58:28.581+02	0	t
1373	42	4225	Fouka	23:58:28.581+02	0	23:58:28.581+02	0	t
1374	42	4226	Bou Ismail	23:58:28.581+02	0	23:58:28.581+02	0	t
1375	42	4227	Ahmer El Ain	23:58:28.581+02	0	23:58:28.581+02	0	t
1376	42	4230	Bouharoun	23:58:28.581+02	0	23:58:28.581+02	0	t
1377	42	4232	Sidi Ghiles	23:58:28.581+02	0	23:58:28.581+02	0	t
1378	42	4233	Messelmoun	23:58:28.581+02	0	23:58:28.581+02	0	t
1379	42	4234	Sidi Rached	23:58:28.581+02	0	23:58:28.581+02	0	t
1380	42	4235	Kolea	23:58:28.581+02	0	23:58:28.581+02	0	t
1381	42	4236	Attatba	23:58:28.581+02	0	23:58:28.581+02	0	t
1382	42	4240	Sidi Semiane	23:58:28.581+02	0	23:58:28.581+02	0	t
1383	42	4241	Beni Milleuk	23:58:28.581+02	0	23:58:28.581+02	0	t
1384	42	4242	Hadjeret Ennous	23:58:28.581+02	0	23:58:28.581+02	0	t
1385	43	4301	Mila	23:58:28.581+02	0	23:58:28.581+02	0	t
1386	43	4302	Ferdjioua	23:58:28.581+02	0	23:58:28.581+02	0	t
1387	43	4303	Chelghoum Laid	23:58:28.581+02	0	23:58:28.581+02	0	t
1388	43	4304	Oued Athmania	23:58:28.581+02	0	23:58:28.581+02	0	t
1389	43	4305	Ain Mellouk	23:58:28.581+02	0	23:58:28.581+02	0	t
1390	43	4306	Telerghma	23:58:28.581+02	0	23:58:28.581+02	0	t
1391	43	4307	Oued Seguen	23:58:28.581+02	0	23:58:28.581+02	0	t
1392	43	4308	Tadjenanet	23:58:28.581+02	0	23:58:28.581+02	0	t
1393	43	4309	Benyahia Abderahmane	23:58:28.581+02	0	23:58:28.581+02	0	t
1394	43	4310	Oued Endja	23:58:28.581+02	0	23:58:28.581+02	0	t
1395	43	4311	Ahmed Rachedi	23:58:28.581+02	0	23:58:28.581+02	0	t
1396	43	4312	Ouled Khelouf	23:58:28.581+02	0	23:58:28.581+02	0	t
1397	43	4313	Tiberguent	23:58:28.581+02	0	23:58:28.581+02	0	t
1398	43	4314	Bouhatem	23:58:28.581+02	0	23:58:28.581+02	0	t
1399	43	4315	Rouached	23:58:28.581+02	0	23:58:28.581+02	0	t
1400	43	4316	Tessala Lemtai	23:58:28.581+02	0	23:58:28.581+02	0	t
1401	43	4317	Grarem Gouga	23:58:28.581+02	0	23:58:28.581+02	0	t
1402	43	4318	Sidi Merouane	23:58:28.581+02	0	23:58:28.581+02	0	t
1403	43	4319	Tassadane Haddada	23:58:28.581+02	0	23:58:28.581+02	0	t
1404	43	4320	Deradji Bousselah	23:58:28.581+02	0	23:58:28.581+02	0	t
1405	43	4321	Minar Zarza	23:58:28.581+02	0	23:58:28.581+02	0	t
1406	43	4322	Amira Arras	23:58:28.581+02	0	23:58:28.581+02	0	t
1407	43	4323	Terrai Bainen	23:58:28.581+02	0	23:58:28.581+02	0	t
1408	43	4324	Hamala	23:58:28.581+02	0	23:58:28.581+02	0	t
1409	43	4325	Ain Tine	23:58:28.581+02	0	23:58:28.581+02	0	t
1410	43	4326	El Mechira	23:58:28.581+02	0	23:58:28.581+02	0	t
1411	43	4327	Sidi Khelifa	23:58:28.581+02	0	23:58:28.581+02	0	t
1412	43	4328	Zeghaia	23:58:28.581+02	0	23:58:28.581+02	0	t
1413	43	4329	Elayadi Barbes	23:58:28.581+02	0	23:58:28.581+02	0	t
1414	43	4330	Ain Beida Harriche	23:58:28.581+02	0	23:58:28.581+02	0	t
1415	43	4331	Yahia Beni Guecha	23:58:28.581+02	0	23:58:28.581+02	0	t
1416	43	4332	Chigara	23:58:28.581+02	0	23:58:28.581+02	0	t
1417	44	4401	Ain Defla	23:58:28.581+02	0	23:58:28.581+02	0	t
1418	44	4402	Miliana	23:58:28.581+02	0	23:58:28.581+02	0	t
1419	44	4403	Bou Medfaa	23:58:28.581+02	0	23:58:28.581+02	0	t
1420	44	4404	Khemis Miliana	23:58:28.581+02	0	23:58:28.581+02	0	t
1421	44	4405	Hammam Righa	23:58:28.581+02	0	23:58:28.581+02	0	t
1422	44	4406	Arib	23:58:28.581+02	0	23:58:28.581+02	0	t
1423	44	4407	Djelida	23:58:28.581+02	0	23:58:28.581+02	0	t
1424	44	4408	El Amra	23:58:28.581+02	0	23:58:28.581+02	0	t
1425	44	4409	Bourached	23:58:28.581+02	0	23:58:28.581+02	0	t
1426	44	4410	El Attaf	23:58:28.581+02	0	23:58:28.581+02	0	t
1427	44	4411	El Abadia	23:58:28.581+02	0	23:58:28.581+02	0	t
1428	44	4412	Djendel	23:58:28.581+02	0	23:58:28.581+02	0	t
1429	44	4413	Oued Cheurfa	23:58:28.581+02	0	23:58:28.581+02	0	t
1430	44	4414	Ain Lechiakh	23:58:28.581+02	0	23:58:28.581+02	0	t
1431	44	4415	Oued Djemaa	23:58:28.581+02	0	23:58:28.581+02	0	t
1432	44	4416	Rouina	23:58:28.581+02	0	23:58:28.581+02	0	t
1433	44	4417	Zeddine	23:58:28.581+02	0	23:58:28.581+02	0	t
1434	44	4418	El Hassania	23:58:28.581+02	0	23:58:28.581+02	0	t
1435	44	4419	Bir Ouled Khelifa	23:58:28.581+02	0	23:58:28.581+02	0	t
1436	44	4420	Ain Soltane	23:58:28.581+02	0	23:58:28.581+02	0	t
1437	44	4421	Tarik Ibn Ziad	23:58:28.581+02	0	23:58:28.581+02	0	t
1438	44	4422	Bordj Emir Khaled	23:58:28.581+02	0	23:58:28.581+02	0	t
1439	44	4423	Ain Torki	23:58:28.581+02	0	23:58:28.581+02	0	t
1440	44	4424	Sidi Lakhdar	23:58:28.581+02	0	23:58:28.581+02	0	t
1441	44	4425	Ben Allel	23:58:28.581+02	0	23:58:28.581+02	0	t
1442	44	4426	Ain Benian	23:58:28.581+02	0	23:58:28.581+02	0	t
1443	44	4427	Hoceinia	23:58:28.581+02	0	23:58:28.581+02	0	t
1444	44	4428	Birbouche	23:58:28.581+02	0	23:58:28.581+02	0	t
1445	44	4429	Djemaa Ouled Cheikh	23:58:28.581+02	0	23:58:28.581+02	0	t
1446	44	4430	Mekhatria	23:58:28.581+02	0	23:58:28.581+02	0	t
1447	44	4431	Bathia	23:58:28.581+02	0	23:58:28.581+02	0	t
1448	44	4432	Tacheta Zegagha	23:58:28.581+02	0	23:58:28.581+02	0	t
1449	44	4433	Ain Bouyahia	23:58:28.581+02	0	23:58:28.581+02	0	t
1450	44	4434	El Maine	23:58:28.581+02	0	23:58:28.581+02	0	t
1451	44	4435	Tiberkanine	23:58:28.581+02	0	23:58:28.581+02	0	t
1452	44	4436	Belaas	23:58:28.581+02	0	23:58:28.581+02	0	t
1453	45	4501	Naama	23:58:28.581+02	0	23:58:28.581+02	0	t
1454	45	4502	Mecheria	23:58:28.581+02	0	23:58:28.581+02	0	t
1455	45	4503	Ain Sefra	23:58:28.581+02	0	23:58:28.581+02	0	t
1456	45	4504	Tiout	23:58:28.581+02	0	23:58:28.581+02	0	t
1457	45	4505	Sfissifa	23:58:28.581+02	0	23:58:28.581+02	0	t
1458	45	4506	Moghrar	23:58:28.581+02	0	23:58:28.581+02	0	t
1459	45	4507	Asla	23:58:28.581+02	0	23:58:28.581+02	0	t
1460	45	4508	Djenien Bourzeg	23:58:28.581+02	0	23:58:28.581+02	0	t
1461	45	4509	Ain Ben Khellil	23:58:28.581+02	0	23:58:28.581+02	0	t
1462	45	4510	Makmen Ben Amar	23:58:28.581+02	0	23:58:28.581+02	0	t
1463	45	4511	Kasdir	23:58:28.581+02	0	23:58:28.581+02	0	t
1464	45	4512	El Biod	23:58:28.581+02	0	23:58:28.581+02	0	t
1465	46	4601	Ain Temouchent	23:58:28.581+02	0	23:58:28.581+02	0	t
1466	46	4602	Chaabet El Ham	23:58:28.581+02	0	23:58:28.581+02	0	t
1467	46	4603	Oueld Kihal	23:58:28.581+02	0	23:58:28.581+02	0	t
1468	46	4604	Hammam Bouhadjar	23:58:28.581+02	0	23:58:28.581+02	0	t
1469	46	4605	Bouzedjar	23:58:28.581+02	0	23:58:28.581+02	0	t
1470	46	4606	Oued Berkeche	23:58:28.581+02	0	23:58:28.581+02	0	t
1471	46	4607	Aghlal	23:58:28.581+02	0	23:58:28.581+02	0	t
1472	46	4608	Terga	23:58:28.581+02	0	23:58:28.581+02	0	t
1473	46	4609	Ain El Arbaa	23:58:28.581+02	0	23:58:28.581+02	0	t
1474	46	4610	Tamzoura	23:58:28.581+02	0	23:58:28.581+02	0	t
1475	46	4611	Chentouf	23:58:28.581+02	0	23:58:28.581+02	0	t
1476	46	4612	Sidi Ben Adda	23:58:28.581+02	0	23:58:28.581+02	0	t
1477	46	4613	Aoubellil	23:58:28.581+02	0	23:58:28.581+02	0	t
1478	46	4614	El Malah	23:58:28.581+02	0	23:58:28.581+02	0	t
1479	46	4615	Sidi Boumediene	23:58:28.581+02	0	23:58:28.581+02	0	t
1480	46	4616	Oued Sabah	23:58:28.581+02	0	23:58:28.581+02	0	t
1481	46	4617	Ouled Boudjemaa	23:58:28.581+02	0	23:58:28.581+02	0	t
1482	46	4618	Ain Tolba	23:58:28.581+02	0	23:58:28.581+02	0	t
1483	46	4619	El Amria	23:58:28.581+02	0	23:58:28.581+02	0	t
1484	46	4620	Hassi El Ghella	23:58:28.581+02	0	23:58:28.581+02	0	t
1485	46	4621	Hassasna	23:58:28.581+02	0	23:58:28.581+02	0	t
1486	46	4622	Ain Kihal	23:58:28.581+02	0	23:58:28.581+02	0	t
1487	46	4623	Beni Saf	23:58:28.581+02	0	23:58:28.581+02	0	t
1488	46	4624	Sidi Safi	23:58:28.581+02	0	23:58:28.581+02	0	t
1489	46	4625	Oulhaca Gheraba	23:58:28.581+02	0	23:58:28.581+02	0	t
1490	46	4626	Sidi Ouriach	23:58:28.581+02	0	23:58:28.581+02	0	t
1491	46	4627	Emir Abdelkader	23:58:28.581+02	0	23:58:28.581+02	0	t
1492	46	4628	El Messaid	23:58:28.581+02	0	23:58:28.581+02	0	t
1493	47	4701	Ghardaia	23:58:28.581+02	0	23:58:28.581+02	0	t
1494	47	4702	El Meniaa	23:58:28.581+02	0	23:58:28.581+02	0	t
1495	47	4703	Dhayet Bendhaoua	23:58:28.581+02	0	23:58:28.581+02	0	t
1496	47	4704	Berriane	23:58:28.581+02	0	23:58:28.581+02	0	t
1497	47	4705	Metlili	23:58:28.581+02	0	23:58:28.581+02	0	t
1498	47	4706	El Guerrara	23:58:28.581+02	0	23:58:28.581+02	0	t
1499	47	4707	El Atteuf	23:58:28.581+02	0	23:58:28.581+02	0	t
1500	47	4708	Zelfana	23:58:28.581+02	0	23:58:28.581+02	0	t
1501	47	4709	Sebseb	23:58:28.581+02	0	23:58:28.581+02	0	t
1502	47	4710	Bounoura	23:58:28.581+02	0	23:58:28.581+02	0	t
1503	47	4711	Hassi Fehal	23:58:28.581+02	0	23:58:28.581+02	0	t
1504	47	4712	Hassi Gara	23:58:28.581+02	0	23:58:28.581+02	0	t
1505	47	4713	Mansoura	23:58:28.581+02	0	23:58:28.581+02	0	t
1506	48	4801	Relizane	23:58:28.581+02	0	23:58:28.581+02	0	t
1507	48	4802	Oued Rhiou	23:58:28.581+02	0	23:58:28.581+02	0	t
1508	48	4803	Belaasel Bouzegza	23:58:28.581+02	0	23:58:28.581+02	0	t
1509	48	4804	Sidi Saada	23:58:28.581+02	0	23:58:28.581+02	0	t
1510	48	4805	Ouled Aich	23:58:28.581+02	0	23:58:28.581+02	0	t
1511	48	4806	Sidi Lazreg	23:58:28.581+02	0	23:58:28.581+02	0	t
1512	48	4807	El H'Madna	23:58:28.581+02	0	23:58:28.581+02	0	t
1514	48	4809	Mediouna	23:58:28.581+02	0	23:58:28.581+02	0	t
1515	48	4810	Sidi Khettab	23:58:28.581+02	0	23:58:28.581+02	0	t
1516	48	4811	Ammi Moussa	23:58:28.581+02	0	23:58:28.581+02	0	t
1517	48	4812	Zemmoura	23:58:28.581+02	0	23:58:28.581+02	0	t
1518	48	4813	Beni Dergoun	23:58:28.581+02	0	23:58:28.581+02	0	t
1519	48	4814	Djidiouia	23:58:28.581+02	0	23:58:28.581+02	0	t
1520	48	4815	El Guettar	23:58:28.581+02	0	23:58:28.581+02	0	t
1521	48	4816	El Hamri	23:58:28.581+02	0	23:58:28.581+02	0	t
1522	48	4817	El Matmar	23:58:28.581+02	0	23:58:28.581+02	0	t
1524	48	4819	Ain Tarik	23:58:28.581+02	0	23:58:28.581+02	0	t
1525	48	4820	Oued Essalem	23:58:28.581+02	0	23:58:28.581+02	0	t
1526	48	4821	Ouarizane	23:58:28.581+02	0	23:58:28.581+02	0	t
1527	48	4822	Mazouna	23:58:28.581+02	0	23:58:28.581+02	0	t
1528	48	4823	Kalaa	23:58:28.581+02	0	23:58:28.581+02	0	t
1529	48	4824	Ain Rahma	23:58:28.581+02	0	23:58:28.581+02	0	t
1530	48	4825	Yellel	23:58:28.581+02	0	23:58:28.581+02	0	t
1531	48	4826	Oued El Djemaa	23:58:28.581+02	0	23:58:28.581+02	0	t
1532	48	4827	Ramka	23:58:28.581+02	0	23:58:28.581+02	0	t
1533	48	4828	Mendes	23:58:28.581+02	0	23:58:28.581+02	0	t
1534	48	4829	Lahlef	23:58:28.581+02	0	23:58:28.581+02	0	t
1535	48	4830	Beni Zentis	23:58:28.581+02	0	23:58:28.581+02	0	t
1536	48	4831	Souk El Had	23:58:28.581+02	0	23:58:28.581+02	0	t
1537	48	4832	Dar Ben Abdellah	23:58:28.581+02	0	23:58:28.581+02	0	t
1538	48	4833	El Hassi	23:58:28.581+02	0	23:58:28.581+02	0	t
1539	48	4834	Had Echkala	23:58:28.581+02	0	23:58:28.581+02	0	t
1540	48	4835	Ben Daoud	23:58:28.581+02	0	23:58:28.581+02	0	t
1541	48	4836	El Ouldja	23:58:28.581+02	0	23:58:28.581+02	0	t
1542	48	4837	Merdja Sidi Abed	23:58:28.581+02	0	23:58:28.581+02	0	t
1523	48	4818	Sidi M'hamed Benouda	23:58:28.581+02	0	23:58:28.581+02	0	t
1543	48	4838	Ouled Sidi Mihoub	23:58:28.581+02	0	23:58:28.581+02	0	t
178	5	0561	Larbaâ	23:53:21.216+02	0	23:53:21.216+02	0	t
273	8	0809	Mechraa Houari Boumedienne	23:53:21.216+02	0	23:53:21.216+02	0	t
1188	34	3423	OULED SIDI-BRAHIM	23:58:28.581+02	0	23:58:28.581+02	0	t
1306	39	3927	EL-M'GHAIER	23:58:28.581+02	0	23:58:28.581+02	0	t
1513	48	4808	Sidi M'hamed Benali	23:58:28.581+02	0	23:58:28.581+02	0	t
\.


--
-- Data for Name: dents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dents (num, adult, designation, created, createdby, updated, updatedby, active) FROM stdin;
1	t	\N	2020-11-18 17:41:31.807007	0	2020-11-18 17:41:31.807007	0	t
2	t	\N	2020-11-18 17:41:31.807007	0	2020-11-18 17:41:31.807007	0	t
3	t	\N	2020-11-18 17:41:54.482184	0	2020-11-18 17:41:54.482184	0	t
4	t	\N	2020-11-18 17:41:54.482184	0	2020-11-18 17:41:54.482184	0	t
5	t	\N	2020-11-18 17:41:54.482184	0	2020-11-18 17:41:54.482184	0	t
6	t	\N	2020-11-18 17:41:54.482184	0	2020-11-18 17:41:54.482184	0	t
7	t	\N	2020-11-18 17:41:54.482184	0	2020-11-18 17:41:54.482184	0	t
8	t	\N	2020-11-18 17:41:54.482184	0	2020-11-18 17:41:54.482184	0	t
9	t	\N	2020-11-18 17:42:20.193524	0	2020-11-18 17:42:20.193524	0	t
10	t	\N	2020-11-18 17:42:20.193524	0	2020-11-18 17:42:20.193524	0	t
11	t	\N	2020-11-18 17:42:20.193524	0	2020-11-18 17:42:20.193524	0	t
12	t	\N	2020-11-18 17:42:20.193524	0	2020-11-18 17:42:20.193524	0	t
13	t	\N	2020-11-18 17:42:20.193524	0	2020-11-18 17:42:20.193524	0	t
14	t	\N	2020-11-18 17:43:26.357605	0	2020-11-18 17:43:26.357605	0	t
15	t	\N	2020-11-18 17:43:26.357605	0	2020-11-18 17:43:26.357605	0	t
16	t	\N	2020-11-18 17:43:26.357605	0	2020-11-18 17:43:26.357605	0	t
17	t	\N	2020-11-18 17:43:26.357605	0	2020-11-18 17:43:26.357605	0	t
18	t	\N	2020-11-18 17:43:26.357605	0	2020-11-18 17:43:26.357605	0	t
19	t	\N	2020-11-18 17:43:26.357605	0	2020-11-18 17:43:26.357605	0	t
20	t	\N	2020-11-18 17:43:26.357605	0	2020-11-18 17:43:26.357605	0	t
21	t	\N	2020-11-18 17:43:26.357605	0	2020-11-18 17:43:26.357605	0	t
22	t	\N	2020-11-18 17:43:26.357605	0	2020-11-18 17:43:26.357605	0	t
23	t	\N	2020-11-18 17:43:26.357605	0	2020-11-18 17:43:26.357605	0	t
24	t	\N	2020-11-18 17:43:26.357605	0	2020-11-18 17:43:26.357605	0	t
25	t	\N	2020-11-18 17:43:26.357605	0	2020-11-18 17:43:26.357605	0	t
26	t	\N	2020-11-18 17:43:26.357605	0	2020-11-18 17:43:26.357605	0	t
27	t	\N	2020-11-18 17:43:26.357605	0	2020-11-18 17:43:26.357605	0	t
28	t	\N	2020-11-18 17:43:26.357605	0	2020-11-18 17:43:26.357605	0	t
29	t	\N	2020-11-18 17:43:26.357605	0	2020-11-18 17:43:26.357605	0	t
30	t	\N	2020-11-18 17:43:26.357605	0	2020-11-18 17:43:26.357605	0	t
31	t	\N	2020-11-18 17:43:26.357605	0	2020-11-18 17:43:26.357605	0	t
32	t	\N	2020-11-18 17:43:26.357605	0	2020-11-18 17:43:26.357605	0	t
A	f	\N	2020-11-18 17:44:50.366773	0	2020-11-18 17:44:50.366773	0	t
B	f	\N	2020-11-18 17:44:50.366773	0	2020-11-18 17:44:50.366773	0	t
C	f	\N	2020-11-18 17:44:50.366773	0	2020-11-18 17:44:50.366773	0	t
D	f	\N	2020-11-18 17:44:50.366773	0	2020-11-18 17:44:50.366773	0	t
E	f	\N	2020-11-18 17:44:50.366773	0	2020-11-18 17:44:50.366773	0	t
F	f	\N	2020-11-18 17:44:50.366773	0	2020-11-18 17:44:50.366773	0	t
G	f	\N	2020-11-18 17:44:50.366773	0	2020-11-18 17:44:50.366773	0	t
H	f	\N	2020-11-18 17:44:50.366773	0	2020-11-18 17:44:50.366773	0	t
I	f	\N	2020-11-18 17:44:50.366773	0	2020-11-18 17:44:50.366773	0	t
J	f	\N	2020-11-18 17:44:50.366773	0	2020-11-18 17:44:50.366773	0	t
K	f	\N	2020-11-18 17:45:33.965942	0	2020-11-18 17:45:33.965942	0	t
L	f	\N	2020-11-18 17:45:33.965942	0	2020-11-18 17:45:33.965942	0	t
M	f	\N	2020-11-18 17:45:33.965942	0	2020-11-18 17:45:33.965942	0	t
N	f	\N	2020-11-18 17:45:33.965942	0	2020-11-18 17:45:33.965942	0	t
O	f	\N	2020-11-18 17:45:33.965942	0	2020-11-18 17:45:33.965942	0	t
P	f	\N	2020-11-18 17:45:33.965942	0	2020-11-18 17:45:33.965942	0	t
Q	f	\N	2020-11-18 17:45:33.965942	0	2020-11-18 17:45:33.965942	0	t
R	f	\N	2020-11-18 17:45:33.965942	0	2020-11-18 17:45:33.965942	0	t
S	f	\N	2020-11-18 17:45:33.965942	0	2020-11-18 17:45:33.965942	0	t
T	f	\N	2020-11-18 18:36:06.518237	0	2020-11-18 18:36:06.518237	0	t
\.


--
-- Data for Name: etats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.etats (id, designation, created, createdby, updated, updatedby, active) FROM stdin;
1	Consultation terminée	2020-11-26 13:38:52.959477	0	2020-11-26 13:38:52.959477	0	t
2	Présent dans la salle d'attente	2020-11-26 13:38:52.959477	0	2020-11-26 13:38:52.959477	0	t
3	RDV Confirmé	2020-11-26 13:38:52.959477	0	2020-11-26 13:38:52.959477	0	t
5	RDV Annulé	2020-11-26 13:38:52.959477	0	2020-11-26 13:38:52.959477	0	t
0	Au fauteil	2020-12-03 08:27:58.223956	0	2020-12-03 08:27:58.223956	0	t
4	RDV Non confirmé	2020-11-26 13:38:52.959477	0	2020-12-16 10:35:21.510589	1	t
\.


--
-- Data for Name: medicaments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medicaments (id, designation, definition, created, createdby, updated, updatedby, active, code, montant) FROM stdin;
1	Paracetamol 500mg	\N	2020-11-21 14:42:10.939338	0	2020-11-21 14:42:10.939338	0	t	\N	\N
11	Clindamycine 1g	\N	2020-12-17 12:06:17.136608	1	2021-01-12 17:34:34.54847	1	t	\N	\N
2	Amoxicilline 1g	\N	2020-11-21 14:42:57.357046	0	2021-01-12 17:34:35.195073	1	t	\N	\N
\.


--
-- Data for Name: motifs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.motifs (id, designation, created, createdby, updated, updatedby, active) FROM stdin;
1	Extraction	2020-11-25 09:36:52.30528	0	2020-11-25 09:36:52.30528	0	t
2	Soins	2020-11-25 09:36:59.382955	0	2020-11-25 09:36:59.382955	0	t
3	Consultation	2020-11-25 09:50:27.956436	1	2020-11-25 09:50:27.956436	1	t
4	AUTRES	2020-11-25 14:47:28.403157	1	2020-12-16 10:34:58.268806	1	t
\.


--
-- Data for Name: ordonnance_posologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ordonnance_posologies (id, designation, created, createdby, updated, updatedby, active) FROM stdin;
1	01 Comp Matin + 01 Comp Soir	2020-12-26 14:59:14.813465	1	2020-12-26 14:59:14.813465	1	t
2	03 Comp Par jours	2020-12-26 14:59:40.260453	1	2020-12-26 14:59:40.260453	1	t
3	05 Comp par jours	2020-12-26 15:02:00.726439	1	2020-12-26 15:02:04.296354	1	t
4	02 fois par jours pendant 5 jours	2020-12-26 15:03:19.413559	1	2020-12-26 15:03:19.413559	1	t
\.


--
-- Data for Name: org; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.org (id, designation, tel, email, site_internet, adresse, created, createdby, updated, updatedby, active, file_name, file_name_background, fax, wilaya_id, reminder_delay, is_rappel_rdv_automatique) FROM stdin;
0	System	\N	\N	\N	\N	18:37:25.514381+01	0	18:37:25.514381+01	0	t	Dzental_logo.png	B3.jpg	\N	\N	24	t
1	demo	t	demo@dzental.com	\N	demo	18:37:54.090643+01	0	18:23:10.30573+01	1	t	logo_1_9_0_2021_18_23_10.png	logo_1_9_0_2021_18_23_10.jpg	00 00 00 00 00	8	24	t
\.


--
-- Data for Name: org_directions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.org_directions (id, org_id, designation, created, createdby, updated, updatedby, active) FROM stdin;
0	0	*	18:15:57.66+02	0	18:15:57.66+02	0	t
\.


--
-- Data for Name: org_horraires; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.org_horraires (id, org_id, jour, heure_de, heure_a, created, createdby, updated, updatedby, active) FROM stdin;
1	1	Dimanche	08:00	16:00	2020-12-06 20:05:51.564544	0	2020-12-06 20:05:51.564544	0	t
2	1	Lundi	10:00	18:00	2020-12-06 20:05:51.564544	0	2020-12-06 20:05:51.564544	0	t
3	1	Mardi	09:00	17:00	2020-12-06 20:05:51.564544	0	2020-12-06 20:05:51.564544	0	t
\.


--
-- Data for Name: org_produits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.org_produits (id, org_id, produit_id, created, createdby, updated, updatedby, active) FROM stdin;
\.


--
-- Data for Name: org_professions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.org_professions (id, org_id, designation, created, createdby, updated, updatedby, active) FROM stdin;
1	1	Chirurgien-dentiste	17:24:57.886002+01	\N	17:24:57.886002+01	\N	t
2	1	Assistant dentaire	17:24:57.886002+01	\N	17:24:57.886002+01	\N	t
3	1	Orthodontiste	17:24:57.886002+01	\N	17:24:57.886002+01	\N	t
4	1	 Prothésiste dentaire	17:24:57.886002+01	\N	17:24:57.886002+01	\N	t
\.


--
-- Data for Name: org_sales; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.org_sales (id, org_id, designation, created, createdby, updated, updatedby, active) FROM stdin;
\.


--
-- Data for Name: org_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.org_transactions (id, org_id, type_transaction_id, patient_id, date_transaction, montant, observation, created, createdby, updated, updatedby, active, type_paiement_id, partenaire_id) FROM stdin;
81	1	8	\N	2021-02-07 17:31:00	-5200	\N	2021-01-28 19:33:47.062277	1	2021-01-28 19:33:47.062277	1	t	1	19
76	1	2	\N	2021-12-17 14:20:00	120	\N	2020-12-17 15:20:50.832578	105	2020-12-17 15:20:50.832578	105	t	3	17
53	1	3	67	2021-01-01 17:08:00	30000	\N	2020-12-01 18:08:29.751165	1	2020-12-01 18:08:29.751165	1	t	2	\N
65	1	1	55	2021-02-07 15:40:00	12345.67	\N	2020-12-07 16:50:48.908812	1	2020-12-07 16:50:48.908812	1	t	2	\N
78	1	1	47	2021-06-16 18:42:00	12000	\N	2021-01-16 19:42:19.961131	1	2021-01-16 19:42:19.961131	1	t	1	\N
52	1	1	1053	2021-12-01 16:20:00	10000	\N	2020-12-01 17:20:23.131245	1	2020-12-01 17:20:23.131245	1	t	3	\N
75	1	2	\N	2021-02-10 12:29:00	-1200	\N	2020-12-16 14:30:12.873953	1	2020-12-16 14:30:12.873953	1	t	2	11
80	1	9	\N	2021-06-16 18:42:00	-1200	\N	2021-01-28 19:33:34.649994	1	2021-01-28 19:33:34.649994	1	t	1	20
\.


--
-- Data for Name: partenaires; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.partenaires (id, org_id, designation, adresse, email, tel, fax, created, createdby, updated, updatedby, active, color) FROM stdin;
11	1	Laboratoire Mira	Hussein Dey Alger,Algerie	h_djellouli@esi.dz	0555 55 55 55	0555 55 55 55	2020-12-12 20:02:43.481245	1	2020-12-12 20:02:43.481245	1	t	bisque
13	\N	je sais pas	\N	\N	\N	\N	2020-12-12 21:07:42.223638	1	2020-12-12 21:07:42.223638	1	t	bisque
18	1	Prothesiste Ahmed	Hussein Dey Alger,Algerie	h_djellouli@esi.dz	0222 22 22 22	0222 22 22 22	2020-12-14 08:54:38.597594	1	2020-12-14 08:54:38.597594	1	t	#1404F6
19	1	Sonelgaz	\N	\N	\N	\N	2021-01-28 19:31:15.792371	1	2021-01-28 19:31:15.792371	1	t	#8897BE
20	1	Seaal	\N	\N	\N	\N	2021-01-28 19:31:22.446003	1	2021-01-28 19:31:22.446003	1	t	#3BCECA
\.


--
-- Data for Name: pathologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pathologies (id, designation, definition, created, createdby, updated, updatedby, active, code) FROM stdin;
1	Abcès	\N	2020-11-15 17:44:15.100278	0	2020-11-15 17:44:15.100278	0	t	\N
2	Aboulie	\N	2020-11-15 17:44:15.100278	0	2020-11-15 17:44:15.100278	0	t	\N
3	Accident ischémique transitoire	\N	2020-11-15 17:44:15.100278	0	2020-11-15 17:44:15.100278	0	t	\N
4	Accident vasculaire cérébral	\N	2020-11-15 17:44:15.100278	0	2020-11-15 17:44:15.100278	0	t	\N
5	Acidocétose	\N	2020-11-15 17:44:15.100278	0	2020-11-15 17:44:15.100278	0	t	\N
6	Acidose	\N	2020-11-15 17:44:15.100278	0	2020-11-15 17:44:15.100278	0	t	\N
7	Acouphène	\N	2020-11-15 17:44:15.100278	0	2020-11-15 17:44:15.100278	0	t	\N
8	Acromégalie	\N	2020-11-15 17:44:15.100278	0	2020-11-15 17:44:15.100278	0	t	\N
9	Addiction	\N	2020-11-15 17:44:15.100278	0	2020-11-15 17:44:15.100278	0	t	\N
10	Adénocarcinome	\N	2020-11-15 17:44:15.100278	0	2020-11-15 17:44:15.100278	0	t	\N
11	Adénome	\N	2020-11-15 17:44:15.100278	0	2020-11-15 17:44:15.100278	0	t	\N
12	Adénopathie	\N	2020-11-15 17:44:15.100278	0	2020-11-15 17:44:15.100278	0	t	\N
13	Adiposité	\N	2020-11-15 17:44:15.100278	0	2020-11-15 17:44:15.100278	0	t	\N
14	Aérophagie	\N	2020-11-15 17:44:15.100278	0	2020-11-15 17:44:15.100278	0	t	\N
15	Agoraphobie	\N	2020-11-15 17:44:15.100278	0	2020-11-15 17:44:15.100278	0	t	\N
16	Algie vasculaire de la face	\N	2020-11-15 17:44:15.100278	0	2020-11-15 17:44:15.100278	0	t	\N
17	Algodystrophie	\N	2020-11-15 17:44:15.100278	0	2020-11-15 17:44:15.100278	0	t	\N
18	Algoneurodystrophie	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
19	Allergie	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
20	Alopécie	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
21	Alzheimer	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
22	Amblyopie	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
23	Aménorrhée	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
24	Amnésie	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
25	Amyotrophie	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
26	Anasarque	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
27	Anémie	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
28	Anévrisme	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
29	Angine	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
30	Angine de poitrine	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
31	Angiopathie	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
32	Angor	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
33	Anorexie	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
34	Anosmie	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
35	Anthrax	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
36	Apathie	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
37	Aphasie	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
38	Aphte	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
39	Aplasie [d'un organe]	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
40	Aplasie médullaire	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
41	Apnée (du sommeil)	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
42	Appendicite	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
43	Apraxie	\N	2020-11-15 17:45:40.96094	0	2020-11-15 17:45:40.96094	0	t	\N
44	 membres inférieurs	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
45	Arthrite	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
46	Arthrose	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
47	Arythmie	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
48	Arythmie cardiaque	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
49	Ascite	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
50	Asphyxie	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
51	Asthme	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
52	Astigmatisme	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
53	Atélectasie	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
54	Athérosclérose	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
55	Attaque de panique	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
56	Autisme	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
57	Auto-immune	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
58	AVC	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
59	AVF	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
60	Bacille de Koch	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
61	Bacillose	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
62	Bartholinite	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
63	Basedow [maladie]	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
64	Bipolaire [trouble]	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
65	Bipolarité	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
66	BK	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
67	Blennoragie	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
68	Borderline	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
69	Botulisme	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
70	Boulimie	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
71	BPCO	\N	2020-11-15 17:48:16.964049	0	2020-11-15 17:48:16.964049	0	t	\N
72	Bradycardie	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
73	Bronchiolite	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
74	Bronchite	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
75	Broncho-pneumopathie chronique obstructive	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
76	Brucellose	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
77	Bursite	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
78	Cachexie	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
79	Calcification	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
80	Calcul	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
81	Camptodactylie	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
82	Cancer bronchique à petites cellules	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
83	Cancer bronchique non à petites cellules	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
84	Candidose	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
85	Capsulite	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
86	Carcinome	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
87	Cardiopathie	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
88	Cataracte	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
89	Cavernome	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
90	CBNPC	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
91	Cécité	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
92	Céphalée	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
93	Charbon	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
94	Chlamydia	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
95	Choc anaphylactique	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
96	Choléra	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
97	Chondropathie	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
98	Chorio-épithéliome	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
99	Choriocarcinome	\N	2020-11-15 17:48:29.516455	0	2020-11-15 17:48:29.516455	0	t	\N
100	Circoncision	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
101	Cirrhose	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
102	Cleptomanie	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
103	Clivage	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
104	Coeliaque	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
105	Colique	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
106	Colite	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
107	Condylome	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
108	Condylome acuminé	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
109	Conflit	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
110	Conjonctivite	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
111	Coqueluche	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
112	Court-circuit artério-veineux	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
113	Coxarthrose	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
114	CPC	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
115	Crête de coq	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
116	Crohn 	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
117	Cruralgie	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
118	Cyanose	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
119	Cyclothymie	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
120	Cyphoscoliose	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
121	Cyphose	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
122	Cystite	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
123	Cytomégalovirus	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
124	Décollement [de la rétine]	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
125	Décompensation	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
126	Dégénérescence maculaire liée à l'âge	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
127	Delirium tremens	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
128	Démence	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
129	Déminéralisation (osseuse)	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
130	Dépression	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
131	Dépression du post-partum	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
132	Déréalisation	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
133	Dermatite	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
134	Dermatose	\N	2020-11-15 17:48:56.975162	0	2020-11-15 17:48:56.975162	0	t	\N
135	Dermite	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
136	Désafférentation	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
137	Diabète	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
138	Diabète gestationnel	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
139	Diarrhée	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
140	Diphtérie	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
141	Diplopie	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
142	Discale [hernie]	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
143	Dissection aortique	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
144	Dissociation	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
145	Diverticulose	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
146	Drépanocytose	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
147	Duchenne	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
148	Dysentrie	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
149	Dysménorrhée	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
150	Dysmorphophobie	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
151	Dyspepsie	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
152	Dysphorie	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
153	Dyspnée	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
154	Dyspraxie	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
155	Dystonie	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
156	Dystrophie musculaire	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
157	Dysurie	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
158	Ecchymose	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
159	Eclampsie	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
160	Eczéma	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
161	Embolie	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
162	Emphysème	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
163	Encéphalite	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
164	Encoprésie	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
165	Endocardite	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
166	Endométriose	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
167	Enurésie	\N	2020-11-15 17:49:30.312921	0	2020-11-15 17:49:30.312921	0	t	\N
168	Epanchement (pleural)	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
169	Epanchement pleural	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
170	Epilepsie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
171	Episode dépressif majeur	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
172	Epistaxis	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
173	Epithéliome	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
174	Epithélomia	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
175	Erythème	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
176	Escarre	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
177	Extrasystole	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
178	Fibrillation	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
179	Fibromyalgie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
180	Fibromyalgie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
181	Fistule	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
182	Flessum	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
183	Flexum	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
184	Furoncle	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
185	Gammapathie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
186	Gastralgie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
187	Gastroentérite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
188	Gastroentérite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
189	Genu Valgum	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
190	Genu Varum	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
191	GEU	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
192	Glaucome	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
193	Goitre	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
194	Gonalgie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
195	Gonarthrose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
196	Goutte [crise de]	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
197	Grossesse extra-utérine	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
198	Hallux valgus	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
199	Hématurie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
200	Hémochromatose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
201	Hépatite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
202	Herpès	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
203	Hiatale [hernie]	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
204	Hodgkin 	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
205	Hygroma kystique	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
206	Hyperacousie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
207	Hypercalcémie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
208	Hypercatabolisme	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
209	Hypercholestérolémie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
210	Hyperglycémie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
211	Hyperkaliémie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
212	Hypertension	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
213	Hypertension intracrânienne	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
214	Hyperuricémie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
215	Hypervolémie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
216	Hypogammaglobulinémie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
217	Hypoglycémie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
218	Hypothyroïdie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
219	Hypovolémie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
220	Hypovolémie relative	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
221	Iatrogénique [effet]	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
222	Ictère	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
223	Immunodéficitaire	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
224	Incontinence	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
225	Infarctus	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
226	Infection nosocomiale	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
227	Insuffisance cardiaque	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
228	Insuffisance rénale	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
229	 respiratoire	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
230	Insuffisance ventriculaire	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
231	IRC	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
232	Kératite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
233	Koïlocyte	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
234	Laryngite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
235	Leishmaniose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
236	Leucémie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
237	Lipome	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
238	Listériose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
239	Lithiase	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
240	Lombalgie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
241	Lumbago	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
242	Lupus	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
243	Lupus érythémateux disséminé	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
244	Luxation	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
245	Luxation	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
246	Luxation congénitale de la hanche	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
247	 transmissible	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
248	Malignité	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
249	Manie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
250	Mastocytose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
251	Mélanome	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
252	Méléna	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
253	Méningite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
254	Mésothéliome	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
255	Métaplasie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
256	Métastase	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
257	Météorisme	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
258	MICI	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
259	Microalbuminurie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
260	Migraine	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
261	MST	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
262	Mucoviscidose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
263	Mutisme	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
264	Mycose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
265	Myélite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
266	Myélome	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
267	Myopathie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
268	Mythomanie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
269	Nécrose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
270	Néphrétique [colique]	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
271	Néphropathie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
272	Néphropathie interstitielle	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
273	Neurinome	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
274	Neurofibromatose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
275	Neutropénie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
276	Névralgie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
277	Névrome	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
278	Névrose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
279	Nociception	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
280	Nosocomiale [maladie]	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
281	Nystagmus	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
282	Oedème	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
283	OEdème de Quincke	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
284	Orchite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
285	Orgelet	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
286	Ostéite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
287	Ostéonécrose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
288	Ostéopénie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
289	Ostéophytose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
290	Ostéoporose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
291	Otite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
292	Paludisme	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
293	Panaris	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
294	Pancréatite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
295	Panique [attaque de]	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
296	Papillome	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
297	Paralysie récurrentielle	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
298	Paranoïa	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
299	Paraplégie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
300	Paresthésie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
301	Parkinson 	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
302	Périathrite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
303	Péricardite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
304	Péritonite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
305	Perversion	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
306	Pharyngite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
307	Phénylcétonurie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
308	Phimosis	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
309	Phlébite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
310	Phobie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
311	Pleurésie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
312	Pneumopathie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
313	Pneumothorax	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
314	Polio	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
315	Poliomyélite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
316	Poliomyélite antérieure aiguë	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
317	Polyarthrite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
318	Polype	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
319	Polyurie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
320	Potomanie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
321	Pré-éclampsie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
322	Précordialgie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
323	Presbyacousie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
324	Presbytie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
325	Procidence	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
326	Prolapsus	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
327	Prolapsus utérin	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
328	Psoriasis	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
329	Psychose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
330	Pyélonéphrite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
331	Pyromanie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
332	Quadriplégie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
333	Rachitisme	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
334	RCH	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
335	Rectocolite hémorragique	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
336	Reflux	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
337	Rhinopharyngite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
338	Rhizarthrose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
339	Rougeole	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
340	Rubéole	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
341	Salmonellose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
342	Salpingite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
343	Sarcome	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
344	Sarcopénie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
345	Saturnisme	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
346	Scarlatine	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
347	Schizophrénie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
348	Schwannome	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
349	Sciatique	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
350	Sclérose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
351	Sclérose en plaques	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
352	Scoliose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
353	Séroconversion	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
354	Séropositif, ive	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
355	Shunt	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
356	Sida	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
357	Silicose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
358	Sommeil (maladie du)	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
359	Spasmophilie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
360	Splénomégalie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
361	Spondylolisthésis	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
362	Stéatose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
363	Sténose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
364	Strabisme	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
365	Syndrome de Raynaud	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
366	Syphilis	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
367	Syringomyélie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
368	Tachycardie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
369	Tendinite	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
370	Tétanos	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
371	Tétraplégique [personne]	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
372	Thrombopénie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
373	Thrombose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
374	Thymome	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
375	Toxo	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
376	Toxoplasmose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
377	Trisomie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
378	Trouble de la personnalité	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
379	Trouble du comportement alimentaire	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
380	Trypanosomiase	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
381	Tuberculose	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
382	Tumeur	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
383	Tumeur	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
384	Typhoïde	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
385	Ulcère	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
386	Urticaire	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
387	Valvulopathie	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
388	Varicelle	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
389	Virus de l'immunodéficience humaine	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
390	Vitiligo	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
391	Zona	\N	2020-11-15 17:51:20.008302	0	2020-11-15 17:51:20.008302	0	t	\N
\.


--
-- Data for Name: patient_certificats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patient_certificats (id, patient_id, numero_certificat, date_certificat, observation, created, createdby, updated, updatedby, active, certificat_motifs_id) FROM stdin;
1	47	Certificat N° 1	2020-12-26 14:22:00	Maladie 3 jours	2020-12-26 15:22:51.116648	1	2020-12-26 15:22:51.116648	1	t	\N
2	47	Certificat N° 1	2021-01-22 15:01:00	<p>JE SOUSSIGNE (E) <b>DJELLOULI HICHAM</b> DOCTEUR EN MEDECINE, </p><p>CERTIFIE\nAVOIR EXAMINE AUJOURD’HUI M. / Mme………………………………………………..\nLE/LA PATIENT(E) EST EN BONNE SANTE PHYSIQUE ET NE SOUFFRE PAS DE GRAVES MALADIES\nCHRONIQUES OU VENERIENNES, DE TUBERCULOSE NI D’AUTRE MALADIE MORTELLE.\nLES ANALYSES SEROLOGIQUES HIV : NEGATIVES\nLE PRESENT CERTIFICAT EST DELIVRE AU PROFIT DE M. /Mme ………………..…..\nEN VUE D’UNE ADOPTION INTERNATIONALE.&nbsp;&nbsp;<br></p>	2021-01-15 16:01:55.021068	1	2021-01-15 16:01:55.021068	1	t	1
3	1086	Certificat N° 1	2021-01-20 18:18:00	JE SOUSSIGNE (E)………………………………………………………………………………..\nDOCTEUR EN MEDECINE, CERTIFIE\nAVOIR EXAMINE AUJOURD’HUI M. / Mme………………………………………………..\nLE/LA PATIENT(E) EST EN BONNE SANTE PHYSIQUE ET NE SOUFFRE PAS DE GRAVES MALADIES\nCHRONIQUES OU VENERIENNES, DE TUBERCULOSE NI D’AUTRE MALADIE MORTELLE.\nLES ANALYSES SEROLOGIQUES HIV : NEGATIVES\nLE PRESENT CERTIFICAT EST DELIVRE AU PROFIT DE M. /Mme ………………..…..\nEN VUE D’UNE ADOPTION INTERNATIONALE.&nbsp;&nbsp;<br>	2021-01-28 19:18:40.774168	1	2021-01-28 19:18:40.774168	1	t	1
\.


--
-- Data for Name: patient_consultations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patient_consultations (id, patient_id, date_consultation, duree, observation, created, createdby, updated, updatedby, active, consulte_par, startsat, endsat) FROM stdin;
3037	1048	2020-11-28 13:57:07.241796	0	\N	2020-12-03 09:07:08.276767	\N	2020-12-03 09:07:08.276767	\N	t	\N	2020-11-28 13:57:07.241796	2020-11-28 13:57:07.241796
3038	55	2020-11-28 00:55:50.411758	0	\N	2020-12-03 09:08:51.233952	\N	2020-12-03 09:08:51.233952	\N	t	\N	2020-11-28 00:55:50.411758	2020-11-28 02:55:50.411758
3039	1053	2020-11-28 00:57:16.555652	595	\N	2020-12-03 09:13:30.446486	\N	2020-12-03 09:13:30.446486	\N	t	\N	2020-11-28 00:57:16.555652	2020-11-28 10:52:16.555652
3040	55	2020-12-03 08:40:22.775984	120	\N	2020-12-03 09:14:36.658982	\N	2020-12-03 09:14:36.658982	\N	t	\N	2020-12-03 08:40:22.775984	2020-12-03 10:40:22.775984
2063	85	2013-06-11 14:45:12.178405	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3041	1047	2020-12-03 09:16:45.54298	0	\N	2020-12-03 09:16:48.483095	\N	2020-12-03 09:16:48.483095	\N	t	\N	2020-12-03 09:16:45.54298	2020-12-03 09:16:48.483095
3044	59	2020-12-03 09:32:53.084527	0	\N	2020-12-03 09:32:55.485587	\N	2020-12-03 09:32:55.485587	\N	t	\N	2020-12-03 09:32:53.084527	2020-12-03 09:32:55.485587
3045	1054	2020-11-28 14:43:46.230483	1129	\N	2020-12-03 09:33:01.037432	\N	2020-12-03 09:33:01.037432	\N	t	\N	2020-11-28 14:43:46.230483	2020-12-03 09:33:01.037432
3046	86	2020-11-28 14:44:12.645675	1128	\N	2020-12-03 09:33:03.82324	\N	2020-12-03 09:33:03.82324	\N	t	\N	2020-11-28 14:44:12.645675	2020-12-03 09:33:03.82324
3047	1048	2020-11-27 23:20:06.84554	614	\N	2020-12-03 09:34:27.333854	\N	2020-12-03 09:34:27.333854	\N	t	\N	2020-11-27 23:20:06.84554	2020-12-03 09:34:27.333854
2113	135	2018-08-12 10:13:17.550719	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3042	1048	2020-12-03 09:17:37.121756	1	\N	2020-12-03 09:19:11.153381	\N	2020-12-03 09:19:11.153381	\N	t	\N	2020-12-03 09:17:37.121756	2020-12-03 09:19:11.153381
3043	56	2020-12-03 09:17:54.719583	2	\N	2020-12-03 09:20:40.545327	\N	2020-12-03 09:20:40.545327	\N	t	\N	2020-12-03 09:17:54.719583	2020-12-03 09:20:40.545327
2114	136	2018-06-21 05:06:29.6331	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2115	137	2018-07-23 16:18:40.550348	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2116	138	2016-04-09 18:33:49.997573	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3048	1054	2020-12-03 10:08:22.488512	0	\N	2020-12-03 10:08:44.344906	\N	2020-12-03 10:08:44.344906	\N	t	\N	2020-12-03 10:08:22.488512	2020-12-03 10:08:44.344906
2117	139	2016-09-19 12:37:49.571122	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2118	140	2014-10-09 09:21:51.063884	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2119	141	2014-04-30 16:40:42.988371	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3049	1047	2020-12-03 09:19:42.545858	170	\N	2020-12-07 12:10:19.027057	\N	2020-12-07 12:10:19.027057	\N	t	\N	2020-12-03 09:19:42.545858	2020-12-07 12:10:19.027057
2120	142	2020-01-06 05:25:55.979495	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2121	143	2015-06-25 18:12:11.053983	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2122	144	2016-10-25 03:32:29.51873	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2123	145	2018-06-25 16:38:28.268781	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3050	48	2020-12-12 21:08:44.368112	0	\N	2020-12-12 21:08:46.960781	\N	2020-12-12 21:08:46.960781	\N	t	\N	2020-12-12 21:08:44.368112	2020-12-12 21:08:46.960781
2124	146	2013-11-15 06:53:14.686308	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2125	147	2016-01-08 13:30:19.260213	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2126	148	2018-02-03 01:48:26.419127	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3051	1071	2020-12-15 20:00:05.195203	0	\N	2020-12-15 20:00:23.401905	\N	2020-12-15 20:00:23.401905	\N	t	\N	2020-12-15 20:00:05.195203	2020-12-15 20:00:23.401905
2127	149	2020-03-25 16:30:11.015612	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2128	150	2020-11-12 20:50:47.218115	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2129	151	2013-07-30 14:41:30.663705	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3052	1053	2020-12-17 16:12:35.121863	0	\N	2020-12-17 16:12:37.740445	\N	2020-12-17 16:12:37.740445	\N	t	\N	2020-12-17 16:12:35.121863	2020-12-17 16:12:37.740445
2130	152	2015-10-10 04:22:58.507343	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2131	153	2020-07-25 02:12:32.653067	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2151	173	2014-04-17 22:48:04.62285	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2132	154	2018-10-11 10:47:29.428577	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2133	155	2017-10-01 23:27:24.398965	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2134	156	2020-08-12 00:32:04.851391	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2135	157	2020-02-07 12:45:35.770613	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2224	246	2017-08-24 06:30:43.647264	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2225	247	2020-10-20 06:42:54.464787	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2226	248	2016-03-06 11:13:31.072558	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2227	249	2016-02-04 15:29:27.843668	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2228	250	2018-07-21 23:30:05.522722	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2229	251	2018-03-28 23:31:38.907294	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2230	252	2017-10-04 14:52:15.88988	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2231	253	2019-02-09 17:01:10.826556	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2232	254	2014-02-23 16:46:44.57943	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2233	255	2018-11-12 21:09:21.306845	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2234	256	2016-08-08 11:24:17.038986	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2235	257	2020-03-22 13:27:41.612998	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2236	258	2014-01-08 01:27:28.407062	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2237	259	2013-07-24 22:34:13.405162	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2238	260	2016-02-11 20:54:59.529422	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2242	264	2015-11-19 10:09:22.184579	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2243	265	2013-11-19 06:24:27.371745	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2244	266	2018-04-10 22:16:23.64215	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2245	267	2017-10-28 04:09:50.644485	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2246	268	2019-10-16 05:06:15.16348	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2247	269	2019-08-06 01:08:39.250917	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2248	270	2019-04-26 19:03:35.582897	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2249	271	2017-04-20 21:21:25.283022	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2250	272	2014-11-23 20:49:56.444371	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2251	273	2018-12-08 06:10:36.085318	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2252	274	2015-11-11 17:22:04.118303	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2253	275	2013-02-22 10:04:34.935397	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2254	276	2014-12-25 11:41:09.577327	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2255	277	2018-11-16 20:18:51.040793	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2256	278	2020-03-31 20:08:13.121196	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2136	158	2020-07-21 13:22:42.187729	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2137	159	2016-04-06 12:42:28.04431	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2138	160	2015-06-02 14:46:45.189602	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2139	161	2017-10-16 03:37:46.259922	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2140	162	2016-09-13 01:24:38.832356	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2141	163	2013-08-06 05:40:30.058241	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2142	164	2016-01-02 00:23:12.455205	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2143	165	2015-10-17 09:34:06.640777	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2144	166	2016-08-08 21:00:08.716785	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2145	167	2013-11-01 06:47:23.729136	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2146	168	2019-08-15 04:11:03.815682	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2147	169	2014-08-22 11:39:11.919595	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2148	170	2020-10-22 17:02:48.577925	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2149	171	2019-10-13 14:17:39.795059	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2150	172	2013-12-17 12:53:36.106574	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2086	108	2016-07-16 00:12:51.222759	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	2	\N	\N
2112	134	2017-05-12 12:59:01.895564	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2152	174	2020-07-23 22:06:31.969135	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2153	175	2019-03-24 19:37:49.586556	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2154	176	2017-11-30 20:58:17.746142	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2155	177	2015-08-23 19:19:33.012369	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2156	178	2019-02-10 01:53:10.087288	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2157	179	2013-08-28 14:48:24.148258	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2158	180	2017-08-04 16:43:08.344487	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2159	181	2018-07-04 13:38:06.91302	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2160	182	2014-04-25 09:23:45.479621	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2161	183	2018-10-22 08:44:16.641377	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2162	184	2018-08-22 04:27:25.419609	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2163	185	2018-09-19 20:44:38.753707	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2164	186	2014-10-27 05:32:57.709833	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2165	187	2019-07-27 11:02:57.928091	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2166	188	2018-04-26 02:21:59.682437	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2167	189	2017-12-22 04:24:24.987132	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2168	190	2014-09-23 08:23:45.110579	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2169	191	2013-11-08 11:01:56.944691	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2170	192	2018-07-10 09:45:04.04666	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2171	193	2015-06-07 11:19:41.03422	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2172	194	2018-03-08 06:12:56.042718	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2173	195	2017-09-08 03:45:26.744121	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2174	196	2020-04-15 10:23:51.737057	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2175	197	2014-11-20 19:38:53.100837	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2176	198	2014-11-11 16:50:07.277294	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2177	199	2016-02-20 00:39:02.001593	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2178	200	2014-08-17 00:37:11.444729	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2179	201	2015-12-01 02:12:54.082198	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2180	202	2020-02-12 16:31:47.371825	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2257	279	2013-08-22 09:59:57.843677	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2258	280	2019-06-28 07:59:53.982336	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2259	281	2018-08-30 14:35:36.261719	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2260	282	2013-09-10 20:34:09.28771	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2261	283	2019-08-14 17:36:56.812778	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2262	284	2014-04-24 17:37:21.925696	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2263	285	2015-06-19 12:11:45.506055	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2264	286	2016-02-04 22:55:21.428054	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2265	287	2013-08-23 06:18:35.065664	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2266	288	2016-06-21 16:01:13.102795	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2267	289	2020-08-03 18:01:19.185669	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2268	290	2017-09-11 02:16:35.772648	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2269	291	2016-06-06 22:42:57.128108	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2270	292	2018-07-03 22:03:25.181664	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2272	294	2013-11-27 07:23:48.200801	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2273	295	2017-01-26 12:36:21.710333	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2274	296	2018-09-19 17:57:11.143213	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2275	297	2018-06-27 02:31:00.798498	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2276	298	2015-05-01 16:03:03.060748	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2277	299	2018-12-22 06:19:57.056107	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2278	300	2016-01-05 01:40:53.909046	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2279	301	2020-11-05 18:13:55.791431	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2280	302	2019-04-29 11:16:35.130065	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2281	303	2015-06-14 02:23:48.238016	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2282	304	2016-06-27 22:32:45.460731	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2181	203	2019-09-26 21:37:05.18577	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2182	204	2015-11-24 10:46:07.315673	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2183	205	2020-04-25 06:39:08.195488	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2184	206	2015-02-05 12:51:15.918459	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2185	207	2018-11-19 04:45:48.437482	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2186	208	2013-08-14 09:12:32.49971	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2187	209	2019-03-21 00:52:51.188888	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2188	210	2013-08-03 05:03:56.112036	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2189	211	2016-12-19 10:49:21.562804	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2190	212	2013-06-14 09:55:35.194878	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2191	213	2013-11-01 19:31:20.348846	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2193	215	2013-05-06 15:30:22.752162	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2194	216	2020-09-06 14:04:07.34386	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2195	217	2016-12-10 00:06:31.379384	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2196	218	2020-04-30 16:49:21.223352	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2197	219	2017-05-04 14:36:07.586554	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2198	220	2013-01-24 11:26:40.005088	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2199	221	2020-06-11 11:33:27.010239	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2200	222	2015-10-29 09:22:38.653419	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2201	223	2019-03-26 07:34:48.354177	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2202	224	2013-12-09 09:49:20.051254	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2203	225	2015-07-10 15:44:55.166056	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2204	226	2018-09-15 14:08:13.514181	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2205	227	2019-04-15 09:22:59.027443	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2206	228	2016-06-09 23:42:20.222425	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2207	229	2017-04-11 06:09:43.702438	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2208	230	2015-04-14 12:43:01.167222	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2209	231	2020-05-14 20:43:11.114207	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2210	232	2013-09-06 00:26:26.896703	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2211	233	2019-03-28 08:19:12.253159	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2212	234	2019-01-06 02:53:13.173254	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3008	1030	2019-05-11 03:01:36.493682	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3009	1031	2021-01-08 15:33:25.319955	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3010	1032	2013-05-27 13:15:32.130185	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3011	1033	2017-04-11 09:51:32.965264	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3012	1034	2018-12-27 01:05:50.657007	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3013	1035	2017-06-30 22:34:24.4594	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3014	1036	2013-12-15 04:09:19.631758	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3015	1037	2016-11-25 06:24:04.092984	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3016	1038	2013-12-10 03:04:23.434271	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3017	1039	2017-11-15 12:16:19.470894	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3018	1040	2015-05-14 08:02:35.741516	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3019	1041	2015-07-22 12:17:13.976366	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3020	1042	2019-07-04 08:44:36.84654	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3021	1043	2020-07-31 06:43:20.644394	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3023	1045	2014-01-06 08:17:48.974222	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3024	1046	2014-01-21 12:43:57.004762	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3025	1047	2015-01-28 02:01:43.65517	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3026	1048	2021-01-05 04:20:33.654603	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3027	1049	2020-06-29 06:24:11.476318	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3028	1050	2016-05-25 23:28:00.946081	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3030	1052	2019-05-06 21:02:45.022591	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2049	71	2016-05-12 07:59:15.90047	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2050	72	2015-12-19 09:50:42.203512	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2052	74	2016-09-17 15:22:45.142523	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2053	75	2016-10-21 16:12:43.480125	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2054	76	2015-11-04 17:51:59.074258	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2055	77	2016-08-20 12:20:18.354194	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2065	87	2015-11-26 06:14:15.522836	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2066	88	2014-05-29 18:53:52.650493	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2067	89	2018-05-24 16:19:02.76461	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2068	90	2015-08-03 20:36:13.017829	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2069	91	2018-10-06 01:04:20.211651	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2070	92	2013-11-27 04:42:04.926652	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2071	93	2013-12-24 19:49:34.27462	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2072	94	2014-12-11 08:02:01.483008	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2073	95	2013-05-12 19:14:03.120579	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2074	96	2016-06-30 08:30:52.095888	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2075	97	2016-11-24 07:45:44.83164	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2076	98	2017-04-21 06:31:21.621579	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2077	99	2019-07-10 20:56:36.519645	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2078	100	2018-10-07 13:15:13.749732	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2079	101	2019-11-09 07:11:23.386672	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2080	102	2018-09-28 17:06:18.504712	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2081	103	2018-10-20 16:57:44.867527	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2082	104	2020-08-31 07:01:18.767676	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2083	105	2015-08-03 04:40:10.153975	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2084	106	2019-10-03 01:29:25.694912	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2085	107	2017-04-15 21:42:31.281271	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2087	109	2013-04-25 12:11:23.237003	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2088	110	2013-04-04 23:35:39.33212	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2089	111	2015-03-29 23:52:03.776326	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2090	112	2013-03-13 23:07:47.606814	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2091	113	2019-03-28 01:35:43.403581	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2092	114	2020-03-08 14:29:12.982575	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3004	1026	2019-08-20 10:28:19.538574	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3036	1058	2017-10-01 13:43:16.116531	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3005	1027	2014-05-07 08:59:15.496893	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3006	1028	2018-04-12 23:26:20.123966	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3007	1029	2020-02-27 11:23:15.290417	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2283	305	2017-07-18 22:51:41.943309	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2284	306	2017-03-04 10:40:08.837326	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2285	307	2014-02-26 10:42:11.977475	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2286	308	2014-06-04 04:45:13.837286	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2287	309	2014-06-25 20:26:04.709425	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2288	310	2015-03-29 21:40:51.237754	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2289	311	2015-04-14 19:12:26.895812	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2290	312	2017-03-14 13:44:42.939743	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2291	313	2013-03-16 17:34:09.363335	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2292	314	2018-06-26 20:17:14.838284	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2293	315	2015-03-23 14:53:34.293465	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2294	316	2014-03-27 13:13:39.756835	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2295	317	2013-10-30 10:03:27.234217	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2296	318	2014-12-10 03:17:29.979946	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2297	319	2016-03-07 23:10:17.89815	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2299	321	2020-02-15 23:33:26.864035	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2300	322	2014-10-26 04:35:49.264049	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2301	323	2014-02-13 06:24:45.734229	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2302	324	2017-11-30 04:50:05.94584	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2303	325	2015-11-13 23:26:39.647301	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2304	326	2013-03-08 06:41:11.513414	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2327	349	2014-09-28 11:31:57.113417	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2328	350	2020-05-14 06:23:51.324741	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2329	351	2017-11-25 23:19:25.320648	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2305	327	2018-12-10 07:58:13.522173	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2306	328	2019-10-04 21:52:27.826246	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2307	329	2016-08-06 23:35:24.958817	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2308	330	2020-08-12 04:12:05.15298	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2309	331	2018-12-31 23:00:55.116938	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2310	332	2020-02-06 10:58:00.735548	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2311	333	2019-05-26 04:43:24.915217	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2312	334	2015-05-27 21:04:52.382397	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2313	335	2014-10-26 02:54:04.000437	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2314	336	2014-03-13 13:48:52.170231	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2315	337	2018-01-28 06:10:15.414844	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2316	338	2014-06-10 23:52:13.609363	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2317	339	2016-02-09 02:25:33.517991	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2318	340	2020-01-05 05:39:39.342548	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2319	341	2018-11-15 00:19:16.660314	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2320	342	2015-02-07 19:30:28.130192	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2321	343	2017-12-07 17:03:28.124738	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2323	345	2016-04-25 13:40:19.281841	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2324	346	2017-08-15 08:45:54.60873	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2325	347	2013-06-02 07:39:24.583216	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2326	348	2016-04-25 21:43:41.98272	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2330	352	2017-04-12 16:11:56.966235	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2331	353	2015-08-13 11:14:40.297736	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2332	354	2015-02-18 16:16:22.343259	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2333	355	2015-01-09 01:04:50.064798	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2334	356	2020-05-15 19:38:03.995338	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2335	357	2020-11-10 05:33:29.249303	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2336	358	2017-02-26 05:07:55.146418	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2337	359	2015-12-23 04:46:51.57535	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2338	360	2015-07-30 19:41:45.847495	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2339	361	2013-06-26 21:17:41.059984	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2340	362	2016-11-22 22:04:46.355438	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2341	363	2015-10-12 22:58:58.901909	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2342	364	2020-09-10 23:26:06.281941	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2343	365	2018-02-18 11:50:53.975629	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2344	366	2014-05-20 15:34:30.388257	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2345	367	2017-04-27 19:05:55.196869	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2346	368	2016-03-09 13:41:11.58991	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2347	369	2015-02-10 01:33:53.547318	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2349	371	2013-05-03 00:15:26.598051	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2350	372	2018-01-14 23:27:33.342249	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2351	373	2017-11-14 10:20:33.114671	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2352	374	2020-08-14 23:14:22.190403	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2353	375	2018-10-28 02:08:14.879586	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2354	376	2018-03-04 02:19:56.761152	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2355	377	2020-05-25 08:07:05.350283	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2356	378	2013-08-31 08:58:25.141119	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2357	379	2019-03-15 20:54:03.51504	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2358	380	2015-06-14 02:34:14.712953	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2359	381	2016-05-18 05:52:17.273644	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2360	382	2018-03-15 02:13:10.58117	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2361	383	2016-10-28 16:26:38.794136	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2362	384	2020-09-14 02:16:10.251897	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2363	385	2020-05-26 02:15:27.145655	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2364	386	2017-02-14 07:26:32.736485	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2365	387	2016-02-06 16:59:54.779385	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2366	388	2013-10-29 16:58:49.346761	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2367	389	2019-02-13 18:03:59.116005	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2368	390	2020-02-24 10:38:04.208113	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2369	391	2018-06-03 13:21:44.769123	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2370	392	2015-10-15 21:56:48.658862	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2371	393	2018-01-13 12:18:39.363732	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2373	395	2017-09-06 01:29:47.817281	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2374	396	2014-11-14 03:13:30.569619	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2375	397	2018-05-27 14:35:03.563251	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2376	398	2016-10-16 06:34:28.483332	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2377	399	2018-06-22 11:40:51.499206	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2378	400	2018-08-31 14:15:41.154553	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2379	401	2015-07-31 08:00:56.07954	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2380	402	2020-06-19 18:39:46.165182	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2381	403	2016-09-14 07:27:37.417554	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2382	404	2017-12-07 09:30:50.696467	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2383	405	2014-09-04 19:17:35.860927	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2384	406	2019-12-13 01:51:57.200639	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2385	407	2016-01-03 13:35:06.149827	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2386	408	2017-12-28 21:03:21.831894	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2387	409	2017-04-29 12:18:00.178648	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2388	410	2015-02-14 13:33:40.247537	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2389	411	2015-06-13 02:06:38.669534	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2390	412	2016-05-30 04:31:20.400908	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2391	413	2017-11-09 18:55:37.340651	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2392	414	2013-01-26 20:09:50.902297	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2415	437	2019-04-29 10:29:05.580137	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2416	438	2020-11-15 07:51:52.314032	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2417	439	2017-11-01 17:36:51.10408	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2418	440	2020-02-17 15:03:49.221673	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2393	415	2018-04-30 13:09:59.794666	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2394	416	2013-06-11 00:40:13.676185	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2395	417	2014-11-21 01:42:42.787192	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2396	418	2016-06-08 01:55:12.201504	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2397	419	2019-01-06 22:12:13.259797	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2398	420	2016-04-15 08:12:06.369666	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2399	421	2015-09-08 09:19:46.864174	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2401	423	2017-08-16 05:42:31.241892	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2402	424	2019-05-17 09:59:15.501132	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2403	425	2020-04-16 19:34:34.865855	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2404	426	2014-07-19 23:17:26.946569	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2405	427	2014-11-10 07:56:04.077468	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2406	428	2014-03-19 20:40:57.441529	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2407	429	2020-02-05 17:34:50.30134	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2408	430	2016-12-21 20:17:32.374913	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2409	431	2018-12-03 14:38:56.305713	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2410	432	2016-01-19 08:03:27.025078	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2411	433	2017-11-18 13:47:05.895844	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2412	434	2017-10-02 01:17:39.699365	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2413	435	2020-02-01 20:52:36.912288	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2414	436	2019-04-03 09:14:29.55345	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2419	441	2020-08-20 01:53:52.041034	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2420	442	2017-12-27 20:21:21.674242	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2421	443	2013-07-01 15:07:12.818165	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2422	444	2017-11-03 02:21:21.930442	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2423	445	2020-07-22 02:45:41.014457	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2425	447	2013-02-16 04:03:06.958746	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2426	448	2018-06-26 08:21:35.939827	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2427	449	2019-03-28 00:45:21.783699	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2428	450	2015-10-17 06:17:35.844024	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2429	451	2018-04-25 15:46:54.18601	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2430	452	2017-05-28 09:48:57.963874	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2431	453	2018-09-29 08:08:13.64215	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2432	454	2017-03-15 15:07:53.068322	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2433	455	2014-04-29 03:15:14.510289	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2434	456	2013-11-06 09:25:52.530591	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2435	457	2017-04-01 01:04:44.403229	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2436	458	2014-09-23 19:55:25.387683	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2437	459	2013-07-15 21:22:06.448726	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2438	460	2014-12-11 13:39:21.264814	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2439	461	2013-02-02 19:04:18.832883	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2440	462	2015-03-14 16:24:12.359727	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2441	463	2018-07-01 13:53:33.082286	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2442	464	2016-05-29 09:42:33.330341	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2443	465	2017-04-21 22:40:17.211583	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2444	466	2020-12-20 14:23:06.336678	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2445	467	2015-10-16 03:56:33.368022	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2446	468	2019-07-30 09:58:39.322431	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2447	469	2013-06-12 18:17:14.752388	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2448	470	2016-01-29 07:08:44.426361	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2449	471	2015-02-23 13:17:50.973259	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2451	473	2017-11-14 02:23:33.25791	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2452	474	2020-06-09 15:09:31.853764	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2453	475	2017-03-16 17:00:55.54063	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2454	476	2019-04-29 19:00:12.702456	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2455	477	2015-04-25 20:43:17.580191	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2456	478	2013-06-22 08:30:23.89154	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2457	479	2019-11-08 14:44:57.230376	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2458	480	2014-12-27 13:06:13.781064	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2459	481	2016-10-28 23:49:04.373547	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2460	482	2014-09-14 23:40:19.882516	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2461	483	2015-09-18 18:53:25.151363	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2462	484	2018-12-24 02:12:21.018592	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2463	485	2017-08-06 05:32:52.783302	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2464	486	2017-06-14 15:30:44.24776	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2465	487	2014-09-10 09:02:26.316365	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2466	488	2013-11-27 11:05:11.726749	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2467	489	2015-02-23 03:45:51.872643	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2468	490	2017-02-09 09:28:40.848211	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2469	491	2013-08-13 08:02:15.922425	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2470	492	2018-03-16 10:45:03.249115	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2471	493	2016-03-30 08:10:06.218623	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2472	494	2017-05-16 15:59:11.73962	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2474	496	2018-10-25 09:29:09.154053	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2475	497	2019-07-04 15:57:44.597584	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2476	498	2020-05-06 12:56:47.366005	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2477	499	2015-12-11 09:00:45.479832	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2478	500	2013-06-30 19:01:59.109848	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2479	501	2014-12-08 13:57:00.019071	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2480	502	2019-03-10 21:49:19.223998	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2503	525	2016-10-16 01:40:14.599765	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2504	526	2014-10-03 16:01:07.537784	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2505	527	2020-09-15 12:58:28.864937	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2481	503	2015-10-18 19:41:33.514016	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2482	504	2019-02-23 14:06:34.801787	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2483	505	2019-01-29 00:34:56.549324	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2484	506	2019-08-07 01:58:23.936471	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2485	507	2018-06-20 09:47:28.862554	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2486	508	2017-02-28 04:44:37.856478	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2487	509	2015-01-10 03:56:46.812503	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2488	510	2017-03-28 18:57:43.641239	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2489	511	2017-04-22 17:06:48.074831	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2490	512	2020-01-19 05:07:33.063691	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2491	513	2014-06-16 14:20:19.295503	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2492	514	2017-06-18 16:46:20.421141	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2493	515	2020-04-23 16:40:16.052739	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2494	516	2013-12-16 20:45:48.641213	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2495	517	2018-03-26 22:01:58.13207	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2496	518	2013-04-07 01:15:20.131294	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2497	519	2017-05-11 22:46:06.906424	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2499	521	2016-11-29 00:19:50.938798	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2500	522	2015-05-15 09:11:26.574977	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2501	523	2013-02-13 04:21:13.683205	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2502	524	2013-02-08 21:13:28.301917	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2506	528	2019-01-01 22:28:20.667849	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2507	529	2015-12-23 11:25:48.807357	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2508	530	2020-03-20 18:12:38.730608	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2509	531	2020-11-02 13:47:31.976281	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2510	532	2016-08-17 16:40:45.385928	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2511	533	2016-09-04 12:33:38.447565	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2512	534	2020-09-19 07:39:22.853339	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2513	535	2019-07-02 17:08:38.892775	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2514	536	2016-05-17 14:28:30.455404	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2515	537	2013-06-09 02:18:24.244381	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2516	538	2018-04-01 22:14:31.775541	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2517	539	2013-08-20 17:51:11.638245	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2518	540	2019-12-14 14:01:01.503957	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2519	541	2013-10-31 00:46:31.325163	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2520	542	2020-04-16 05:50:25.061484	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2521	543	2017-12-20 09:42:50.438374	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2522	544	2013-06-11 02:31:49.716043	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2523	545	2020-12-10 07:55:39.01887	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2524	546	2016-02-28 21:36:31.283658	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2526	548	2016-07-23 21:01:16.205589	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2527	549	2014-06-02 13:27:25.742982	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2528	550	2016-08-10 21:59:55.702756	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2529	551	2015-04-27 18:53:06.87522	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2530	552	2017-07-07 17:04:56.669298	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2531	553	2017-08-02 15:47:47.409667	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2532	554	2019-08-19 08:13:23.097249	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2533	555	2019-06-27 23:07:17.918539	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2534	556	2019-11-07 11:54:46.900024	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2535	557	2015-02-01 15:11:47.123959	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2536	558	2014-04-06 21:10:35.239286	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2537	559	2019-04-21 19:47:04.639776	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2538	560	2015-01-26 10:54:02.958965	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2539	561	2013-11-26 06:09:05.867191	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2540	562	2017-11-05 12:11:31.781548	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2541	563	2020-10-01 08:52:19.532384	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2542	564	2013-09-06 01:25:49.014101	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2543	565	2016-10-07 17:50:23.266844	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2544	566	2016-12-01 10:29:14.574647	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2545	567	2017-09-20 00:36:19.476396	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2546	568	2018-06-20 05:44:08.594078	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2547	569	2017-11-09 02:13:41.431796	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2548	570	2019-12-16 21:34:06.472938	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2549	571	2018-02-19 17:24:50.111589	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2550	572	2015-10-07 01:21:56.733319	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2551	573	2016-07-03 14:04:40.372749	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2552	574	2018-11-20 00:05:40.243131	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2553	575	2018-07-22 07:37:39.717374	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2554	576	2019-05-18 10:52:11.127146	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2555	577	2017-01-03 11:13:43.841799	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2556	578	2013-07-11 04:25:04.129873	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2557	579	2017-01-23 12:35:55.106766	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2558	580	2020-03-17 12:58:29.095473	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2559	581	2017-02-08 14:20:27.711856	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2560	582	2019-01-25 19:30:02.32495	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2562	584	2015-06-24 03:11:41.212346	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2563	585	2019-04-27 16:27:17.679226	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2564	586	2018-07-16 22:16:42.484997	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2565	587	2014-11-24 16:37:49.078078	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2566	588	2014-08-27 09:49:49.284883	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2567	589	2020-11-17 05:58:53.596013	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2568	590	2017-02-26 17:08:23.575118	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2591	613	2017-10-03 21:23:52.758684	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2592	614	2018-02-17 21:07:58.596644	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2593	615	2018-11-12 08:53:17.592306	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2569	591	2020-07-03 03:03:26.560655	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2570	592	2020-10-09 05:38:01.610838	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2571	593	2014-06-25 09:53:38.397468	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2572	594	2016-08-17 19:45:05.361992	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2573	595	2015-04-12 14:46:10.091481	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2574	596	2015-07-26 06:04:43.599347	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2575	597	2016-07-13 22:42:26.115093	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2576	598	2015-12-21 12:18:21.78836	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2577	599	2016-09-06 20:14:08.418671	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2578	600	2019-03-16 09:52:54.143139	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2579	601	2016-04-08 20:24:16.480403	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2580	602	2020-08-26 16:41:22.312409	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2581	603	2013-06-03 23:07:01.634249	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2582	604	2017-04-25 09:43:52.114051	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2584	606	2018-01-11 17:21:22.834553	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2585	607	2013-12-01 21:51:47.271628	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2586	608	2014-07-10 03:08:50.271734	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2587	609	2013-05-26 03:57:33.378428	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2588	610	2016-05-03 22:21:03.598263	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2589	611	2017-06-05 09:11:50.006495	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2590	612	2015-05-25 16:53:12.443944	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2594	616	2018-03-17 01:21:27.839253	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2595	617	2017-08-15 04:35:53.121467	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2596	618	2016-07-09 09:19:54.287256	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2597	619	2015-07-25 04:56:12.059938	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2598	620	2018-04-22 05:23:43.989207	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2599	621	2016-10-02 20:56:58.254045	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2600	622	2020-07-03 05:26:37.916077	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2601	623	2016-11-08 04:59:35.752561	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2602	624	2020-04-20 23:00:05.844427	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2603	625	2013-12-23 07:38:43.707218	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2604	626	2015-01-27 09:43:45.863236	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2605	627	2019-09-24 08:04:11.933705	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2606	628	2016-03-14 22:12:13.06174	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2607	629	2015-01-15 07:14:22.754105	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2609	631	2013-10-01 21:59:02.407421	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2610	632	2016-03-16 15:23:13.729938	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2611	633	2018-10-13 08:43:02.05698	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2612	634	2013-12-19 10:30:04.115447	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2613	635	2015-11-23 17:21:46.11369	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2614	636	2015-04-18 23:09:10.349623	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2615	637	2019-08-16 17:36:04.411779	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2616	638	2018-01-23 08:53:03.77745	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2617	639	2017-08-02 10:29:13.629143	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2618	640	2015-05-04 21:05:57.600264	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2619	641	2019-05-01 08:34:19.562446	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2620	642	2019-09-26 10:21:47.14954	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2621	643	2014-05-20 16:52:00.237525	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2622	644	2019-02-20 12:58:19.217789	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2623	645	2016-06-14 18:01:24.98829	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2624	646	2013-02-16 10:27:20.046528	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2625	647	2013-10-27 04:27:51.420667	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2626	648	2014-06-06 15:52:40.294134	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2627	649	2020-11-19 02:31:14.639317	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2628	650	2015-08-05 23:41:56.628798	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2629	651	2016-05-02 07:31:07.358419	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2630	652	2014-08-27 13:34:08.801995	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2631	653	2013-02-16 23:06:53.445897	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2632	654	2018-10-31 03:53:21.311644	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2633	655	2019-01-20 10:22:40.890638	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2635	657	2015-07-15 10:21:59.922299	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2636	658	2019-03-02 23:37:03.217006	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2637	659	2020-12-06 10:28:14.917243	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2638	660	2017-06-29 00:00:20.996189	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2639	661	2019-01-16 06:54:41.987001	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2640	662	2015-05-03 06:37:06.340165	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2641	663	2014-09-27 23:35:20.646081	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2642	664	2013-08-15 07:29:32.845941	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2643	665	2019-04-20 19:34:56.263474	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2644	666	2020-02-25 19:57:34.226666	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2645	667	2019-07-12 05:41:12.945257	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2646	668	2013-02-01 03:49:18.99083	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2647	669	2013-11-19 21:56:11.933419	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2648	670	2015-07-09 15:17:35.681069	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2649	671	2016-06-20 02:00:34.705233	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2650	672	2016-11-03 13:21:13.783254	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2651	673	2020-05-11 11:33:51.364854	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2652	674	2018-12-12 01:44:07.095832	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2653	675	2015-01-26 07:58:20.580477	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2654	676	2013-08-19 00:02:16.73175	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2655	677	2019-03-06 01:16:10.546957	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2656	678	2020-05-13 17:14:54.861249	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2679	701	2015-06-12 07:43:04.259336	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2680	702	2019-01-05 23:09:55.36069	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2681	703	2018-03-16 22:18:54.576014	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2657	679	2020-11-24 07:45:31.595029	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2658	680	2016-01-30 23:25:18.2569	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2659	681	2013-07-21 10:54:29.965602	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2660	682	2020-09-21 08:45:17.403237	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2661	683	2015-09-29 03:24:48.71672	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2662	684	2015-07-18 09:21:47.618488	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2663	685	2020-07-04 23:05:12.75761	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2665	687	2013-09-23 10:43:12.370609	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2666	688	2016-01-03 12:06:53.709996	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2667	689	2013-08-25 10:18:53.080407	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2668	690	2014-06-11 23:08:26.001841	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2669	691	2017-12-12 08:50:11.909708	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2670	692	2015-07-14 10:24:46.827855	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2671	693	2020-07-16 14:20:53.187664	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2672	694	2018-04-20 01:34:31.296782	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2673	695	2017-04-02 08:09:11.02504	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2674	696	2019-07-07 22:24:34.924542	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2675	697	2015-01-20 12:33:40.345061	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2676	698	2020-10-20 14:40:06.839876	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2677	699	2014-06-13 01:29:17.294748	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2678	700	2017-04-15 03:09:40.176053	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2682	704	2013-05-08 17:37:29.896943	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2683	705	2019-02-05 05:38:21.015042	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2684	706	2014-02-04 12:00:53.111794	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2685	707	2017-02-26 23:57:41.790936	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2686	708	2019-02-15 04:24:45.083481	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2687	709	2016-12-15 04:09:00.09334	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2688	710	2016-01-23 04:33:43.837401	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2689	711	2013-09-25 15:32:24.194976	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2690	712	2013-12-01 00:06:33.115341	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2692	714	2020-04-03 01:09:03.893217	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2693	715	2013-03-06 12:06:51.503435	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2694	716	2017-05-09 02:13:32.542207	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2695	717	2013-07-19 11:48:44.242572	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2696	718	2019-06-13 01:45:01.03065	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2697	719	2018-08-23 22:06:03.073671	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2698	720	2014-11-17 17:46:30.267514	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2699	721	2020-07-29 09:29:05.188734	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2700	722	2014-01-08 11:53:40.05803	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2701	723	2019-02-02 03:45:37.08642	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2702	724	2016-02-13 13:42:15.159468	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2703	725	2019-04-22 09:22:13.959129	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2704	726	2020-07-10 17:41:52.00026	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2705	727	2014-11-17 15:04:07.284384	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2706	728	2016-01-09 03:26:24.00194	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2707	729	2013-12-24 21:32:00.593646	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2708	730	2015-12-30 09:58:03.703391	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2709	731	2014-10-07 20:28:43.622861	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2710	732	2017-11-08 10:36:27.615906	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2711	733	2019-06-03 09:15:16.201435	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2712	734	2019-03-28 20:12:02.671482	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2713	735	2019-09-15 09:31:59.365883	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2714	736	2018-01-01 16:25:37.034806	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2715	737	2018-03-22 10:35:41.367694	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2716	738	2015-10-09 10:33:47.837529	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2717	739	2014-12-15 09:51:59.862839	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2718	740	2017-11-20 08:01:18.974203	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2719	741	2020-01-14 17:46:48.043476	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2720	742	2016-11-17 21:18:04.650468	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2721	743	2018-03-19 11:17:38.576755	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2723	745	2018-01-14 08:53:28.615503	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2724	746	2016-11-05 14:13:22.098887	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2725	747	2019-07-22 06:57:37.118645	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2726	748	2016-04-12 06:42:56.041	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2727	749	2014-02-02 05:40:26.420381	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2728	750	2019-11-07 14:19:05.119575	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2729	751	2019-07-11 12:43:16.687156	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2730	752	2016-01-29 22:07:17.184958	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2731	753	2019-11-12 23:25:32.133595	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2732	754	2013-06-14 02:43:04.537274	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2733	755	2014-03-19 04:12:13.198056	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2734	756	2016-04-13 23:43:53.922509	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2735	757	2020-11-04 20:02:24.723344	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2736	758	2017-09-26 06:01:24.08861	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2737	759	2015-01-10 16:02:44.345278	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2738	760	2013-12-13 03:28:57.571036	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2739	761	2014-10-29 16:16:25.656312	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2740	762	2014-09-18 00:53:07.673667	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2741	763	2013-04-17 22:23:27.145996	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2742	764	2020-12-25 21:55:36.594644	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2743	765	2016-12-02 02:55:18.874346	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2744	766	2015-05-01 09:15:54.44984	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2767	789	2015-12-28 21:06:29.911417	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2768	790	2016-09-21 20:44:48.691552	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2769	791	2017-07-02 12:04:26.231551	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2770	792	2017-08-16 17:32:19.197015	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2746	768	2020-03-03 22:18:35.479892	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2747	769	2017-07-10 23:01:51.993748	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2748	770	2020-05-15 20:06:06.800432	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2749	771	2020-12-07 20:19:47.36429	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2750	772	2013-09-02 07:37:15.738443	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2751	773	2018-07-12 13:44:22.164395	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2752	774	2015-09-28 11:29:35.090982	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2753	775	2019-02-16 07:30:14.669338	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2754	776	2020-11-19 16:36:24.829984	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2755	777	2014-12-27 12:45:15.8532	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2756	778	2017-05-06 07:55:29.73899	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2757	779	2014-04-30 03:57:07.868483	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2758	780	2013-05-28 07:44:00.088041	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2759	781	2015-02-03 18:22:24.182282	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2760	782	2014-08-28 12:52:37.033019	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2761	783	2019-11-26 03:29:41.516213	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2762	784	2014-10-06 17:43:33.627099	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2763	785	2015-06-20 08:07:05.294215	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2764	786	2019-11-01 03:07:18.873065	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2765	787	2018-03-19 17:43:24.426914	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2766	788	2020-10-11 14:40:29.358149	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2772	794	2017-07-13 11:29:48.284503	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2773	795	2017-01-14 01:51:53.882098	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2774	796	2013-03-30 02:57:20.648707	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2775	797	2014-07-07 17:30:27.424851	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2776	798	2019-02-22 20:03:26.938314	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2777	799	2020-05-22 20:13:49.491407	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2778	800	2014-05-07 13:16:33.81756	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2779	801	2019-01-25 02:43:08.840076	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2780	802	2020-11-17 23:27:56.867732	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2781	803	2013-08-29 03:38:22.984867	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2782	804	2014-06-03 04:15:08.843421	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2783	805	2015-07-08 02:48:30.654403	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2784	806	2017-10-16 14:19:17.488124	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2785	807	2020-04-05 16:58:45.247147	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2786	808	2017-02-17 23:18:44.895384	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2787	809	2013-06-16 00:17:42.088914	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2788	810	2017-02-19 17:50:00.936972	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2789	811	2019-12-15 07:56:49.347661	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2790	812	2013-07-23 22:15:05.006073	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2791	813	2017-04-01 21:16:42.995384	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2792	814	2018-02-10 18:45:46.181639	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2793	815	2014-05-06 19:45:16.637207	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2794	816	2013-03-10 11:11:09.212685	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2795	817	2017-07-20 08:54:08.549094	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2796	818	2020-01-17 07:51:53.340534	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2797	819	2018-10-24 06:37:47.768629	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2799	821	2018-08-18 09:06:11.399837	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2800	822	2014-10-19 06:38:51.514163	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2801	823	2017-01-05 15:42:18.311097	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2802	824	2020-08-22 23:02:39.508108	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2803	825	2016-11-06 11:32:48.813678	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2804	826	2013-11-05 22:49:31.529847	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2805	827	2015-12-25 19:37:31.314256	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2806	828	2014-04-13 10:01:07.410828	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2807	829	2014-03-17 20:53:23.983938	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2808	830	2019-12-25 21:52:27.929838	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2809	831	2017-10-14 16:54:57.584773	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2810	832	2019-05-22 00:32:18.925086	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2811	833	2013-08-10 11:56:20.426926	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2812	834	2020-10-10 08:52:19.406505	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2813	835	2014-05-22 06:09:19.316398	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2814	836	2017-06-12 06:20:03.293785	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2815	837	2019-08-25 03:34:17.414268	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2816	838	2014-12-19 06:01:43.649555	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2817	839	2014-08-25 01:07:42.766282	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2819	841	2013-05-07 15:54:48.272687	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2820	842	2013-12-13 17:54:29.18551	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2821	843	2014-03-02 14:39:58.704904	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2822	844	2018-02-06 23:48:23.29092	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2823	845	2014-11-05 21:38:16.212349	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2824	846	2014-08-05 14:45:06.664029	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2825	847	2019-05-22 00:21:23.495975	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2826	848	2020-03-11 17:16:56.68218	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2827	849	2020-07-11 00:13:42.986254	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2828	850	2017-05-06 00:11:03.911081	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2829	851	2016-10-05 03:11:28.628651	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2830	852	2017-10-22 04:37:12.331033	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2831	853	2020-05-05 02:41:53.344969	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2832	854	2018-09-03 02:20:42.84496	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2855	877	2016-07-03 13:48:09.904161	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2856	878	2015-03-04 18:14:11.399836	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2857	879	2018-05-18 07:31:56.447483	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2833	855	2019-03-12 00:28:19.067869	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2834	856	2013-04-01 17:41:53.485514	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2835	857	2013-03-07 10:30:47.061307	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2836	858	2019-06-22 20:15:01.594801	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2837	859	2016-05-20 00:47:56.288322	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2839	861	2019-12-14 07:38:44.089334	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2840	862	2013-06-05 10:31:26.961625	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2841	863	2014-11-11 22:42:35.28528	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2842	864	2015-10-25 13:04:21.74215	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2843	865	2018-12-12 01:03:46.985211	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2844	866	2015-04-21 18:42:49.791612	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2845	867	2016-06-30 22:16:21.319462	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2846	868	2017-05-24 18:09:44.749333	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2847	869	2018-01-17 10:49:31.270214	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2848	870	2015-06-12 14:34:09.579202	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2849	871	2018-10-28 12:07:30.822763	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2850	872	2018-12-31 22:30:10.83344	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2851	873	2015-03-30 19:02:01.257367	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2852	874	2014-09-01 05:58:26.174672	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2853	875	2018-03-31 19:24:10.96845	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2854	876	2020-09-20 04:05:14.52865	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2858	880	2015-11-15 03:33:59.155307	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2859	881	2014-12-09 21:31:33.148282	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2860	882	2017-04-29 17:53:19.70076	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2861	883	2014-02-16 21:23:51.303312	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2862	884	2014-04-24 14:58:53.120276	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2863	885	2015-02-20 02:31:46.285972	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2864	886	2013-08-09 01:52:32.733226	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2865	887	2019-11-16 06:56:18.265485	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2866	888	2019-08-26 10:48:13.722174	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2868	890	2018-05-03 07:40:31.008482	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2869	891	2013-03-07 18:16:49.019744	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2870	892	2014-04-17 18:33:00.804233	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2871	893	2013-03-27 17:52:15.289862	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2872	894	2019-05-15 00:04:43.634132	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2873	895	2013-04-03 20:51:34.421952	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2874	896	2019-01-22 18:12:47.59213	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2875	897	2013-03-19 22:35:05.393501	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2876	898	2013-09-07 19:35:10.236678	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2877	899	2020-06-14 10:11:45.582205	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2878	900	2018-03-28 17:25:31.460448	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2879	901	2014-02-04 00:25:17.289715	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2880	902	2020-11-07 08:35:11.198412	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2881	903	2016-09-08 06:22:04.713288	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2882	904	2013-11-30 06:47:23.090261	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2883	905	2018-11-10 14:32:30.404983	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2884	906	2017-10-17 08:18:15.206247	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2885	907	2018-09-22 22:30:31.289955	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2886	908	2017-04-18 04:33:25.271447	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2887	909	2019-11-26 07:56:09.27022	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2888	910	2014-01-16 16:15:21.666205	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2889	911	2016-10-09 17:59:21.130067	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2890	912	2016-04-05 03:26:57.198447	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2891	913	2015-11-16 22:11:50.651133	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2892	914	2020-08-07 20:36:06.100704	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2893	915	2015-10-23 16:08:02.240312	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2894	916	2018-10-13 00:04:22.928053	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2895	917	2016-09-08 06:10:23.351028	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2896	918	2020-01-21 15:09:12.324609	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2897	919	2016-03-01 11:13:37.72992	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2898	920	2017-12-17 04:05:40.251527	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2899	921	2017-09-25 14:40:19.20142	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2900	922	2017-12-30 19:14:23.851421	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2901	923	2017-01-09 23:17:39.22137	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2902	924	2014-11-29 07:35:12.862438	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2903	925	2020-02-16 20:51:13.507386	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2904	926	2020-09-18 09:10:13.341426	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2905	927	2018-10-31 07:35:52.166173	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2906	928	2013-12-15 06:36:59.363769	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2907	929	2016-04-16 06:28:47.585351	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2909	931	2019-07-14 13:11:03.750447	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2916	938	2019-02-19 00:58:52.462793	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2917	939	2017-09-13 13:15:39.384592	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2918	940	2014-04-11 01:54:46.427071	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2919	941	2016-02-22 03:17:01.452217	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2920	942	2014-02-09 03:56:23.654818	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2921	943	2016-03-20 11:58:25.789034	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2922	944	2020-05-06 20:27:12.170952	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2923	945	2014-11-02 09:23:49.351225	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2924	946	2016-07-14 00:11:22.229709	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2925	947	2017-11-08 01:34:24.801901	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2926	948	2016-03-31 01:13:37.310852	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2028	50	2020-01-13 15:50:50.406438	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2029	51	2016-05-27 02:37:53.404434	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2030	52	2013-01-21 22:12:50.346807	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2031	53	2019-02-01 21:30:04.876424	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2032	54	2017-06-03 10:26:34.365298	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2033	55	2020-08-29 08:48:55.659095	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2034	56	2016-12-11 23:44:15.596832	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2035	57	2014-01-25 23:29:41.784122	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2036	58	2019-01-19 17:23:34.630532	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2037	59	2013-12-26 17:34:52.453912	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2038	60	2014-06-01 22:34:20.129057	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2039	61	2019-08-03 03:07:50.149223	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2040	62	2017-03-04 22:52:48.27115	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2041	63	2019-07-04 09:24:16.383389	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2042	64	2013-06-14 19:52:10.389902	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2043	65	2019-06-01 14:10:34.072888	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2044	66	2014-05-29 17:44:33.341486	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2045	67	2014-06-10 17:16:30.143148	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2046	68	2018-07-20 09:31:19.63971	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2047	69	2020-08-03 04:17:47.195398	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2048	70	2015-02-26 04:14:13.397566	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2056	78	2013-12-17 07:41:24.327171	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2057	79	2015-09-27 04:28:23.743667	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2058	80	2015-03-26 13:36:48.288223	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2059	81	2019-07-07 17:36:27.460481	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2060	82	2016-05-18 10:20:33.753494	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2061	83	2017-07-19 06:33:08.266061	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2062	84	2019-10-16 03:48:30.151415	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2064	86	2019-03-03 18:55:58.435402	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	2	\N	\N
2025	47	2018-03-28 04:14:07.425185	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2051	73	2014-02-24 12:07:54.82313	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2026	47	2016-12-31 16:28:41.570659	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2027	47	2018-06-08 12:50:00.615075	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3000	1022	2018-12-08 04:08:57.527051	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3001	1023	2019-12-03 08:39:22.587295	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3002	1024	2014-01-17 13:16:14.476686	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3003	1025	2019-10-27 20:15:00.659474	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2192	214	2020-09-19 19:10:47.693095	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2271	293	2016-06-08 09:29:58.743954	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2298	320	2017-07-17 09:05:02.64466	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2322	344	2014-03-30 04:33:52.129919	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2348	370	2019-11-22 21:06:50.31159	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2372	394	2013-04-09 05:41:06.612252	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2400	422	2015-08-02 01:32:00.679002	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2424	446	2013-06-09 05:02:19.547708	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2450	472	2019-09-03 20:07:19.520064	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2473	495	2020-08-28 05:15:31.584767	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2498	520	2017-10-12 16:04:51.556094	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2525	547	2014-07-14 21:53:04.825352	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2561	583	2015-10-09 01:05:05.93756	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2583	605	2015-08-10 13:08:05.048939	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2608	630	2015-10-07 15:13:19.049651	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2634	656	2015-09-26 22:29:50.064123	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2664	686	2018-03-29 18:01:38.74275	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2691	713	2017-07-10 07:06:19.556733	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2722	744	2019-10-05 04:21:11.847608	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2745	767	2017-08-11 16:33:51.906119	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2771	793	2017-12-13 20:55:20.589888	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2798	820	2018-01-19 17:33:51.739626	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2818	840	2013-04-19 13:14:55.491203	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2838	860	2016-05-16 21:12:32.153525	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2867	889	2013-04-02 15:31:43.716505	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2908	930	2015-08-19 18:59:12.354779	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2939	961	2020-05-22 06:11:15.333033	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2968	990	2020-08-27 17:09:08.003687	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2994	1016	2013-09-22 05:04:26.593492	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3022	1044	2015-11-13 18:02:07.426515	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3029	1051	2018-02-13 16:51:59.927254	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2927	949	2018-12-04 01:30:06.276998	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2928	950	2016-09-25 06:16:37.255887	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2929	951	2019-05-29 04:31:55.246172	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2930	952	2019-02-07 13:20:03.538199	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2931	953	2013-12-09 12:19:35.216883	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2932	954	2015-09-21 21:09:23.098554	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2933	955	2015-08-02 23:06:10.972772	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2934	956	2019-10-08 23:54:13.983336	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2935	957	2014-12-25 06:27:18.781793	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2936	958	2019-12-08 13:09:25.776818	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2937	959	2013-03-22 18:35:12.021196	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2938	960	2016-03-25 09:02:56.767206	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2940	962	2018-11-12 19:06:15.684632	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2941	963	2014-08-28 17:30:18.714533	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2942	964	2013-11-29 20:40:11.196653	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2943	965	2015-05-06 01:08:31.159086	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2944	966	2014-11-03 16:37:51.776156	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2945	967	2020-12-18 00:43:38.743356	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2946	968	2013-05-29 18:10:13.254611	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2947	969	2015-04-01 22:59:10.069097	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2948	970	2016-04-11 06:34:21.546918	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2954	976	2013-01-28 06:02:35.098608	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2955	977	2013-02-21 21:01:08.317953	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2956	978	2018-05-19 15:28:42.153687	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2957	979	2019-10-01 13:05:51.534124	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2958	980	2018-04-06 15:25:28.921561	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2959	981	2018-12-04 08:51:47.315685	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2960	982	2014-10-27 06:46:10.087026	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2961	983	2018-02-01 10:14:35.394296	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2962	984	2019-05-21 04:48:58.716508	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2963	985	2019-08-10 23:57:39.051391	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2964	986	2018-09-03 07:04:33.354409	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2965	987	2018-10-18 04:11:07.274326	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2966	988	2020-06-13 21:08:11.967899	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2967	989	2019-01-25 10:05:07.506212	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2969	991	2017-11-27 01:19:22.609191	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2970	992	2020-12-06 08:13:55.204909	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2971	993	2018-06-05 17:03:28.545787	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2972	994	2018-11-21 12:36:23.772769	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2973	995	2019-11-13 23:10:24.859481	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2974	996	2020-03-15 14:33:20.923553	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2975	997	2016-08-11 01:34:20.437114	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2976	998	2020-09-01 09:54:27.817796	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2977	999	2013-08-21 04:24:52.040028	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2978	1000	2017-08-18 17:28:28.242995	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2979	1001	2015-07-09 15:48:28.017269	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2910	932	2014-07-29 09:30:38.738703	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2911	933	2016-02-10 04:43:04.409622	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2912	934	2019-06-11 03:15:42.721091	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2913	935	2016-02-11 10:58:41.302058	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2914	936	2016-02-25 14:31:58.468929	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2915	937	2015-04-03 23:06:41.726155	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2949	971	2017-06-01 12:22:47.366421	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2950	972	2019-04-10 09:35:03.675991	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2951	973	2018-05-23 10:52:05.65515	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2952	974	2019-04-04 06:13:08.821549	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2953	975	2019-12-22 17:54:01.336132	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2093	115	2016-12-11 18:08:11.415275	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2094	116	2019-12-11 23:38:14.267111	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2095	117	2017-06-29 06:55:36.670482	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2096	118	2015-11-24 22:31:47.227023	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2097	119	2018-02-03 19:51:58.865136	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2098	120	2017-09-19 02:37:24.57113	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2099	121	2017-09-04 10:07:51.80398	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2100	122	2018-01-06 07:55:01.666494	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2101	123	2014-11-22 14:28:54.125739	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2102	124	2016-07-08 14:01:30.120731	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2103	125	2013-11-09 19:05:58.401116	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2104	126	2018-05-30 15:24:09.630057	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2105	127	2015-04-17 01:21:56.218507	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2106	128	2017-10-16 08:07:52.009653	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2107	129	2020-05-06 08:13:34.850929	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2108	130	2016-03-20 11:30:59.434683	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2109	131	2017-01-24 12:30:29.026053	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2110	132	2020-12-07 14:38:51.825907	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2111	133	2013-01-26 05:00:55.513688	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2213	235	2017-11-02 22:37:46.687177	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2214	236	2018-03-29 16:00:46.149867	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2215	237	2015-11-24 02:49:04.701855	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2216	238	2017-05-04 20:35:16.180533	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2217	239	2014-11-26 03:31:38.689878	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2239	261	2013-09-08 21:01:08.04366	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2240	262	2013-12-29 15:14:43.961589	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2241	263	2020-10-07 04:34:29.09088	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2218	240	2019-11-17 20:00:20.630675	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2219	241	2020-08-07 09:28:05.563746	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2220	242	2016-02-18 14:41:55.949003	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2221	243	2013-12-16 02:53:34.408084	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2222	244	2018-07-24 22:43:08.350765	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2223	245	2020-07-02 20:31:19.823159	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2980	1002	2013-09-30 12:36:11.336619	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2981	1003	2013-03-15 14:19:17.684757	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2982	1004	2016-11-14 04:17:35.553923	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2983	1005	2014-09-04 22:56:24.368063	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2984	1006	2016-12-25 22:59:30.08936	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2985	1007	2014-06-20 06:14:49.333108	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2986	1008	2015-09-17 03:15:29.850312	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2987	1009	2013-06-06 09:45:29.847808	7	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2988	1010	2017-05-26 06:15:37.110843	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2989	1011	2015-05-13 06:45:28.980043	4	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2990	1012	2019-11-06 11:15:34.136866	10	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2991	1013	2015-12-25 06:00:18.06855	2	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2992	1014	2019-11-17 07:48:00.449725	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2993	1015	2013-07-28 06:52:27.570346	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2995	1017	2016-09-29 19:55:11.410319	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2996	1018	2017-04-23 13:43:12.857282	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2997	1019	2014-06-26 16:23:27.809532	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2998	1020	2019-03-20 01:48:25.311785	1	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
2999	1021	2017-09-11 04:53:55.972573	8	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3031	1053	2020-01-05 02:45:00.973755	6	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3032	1054	2018-02-05 18:42:47.953179	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3033	1055	2017-09-07 10:57:02.645111	5	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3034	1056	2020-11-21 10:18:18.653999	3	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
3035	1057	2018-01-22 08:47:05.604801	9	\N	2020-12-02 13:24:53.874231	1	2020-12-02 13:24:53.874231	\N	t	1	\N	\N
\.


--
-- Data for Name: patient_ordonnances; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patient_ordonnances (id, patient_id, numero_ordonnance, date_ordonnance, observation, created, createdby, updated, updatedby, active) FROM stdin;
18	55	Ordonnance N° 2	2020-11-20 15:47:00	test	2020-11-21 16:48:24.149861	1	2020-11-21 16:48:24.149861	1	t
23	55	Ordonnance N° 4	2020-11-07 16:58:00	wxcw	2020-11-21 17:58:15.5271	1	2020-11-21 17:58:15.5271	1	t
26	55	Ordonnance N° 3	2020-11-22 11:41:00	\N	2020-11-22 12:42:17.984085	1	2020-11-22 12:42:17.984085	1	t
27	55	Ordonnance N° 4	2020-10-23 15:24:00	\N	2020-11-23 17:24:07.92325	1	2020-11-23 17:24:07.92325	1	t
28	55	Ordonnance N° 5	2020-11-14 16:28:00	\N	2020-11-23 17:28:40.636844	1	2020-11-23 17:28:40.636844	1	t
29	55	Ordonnance N° 6	2020-11-15 16:38:00	\N	2020-11-23 17:38:14.918897	1	2020-11-23 17:38:14.918897	1	t
30	55	Ordonnance N° 7	2020-11-21 16:38:00	\N	2020-11-23 17:38:56.108951	1	2020-11-23 17:38:56.108951	1	t
31	55	Ordonnance N° 8	2020-11-19 16:39:00	\N	2020-11-23 17:39:40.640054	1	2020-11-23 17:39:40.640054	1	t
33	55	Ordonnance N° 9	2020-11-14 17:02:00	\N	2020-11-23 18:03:01.152462	1	2020-11-23 18:03:01.152462	1	t
34	55	Ordonnance N° 10	2020-11-24 07:08:00	\N	2020-11-24 08:08:35.431271	1	2020-11-24 08:08:35.431271	1	t
63	47	Ordonnance N° 1	2021-01-12 16:32:00	ras	2021-01-12 17:33:18.521503	1	2021-01-12 17:33:18.521503	1	t
64	1086	Ordonnance N° 1	2021-01-28 18:18:00	\N	2021-01-28 19:18:24.186877	1	2021-01-28 19:18:24.186877	1	t
\.


--
-- Data for Name: patient_ordonnances_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patient_ordonnances_details (id, ordonnance_id, medicament_id, observation, created, createdby, updated, updatedby, active, ordonnance_posologies_id) FROM stdin;
1	15	1	sqsqs	2020-11-21 15:42:37.478051	1	2020-11-21 15:42:37.478051	1	t	\N
2	15	2	bvv	2020-11-21 15:42:37.478051	1	2020-11-21 15:42:37.478051	1	t	\N
3	16	1	sqsqs	2020-11-21 15:43:07.140999	1	2020-11-21 15:43:07.140999	1	t	\N
4	16	2	bvv	2020-11-21 15:43:07.140999	1	2020-11-21 15:43:07.140999	1	t	\N
5	17	1	sqsqs	2020-11-21 16:33:54.111575	1	2020-11-21 16:33:54.111575	1	t	\N
6	17	2	bvv	2020-11-21 16:33:54.111575	1	2020-11-21 16:33:54.111575	1	t	\N
7	18	1	à jeun	2020-11-21 16:48:24.149861	1	2020-11-21 16:48:24.149861	1	t	\N
8	18	1		2020-11-21 16:48:24.149861	1	2020-11-21 16:48:24.149861	1	t	\N
9	19	1		2020-11-21 16:49:23.839712	1	2020-11-21 16:49:23.839712	1	t	\N
10	19	2		2020-11-21 16:49:23.839712	1	2020-11-21 16:49:23.839712	1	t	\N
11	23	2	x<wx	2020-11-21 17:58:15.5271	1	2020-11-21 17:58:15.5271	1	t	\N
12	24	1	dfsf	2020-11-21 17:58:39.876741	1	2020-11-21 17:58:39.876741	1	t	\N
13	25	2	xxxxxxx	2020-11-21 17:59:01.810694	1	2020-11-21 17:59:01.810694	1	t	\N
14	26	1	test	2020-11-22 12:42:17.984085	1	2020-11-22 12:42:17.984085	1	t	\N
15	27	3	eaeaz	2020-11-23 17:24:07.92325	1	2020-11-23 17:24:07.92325	1	t	\N
16	28	4	sdfsdf	2020-11-23 17:28:40.636844	1	2020-11-23 17:28:40.636844	1	t	\N
17	29	1		2020-11-23 17:38:14.918897	1	2020-11-23 17:38:14.918897	1	t	\N
18	30	2		2020-11-23 17:38:56.108951	1	2020-11-23 17:38:56.108951	1	t	\N
19	31	2		2020-11-23 17:39:40.640054	1	2020-11-23 17:39:40.640054	1	t	\N
20	33	9	sss	2020-11-23 18:03:01.152462	1	2020-11-23 18:03:01.152462	1	t	\N
21	33	10		2020-11-23 18:03:01.152462	1	2020-11-23 18:03:01.152462	1	t	\N
22	34	2		2020-11-24 08:08:35.431271	1	2020-11-24 08:08:35.431271	1	t	\N
23	35	1		2020-12-07 19:52:49.633784	1	2020-12-07 19:52:49.633784	1	t	\N
24	35	2		2020-12-07 19:52:49.634101	1	2020-12-07 19:52:49.634101	1	t	\N
25	36	2		2020-12-13 12:53:34.1013	1	2020-12-13 12:53:34.1013	1	t	\N
26	37	2		2020-12-13 12:55:13.492962	1	2020-12-13 12:55:13.492962	1	t	\N
28	38	2		2020-12-13 12:55:52.497736	1	2020-12-13 12:55:52.497736	1	t	\N
27	38	1		2020-12-13 12:55:52.497562	1	2020-12-13 12:55:52.497562	1	t	\N
29	38	4		2020-12-13 12:55:52.497869	1	2020-12-13 12:55:52.497869	1	t	\N
30	39	4		2020-12-13 13:02:50.127069	1	2020-12-13 13:02:50.127069	1	t	\N
31	40	1		2020-12-14 09:03:29.553381	1	2020-12-14 09:03:29.553381	1	t	\N
32	41	1		2020-12-14 21:58:50.531709	1	2020-12-14 21:58:50.531709	1	t	\N
33	42	2		2020-12-17 12:07:30.384284	1	2020-12-17 12:07:30.384284	1	t	\N
34	43	12	test	2020-12-17 12:11:24.781066	1	2020-12-17 12:11:24.781066	1	t	\N
35	44	13	test2	2020-12-17 12:13:47.428305	1	2020-12-17 12:13:47.428305	1	t	\N
36	45	14	test3	2020-12-17 12:14:26.879492	1	2020-12-17 12:14:26.879492	1	t	\N
37	46	2		2020-12-17 16:09:50.169693	105	2020-12-17 16:09:50.169693	105	t	\N
38	47	1		2020-12-26 15:02:24.098716	1	2020-12-26 15:02:24.098716	1	t	\N
39	48	1		2020-12-26 15:03:24.844886	1	2020-12-26 15:03:24.844886	1	t	\N
40	49	1		2020-12-26 15:19:10.817743	1	2020-12-26 15:19:10.817743	1	t	4
41	49	2		2020-12-26 15:19:10.817947	1	2020-12-26 15:19:10.817947	1	t	3
42	50	2		2020-12-26 15:19:48.173579	1	2020-12-26 15:19:48.173579	1	t	5
43	51	15	tes	2021-01-12 12:36:49.161665	1	2021-01-12 12:36:49.161665	1	t	3
44	52	16	test	2021-01-12 12:37:23.440433	1	2021-01-12 12:37:23.440433	1	t	6
45	53	16		2021-01-12 12:38:11.757564	1	2021-01-12 12:38:11.757564	1	t	6
46	54	17		2021-01-12 12:38:42.743468	1	2021-01-12 12:38:42.743468	1	t	6
47	55	18		2021-01-12 12:39:27.547592	1	2021-01-12 12:39:27.547592	1	t	6
48	56	18		2021-01-12 12:39:45.908314	1	2021-01-12 12:39:45.908314	1	t	7
49	57	17	fezfzefz	2021-01-12 12:39:57.71463	1	2021-01-12 12:39:57.71463	1	t	4
50	58	18	dfsf	2021-01-12 12:40:18.04039	1	2021-01-12 12:40:18.04039	1	t	7
51	58	16	zeze	2021-01-12 12:40:18.040916	1	2021-01-12 12:40:18.040916	1	t	4
52	59	19		2021-01-12 12:41:34.683387	1	2021-01-12 12:41:34.683387	1	t	8
53	60	1		2021-01-12 12:42:15.360404	1	2021-01-12 12:42:15.360404	1	t	2
54	61	20	tst	2021-01-12 12:42:46.982824	1	2021-01-12 12:42:46.982824	1	t	9
55	62	2	test	2021-01-12 12:49:35.145175	1	2021-01-12 12:49:35.145175	1	t	2
56	63	1	(2 boites)	2021-01-12 17:33:18.566141	1	2021-01-12 17:33:18.566141	1	t	1
57	63	2	(3 boites)	2021-01-12 17:33:18.567031	1	2021-01-12 17:33:18.567031	1	t	3
58	64	11	test	2021-01-28 19:18:24.188783	1	2021-01-28 19:18:24.188783	1	t	1
\.


--
-- Data for Name: patient_pathologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patient_pathologies (id, patient_id, pathologie_id, gravite, explicatif, created, createdby, updated, updatedby, active, severite_id) FROM stdin;
70	55	398	\N	pppp	2020-11-23 14:51:54.884878	1	2020-11-23 14:51:54.884878	1	t	8
71	55	4	\N	WDFSF	2020-11-25 14:50:13.05799	1	2020-11-25 14:50:13.05799	1	t	2
72	55	4	\N	\N	2020-11-25 14:50:13.886368	1	2020-11-25 14:50:13.886368	1	t	2
73	55	16	\N	\N	2020-11-25 14:50:17.395885	1	2020-11-25 14:50:17.395885	1	t	2
75	1048	3	\N	\N	2020-12-07 18:51:18.291657	1	2020-12-07 18:51:18.291657	1	t	2
76	1048	3	\N	\N	2020-12-07 18:54:57.589017	1	2020-12-07 18:54:57.589017	1	t	2
77	50	5	\N	\N	2020-12-07 18:56:58.965022	1	2020-12-07 18:56:58.965022	1	t	3
78	49	5	\N	\N	2020-12-07 18:58:06.198379	1	2020-12-07 18:58:06.198379	1	t	3
80	48	3	\N	\N	2020-12-08 11:10:00.9087	1	2020-12-08 11:10:00.9087	1	t	2
82	47	\N	\N	\N	2020-12-13 12:41:14.478114	1	2020-12-13 12:41:14.478114	1	t	\N
91	143	6	\N	Bla bla	2020-12-17 16:02:50.384043	105	2020-12-17 16:02:50.384043	105	t	2
96	47	6	\N	\N	2021-01-12 12:30:04.583594	1	2021-01-12 12:30:04.583594	1	t	\N
97	47	13	\N	\N	2021-01-12 12:32:26.018718	1	2021-01-12 12:32:26.018718	1	t	\N
98	47	7	\N	dsd	2021-01-12 12:32:32.593627	1	2021-01-12 12:32:32.593627	1	t	\N
99	1086	1	\N	test	2021-01-28 19:13:00.056489	1	2021-01-28 19:13:00.056489	1	t	1
\.


--
-- Data for Name: patient_radiographies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patient_radiographies (id, patient_id, radiographie_id, gravite, explicatif, created, createdby, updated, updatedby, active, file_name) FROM stdin;
46	1047	1	\N	\N	2020-11-16 19:36:31.542635	1	2020-11-16 19:36:31.542635	1	t	radio_1047_1_16_10_2020_19_36_31.
51	55	3	\N	a	2020-11-16 19:45:24.870041	1	2020-11-16 19:45:24.870041	1	t	radio_55_3_16_10_2020_19_45_24.jfif
52	55	1	\N	b	2020-11-16 19:45:31.869802	1	2020-11-16 19:45:31.869802	1	t	
55	56	3	\N	\N	2020-11-16 21:04:28.399259	1	2020-11-16 21:04:28.399259	1	t	radio_56_3_16_10_2020_21_4_28.png
56	56	1	\N	\N	2020-11-16 21:04:34.568632	1	2020-11-16 21:04:34.568632	1	t	
57	1049	3	\N	\N	2020-11-19 19:49:32.247135	1	2020-11-19 19:49:32.247135	1	t	radio_1049_3_19_10_2020_19_49_32.jfif
59	55	21	\N	dsqdqs	2020-11-23 13:46:41.556157	1	2020-11-23 13:46:41.556157	1	t	
60	55	22	\N	oooooo	2020-11-23 13:47:36.042944	1	2020-11-23 13:47:36.042944	1	t	
61	55	\N	\N	nn	2020-11-23 13:48:00.909617	1	2020-11-23 13:48:00.909617	1	t	
62	55	25	\N	llllll	2020-11-23 14:53:35.694034	1	2020-11-23 14:53:35.694034	1	t	radio_55_25_23_10_2020_14_53_35.jfif
63	52	1	\N	test	2020-12-07 18:47:37.05225	1	2020-12-07 18:47:37.05225	1	t	
64	50	3	\N	\N	2020-12-07 19:01:29.090555	1	2020-12-07 19:01:29.090555	1	t	
67	48	2	\N	\N	2020-12-08 12:09:21.714768	1	2020-12-08 12:09:21.714768	1	t	
71	47	1	\N	\N	2020-12-12 21:51:35.54642	1	2020-12-12 21:51:35.54642	1	t	radio_47_1_12_11_2020_21_51_35.jfif
72	47	1	\N	\N	2020-12-12 21:51:39.727982	1	2020-12-12 21:51:39.727982	1	t	radio_47_1_12_11_2020_21_51_39.jfif
73	47	\N	\N	\N	2020-12-13 12:45:44.093503	1	2020-12-13 12:45:44.093503	1	t	
74	47	1	\N	\N	2020-12-13 12:45:49.247248	1	2020-12-13 12:45:49.247248	1	t	
75	47	3	\N	\N	2020-12-17 14:15:03.549668	105	2020-12-17 14:15:03.549668	105	t	
76	1086	3	\N	test	2021-01-28 19:17:45.289777	1	2021-01-28 19:17:45.289777	1	t	radio_1086_3_28_0_2021_19_17_45.png
\.


--
-- Data for Name: patient_rdvs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patient_rdvs (id, patient_id, etat_id, title, color, startsat, endsat, draggable, resizable, created, createdby, updated, updatedby, active, motif_id, reminder_sent) FROM stdin;
259	\N	4	xxxxxxx Hicham : Extraction	{"primary":"#CE3491","secondary":"#CE3491"}	2021-01-22 19:50:00	2021-01-22 20:20:00	t	t	2021-01-22 19:21:38.22234	1	2021-01-22 19:21:38.22234	1	t	1	f
260	\N	4	xxxxxxx Hicham : Extraction	{"primary":"#C47956","secondary":"#C47956"}	2021-01-22 19:40:00	2021-01-22 20:10:00	t	t	2021-01-22 19:21:56.629761	1	2021-01-22 19:21:56.629761	1	t	1	f
261	\N	2	xxxxxxx Hicham : Extraction	{"primary":"#285D6E","secondary":"#285D6E"}	2021-01-22 20:40:00	2021-01-22 21:10:00	t	t	2021-01-22 19:22:17.113016	1	2021-01-22 19:22:17.113016	1	t	1	f
266	\N	4	xxxxxxx Hicham : Extraction	{"primary":"#03CAF3","secondary":"#03CAF3"}	2021-01-22 21:20:00	2021-01-22 21:50:00	t	t	2021-01-22 19:23:22.638419	1	2021-01-22 19:23:22.638419	1	t	1	f
271	47	2	Guermis Aida : Soins	{"primary":"#B30606","secondary":"#B30606"}	2021-01-23 13:40:00	2021-01-23 14:10:00	t	t	2021-01-23 12:47:43.535767	1	2021-01-23 12:47:43.535767	1	t	2	f
262	\N	4	xxxxxxx Hicham : Extraction	{"primary":"#03CAF3","secondary":"#03CAF3"}	2021-01-22 21:20:00	2021-01-22 21:50:00	t	t	2021-01-22 19:23:22.432741	1	2021-01-22 19:23:22.432741	1	t	1	f
268	1079	2	Vvvvvv Vvvvvvvvv : Soins	{"primary":"#6976AB","secondary":"#6976AB"}	2021-01-22 21:20:00	2021-01-22 21:50:00	t	t	2021-01-22 19:31:11.068775	1	2021-01-22 19:31:11.068775	1	t	2	f
272	50	2	Sadeg Mohammed Elamine : Soins	{"primary":"#2313B5","secondary":"#2313B5"}	2021-01-23 20:40:00	2021-01-23 21:10:00	t	t	2021-01-23 18:52:26.896668	1	2021-01-23 18:52:26.896668	1	t	2	f
225	48	2	Bellefaa Yamina : Soins	{"primary":"#CC9394","secondary":"#CC9394"}	\N	\N	t	t	2020-12-12 21:09:12.089749	1	2020-12-17 14:26:07.546027	1	t	2	f
263	\N	4	xxxxxxx Hicham : Extraction	{"primary":"#03CAF3","secondary":"#03CAF3"}	2021-01-22 21:20:00	2021-01-22 21:50:00	t	t	2021-01-22 19:23:22.433055	1	2021-01-22 19:23:22.433055	1	t	1	f
269	1080	2	Dvdvdvdvd Dvdvdvdvd : Soins	{"primary":"#78FD37","secondary":"#78FD37"}	2021-01-22 21:10:00	2021-01-22 21:40:00	t	t	2021-01-22 19:31:33.670583	1	2021-01-22 19:31:33.670583	1	t	2	f
264	\N	4	xxxxxxx Hicham : Extraction	{"primary":"#03CAF3","secondary":"#03CAF3"}	2021-01-22 21:20:00	2021-01-22 21:50:00	t	t	2021-01-22 19:23:22.567331	1	2021-01-22 19:23:22.567331	1	t	1	f
270	1083	2	Wwwww Wwww : Extraction	{"primary":"#0A58BF","secondary":"#0A58BF"}	2021-01-22 22:10:00	2021-01-22 22:40:00	t	t	2021-01-22 20:13:18.670583	1	2021-01-22 20:13:18.670583	1	t	1	f
265	\N	4	xxxxxxx Hicham : Extraction	{"primary":"#03CAF3","secondary":"#03CAF3"}	2021-01-22 21:20:00	2021-01-22 21:50:00	t	t	2021-01-22 19:23:22.570858	1	2021-01-22 19:23:22.570858	1	t	1	f
267	1076	4	Xxxxxxx Hicham : AUTRES	{"primary":"#D336B7","secondary":"#D336B7"}	2021-01-22 21:10:00	2021-01-22 21:40:00	t	t	2021-01-22 19:25:21.781665	1	2021-01-28 19:10:20.417973	1	t	4	t
273	1086	4	Xxxxxjellouli Hicham : Soins	{"primary":"#A2E1D4","secondary":"#A2E1D4"}	2021-01-04 07:00:00	2021-01-04 07:30:00	t	t	2021-01-28 19:19:00.647474	1	2021-01-28 19:19:00.647474	1	t	2	f
239	47	3	Guermis Aida : Extraction	{"primary":"#0505EC","secondary":"#0505EC"}	2021-12-16 02:00:00	2020-12-16 02:30:00	t	t	2020-12-16 11:31:32.744996	1	2020-12-16 13:53:06.210791	1	t	1	t
240	50	3	Sadeg Mohammed Elamine : Extraction	{"primary":"#FFFED9","secondary":"#FFFED9"}	2021-12-16 11:30:00	2020-12-16 12:00:00	t	t	2020-12-16 11:31:39.109013	1	2020-12-16 13:53:19.153921	1	t	1	t
215	66	5	Bouyaci Leila : Consultation	{"primary":"#727161","secondary":"#727161"}	2021-12-03 10:00:00	2020-12-03 10:30:00	t	t	2020-12-03 09:32:27.435553	1	2020-12-16 13:53:34.312081	1	t	3	f
222	47	0	Guermi Aida : Consultation	{"primary":"#CF0E7A","secondary":"#CF0E7A"}	2021-12-07 19:10:00	2020-12-07 19:40:00	t	t	2020-12-07 21:23:30.932747	1	2020-12-07 21:23:43.847522	1	t	3	f
229	48	4	Bellefaa Yamina : Consultation	{"primary":"#361382","secondary":"#361382"}	2021-12-08 07:00:00	2020-12-08 07:30:00	t	t	2020-12-13 18:41:51.994353	1	2020-12-13 18:41:51.994353	1	t	3	f
235	48	3	Bellefaa Yamina : Extraction	{"primary":"#389CB1","secondary":"#389CB1"}	2021-12-15 10:00:00	2020-12-15 10:30:00	t	t	2020-12-14 21:56:18.400484	1	2020-12-15 19:59:10.770314	1	t	1	f
253	119	5	Bellima Adel : Consultation	{"primary":"#B2810F","secondary":"#B2810F"}	2021-12-31 03:30:00	2020-12-31 04:00:00	t	t	2020-12-17 11:18:21.590563	1	2020-12-17 15:19:58.65687	105	t	3	f
248	106	4	Bessai Sofiane : Soins	{"primary":"#AB356E","secondary":"#AB356E"}	2021-12-18 09:50:00	2020-12-18 10:20:00	t	t	2020-12-17 08:37:02.129954	1	2020-12-17 16:14:47.601519	105	t	2	t
200	55	1	Kateb Rezka : Soins	{"primary":"#905343","secondary":"#905343"}	2021-11-27 23:30:00	2020-11-28 00:00:00	t	t	2020-11-28 00:54:52.289617	1	2020-11-28 02:55:50.411758	1	t	2	f
152	1053	1	Djellouli Hicham : Extraction	{"primary":"#EFA3D5","secondary":"#EFA3D5"}	2021-11-27 16:40:00	2020-11-27 17:10:00	t	t	2020-11-27 22:09:06.611779	1	2020-11-28 10:52:16.555652	1	t	1	f
122	57	3	Boumous Noureddine : Soins	{"primary":"#4A6007","secondary":"#4A6007"}	2021-11-26 04:00:00	2020-11-26 04:30:00	t	t	2020-11-26 21:52:59.662151	1	2020-11-27 23:12:55.956595	1	t	2	f
121	57	5	Boumous Noureddine : Soins	\N	2021-11-26 07:00:00	2020-11-26 07:30:00	t	t	2020-11-26 21:52:47.766592	1	2020-11-27 23:17:02.786876	1	t	2	f
210	1047	1	Aaaaa Bbbb : Soins	\N	2021-11-29 05:00:00	2020-11-29 07:35:33.195	t	t	2020-11-29 09:36:01.131295	1	2020-12-03 09:16:48.483095	1	t	2	f
206	1048	1	Ax Ax : Soins	{"primary":"#308868","secondary":"#308868"}	2021-11-28 12:50:47.998	2020-11-28 13:20:47.998	t	t	2020-11-28 13:57:07.241796	1	2020-12-07 12:12:41.324862	1	t	2	f
147	1047	2	Aaaaa Bbbb : Soins	{"primary":"#0025A6","secondary":"#0025A6"}	2021-12-04 07:00:00	2020-12-04 07:30:00	t	t	2020-11-27 18:35:42.917888	1	2020-11-27 18:35:42.917888	1	t	2	f
82	1047	4	Aaaaa Bbbb : Extraction	{"primary":"#1EA19C","secondary":"#1EA19C"}	2021-01-13 06:00:00	2020-11-13 06:30:00	t	t	2020-11-25 14:32:55.332079	1	2020-11-27 23:10:58.713097	1	t	1	f
88	57	2	Boumous Noureddine : Soins	{"primary":"#F76F31","secondary":"#F76F31"}	2021-02-10 07:00:00	2020-11-10 07:30:00	t	t	2020-11-25 14:47:18.453828	1	2020-11-25 14:47:18.453828	1	t	2	f
199	55	5	Kateb Rezka : Soins	{"primary":"#D58E07","secondary":"#D58E07"}	2021-11-27 23:30:00	2020-11-28 00:00:00	t	t	2020-11-28 00:51:58.921529	1	2020-11-28 00:55:36.411771	1	t	2	f
117	86	1	Boumesla Ghezala : Consultation	{"primary":"#D662B9","secondary":"#D662B9"}	2021-11-26 02:12:23.999	2020-11-26 02:57:35.624	t	t	2020-11-26 12:53:53.062947	1	2020-12-03 09:33:03.82324	1	t	3	f
112	1048	1	Ax Ax : Soins	{"primary":"#BA7F10","secondary":"#BA7F10"}	2021-11-25 23:41:23.994	2020-11-26 00:56:23.994	t	t	2020-11-26 12:52:18.233002	1	2020-12-03 09:34:27.333854	1	t	2	f
95	59	2	Bakriti Madjid : Soins	{"primary":"#CB5D7B","secondary":"#CB5D7B"}	2021-11-05 12:00:00	2020-11-05 12:30:00	t	t	2020-11-25 14:59:14.60821	1	2020-11-25 14:59:14.60821	1	t	2	f
96	59	2	Bakriti Madjid : Soins	{"primary":"#B9CE13","secondary":"#B9CE13"}	2021-11-05 11:00:00	2020-11-05 11:30:00	t	t	2020-11-25 14:59:51.254428	1	2020-11-25 14:59:51.254428	1	t	2	f
120	83	5	Benaissa Abdelkader : Consultation	{"primary":"#6A52BE","secondary":"#6A52BE"}	2021-11-26 05:32:35.997	2020-11-26 06:02:35.997	t	t	2020-11-26 12:54:15.376629	1	2020-11-27 23:12:22.635877	1	t	3	f
241	61	4	Messaoud Ammar : Extraction	{"primary":"#275B14","secondary":"#275B14"}	2021-12-16 13:00:00	2020-12-16 13:30:00	t	t	2020-12-16 11:31:44.094744	1	2020-12-16 13:50:18.195575	1	t	1	t
255	48	2	Bellefaa Yamina : Consultation	{"primary":"#36049C","secondary":"#36049C"}	2021-12-17 12:23:12.727	2020-12-17 12:53:12.727	t	t	2020-12-17 14:40:01.348288	1	2020-12-17 15:19:56.888076	105	t	3	f
254	47	3	Guermis Aida : Consultation	{"primary":"#36E79B","secondary":"#36E79B"}	2021-12-17 08:00:00	2020-12-17 08:30:00	t	t	2020-12-17 14:26:37.681394	1	2020-12-17 16:12:25.049329	105	t	3	f
249	49	4	Setti Abdelhakim : Soins	{"primary":"#D9DC87","secondary":"#D9DC87"}	2021-12-18 06:00:00	2020-12-18 06:30:00	t	t	2020-12-17 08:38:03.779758	1	2020-12-17 16:14:45.586491	105	t	2	t
236	47	2	Guermis Aida : Consultation	{"primary":"#E6180D","secondary":"#E6180D"}	2021-12-15 09:15:00	2020-12-15 09:45:00	t	t	2020-12-15 19:22:51.236538	1	2020-12-15 20:00:15.921107	1	t	3	f
230	65	4	Loucif Mohammed Amin : Soins	{"primary":"#380EEB","secondary":"#380EEB"}	2021-12-14 09:00:00	2020-12-14 09:30:00	t	t	2020-12-14 16:38:45.099498	1	2020-12-16 11:54:41.969427	1	t	2	f
231	69	4	Allouche Raouf : Soins	{"primary":"#C92C92","secondary":"#C92C92"}	2021-12-14 07:00:00	2020-12-14 07:30:00	t	t	2020-12-14 16:38:51.134986	1	2020-12-16 11:54:43.013897	1	t	2	f
223	48	5	Bellefaa Yamina : Soins	{"primary":"#29F645","secondary":"#29F645"}	2021-12-12 19:01:35.998	2020-12-12 19:31:35.998	t	t	2020-12-12 21:08:31.195203	1	2020-12-26 22:03:14.405312	1	t	2	f
201	55	2	Kateb Rezka : Extraction	{"primary":"#582DFD","secondary":"#582DFD"}	2021-11-26 23:54:31.999	2020-11-27 01:17:36	t	t	2020-11-28 01:07:01.261487	1	2020-11-28 01:19:07.210827	1	t	1	f
91	59	0	Bakriti Madjid : Soins	{"primary":"#5AF507","secondary":"#5AF507"}	2021-11-14 06:00:00	2020-11-14 08:30:00	t	t	2020-11-25 14:58:49.957983	1	2020-11-27 23:10:34.497624	1	t	2	f
194	61	0	Messaoud Ammar : Extraction	{"primary":"#88C4CF","secondary":"#88C4CF"}	2021-11-27 23:30:00	2020-11-28 00:00:00	t	t	2020-11-28 00:50:24.94598	1	2020-11-28 00:52:07.397938	1	t	1	f
211	55	1	Kateb Rezka : Soins	{"primary":"#46D1A5","secondary":"#46D1A5"}	2021-12-03 07:30:00	2020-12-03 08:00:00	t	t	2020-12-03 08:38:32.052046	1	2020-12-03 10:40:22.775984	1	t	2	f
207	55	0	Kateb Rezka : Soins	{"primary":"#909719","secondary":"#909719"}	2021-11-28 16:20:00	2020-11-28 16:50:00	t	t	2020-11-28 14:35:02.982171	1	2020-12-03 09:19:46.31744	1	t	2	f
92	59	1	Bakriti Madjid : Soins	{"primary":"#308D44","secondary":"#308D44"}	2021-12-02 05:00:00	2020-12-02 05:30:00	t	t	2020-11-25 14:58:55.012476	1	2020-12-03 09:32:55.485587	1	t	2	f
171	1054	1	Oooooooooooooooo Hicham : Extraction	{"primary":"#8A79AE","secondary":"#8A79AE"}	2021-11-27 17:40:00	2020-11-27 18:10:00	t	t	2020-11-27 18:53:36.795813	1	2020-12-03 09:33:01.037432	1	t	1	f
170	1054	1	Oooooooooooooooo Hicham : Extraction	{"primary":"#8D320A","secondary":"#8D320A"}	2021-11-27 18:40:00	2020-11-27 19:10:00	t	t	2020-11-27 18:52:41.422778	1	2020-12-03 10:08:44.344906	1	t	1	f
123	1048	2	Ax Ax : Consultation	{"primary":"#FF85EC","secondary":"#FF85EC"}	2021-11-26 07:15:00	2020-11-26 07:45:00	t	t	2020-11-26 21:53:37.073922	1	2020-11-26 21:53:37.073922	1	t	3	f
157	69	5	Allouche Raouf : Soins	{"primary":"#7E0759","secondary":"#7E0759"}	2021-11-27 19:57:43.998	2020-11-27 23:04:35.999	t	t	2020-11-27 22:15:33.085324	1	2020-11-27 22:40:39.056334	1	t	2	f
153	1054	5	Oooooooooooooooo Hicham : Soins	{"primary":"#AFE27B","secondary":"#AFE27B"}	2021-11-27 18:48:19.997	2020-11-27 19:53:15.499	t	t	2020-11-27 22:10:20.32373	1	2020-11-27 22:41:42.803873	1	t	2	f
89	57	2	Boumous Noureddine : AUTRE	{"primary":"#96FC7A","secondary":"#96FC7A"}	2021-03-13 06:00:00	2020-11-13 06:30:00	t	t	2020-11-25 14:47:34.026731	1	2020-11-27 23:10:41.799789	1	t	4	f
209	1047	1	Aaaaa Bbbb : Soins	{"primary":"#08218A","secondary":"#08218A"}	2021-11-28 19:00:00	2020-11-28 19:30:00	t	t	2020-11-28 20:40:30.537318	1	2020-12-07 12:10:19.027057	1	t	2	f
177	70	4	Krimi Mehdi : Soins	{"primary":"#29F2F9","secondary":"#29F2F9"}	2021-11-27 19:20:00	2020-11-27 19:50:00	t	t	2020-11-27 18:56:32.732464	1	2020-11-27 18:56:32.732464	1	t	2	f
90	59	2	Bakriti Madjid : Soins	{"primary":"#B8B114","secondary":"#B8B114"}	2021-11-09 07:00:00	2020-11-09 07:30:00	t	t	2020-11-25 14:58:45.78801	1	2020-11-25 14:58:45.78801	1	t	2	f
100	56	3	Khelfi Louiza : Consultation	{"primary":"#C9A6BB","secondary":"#C9A6BB"}	2021-11-13 06:00:00	2020-11-13 07:30:00	t	t	2020-11-25 15:06:57.218106	1	2020-11-27 23:11:02.914701	1	t	3	f
250	48	4	Bellefaa Yamina : Consultation	{"primary":"#D0E022","secondary":"#D0E022"}	2021-12-19 07:00:00	2020-12-19 07:30:00	t	t	2020-12-17 08:42:35.345668	1	2020-12-17 08:42:35.345668	1	t	3	f
257	49	4	Setti Abdelhakim : Soins	{"primary":"#2499C5","secondary":"#2499C5"}	2021-12-17 16:40:00	2020-12-17 17:10:00	t	t	2020-12-17 15:20:12.769807	105	2020-12-17 15:20:12.769807	105	t	2	f
256	47	4	Guermis Aida : Soins	{"primary":"#420D6C","secondary":"#420D6C"}	2021-12-18 07:58:18.182	2020-12-18 08:30:00	t	t	2020-12-17 15:17:47.556735	105	2020-12-17 16:14:45.080857	105	t	2	t
220	47	2	Guermi Aida : Soins	{"primary":"#5B6991","secondary":"#5B6991"}	2021-12-07 05:00:00	2020-12-07 05:30:00	t	t	2020-12-07 21:13:08.022428	1	2020-12-07 21:23:42.014643	1	t	2	f
224	48	3	Bellefaa Yamina : Soins	{"primary":"#1407C9","secondary":"#1407C9"}	2021-12-12 22:20:00	2020-12-12 22:50:00	t	t	2020-12-12 21:09:05.893809	1	2020-12-12 21:09:05.893809	1	t	2	f
195	63	2	Ziane Cherif Zoubida : Extraction	{"primary":"#1DC6C4","secondary":"#1DC6C4"}	2021-11-27 22:20:00	2020-11-27 22:50:00	t	t	2020-11-28 00:50:35.051574	1	2020-11-28 14:43:51.172222	1	t	1	f
198	83	2	Benaissa Abdelkader : Extraction	{"primary":"#03226F","secondary":"#03226F"}	2021-11-27 22:40:00	2020-11-27 23:10:00	t	t	2020-11-28 00:51:06.222908	1	2020-11-28 14:43:52.614935	1	t	1	f
172	1048	3	Ax Ax : Soins	{"primary":"#5BE196","secondary":"#5BE196"}	2021-11-27 18:20:00	2020-11-27 18:50:00	t	t	2020-11-27 18:53:49.46139	1	2020-11-27 18:53:49.46139	1	t	2	f
173	1048	3	Ax Ax : Soins	{"primary":"#5BE196","secondary":"#5BE196"}	2021-11-27 18:20:00	2020-11-27 18:50:00	t	t	2020-11-27 18:54:53.31895	1	2020-11-27 18:54:53.31895	1	t	2	f
221	47	2	Guermi Aida : Consultation	{"primary":"#F94D2E","secondary":"#F94D2E"}	2021-12-09 05:00:00	2020-12-09 05:30:00	t	t	2020-12-07 21:13:51.666782	1	2020-12-16 13:53:11.406833	1	t	3	t
251	49	0	Setti Abdelhakim : Consultation	{"primary":"#00E0C0","secondary":"#00E0C0"}	2021-12-17 09:30:00	2020-12-17 10:00:00	t	t	2020-12-17 11:15:24.468746	1	2020-12-17 15:18:36.893821	105	t	3	f
228	48	2	Bellefaa Yamina : Soins	{"primary":"#417734","secondary":"#417734"}	2021-12-13 18:10:00	2020-12-13 18:40:00	t	t	2020-12-13 18:39:17.17847	1	2020-12-13 18:39:17.17847	1	t	2	f
227	48	5	Bellefaa Yamina : Soins	{"primary":"#417734","secondary":"#417734"}	2021-12-13 17:10:00	2020-12-13 17:40:00	t	t	2020-12-13 18:39:12.571727	1	2020-12-13 21:28:50.954949	1	t	2	f
234	1071	1	Djellouli Aek : Consultation	{"primary":"#84A45D","secondary":"#84A45D"}	2021-12-15 06:45:00	2020-12-15 05:45:00	t	t	2020-12-14 21:43:30.466001	1	2020-12-15 20:00:23.401905	1	t	3	f
233	1072	0	Djellouli Nawel : Extraction	{"primary":"#6A25CC","secondary":"#6A25CC"}	2021-12-15 06:15:00	2020-12-15 06:45:00	t	t	2020-12-14 21:43:16.50879	1	2020-12-15 20:00:33.101846	1	t	1	f
214	60	2	Mestar Mokhtar : Consultation	{"primary":"#A52CFB","secondary":"#A52CFB"}	2021-12-03 10:10:00	2020-12-03 10:40:00	t	t	2020-12-03 09:32:04.435582	1	2020-12-17 15:18:40.309472	105	t	3	f
258	47	4	Guermis Aida : Consultation	{"primary":"#D63BA1","secondary":"#D63BA1"}	2021-12-19 13:15:00	2020-12-19 14:00:00	t	t	2020-12-17 16:11:30.536686	105	2020-12-17 16:11:30.536686	105	t	3	f
212	1053	1	Djellouli Hicham : Extraction	{"primary":"#377202","secondary":"#377202"}	2021-12-10 04:00:00	2020-12-10 04:30:00	t	t	2020-12-03 09:30:51.222512	1	2020-12-17 16:12:37.740445	105	t	1	f
226	49	0	Setti Abdelhakim : Soins	{"primary":"#14B7D5","secondary":"#14B7D5"}	2021-12-12 21:00:00	2020-12-12 21:30:00	t	t	2020-12-12 21:09:22.002871	1	2020-12-26 22:04:30.07217	1	t	2	f
232	49	4	Setti Abdelhakim : Soins	{"primary":"#A81FEB","secondary":"#A81FEB"}	2021-12-14 07:45:00	2020-12-14 08:15:00	t	t	2020-12-14 18:39:53.866354	1	2020-12-16 11:54:42.499797	1	t	2	f
208	1047	2	Aaaaa Bbbb : Soins	{"primary":"#CC7C9C","secondary":"#CC7C9C"}	2021-11-18 07:00:00	2020-11-18 07:30:00	t	t	2020-11-28 15:30:01.258548	1	2020-11-28 15:30:01.258548	1	t	2	f
174	1048	3	Ax Ax : Soins	{"primary":"#5BE196","secondary":"#5BE196"}	2021-11-27 18:20:00	2020-11-27 18:50:00	t	t	2020-11-27 18:54:54.908723	1	2020-11-27 18:54:54.908723	1	t	2	f
175	1048	3	Ax Ax : Soins	{"primary":"#5BE196","secondary":"#5BE196"}	2021-11-27 18:20:00	2020-11-27 18:50:00	t	t	2020-11-27 18:54:55.467289	1	2020-11-27 18:54:55.467289	1	t	2	f
202	1048	1	Ax Ax : Soins	{"primary":"#22279E","secondary":"#22279E"}	2021-11-28 09:27:55.999	2020-11-28 09:59:20	t	t	2020-11-28 10:49:51.862785	1	2020-12-03 09:19:11.153381	1	t	2	f
176	1048	3	Ax Ax : Soins	{"primary":"#5BE196","secondary":"#5BE196"}	2021-11-27 18:20:00	2020-11-27 18:50:00	t	t	2020-11-27 18:54:55.693315	1	2020-11-27 18:54:55.693315	1	t	2	f
196	78	5	Ouis Mohammed : Extraction	{"primary":"#D595B4","secondary":"#D595B4"}	2021-11-27 23:10:00	2020-11-27 23:40:00	t	t	2020-11-28 00:50:48.010514	1	2020-11-28 00:51:32.176473	1	t	1	f
237	47	4	Guermis Aida : Soins	{"primary":"#FFE285","secondary":"#FFE285"}	2021-12-15 18:36:24	2020-12-15 20:48:00	t	t	2020-12-15 19:36:31.031289	1	2020-12-15 19:37:16.567959	1	t	2	f
197	81	5	Mekeddem Soumia : Extraction	{"primary":"#CFBF7F","secondary":"#CFBF7F"}	2021-11-27 23:00:00	2020-11-27 23:30:00	t	t	2020-11-28 00:50:52.708147	1	2020-11-28 00:54:09.160217	1	t	1	f
203	1048	3	Ax Ax : Soins	{"primary":"#28E29C","secondary":"#28E29C"}	2021-11-28 11:08:39.998	2020-11-28 11:38:39.998	t	t	2020-11-28 10:50:01.114054	1	2020-11-28 10:50:29.151844	1	t	2	f
204	1048	4	Ax Ax : Soins	{"primary":"#30F4CD","secondary":"#30F4CD"}	2021-11-28 10:48:32	2020-11-28 11:18:32	t	t	2020-11-28 10:50:06.737821	1	2020-11-28 10:50:31.235359	1	t	2	f
99	56	2	Khelfi Louiza : Consultation	\N	2021-11-25 07:00:00	2020-11-25 15:06:30.239	t	t	2020-11-25 15:06:46.50549	1	2020-11-25 15:06:46.50549	1	t	3	f
205	69	2	Allouche Raouf : Soins	{"primary":"#9D2D5B","secondary":"#9D2D5B"}	2021-11-28 12:10:00	2020-11-28 12:40:00	t	t	2020-11-28 10:51:48.693794	1	2020-11-28 10:51:48.693794	1	t	2	f
105	1047	2	Aaaaa Bbbb : Consultation	{"primary":"#41D935","secondary":"#41D935"}	2021-11-23 09:00:00	2020-11-23 09:30:00	t	t	2020-11-25 17:23:29.852009	1	2020-11-25 17:23:29.852009	1	t	3	f
115	87	2	Bendaoud Djamila : AUTRE	{"primary":"#51E5EE","secondary":"#51E5EE"}	2021-11-26 01:26:59.994	2020-11-26 01:56:59.994	t	t	2020-11-26 12:53:31.208775	1	2020-11-28 14:44:16.144057	1	t	4	f
110	56	2	Khelfi Louiza : Consultation	{"primary":"#8119E4","secondary":"#8119E4"}	2021-11-26 07:30:11.997	2020-11-26 08:36:35.997	t	t	2020-11-26 12:00:17.624541	1	2020-11-26 21:14:19.869833	1	t	3	f
114	78	4	Ouis Mohammed : Soins	{"primary":"#092EB1","secondary":"#092EB1"}	2021-11-26 03:26:47.988	2020-11-26 05:22:23.614	t	t	2020-11-26 12:52:45.126661	1	2020-11-27 23:11:59.838697	1	t	2	f
104	56	1	Khelfi Louiza : AUTRE	{"primary":"#C8C5D1","secondary":"#C8C5D1"}	2021-11-28 11:43:50.4	2020-11-28 12:13:50.4	t	t	2020-11-25 17:19:59.034223	1	2020-12-03 09:20:40.545327	1	t	4	f
93	59	5	Bakriti Madjid : Soins	{"primary":"#0542B8","secondary":"#0542B8"}	2021-11-16 06:00:00	2020-11-16 06:30:00	t	t	2020-11-25 14:59:03.405356	1	2020-11-27 23:10:28.660749	1	t	2	f
238	47	3	Guermis Aida : Consultation	{"primary":"#849e3d","secondary":"#3E7E9E"}	2021-12-15 13:10:00	2020-12-15 13:40:00	t	t	2020-12-15 20:01:34.654513	1	2020-12-15 20:01:34.654513	1	t	3	f
94	59	2	Bakriti Madjid : Soins	{"primary":"#10A3D3","secondary":"#10A3D3"}	2021-11-05 07:00:00	2020-11-05 07:30:00	t	t	2020-11-25 14:59:06.633672	1	2020-11-25 14:59:06.633672	1	t	2	f
97	59	2	Bakriti Madjid : Soins	{"primary":"#4B7DD1","secondary":"#4B7DD1"}	2021-11-05 12:00:00	2020-11-05 12:30:00	t	t	2020-11-25 14:59:56.556074	1	2020-11-25 14:59:56.556074	1	t	2	f
244	74	5	Bahloul Salima : Soins	{"primary":"#1E5A18","secondary":"#1E5A18"}	2021-12-18 09:00:00	2020-12-18 09:30:00	t	t	2020-12-16 13:11:00.493622	1	2020-12-16 13:11:00.493622	1	t	2	f
242	49	5	Setti Abdelhakim : Soins	{"primary":"#5A5068","secondary":"#5A5068"}	2021-12-17 08:00:00	2020-12-17 08:30:00	t	t	2020-12-16 12:21:08.725904	1	2020-12-16 13:53:31.629336	1	t	2	t
245	92	5	Mezioud Mohamed : Soins	{"primary":"#B5869B","secondary":"#B5869B"}	2021-12-17 05:00:00	2020-12-17 05:30:00	t	t	2020-12-16 13:11:14.199959	1	2020-12-17 15:18:43.109283	105	t	2	t
252	48	5	Bellefaa Yamina : Consultation	{"primary":"#D27A61","secondary":"#D27A61"}	2021-12-17 10:20:00	2020-12-17 10:50:00	t	t	2020-12-17 11:16:44.619438	1	2020-12-17 16:12:27.177026	105	t	3	f
247	174	4	Latri Boubaker : Soins	{"primary":"#B60FC5","secondary":"#B60FC5"}	2021-12-18 07:00:00	2020-12-18 07:30:00	t	t	2020-12-16 13:11:36.871162	1	2020-12-17 16:14:46.303067	105	t	2	t
246	106	4	Bessai Sofiane : Soins	{"primary":"#1A3BEB","secondary":"#1A3BEB"}	2021-12-18 07:00:00	2020-12-18 07:30:00	t	t	2020-12-16 13:11:24.666471	1	2020-12-17 16:14:46.597423	105	t	2	t
243	74	4	Bahloul Salima : Soins	{"primary":"#2825FA","secondary":"#2825FA"}	2021-12-18 07:00:00	2020-12-18 07:30:00	t	t	2020-12-16 13:10:53.717158	1	2020-12-17 16:14:49.374703	105	t	2	t
86	1048	2	Ax Ax : Soins	{"primary":"#3F4D57","secondary":"#3F4D57"}	2020-01-10 07:00:00	2020-11-10 07:30:00	t	t	2020-11-25 14:39:41.02111	1	2020-11-25 14:39:41.02111	1	t	2	f
87	58	2	Bellal Amina : Soins	{"primary":"#C4859E","secondary":"#C4859E"}	2020-08-10 07:00:00	2020-11-10 08:00:00	t	t	2020-11-25 14:40:09.337519	1	2020-11-25 14:40:09.337519	1	t	2	f
81	1047	2	Aaaaa Bbbb : Extraction	{"primary":"#A04B91","secondary":"#A04B91"}	2020-11-01 07:00:00	2020-11-01 07:30:00	t	t	2020-11-25 14:32:51.38537	1	2020-11-25 14:32:51.38537	1	t	1	f
\.


--
-- Data for Name: patient_traitements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patient_traitements (id, patient_id, date_traitement, dent_num, procedure_id, acte_id, montant, observation, created, createdby, updated, updatedby, active) FROM stdin;
4	55	2017-01-26 22:02:00	18	3	3	4000	\N	2020-11-20 23:12:11.776994	1	2020-11-20 23:12:11.776994	1	t
5	55	2020-11-03 22:12:00	5	3	3	4000	\N	2020-11-20 23:12:36.667365	1	2020-11-20 23:12:36.667365	1	t
6	55	2020-11-20 22:18:00	18	4	4	400	\N	2020-11-20 23:18:46.572015	1	2020-11-20 23:18:46.572015	1	t
8	55	2020-11-06 00:54:00	3	3	3	4000	\N	2020-11-20 23:54:52.517439	1	2020-11-20 23:54:52.517439	1	t
10	55	2020-11-08 22:57:00	4	\N	\N	0	\N	2020-11-20 23:57:20.014622	1	2020-11-20 23:57:20.014622	1	t
12	55	2020-11-06 23:03:00	3	2	2	1500.12	\N	2020-11-21 00:03:35.088377	1	2020-11-21 00:03:35.088377	1	t
14	55	2020-11-20 23:26:00	4	3	3	4000	\N	2020-11-21 00:23:43.168223	1	2020-11-21 00:23:43.168223	1	t
15	55	2020-11-05 11:21:00	19	7	7	1000	\N	2020-11-21 10:22:03.137439	1	2020-11-21 10:22:03.137439	1	t
16	55	2020-11-21 11:52:00	5	3	3	4000	\N	2020-11-21 10:52:58.553612	1	2020-11-21 10:52:58.553612	1	t
17	55	2020-11-15 10:31:00	4	2	2	1500.12	CCCCC	2020-11-21 11:32:07.333549	1	2020-11-21 11:32:07.333549	1	t
32	1047	2020-11-26 16:31:00	F	5	5	3000	\N	2020-11-28 17:31:27.115338	1	2020-11-28 17:31:27.115338	1	t
33	1047	2020-11-06 16:33:00	R	15	18	1222.22	\N	2020-11-28 17:34:02.704544	1	2020-11-28 17:34:02.704544	1	t
34	1048	2020-11-07 16:38:00	18	4	4	400	\N	2020-11-28 17:38:07.371316	1	2020-11-28 17:38:07.371316	1	t
35	1048	2020-12-02 16:38:00	5	16	19	43.23	\N	2020-11-28 17:39:20.104552	1	2020-11-28 17:39:20.104552	1	t
36	47	2020-12-07 19:10:00	A	9	9	15000	\N	2020-12-07 19:51:35.871745	1	2020-12-07 19:51:35.871745	1	t
37	47	2020-12-17 20:51:00	K	11	11	6000	\N	2020-12-07 19:51:52.985799	1	2020-12-07 19:51:52.985799	1	t
38	47	2020-12-01 18:52:00	Q	10	10	200000	\N	2020-12-07 19:52:22.418849	1	2020-12-07 19:52:22.418849	1	t
39	47	2020-12-31 10:24:00	B	10	17	6666	sss	2020-12-12 11:24:51.466974	1	2020-12-12 11:24:51.466974	1	t
40	47	2020-12-13 11:49:00	R	3	3	4000	\N	2020-12-13 12:50:29.76756	1	2020-12-13 12:50:29.76756	1	t
41	47	2020-12-17 13:16:00	H	9	9	15000	\N	2020-12-17 14:16:33.436356	1	2020-12-17 14:16:33.436356	1	t
42	47	2020-12-17 16:15:00	H	10	10	200000	\N	2020-12-17 15:16:11.816589	105	2020-12-17 15:16:11.816589	105	t
43	47	2020-12-17 16:08:00	O	7	7	5000	\N	2020-12-17 16:08:34.420414	105	2020-12-17 16:08:34.420414	105	t
44	47	2021-01-15 17:27:00	\N	2	2	0	\N	2021-01-13 18:27:59.611889	1	2021-01-13 18:27:59.611889	1	t
45	47	2021-01-13 17:28:00	\N	4	4	0	\N	2021-01-13 18:28:24.422865	1	2021-01-13 18:28:24.422865	1	t
46	1086	2021-01-28 18:18:00	15	6	6	2000	test	2021-01-28 19:18:11.210411	1	2021-01-28 19:18:11.210411	1	t
\.


--
-- Data for Name: patient_vitals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patient_vitals (id, patient_id, vital_id, valeur, created, createdby, updated, updatedby, active) FROM stdin;
5	47	4	ds	2020-12-08 11:42:46.951904	1	2020-12-08 11:42:46.951904	1	t
7	48	2	\N	2020-12-08 12:08:58.6708	1	2020-12-08 12:08:58.6708	1	t
12	47	3	test	2020-12-12 11:36:59.197275	1	2020-12-12 11:36:59.197275	1	t
13	47	\N	\N	2020-12-13 12:31:11.105095	1	2020-12-13 12:31:11.105095	1	t
14	47	\N	\N	2020-12-13 12:31:13.383521	1	2020-12-13 12:31:13.383521	1	t
15	47	\N	\N	2020-12-13 12:33:47.167137	1	2020-12-13 12:33:47.167137	1	t
16	47	\N	\N	2020-12-13 12:33:49.277234	1	2020-12-13 12:33:49.277234	1	t
17	47	\N	\N	2020-12-13 12:33:54.541144	1	2020-12-13 12:33:54.541144	1	t
18	47	2	\N	2020-12-13 12:34:39.635304	1	2020-12-13 12:34:39.635304	1	t
21	47	5	test	2020-12-13 12:38:32.036546	1	2020-12-13 12:38:32.036546	1	t
24	143	7	12 kg de plus	2020-12-17 16:02:26.37281	105	2020-12-17 16:02:26.37281	105	t
25	1086	1	test	2021-01-28 19:12:51.477186	1	2021-01-28 19:12:51.477186	1	t
\.


--
-- Data for Name: patients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patients (id, nin, nom, nom_jeune_fille, prenom, sexe, date_naiss, type_date_naiss, lieu_naiss, adresse, commune_id, wilaya_id, situation_familiale, ppere, nmere, pmere, lib, created, createdby, updated, updatedby, active, uuid, tel, email, org_id) FROM stdin;
55	\N	Kateb	\N	Rezka	F	1985-10-14	N	Ouargla	\N	363	11	C	Ahmed	Korichi	Malika	Kateb Rezka 14/10/1985	2020-11-17 14:39:02.784653	1	2020-11-17 14:39:02.784653	1	t	14101985ktbrzkhmdkrchmlk	0672167575	h_djellouli@esi.dz	0
1047	\N	Aaaaa	\N	Bbbb	M	2005-11-11	N	Aaaaaa	Hussein Dey Alger,Algerie	362	1	M	\N	\N	\N	Aaaaa Bbbb 11/11/2005	2020-11-19 08:39:37.70758	1	2020-11-19 08:39:37.70758	1	t	11112005b	0554 56 66 92	h_djellouli@esi.dz	0
1053	\N	Djellouli	\N	Hicham	F	1989-11-11	N	\N	Hussein Dey Alger,Algerie	573	16	M	\N	\N	\N	Djellouli Hicham 11/11/1989	2020-11-27 11:11:34.593017	1	2020-11-27 11:11:34.593017	1	t	11111989jllhchm	0213 67 21 67	h_djellouli@esi.dz	0
1054	\N	Bido	\N	Hicham	M	1989-11-11	N	\N	Hussein Dey Alger,Algerie	573	16	M	\N	\N	\N	Bido Hicham 11/11/1989	2020-12-01 17:50:04.329123	1	2020-12-01 17:50:04.329123	1	t	11111989bdhchm	0213 67 21 67	h_djellouli@esi.dz	0
74	\N	Bahloul	\N	Salima	F	2005-10-31	N	Non Definie	\N	\N	8	D	Amar	Boumezbar	Bahidja	Bahloul Salima 31/10/2005	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	31102005bhllslmmrbmzbrbhj	0672167575	h_djellouli@esi.dz	0
1048	\N	Axss	\N	Axss	M	1989-11-11	P	Sss	Hussein Dey Alger,Algerie	630	17	M	\N	\N	\N	Axss Axss 11/11/1989	2020-12-08 10:46:13.88962	1	2020-12-08 10:46:13.88962	1	f	11111989xsxs	0672 16 75 75	h_djellouli@esi.dz	0
56	\N	Khelfis	\N	Louiza	F	1978-10-03	N	Souk Ahras	\N	\N	8	D	Ali	Dhouaibia	Yamina	Khelfis Louiza 03/10/1978	2020-12-08 10:41:24.754478	1	2020-12-08 10:41:24.754478	1	t	03101978khlfslzldbmn	0672167575	h_djellouli@esi.dz	0
80	\N	Kalaisss	\N	Kheiras	F	1958-11-17	N	Oran	\N	\N	8	C	Belkacem	Ilias	Fatma	Kalaisss Kheiras 17/11/1958	2020-12-08 10:49:08.415368	1	2020-12-08 10:49:08.415368	1	t	17111958klskhrsblkcmlsftm	0672167575	h_djellouli@esi.dz	0
57	\N	Boumous	\N	Noureddine	M	1992-11-04	N	Brezina	\N	\N	8	C	Mohamed	Boumous	Fatima	Boumous Noureddine 04/11/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04111992bmsnrdnmhmdbmsftm	0672167575	h_djellouli@esi.dz	0
58	\N	Bellal	\N	Amina	F	1989-08-17	N	El Bayadh	\N	\N	8	C	Mouloud	Semar	Rouza	Bellal Amina 17/08/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17081989bllmnmldsmrrz	0672167575	h_djellouli@esi.dz	0
59	\N	Bakriti	\N	Madjid	M	1983-06-17	N	Hassi Mameche	\N	\N	8	C	Kaddour	Bakreti	Fatma	Bakriti Madjid 17/06/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17061983bkrtmjdkdrbkrtftm	0672167575	h_djellouli@esi.dz	0
60	\N	Mestar	\N	Mokhtar	M	1977-01-04	N	Sig	\N	\N	8	C	Belkhir	Belberkani	Aicha	Mestar Mokhtar 04/01/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04011977mstrmkhtrblkhrblbrknch	0672167575	h_djellouli@esi.dz	0
61	\N	Messaoud	\N	Ammar	M	1985-10-08	N	Ain Nouissy	\N	\N	8	C	Noureddine	Ait Brahim	Saliha	Messaoud Ammar 08/10/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08101985msdmrnrdntbrhmslh	0672167575	h_djellouli@esi.dz	0
62	\N	Abderrahim	\N	Farida	F	1986-05-05	N	Mohammadia	\N	\N	8	C	Belahouel	Bettahar	Fatima	Abderrahim Farida 05/05/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05051986bdrhmfrdblhlbthrftm	0672167575	h_djellouli@esi.dz	0
63	\N	Ziane Cherif	\N	Zoubida	F	1950-02-01	N	Sig	\N	\N	8	V	Ali Cherif	Gettaf	Fatima	Ziane Cherif Zoubida 01/02/1950	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01021950znchrfzbdlchrfgtfftm	0672167575	h_djellouli@esi.dz	0
64	\N	Labdazi	\N	Imad	M	1985-10-29	N	Non Definie	\N	\N	8	C	Hocine	Naili	Khadidja	Labdazi Imad 29/10/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29101985lbdzmdhcnnlkhdj	0672167575	h_djellouli@esi.dz	0
65	\N	Loucif	\N	Mohammed Amin	M	1990-09-23	N	Non Definie	\N	\N	8	C	Laamari	Bensamira	Soria	Loucif Mohammed Amin 23/09/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23091990lcfmhmdmnlmrbnsmrsr	0672167575	h_djellouli@esi.dz	0
66	\N	Bouyaci	\N	Leila	F	1977-02-21	N	Non Definie	\N	\N	8	C	Amar	Fartas	Bahiya	Bouyaci Leila 21/02/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21021977bcllmrfrtsbh	0672167575	h_djellouli@esi.dz	0
67	\N	Boulakhiout	\N	Housseyn	M	1995-12-31	N	Non Definie	\N	\N	8	C	Abdelrazek	Kouahla	Houria	Boulakhiout Housseyn 31/12/1995	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	31121995blkhthsnbdlrzkkhlhr	0672167575	h_djellouli@esi.dz	0
68	\N	Chemam	\N	Karim	M	1992-04-03	N	Non Definie	\N	\N	8	C	Abdekader	Nahal	Khaira	Chemam Karim 03/04/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03041992chmmkrmbdkdrnhlkhr	0672167575	h_djellouli@esi.dz	0
69	\N	Allouche	\N	Raouf	M	1982-09-02	N	Non Definie	\N	\N	8	C	Kaddour	Herga	Malika	Allouche Raouf 02/09/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02091982lchrfkdrhrgmlk	0672167575	h_djellouli@esi.dz	0
70	\N	Krimi	\N	Mehdi	M	1989-07-02	N	Non Definie	\N	\N	8	C	Mohamed	Felfoul	Fatma	Krimi Mehdi 02/07/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02071989krmmhdmhmdflflftm	0672167575	h_djellouli@esi.dz	0
71	\N	Makhlouf	\N	Walid	M	1994-09-20	N	Non Definie	\N	\N	8	C	Mohamed	Bounaia	Djazira	Makhlouf Walid 20/09/1994	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20091994mkhlfwldmhmdbnjzr	0672167575	h_djellouli@esi.dz	0
72	\N	Abdaoui	\N	Zineddine	M	1992-12-31	N	Non Definie	\N	\N	8	C	Mohamed	Maizi	Khadidja	Abdaoui Zineddine 31/12/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	31121992bdzndnmhmdmzkhdj	0672167575	h_djellouli@esi.dz	0
73	\N	Abdaoui	\N	Mohammed Es Salih	M	1985-02-16	N	Non Definie	\N	\N	8	C	Messaoud	Boudjehem	Akila	Abdaoui Mohammed Es Salih 16/02/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16021985bdmhmdsslhmsdbjhmkl	0672167575	h_djellouli@esi.dz	0
75	10990132032780001 	Mehri	\N	Aissa	M	1990-09-13	N	Souk Ahras	\N	\N	8	C	Telili	Chabbi	Houria	Mehri Aissa 13/09/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13091990mhrstllchbhr	0672167575	h_djellouli@esi.dz	0
76	\N	Ziar	\N	Abdelkrim	M	1975-03-03	N	Zahana	\N	\N	8	C	Mohamed	Chaib	Zohra	Ziar Abdelkrim 03/03/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03031975zrbdlkrmmhmdchbzhr	0672167575	h_djellouli@esi.dz	0
77	\N	Kouadri	\N	Mohamed Amine	M	1992-01-17	N	Saida	\N	\N	8	C	Khelifa	Bouri	Alaichouch	Kouadri Mohamed Amine 17/01/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17011992kdrmhmdmnkhlfbrlchch	0672167575	h_djellouli@esi.dz	0
78	\N	Ouis	\N	Mohammed	M	1982-06-22	N	Mostaganem	\N	\N	8	D	Abed	Adda	Aouda	Ouis Mohammed 22/06/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22061982smhmdbddd	0672167575	h_djellouli@esi.dz	0
79	\N	Benmessaoud	\N	Razika	F	1970-01-01	N	Setif	\N	\N	8	C	Mohammed	Kaidi	Amria	Benmessaoud Razika 01/01/1970	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01011970bnmsdrzkmhmdkdmr	0672167575	h_djellouli@esi.dz	0
81	\N	Mekeddem	\N	Soumia	F	1991-07-01	N	Saida	\N	\N	8	C	Naceur	Ardjani	Zohra	Mekeddem Soumia 01/07/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01071991mkdmsmncrrjnzhr	0672167575	h_djellouli@esi.dz	0
82	\N	Mesquine	\N	Bilal	M	1991-05-25	N	Youb	\N	\N	8	C	Abdelkader	Djouadi	Kheira	Mesquine Bilal 25/05/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25051991msqnbllbdlkdrjdkhr	0672167575	h_djellouli@esi.dz	0
83	\N	Benaissa	\N	Abdelkader	M	1985-04-06	N	Oued El Abtal	\N	\N	8	C	Mohamed	Bousmaha	Fatma	Benaissa Abdelkader 06/04/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06041985bnsbdlkdrmhmdbsmhftm	0672167575	h_djellouli@esi.dz	0
84	\N	Medjadji	\N	Mohammed Habib	M	1951-06-15	N	Mascara	\N	\N	8	D	Ali	Bouketab	Fatima	Medjadji Mohammed Habib 15/06/1951	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15061951mjjmhmdhbblbktbftm	0672167575	h_djellouli@esi.dz	0
85	\N	Mir	\N	Melouka	F	1982-03-08	N	Youb	\N	\N	8	C	Abdelkader	Fokari	Fatma	Mir Melouka 08/03/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08031982mrmlkbdlkdrfkrftm	0672167575	h_djellouli@esi.dz	0
86	\N	Boumesla	\N	Ghezala	F	1964-07-17	N	El Hachem	\N	\N	8	D	Elhartani	Chaib	Yamina	Boumesla Ghezala 17/07/1964	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17071964bmslghzllhrtnchbmn	0672167575	h_djellouli@esi.dz	0
87	\N	Bendaoud	\N	Djamila	F	1966-08-19	N	Oran	\N	\N	8	V	Ahmed	Sidhoum	Yamina	Bendaoud Djamila 19/08/1966	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19081966bnddjmlhmdsdmmn	0672167575	h_djellouli@esi.dz	0
88	\N	Kenancha	\N	Fatiha	F	1968-03-18	N	Oued El Abtal	\N	\N	8	D	Djebbar	Mejeda	Yamina	Kenancha Fatiha 18/03/1968	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18031968knnchfthjbrmjdmn	0672167575	h_djellouli@esi.dz	0
89	\N	Bougherara	\N	Youcef	M	1988-03-09	N	Mascara	\N	\N	8	C	Zineddine	Regada	Zoubida	Bougherara Youcef 09/03/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09031988bghrrcfzndnrgdzbd	0672167575	h_djellouli@esi.dz	0
90	\N	Bouzeriba	\N	Fatima Zohra	F	1981-01-24	N	Hacine	\N	\N	8	C	Djillali	Bouzeriba	Aicha	Bouzeriba Fatima Zohra 24/01/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24011981bzrbftmzhrjllbzrbch	0672167575	h_djellouli@esi.dz	0
91	\N	Filah	\N	Ali	M	1985-04-28	N	Non Definie	\N	\N	8	C	Abdelmalek	Benbrika	Khadidja	Filah Ali 28/04/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28041985flhlbdlmlkbnbrkkhdj	0672167575	h_djellouli@esi.dz	0
92	\N	Mezioud	\N	Mohamed	M	1975-03-01	N	Sidi Ali	\N	\N	8	C	Benchaa	Mezioud	Cheaa	Mezioud Mohamed 01/03/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01031975mzdmhmdbnchmzdch	0672167575	h_djellouli@esi.dz	0
93	\N	Chehallil	\N	Imene	F	1989-01-19	N	Oued El Abtal	\N	\N	8	D	Mersli	Mayouf	Halima	Chehallil Imene 19/01/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19011989chhllmnmrslmfhlm	0672167575	h_djellouli@esi.dz	0
49	\N	Setti	\N	Abdelhakim	M	1995-04-20	N	Oued Taria	\N	\N	8	C	Belhachemi	Djazouli	Keltoum	Setti Abdelhakim 20/04/1995	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20041995stbdlhkmblhchmjzlkltm	0672167575	h_djellouli@esi.dz	0
50	\N	Sadeg	\N	Mohammed Elamine	M	1988-07-28	N	Sidi Bel Abbes	\N	\N	8	C	Mohamed	Rayes	Mokhtaria	Sadeg Mohammed Elamine 28/07/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28071988sdgmhmdlmnmhmdrsmkhtr	0672167575	h_djellouli@esi.dz	0
52	\N	Hidour	\N	Hamou	M	1990-10-07	N	Ain Kermes	\N	\N	8	C	Smahi	Hocini	Ghalia	Hidour Hamou 07/10/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07101990hdrhmsmhhcnghl	0672167575	h_djellouli@esi.dz	0
96	\N	Hamadouche	\N	Rezki	M	1985-12-02	N	Ghriss	\N	\N	8	D	Saada	Saloua	Malika	Hamadouche Rezki 02/12/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02121985hmdchrzksdslmlk	0672167575	h_djellouli@esi.dz	0
97	\N	Selama	\N	Sad Eddine	M	1987-07-19	N	Guemar	\N	\N	8	M	Laiche	Goubi	Saliha	Selama Sad Eddine 19/07/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19071987slmsddnlchgbslh	0672167575	h_djellouli@esi.dz	0
98	\N	Djouadi	\N	Nour Eddine	M	1972-06-27	N	El Oued	\N	\N	8	M	Laid	Djouadi	Heddi	Djouadi Nour Eddine 27/06/1972	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27061972jdnrdnldjdhd	0672167575	h_djellouli@esi.dz	0
100	\N	Ben Aoun	\N	Farida	F	1972-10-22	N	El Oued	\N	\N	8	M	Lammari	Souid	Sakina	Ben Aoun Farida 22/10/1972	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22101972bnnfrdlmrsdskn	0672167575	h_djellouli@esi.dz	0
101	\N	Boutera	\N	Abdelhak	M	1981-08-16	N	El Oued	\N	\N	8	M	Mohammed	Meziou	Aicha	Boutera Abdelhak 16/08/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16081981btrbdlhkmhmdmzch	0672167575	h_djellouli@esi.dz	0
102	\N	Ghendir	\N	Amor	M	1978-10-26	N	El Oued	\N	\N	8	M	Larouci	Drihem	Kouka	Ghendir Amor 26/10/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26101978ghndrmrlrcdrhmkk	0672167575	h_djellouli@esi.dz	0
103	\N	Ghendir	\N	Mohammed Laid	M	1980-09-16	N	El Oued	\N	\N	8	M	Laroussi	Kouka	Drihem	Ghendir Mohammed Laid 16/09/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16091980ghndrmhmdldlrskkdrhm	0672167575	h_djellouli@esi.dz	0
104	\N	Hezla	\N	Laid	M	1975-07-11	N	El Oued	\N	\N	8	M	Mohammed	Hezla	Hania	Hezla Laid 11/07/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11071975hzlldmhmdhzlhn	0672167575	h_djellouli@esi.dz	0
105	\N	Meziane	\N	Fatima	F	1978-09-12	N	Tazmalt	\N	\N	8	M	Smail	Mahtout	Melaaz	Meziane Fatima 12/09/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12091978mznftmsmlmhttmlz	0672167575	h_djellouli@esi.dz	0
106	\N	Bessai	\N	Sofiane	M	1981-07-26	N	M'Chedallah	\N	\N	8	M	Lahlou	Maza	Hayat	Bessai Sofiane 26/07/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26071981bssfnlhlmzht	0672167575	h_djellouli@esi.dz	0
107	\N	Aberbour	\N	Mohand	M	1968-01-23	N	Tazmalt	\N	\N	8	M	Boudjema	Smaili	Megdouda	Aberbour Mohand 23/01/1968	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23011968brbrmhndbjmsmlmgdd	0672167575	h_djellouli@esi.dz	0
108	\N	Adaika	\N	Manel	F	1990-07-29	N	El Oued	\N	\N	8	M	Mebrouk	Mesbahi	Malika	Adaika Manel 29/07/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29071990dkmnlmbrkmsbhmlk	0672167575	h_djellouli@esi.dz	0
109	\N	Belhadef	\N	Abdellatif	M	1969-03-03	N	El Oued	\N	\N	8	M	Ali	Deyab	Fatma	Belhadef Abdellatif 03/03/1969	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03031969blhdfbdltfldbftm	0672167575	h_djellouli@esi.dz	0
110	\N	Zine	\N	Bachir	M	1973-02-08	N	Robbah	\N	\N	8	M	Ali	Ben Ali	Messaouda	Zine Bachir 08/02/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08021973znbchrlbnlmsd	0672167575	h_djellouli@esi.dz	0
111	\N	Meneceur	\N	Hamza	M	1981-01-05	N	El Oued	\N	\N	8	M	Ammar	Bedda Zekri	Yamna	Meneceur Hamza 05/01/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05011981mncrhmzmrbdzkrmn	0672167575	h_djellouli@esi.dz	0
112	\N	Zendah	\N	Tayeb	M	1980-10-01	N	El Oued	\N	\N	8	M	Ammar	Zendah	Baya	Zendah Tayeb 01/10/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01101980zndhtbmrzndhb	0672167575	h_djellouli@esi.dz	0
113	\N	Amara	\N	Khaled	M	1983-01-20	N	El Oued	\N	\N	8	M	Azzali	Houideg	Meriem	Amara Khaled 20/01/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20011983mrkhldzlhdgmrm	0672167575	h_djellouli@esi.dz	0
114	\N	Terki	\N	Houda	F	1986-08-19	N	El Oued	\N	\N	8	M	Bachir	Habi	Bechira	Terki Houda 19/08/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19081986trkhdbchrhbbchr	0672167575	h_djellouli@esi.dz	0
115	\N	Gherbi	\N	Faical	M	1981-03-07	N	El Oued	\N	\N	8	M	Khalifa	Gherbi	Khadidja	Gherbi Faical 07/03/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07031981ghrbfclkhlfghrbkhdj	0672167575	h_djellouli@esi.dz	0
48	\N	Bellefaa	\N	Yamina	F	1957-01-01	N	Mohammadia	\N	21	1	V	Kada	Rached	Kheira	Bellefaa Yamina 01/01/1957	2021-01-15 19:28:26.09937	1	2021-01-15 19:28:26.09937	1	f	01011957blfmnkdrchdkhr	0672167575	amira.hem@gmail.com	0
51	\N	Basss	\N	Ouahibass	F	1974-07-11	N	El Biar	\N	285	8	V	Ali	Hamsi	Oum Saad	Basss Ouahibass 11/07/1974	2020-12-08 10:45:19.785976	1	2020-12-08 10:45:19.785976	1	t	11071974bshbslhmsmsd	0672167575	h_djellouli@esi.dz	0
53	\N	Berraouis	\N	Ahmed	M	1992-10-14	N	Sfisef	\N	\N	8	C	Mimoun	Maghraoui	Fatima Zohra	Berraouis Ahmed 14/10/1992	2020-12-08 10:44:48.216812	1	2020-12-08 10:44:48.216812	1	t	14101992brshmdmmnmghrftmzhr	0672167575	h_djellouli@esi.dz	0
116	\N	Attoussi	\N	Amal	F	1987-10-09	N	El Oued	\N	\N	8	M	Abdelouahed	Attoussi	Saloua	Attoussi Amal 09/10/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09101987tsmlbdlhdtssl	0672167575	h_djellouli@esi.dz	0
117	\N	Bey	\N	Chifa	F	1992-09-14	N	El Oued	\N	\N	8	M	Mahmoud	Belaid	Zahia	Bey Chifa 14/09/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	14091992bchfmhmdbldzh	0672167575	h_djellouli@esi.dz	0
118	\N	Mesbahi	\N	Mossaab	M	1989-10-08	N	El Oued	\N	\N	8	M	Mohamed El Hadi	Chabrou	Zakia	Mesbahi Mossaab 08/10/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08101989msbhmsbmhmdlhdchbrzk	0672167575	h_djellouli@esi.dz	0
120	\N	Bennaceur	\N	Salim	M	1983-02-28	N	El Oued	\N	\N	8	M	Mohammed	Sai	Fatma	Bennaceur Salim 28/02/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28021983bncrslmmhmdsftm	0672167575	h_djellouli@esi.dz	0
121	\N	Chaib	\N	Leila	M	1970-08-16	N	Skikda	\N	\N	8	M	Mohammed Abdou	Djorouni	Kalthoum	Chaib Leila 16/08/1970	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16081970chbllmhmdbdjrnklthm	0672167575	h_djellouli@esi.dz	0
122	\N	Laibi	\N	Omar	M	1983-02-23	N	El Oued	\N	\N	8	M	Mohammed Laid	Aoudhina	Messaouda	Laibi Omar 23/02/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23021983lbmrmhmdlddnmsd	0672167575	h_djellouli@esi.dz	0
123	\N	Amara	\N	Nassima	F	1977-05-31	N	Tazmalt	\N	\N	8	M	Ahmed	Saidi	Zahoua	Amara Nassima 31/05/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	31051977mrnsmhmdsdzh	0672167575	h_djellouli@esi.dz	0
124	\N	Bouakkache	\N	Hamid	M	1967-11-29	N	Tazmalt	\N	\N	8	M	Ali	Merabtine	Djamila	Bouakkache Hamid 29/11/1967	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29111967bkchhmdlmrbtnjml	0672167575	h_djellouli@esi.dz	0
125	\N	Rabia	\N	Mokrane	M	1984-01-04	N	Akbou	\N	\N	8	M	Hamou	Ouhamou	Horia	Rabia Mokrane 04/01/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04011984rbmkrnhmhmhr	0672167575	h_djellouli@esi.dz	0
126	\N	Haga	\N	Nabil	M	1979-06-16	N	El Oued	\N	\N	8	M	Lamine	Serouti	Kheira	Haga Nabil 16/06/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16061979hgnbllmnsrtkhr	0672167575	h_djellouli@esi.dz	0
127	\N	Omrani	\N	Yahia	M	1979-11-09	N	El Oued	\N	\N	8	M	Lamine	Omrani	Khadidja	Omrani Yahia 09/11/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09111979mrnhlmnmrnkhdj	0672167575	h_djellouli@esi.dz	0
128	\N	Zelaci	\N	Adel	M	1975-07-23	N	El Oued	\N	\N	8	M	Lazhari	Rezag Baara	Messaouda	Zelaci Adel 23/07/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23071975zlcdllzhrrzgbrmsd	0672167575	h_djellouli@esi.dz	0
129	\N	Khanfsi	\N	Boudjemaa	M	1985-04-07	N	Timimoun	\N	\N	8	M	Abdesslam	Hadj Kadi	Fatma	Khanfsi Boudjemaa 07/04/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07041985khnfsbjmbdslmhjkdftm	0672167575	h_djellouli@esi.dz	0
131	\N	Bendjabour	\N	Bouabdellah	M	1979-09-17	N	Oran	\N	\N	8	M	Mohammed	Bekkara	Fatma	Bendjabour Bouabdellah 17/09/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17091979bnjbrbbdlhmhmdbkrftm	0672167575	h_djellouli@esi.dz	0
132	\N	Annabi	\N	Nassima	F	1988-03-04	N	Blida	\N	\N	8	M	Ahmed	Louachfoun	Hafida	Annabi Nassima 04/03/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04031988nbnsmhmdlchfnhfd	0672167575	h_djellouli@esi.dz	0
133	\N	Benkhalledi	\N	Fella	F	1988-04-20	N	Medea	\N	\N	8	M	Omar	Rekia	Faiza	Benkhalledi Fella 20/04/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20041988bnkhldflmrrkfz	0672167575	h_djellouli@esi.dz	0
134	\N	Kacemi	\N	Abdelmalik	M	1983-05-25	N	Aougrout	\N	\N	8	M	Ahmed	Kacemi	Aicha	Kacemi Abdelmalik 25/05/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25051983kcmbdlmlkhmdkcmch	0672167575	h_djellouli@esi.dz	0
135	\N	Agaoua	\N	Karim	M	1967-01-01	N	Tazmalt	\N	\N	8	M	Lounes	Takarabet	Faroudja	Agaoua Karim 01/01/1967	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01011967gkrmlnstkrbtfrj	0672167575	h_djellouli@esi.dz	0
136	\N	Boussaid	\N	Ahmed	M	1965-01-01	N	Charouine	\N	\N	8	M	Ali	Boussaid	Cheikha	Boussaid Ahmed 01/01/1965	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01011965bsdhmdlbsdchkh	0672167575	h_djellouli@esi.dz	0
137	\N	Sahi	\N	Fella	F	1988-12-13	N	Medea	\N	\N	8	M	Boulanouar	Abassi	Yamina	Sahi Fella 13/12/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13121988chflblnrbsmn	0672167575	h_djellouli@esi.dz	0
138	\N	Hadji	\N	Amel	F	1987-01-06	N	Sidi Bel Abbes	\N	\N	8	M	Cheikh	Hadji	Fatima	Hadji Amel 06/01/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06011987hjmlchkhhjftm	0672167575	h_djellouli@esi.dz	0
139	\N	Saim Haddache	\N	Boumediene	M	1978-10-14	N	Sidi Bel Abbes	\N	\N	8	M	Hadj	Bahi	Khadra	Saim Haddache Boumediene 14/10/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	14101978smhdchbmdnhjbhkhdr	0672167575	h_djellouli@esi.dz	0
140	\N	Ben Abdallah	\N	Belgacem	M	1968-08-13	N	El Oued	\N	\N	8	M	Brahim	Belgacemi	Sacia	Ben Abdallah Belgacem 13/08/1968	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13081968bnbdlhblgcmbrhmblgcmsc	0672167575	h_djellouli@esi.dz	0
141	\N	Haret	\N	Farid	M	1979-04-27	N	Sidi Bel Abbes	\N	\N	8	M	Mokhtar	Habi	Zohra	Haret Farid 27/04/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27041979hrtfrdmkhtrhbzhr	0672167575	h_djellouli@esi.dz	0
142	\N	Miliani	\N	Elarabi	M	1983-09-05	N	Djidiouia	\N	\N	8	M	Laid	Serradj	Fatma	Miliani Elarabi 05/09/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05091983mlnlrbldsrjftm	0672167575	h_djellouli@esi.dz	0
143	\N	Mederbel	\N	Hadri	M	1973-08-22	N	Tessala	\N	\N	8	M	Abdelkader	Mederbel	Setti	Mederbel Hadri 22/08/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22081973mdrblhdrbdlkdrmdrblst	0672167575	h_djellouli@esi.dz	0
144	\N	Soltani	\N	Fakhr Eddine	M	1987-01-18	N	Khenchela	\N	\N	8	M	Brahim	Soltani	Nadia	Soltani Fakhr Eddine 18/01/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18011987sltnfkhrdnbrhmsltnnd	0672167575	h_djellouli@esi.dz	0
145	\N	Semmar	\N	Mohammed	M	1990-11-28	N	Hammam Bouhadjar	\N	\N	8	M	Kadi	Mouafak	Khaldia	Semmar Mohammed 28/11/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28111990smrmhmdkdmfkkhld	0672167575	h_djellouli@esi.dz	0
147	\N	Chelbi	\N	Latifa	F	1971-04-02	N	Souk Ahras	\N	\N	8	M	Houcine	Chelbi	Mabrouka	Chelbi Latifa 02/04/1971	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02041971chlbltfhcnchlbmbrk	0672167575	h_djellouli@esi.dz	0
148	\N	Dekiche	\N	Nabil	M	1969-02-04	N	Souk Ahras	\N	\N	8	M	Hacen	Mansouri	Fatma	Dekiche Nabil 04/02/1969	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04021969dkchnblhcnmnsrftm	0672167575	h_djellouli@esi.dz	0
149	\N	Djaidir	\N	Abdallah	M	1987-02-06	N	El Guerrara	\N	\N	8	M	Dahmane	Boumaidouna	Mebarka	Djaidir Abdallah 06/02/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06021987jdrbdlhdhmnbmdnmbrk	0672167575	h_djellouli@esi.dz	0
150	\N	Brahmi	\N	Nadia	F	1974-06-25	N	Es Senia	\N	\N	8	M	Beloufa	Ghalem	Kheira	Brahmi Nadia 25/06/1974	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25061974brhmndblfghlmkhr	0672167575	h_djellouli@esi.dz	0
151	\N	Abdaoui	\N	Hedda	F	1984-07-28	N	Belkhir	\N	\N	8	M	Selaiman	Ghachir	Akila	Abdaoui Hedda 28/07/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28071984bdhdslmnghchrkl	0672167575	h_djellouli@esi.dz	0
152	\N	Kadem	\N	Ahmed	M	1969-06-16	N	Arzew	\N	\N	8	M	Abdelkader	Djazouli	Malika	Kadem Ahmed 16/06/1969	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16061969kdmhmdbdlkdrjzlmlk	0672167575	h_djellouli@esi.dz	0
153	\N	Chettab	\N	Hanene	F	1991-12-18	N	Constantine	\N	\N	8	M	Ibrahim	Zaami	Aicha	Chettab Hanene 18/12/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18121991chtbhnnbrhmzmch	0672167575	h_djellouli@esi.dz	0
154	\N	Chaba Mouna	\N	Hayet	F	1985-05-08	N	Medea	\N	\N	8	D	Abdelkader	Beldjerdi	Rekia	Chaba Mouna Hayet 08/05/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08051985chbmnhtbdlkdrbljrdrk	0672167575	h_djellouli@esi.dz	0
155	\N	Derras	\N	Mohammed	M	1987-12-25	N	Sidi Bel Abbes	\N	\N	8	M	Talha	Belhadj	Houria	Derras Mohammed 25/12/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25121987drsmhmdtlhblhjhr	0672167575	h_djellouli@esi.dz	0
156	\N	Zedadra	\N	Abdelhalim	M	1977-11-26	N	Belkhir	\N	\N	8	M	Arbi	Bougarn	Elhadba	Zedadra Abdelhalim 26/11/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26111977zddrbdlhlmrbbgrnlhdb	0672167575	h_djellouli@esi.dz	0
157	\N	Zerdodi	\N	Abdelkadir	M	1986-07-15	N	Guelma	\N	\N	8	M	Selaiman	Ben Abda	Fatiha	Zerdodi Abdelkadir 15/07/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15071986zrddbdlkdrslmnbnbdfth	0672167575	h_djellouli@esi.dz	0
158	\N	Riahi	\N	Fathi	M	1984-02-27	N	Souk Ahras	\N	\N	8	M	Mesbah	Dridi	Houria	Riahi Fathi 27/02/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27021984rhfthmsbhdrdhr	0672167575	h_djellouli@esi.dz	0
159	\N	Tradkhodja	\N	Hassen	M	1983-03-11	N	Souk Ahras	\N	\N	8	M	Mabrouk	Tradkhodja	Oumsaad	Tradkhodja Hassen 11/03/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11031983trdkhjhsnmbrktrdkhjmsd	0672167575	h_djellouli@esi.dz	0
160	\N	Ktitni	\N	Samir	M	1982-07-08	N	Guelma	\N	\N	8	M	Abdolah	Boukaskas	Habiba	Ktitni Samir 08/07/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08071982kttnsmrbdlhbkskshbb	0672167575	h_djellouli@esi.dz	0
161	\N	Belfarh	\N	Abdelkader	M	1971-04-29	N	El Bayadh	\N	\N	8	M	Taher	Belguerine	Messaouda	Belfarh Abdelkader 29/04/1971	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29041971blfrhbdlkdrthrblgrnmsd	0672167575	h_djellouli@esi.dz	0
162	\N	Hammadi	\N	Salim	M	1981-07-11	N	Hadjout	\N	\N	8	M	Rabah	Belkada	Zouhour	Hammadi Salim 11/07/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11071981hmdslmrbhblkdzhr	0672167575	h_djellouli@esi.dz	0
163	\N	Bahar	\N	Maamar	M	1973-08-25	N	Hadjout	\N	\N	8	M	Mohamed	Lahcene	Zohra	Bahar Maamar 25/08/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25081973bhrmmrmhmdlhcnzhr	0672167575	h_djellouli@esi.dz	0
164	\N	Hamouche	\N	Zina	M	1993-05-28	N	Djebahia	\N	\N	8	M	Mohamed	Saadi	Fatiha	Hamouche Zina 28/05/1993	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28051993hmchznmhmdsdfth	0672167575	h_djellouli@esi.dz	0
165	\N	Abdi	\N	Mohcene	M	1983-08-31	N	El Kala	\N	\N	8	M	Mehdi	Boumhani	Sacia	Abdi Mohcene 31/08/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	31081983bdmhcnmhdbmhnsc	0672167575	h_djellouli@esi.dz	0
166	\N	Attia	\N	Yacine	M	1986-12-21	N	Laghouat	\N	\N	8	M	Lakhdar	Attia	Aicha	Attia Yacine 21/12/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21121986tcnlkhdrtch	0672167575	h_djellouli@esi.dz	0
167	\N	Nabi	\N	Habib	M	1977-04-30	N	Youb	\N	\N	8	M	Kada	Hachmane	Magnia	Nabi Habib 30/04/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30041977nbhbbkdhchmnmgn	0672167575	h_djellouli@esi.dz	0
168	\N	Medjahdi	\N	Lahaouari	M	1971-08-15	N	Oran	\N	\N	8	M	Mohamed	Bendida	Kheira	Medjahdi Lahaouari 15/08/1971	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15081971mjhdlhrmhmdbnddkhr	0672167575	h_djellouli@esi.dz	0
169	\N	Sabour	\N	Abdelkader	M	1973-12-28	N	Medea	\N	\N	8	M	Benyahia	Zirek	Fatma	Sabour Abdelkader 28/12/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28121973sbrbdlkdrbnhzrkftm	0672167575	h_djellouli@esi.dz	0
170	\N	Mesai Ahmed	\N	Yakoub	M	1985-10-06	N	El Oued	\N	\N	8	M	Lalmi	Mesai Ahmed	Tounes	Mesai Ahmed Yakoub 06/10/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06101985mchmdkbllmmchmdtns	0672167575	h_djellouli@esi.dz	0
171	\N	Henka	\N	Nour Eddine	M	1983-01-10	N	Robbah	\N	\N	8	M	Khalifa	Henka	Fatima	Henka Nour Eddine 10/01/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10011983hnknrdnkhlfhnkftm	0672167575	h_djellouli@esi.dz	0
172	\N	Touahria	\N	Youcef	M	1981-02-01	N	El Oued	\N	\N	8	M	Djilani	Douib	Messaouda	Touahria Youcef 01/02/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01021981thrcfjlndbmsd	0672167575	h_djellouli@esi.dz	0
173	\N	Harbi	\N	Meriem	F	1969-05-19	N	Youb	\N	\N	8	M	Abdelkader	Aiboud	Halima	Harbi Meriem 19/05/1969	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19051969hrbmrmbdlkdrbdhlm	0672167575	h_djellouli@esi.dz	0
174	\N	Latri	\N	Boubaker	M	1988-07-01	N	El Oued	\N	\N	8	C	Nacer	Rabani	Khamsa	Latri Boubaker 01/07/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01071988ltrbbkrncrrbnkhms	0672167575	h_djellouli@esi.dz	0
176	\N	Halouadji	\N	El Hassan	M	1987-06-03	N	El Oued	\N	\N	8	M	Ali	Halouadji	Zohra	Halouadji El Hassan 03/06/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03061987hljlhsnlhljzhr	0672167575	h_djellouli@esi.dz	0
177	\N	Aci	\N	Bachir	M	1982-01-08	N	Youb	\N	\N	8	M	Mostefa	Dagbaj	Fatiha	Aci Bachir 08/01/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08011982cbchrmstfdgbjfth	0672167575	h_djellouli@esi.dz	0
178	\N	Chouih	\N	Abdelhak	M	1993-12-27	N	Youb	\N	\N	8	M	Abdelkader	Bacha	Bouhana	Chouih Abdelhak 27/12/1993	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27121993chhbdlhkbdlkdrbchbhn	0672167575	h_djellouli@esi.dz	0
179	\N	Mouedden	\N	Fatna	F	1981-02-05	N	Youb	\N	\N	8	M	Djeloul	Ardjani	Khaira	Mouedden Fatna 05/02/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05021981mdnftnjllrjnkhr	0672167575	h_djellouli@esi.dz	0
180	\N	Azri	\N	Ahmed	M	1977-12-12	N	Relizane	\N	\N	8	M	Mostefa	Bardad	Fatiha	Azri Ahmed 12/12/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12121977zrhmdmstfbrddfth	0672167575	h_djellouli@esi.dz	0
181	\N	Zerrouk	\N	Bachir	M	1986-05-19	N	Debila	\N	\N	8	M	Maamar	Djeraya	Habiba	Zerrouk Bachir 19/05/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19051986zrkbchrmmrjrhbb	0672167575	h_djellouli@esi.dz	0
182	\N	Djebali	\N	Abdelouahed	M	1984-01-04	N	El Oued	\N	\N	8	M	Abderrazak	Benamor	Mabrouka	Djebali Abdelouahed 04/01/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04011984jblbdlhdbdrzkbnmrmbrk	0672167575	h_djellouli@esi.dz	0
183	\N	Mesai Mohammed	\N	Oussama	M	1989-09-12	N	El Oued	\N	\N	8	C	Abdelghani	Gheraissa	Zineb	Mesai Mohammed Oussama 12/09/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12091989msmhmdsmbdlghnghrsznb	0672167575	h_djellouli@esi.dz	0
184	\N	Benterrouche	\N	Sarra	F	1985-05-29	N	Constantine	\N	\N	8	D	Rabeh	Said	Mimi	Benterrouche Sarra 29/05/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29051985bntrchsrrbhsdmm	0672167575	h_djellouli@esi.dz	0
185	\N	Smouhi	\N	Amir	M	1992-05-25	N	El Oued	\N	\N	8	C	Bachir	Belfar	Souad	Smouhi Amir 25/05/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25051992smhmrbchrblfrsd	0672167575	h_djellouli@esi.dz	0
186	\N	Hafiane	\N	Abdelkrim	M	1973-03-28	N	Fenoughil	\N	\N	8	M	Kaddour	Hadaji	Khadoudja	Hafiane Abdelkrim 28/03/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28031973hfnbdlkrmkdrhjkhdj	0672167575	h_djellouli@esi.dz	0
187	\N	Tirouche	\N	Mokhtar	M	1982-01-01	N	Bouhamdane	\N	\N	8	M	Khoudja	Smaili	Halima	Tirouche Mokhtar 01/01/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01011982trchmkhtrkhjsmlhlm	0672167575	h_djellouli@esi.dz	0
188	\N	Sid Amor	\N	Barka	M	1973-08-09	N	Adrar	\N	\N	8	M	Abderrahmane	Tayebi	Mebarka	Sid Amor Barka 09/08/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09081973sdmrbrkbdrhmntbmbrk	0672167575	h_djellouli@esi.dz	0
189	\N	Kentaoui	\N	Ahmed	M	1973-07-01	N	Fenoughil	\N	\N	8	M	Mokhtar	Fouti	Aicha	Kentaoui Ahmed 01/07/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01071973knthmdmkhtrftch	0672167575	h_djellouli@esi.dz	0
190	\N	Djadour	\N	Taieb	M	1958-01-01	N	Laghouat	\N	\N	8	M	Ahmed	Achour	Mebarka	Djadour Taieb 01/01/1958	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01011958jdrtbhmdchrmbrk	0672167575	h_djellouli@esi.dz	0
191	\N	Safir	\N	Mohammed	M	1984-03-16	N	Ain Beida	\N	\N	8	M	Ahmed	Sadji	Elyamna	Safir Mohammed 16/03/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16031984sfrmhmdhmdsjlmn	0672167575	h_djellouli@esi.dz	0
192	\N	Djouadi	\N	Salim	M	1983-11-02	N	Oued Zenati	\N	\N	8	M	Hmida	Djouadi	Hanifa	Djouadi Salim 02/11/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02111983jdslmhmdjdhnf	0672167575	h_djellouli@esi.dz	0
193	\N	Moulay	\N	Khadidja	F	1960-08-30	N	Medea	\N	\N	8	V	Mohamed	Zouaoui	Yamena	Moulay Khadidja 30/08/1960	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30081960mlkhdjmhmdzmn	0672167575	h_djellouli@esi.dz	0
194	\N	Hakime	\N	Mohammed	M	1986-03-07	N	Morsott	\N	\N	8	M	Mansour	Hakim	Saida	Hakime Mohammed 07/03/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07031986hkmmhmdmnsrhkmsd	0672167575	h_djellouli@esi.dz	0
195	\N	Berkani	\N	Hocine	M	1974-08-14	N	Ain Babouche	\N	\N	8	M	Salah	Berkani	Fatiha	Berkani Hocine 14/08/1974	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	14081974brknhcnslhbrknfth	0672167575	h_djellouli@esi.dz	0
196	\N	Merazguia	\N	Kamel	M	1977-03-20	N	Sedrata	\N	\N	8	M	Salah	Bougandoura	Taous	Merazguia Kamel 20/03/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20031977mrzgkmlslhbgndrts	0672167575	h_djellouli@esi.dz	0
197	\N	Zeghoud	\N	Lotfi	M	1981-06-16	N	Oum Bouaghi	\N	\N	8	M	Boubaker	Daoudi	Aicha	Zeghoud Lotfi 16/06/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16061981zghdltfbbkrddch	0672167575	h_djellouli@esi.dz	0
198	\N	Gherairia	\N	Seyfeddine	M	1992-02-02	N	M'Daourouche	\N	\N	8	M	Mohammed	Marki	Djemaa	Gherairia Seyfeddine 02/02/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02021992ghrrsfdnmhmdmrkjm	0672167575	h_djellouli@esi.dz	0
199	\N	Guerriche	\N	Mohammed	M	1977-03-06	N	Tlemcen	\N	\N	8	M	Ahmed	Khaldoune	Halima	Guerriche Mohammed 06/03/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06031977grchmhmdhmdkhldnhlm	0672167575	h_djellouli@esi.dz	0
200	\N	Messai	\N	Ishak	M	1990-08-07	N	Oum Bouaghi	\N	\N	8	M	Kaddour	Seguni	Hassina	Messai Ishak 07/08/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07081990mschkkdrsgnhsn	0672167575	h_djellouli@esi.dz	0
201	\N	Ziad	\N	Haroun	M	1988-09-25	N	Oum Bouaghi	\N	\N	8	M	Khouthir	Chebouti	Akila	Ziad Haroun 25/09/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25091988zdhrnkhthrchbtkl	0672167575	h_djellouli@esi.dz	0
202	\N	Farhaoui	\N	Lynda	F	1980-01-04	N	Oued Zenati	\N	\N	8	M	Houcine	Hadouche	Lakri	Farhaoui Lynda 04/01/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04011980frhlndhcnhdchlkr	0672167575	h_djellouli@esi.dz	0
203	\N	Gouami	\N	Wahid	M	1988-08-12	N	Guelma	\N	\N	8	M	Naameddine	Bouida	Nacira	Gouami Wahid 12/08/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12081988gmwhdnmdnbdncr	0672167575	h_djellouli@esi.dz	0
204	\N	Drouiche	\N	Fouzia	F	1984-04-02	N	M'Daourouche	\N	\N	8	M	Ismail	Drouiche	Dalila	Drouiche Fouzia 02/04/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02041984drchfzsmldrchdll	0672167575	h_djellouli@esi.dz	0
205	\N	Ouanzar	\N	Chouaib	M	1968-01-01	N	Ain Babouche	\N	\N	8	M	Said	Ouanzar	Elouazna	Ouanzar Chouaib 01/01/1968	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01011968nzrchbsdnzrlzn	0672167575	h_djellouli@esi.dz	0
206	\N	Yahiaoui	\N	Laid	M	1983-09-20	N	M'Daourouche	\N	\N	8	M	Salah	Yahiaoui	Ouarda	Yahiaoui Laid 20/09/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20091983hldslhhrd	0672167575	h_djellouli@esi.dz	0
207	\N	Houhamedi	\N	Abdeldjalil	M	1990-09-13	N	Oum Bouaghi	\N	\N	8	D	Bachir	Medfouni	Zineb	Houhamedi Abdeldjalil 13/09/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13091990hhmdbdljllbchrmdfnznb	0672167575	h_djellouli@esi.dz	0
208	\N	Sabri	\N	Faysal	M	1984-05-03	N	Oum Bouaghi	\N	\N	8	M	Hadj	Berkani	Saliha	Sabri Faysal 03/05/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03051984sbrfslhjbrknslh	0672167575	h_djellouli@esi.dz	0
209	\N	Meliani	\N	Abdeldjalil	M	1993-11-01	N	Ben Badis	\N	\N	8	C	Bensekrane	Rebaoui	Nacera	Meliani Abdeldjalil 01/11/1993	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01111993mlnbdljllbnskrnrbncr	0672167575	h_djellouli@esi.dz	0
210	\N	Moumeni	\N	Ismail	M	1987-11-08	N	Deldoul	\N	\N	8	M	Ahmed	Boukari	Zohra	Moumeni Ismail 08/11/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08111987mmnsmlhmdbkrzhr	0672167575	h_djellouli@esi.dz	0
212	\N	Ould Aissa	\N	Malika	F	1989-08-03	N	Tlemcen	\N	\N	8	C	Benamar	Hamidi	Fatiha	Ould Aissa Malika 03/08/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03081989ldsmlkbnmrhmdfth	0672167575	h_djellouli@esi.dz	0
213	\N	Boulakhras	\N	Samira	F	1989-09-10	N	Ksar Sbahi	\N	\N	8	M	Ghazal	Batoul	Malika	Boulakhras Samira 10/09/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10091989blkhrssmrghzlbtlmlk	0672167575	h_djellouli@esi.dz	0
214	\N	Belarbi	\N	Salima	F	1983-02-22	N	Non Definie	\N	\N	8	M	Yahia	Makhlouf	Ammara	Belarbi Salima 22/02/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22021983blrbslmhmkhlfmr	0672167575	h_djellouli@esi.dz	0
215	\N	Abdelmalek	\N	Omar	M	1971-12-15	N	Non Definie	\N	\N	8	M	Laid	Abdelmalek	Halima	Abdelmalek Omar 15/12/1971	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15121971bdlmlkmrldbdlmlkhlm	0672167575	h_djellouli@esi.dz	0
216	\N	Kadem	\N	Fouzia	F	1988-07-25	N	Ain Babouche	\N	\N	8	D	Lakhder	Meslem	Mebrouka	Kadem Fouzia 25/07/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25071988kdmfzlkhdrmslmmbrk	0672167575	h_djellouli@esi.dz	0
217	\N	Mamouri	\N	Lakhdar	M	1984-07-23	N	Non Definie	\N	\N	8	M	Benamar	Boutalaa	Halima	Mamouri Lakhdar 23/07/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23071984mmrlkhdrbnmrbtlhlm	0672167575	h_djellouli@esi.dz	0
218	\N	Fodil	\N	Abdelkader	M	1975-10-22	N	Non Definie	\N	\N	8	C	Lahcene	Azzi	Fatma	Fodil Abdelkader 22/10/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22101975fdlbdlkdrlhcnzftm	0672167575	h_djellouli@esi.dz	0
219	\N	Boukra	\N	Abdel Fatih	M	1971-08-18	N	Non Definie	\N	\N	8	D	Mohammed	Arefad	Fatma	Boukra Abdel Fatih 18/08/1971	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18081971bkrbdlfthmhmdrfdftm	0672167575	h_djellouli@esi.dz	0
220	\N	Zemmouli	\N	Aida	F	1981-04-02	N	Taoura	\N	\N	8	M	Boudjemaa	Teraa	Nedjma	Zemmouli Aida 02/04/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02041981zmldbjmtrnjm	0672167575	h_djellouli@esi.dz	0
221	\N	Draiaia	\N	Kamel	M	1974-08-14	N	Souk Ahras	\N	\N	8	M	Salah	Guettar	Fatma	Draiaia Kamel 14/08/1974	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	14081974drkmlslhgtrftm	0672167575	h_djellouli@esi.dz	0
222	\N	Benabed	\N	Youcef	M	1968-07-11	N	Non Definie	\N	\N	8	C	Moustapha	Benabed	Bekhta	Benabed Youcef 11/07/1968	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11071968bnbdcfmstphbnbdbkht	0672167575	h_djellouli@esi.dz	0
223	\N	Haffaf	\N	Abdelouafi	M	1978-09-10	N	Non Definie	\N	\N	8	D	Benamar	Belabdeli	Zahra	Haffaf Abdelouafi 10/09/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10091978hffbdlfbnmrblbdlzhr	0672167575	h_djellouli@esi.dz	0
224	\N	Merzouk	\N	Nor Eddine	M	1978-10-21	N	Non Definie	\N	\N	8	C	Ahmed	Medjahdi	Fatma	Merzouk Nor Eddine 21/10/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21101978mrzknrdnhmdmjhdftm	0672167575	h_djellouli@esi.dz	0
225	\N	Achachi	\N	Mounir	M	1980-09-09	N	Non Definie	\N	\N	8	C	Mohammed	Achachi	Djamila	Achachi Mounir 09/09/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09091980chchmnrmhmdchchjml	0672167575	h_djellouli@esi.dz	0
226	\N	Raoui	\N	Najib	M	1975-11-07	N	Non Definie	\N	\N	8	M	Ahmed	Raoui	Hafida	Raoui Najib 07/11/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07111975rnjbhmdrhfd	0672167575	h_djellouli@esi.dz	0
227	\N	Hadj Ali	\N	Abdelaziz	M	1979-06-19	N	Non Definie	\N	\N	8	M	Ahmed	Mehamedi	Kheira	Hadj Ali Abdelaziz 19/06/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19061979hjlbdlzzhmdmhmdkhr	0672167575	h_djellouli@esi.dz	0
228	\N	Bessouia	\N	Mohammed	M	1978-08-16	N	Non Definie	\N	\N	8	M	Mokadem	Hadjri	Fatiha	Bessouia Mohammed 16/08/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16081978bsmhmdmkdmhjrfth	0672167575	h_djellouli@esi.dz	0
229	\N	Hamidi	\N	Hocine	M	1981-12-11	N	Bouda	\N	\N	8	M	Boudjemaa	Saidi	Mebarka	Hamidi Hocine 11/12/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11121981hmdhcnbjmsdmbrk	0672167575	h_djellouli@esi.dz	0
230	\N	Hammad	\N	Ahmed	M	1971-09-24	N	Reggane	\N	\N	8	M	Sida Ahmed	Mahdjoubi	Mebirika	Hammad Ahmed 24/09/1971	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24091971hmdhmdsdhmdmhjbmbrk	0672167575	h_djellouli@esi.dz	0
231	\N	Tor	\N	Nour Eddine	M	1978-03-17	N	Non Definie	\N	\N	8	M	Ahmed	Soufi	Rachida	Tor Nour Eddine 17/03/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17031978trnrdnhmdsfrchd	0672167575	h_djellouli@esi.dz	0
232	\N	Beghou	\N	Choukri	M	1978-05-05	N	Ain Babouche	\N	\N	8	M	Maache	Kadem	Khadoudja	Beghou Choukri 05/05/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05051978bghchkrmchkdmkhdj	0672167575	h_djellouli@esi.dz	0
233	\N	Belbachir	\N	Houssameddine	M	1992-06-08	N	Non Definie	\N	\N	8	M	Madani	Bensaber	Aicha	Belbachir Houssameddine 08/06/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08061992blbchrhsmdnmdnbnsbrch	0672167575	h_djellouli@esi.dz	0
234	\N	Messaoudi	\N	Mahfoud	M	1982-03-22	N	Adrar	\N	\N	8	M	Mohammed	Messaoudi	Mebrouka	Messaoudi Mahfoud 22/03/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22031982msdmhfdmhmdmsdmbrk	0672167575	h_djellouli@esi.dz	0
235	\N	Arbi	\N	Ilyes	M	1986-06-19	N	Tiaret	\N	\N	8	M	Ghali	Boudjlida	Kheira	Arbi Ilyes 19/06/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19061986rblsghlbjldkhr	0672167575	h_djellouli@esi.dz	0
236	\N	Hiba	\N	Abdelkarim	M	1985-04-01	N	Tamest	\N	\N	8	M	Mohamed	Kachnaoui	Amati	Hiba Abdelkarim 01/04/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01041985hbbdlkrmmhmdkchnmt	0672167575	h_djellouli@esi.dz	0
237	\N	Chaib	\N	Khalid	M	1991-05-16	N	Oued Rhiou	\N	\N	8	M	Kaddour	Kallouche	Bakhta	Chaib Khalid 16/05/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16051991chbkhldkdrklchbkht	0672167575	h_djellouli@esi.dz	0
238	\N	Chetouane	\N	Mustapha	M	1982-10-19	N	Relizane	\N	\N	8	M	Abdelkader	Yaagoub	Fatima	Chetouane Mustapha 19/10/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19101982chtnmstphbdlkdrgbftm	0672167575	h_djellouli@esi.dz	0
240	\N	Belmokhtar	\N	Rabiha	M	1982-11-19	N	Non Definie	\N	\N	8	M	Mostefa	Bouzi	Yamina	Belmokhtar Rabiha 19/11/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19111982blmkhtrrbhmstfbzmn	0672167575	h_djellouli@esi.dz	0
241	\N	Taghribet	\N	Hadda	F	1980-03-31	N	Ain Babouche	\N	\N	8	M	Azeddine	Taghribet	Rebaia	Taghribet Hadda 31/03/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	31031980tghrbthdzdntghrbtrb	0672167575	h_djellouli@esi.dz	0
242	\N	Sebbar	\N	Fouad	M	1980-09-24	N	Oum Bouaghi	\N	\N	8	M	Tahar	Mefti	Mehria	Sebbar Fouad 24/09/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24091980sbrfdthrmftmhr	0672167575	h_djellouli@esi.dz	0
243	\N	Mekkaoui	\N	Omar	M	1984-02-24	N	Tsabit	\N	\N	8	M	Achour	Mekkaoui	Fatma	Mekkaoui Omar 24/02/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24021984mkmrchrmkftm	0672167575	h_djellouli@esi.dz	0
244	\N	Malki	\N	Meryem	F	1988-06-17	N	Non Definie	\N	\N	8	M	Omar	Ghayaib	El Zahra	Malki Meryem 17/06/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17061988mlkmrmmrghblzhr	0672167575	h_djellouli@esi.dz	0
245	\N	Kinna	\N	Mhammed	M	1983-03-03	N	Aougrout	\N	\N	8	M	Ahmed	Bahida	Fatna	Kinna Mhammed 03/03/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03031983knmhmdhmdbhdftn	0672167575	h_djellouli@esi.dz	0
246	\N	Grine	\N	Zouaoui	M	1976-05-10	N	Sidi Ali Boussidi	\N	\N	8	M	Youcef	Grine	Rekia	Grine Zouaoui 10/05/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10051976grnzcfgrnrk	0672167575	h_djellouli@esi.dz	0
247	\N	Djeriri	\N	Fethi	M	1987-12-07	N	Sidi Bel Abbes	\N	\N	8	M	Ahmed	Dahaoui	Fatiha	Djeriri Fethi 07/12/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07121987jrrfthhmddhfth	0672167575	h_djellouli@esi.dz	0
248	\N	Kebir	\N	Kaddour	M	1978-05-11	N	Sidi Ali Boussidi	\N	\N	8	M	Djillali	Bouchiba	Fatima	Kebir Kaddour 11/05/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11051978kbrkdrjllbchbftm	0672167575	h_djellouli@esi.dz	0
249	\N	Bousmaha	\N	Abdelkader	M	1977-09-10	N	Non Definie	\N	\N	8	M	Mohammed	Zahzouh	Houria	Bousmaha Abdelkader 10/09/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10091977bsmhbdlkdrmhmdzhzhhr	0672167575	h_djellouli@esi.dz	0
250	\N	Moumeni	\N	El Hadj	M	1974-07-18	N	Non Definie	\N	\N	8	M	Amar	Belarbi	Omelheir	Moumeni El Hadj 18/07/1974	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18071974mmnlhjmrblrbmlhr	0672167575	h_djellouli@esi.dz	0
251	\N	Gafour	\N	Kheir Eddine	M	1979-03-24	N	Ben Badis	\N	\N	8	M	Abdelkader	Khaldi	Djemaa	Gafour Kheir Eddine 24/03/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24031979gfrkhrdnbdlkdrkhldjm	0672167575	h_djellouli@esi.dz	0
252	\N	Zaidi	\N	Amina	F	1984-10-20	N	Tebessa	\N	\N	8	M	Athmane	Bouzid	Fadhila	Zaidi Amina 20/10/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20101984zdmnthmnbzdfdl	0672167575	h_djellouli@esi.dz	0
253	\N	Ziad	\N	Tarek	M	1979-12-03	N	Oum Bouaghi	\N	\N	8	M	Abderrachid	Ziad	Hadda	Ziad Tarek 03/12/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03121979zdtrkbdrchdzdhd	0672167575	h_djellouli@esi.dz	0
254	\N	Bouaziz	\N	Ramzi	M	1984-09-07	N	Oum Bouaghi	\N	\N	8	M	Ammar	Berkani	Fatim El Zahra	Bouaziz Ramzi 07/09/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07091984bzzrmzmrbrknftmlzhr	0672167575	h_djellouli@esi.dz	0
255	\N	Belhadi	\N	Hafida	F	1970-07-02	N	Non Definie	\N	\N	8	D	Menouar	Kahouadji	Kheira	Belhadi Hafida 02/07/1970	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02071970blhdhfdmnrkhjkhr	0672167575	h_djellouli@esi.dz	0
256	\N	Dahmani	\N	Hicham	M	1990-10-29	N	Non Definie	\N	\N	8	C	Omar	Kourichi	El Zahra	Dahmani Hicham 29/10/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29101990dhmnhchmmrkrchlzhr	0672167575	h_djellouli@esi.dz	0
257	\N	Cherak	\N	Saliha	F	1978-07-16	N	Sidi Bel Abbes	\N	\N	8	M	Zouaoui	Bessaad	Moulat	Cherak Saliha 16/07/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16071978chrkslhzbsdmlt	0672167575	h_djellouli@esi.dz	0
258	\N	Yarou	\N	Lakhdar Khalil	M	1982-07-22	N	Sidi Ali Boussidi	\N	\N	8	M	Sohbi	Berekla	Rachida	Yarou Lakhdar Khalil 22/07/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22071982rlkhdrkhllchbbrklrchd	0672167575	h_djellouli@esi.dz	0
259	\N	Mebarkia	\N	Smail	M	1966-01-07	N	Tebessa	\N	\N	8	M	Ali	Brakni	Djemaa	Mebarkia Smail 07/01/1966	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07011966mbrksmllbrknjm	0672167575	h_djellouli@esi.dz	0
260	\N	Boudali	\N	Abdallah	M	1981-05-01	N	Sidi Bel Abbes	\N	\N	8	M	Tahar	Bendjabbar	Djamaa	Boudali Abdallah 01/05/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01051981bdlbdlhthrbnjbrjm	0672167575	h_djellouli@esi.dz	0
261	\N	Mougas	\N	Souaad	F	1987-12-23	N	Non Definie	\N	\N	8	C	Mohammed	Kadi	Khadidja	Mougas Souaad 23/12/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23121987mgssdmhmdkdkhdj	0672167575	h_djellouli@esi.dz	0
262	\N	Djidj	\N	Azeddine	M	1975-02-11	N	Non Definie	\N	\N	8	M	Djilali	Lahmer	Zoulikha	Djidj Azeddine 11/02/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11021975jjzdnjlllhmrzlkh	0672167575	h_djellouli@esi.dz	0
264	\N	Dahmani	\N	Karim	M	1980-05-24	N	Yellel	\N	\N	8	M	Saada	Gourine	Fatima	Dahmani Karim 24/05/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24051980dhmnkrmsdgrnftm	0672167575	h_djellouli@esi.dz	0
265	\N	Kadri	\N	Abdelghani	M	1978-02-01	N	Non Definie	\N	\N	8	M	Bouarfa	Madouri	Fatma	Kadri Abdelghani 01/02/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01021978kdrbdlghnbrfmdrftm	0672167575	h_djellouli@esi.dz	0
266	\N	Rouigueb	\N	Kamal	M	1987-09-12	N	Non Definie	\N	\N	8	C	Mohammed	Messmoudi	Maghnia	Rouigueb Kamal 12/09/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12091987rgbkmlmhmdmsmdmghn	0672167575	h_djellouli@esi.dz	0
267	\N	Felouki	\N	Siham	F	1983-07-13	N	Non Definie	\N	\N	8	M	Mokhtar	Seddar	Halima	Felouki Siham 13/07/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13071983flkchmmkhtrsdrhlm	0672167575	h_djellouli@esi.dz	0
268	\N	Bensalah	\N	Abdellatif	M	1986-10-12	N	Non Definie	\N	\N	8	M	Bekkaye	Rahal	Habiba	Bensalah Abdellatif 12/10/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12101986bnslhbdltfbkrhlhbb	0672167575	h_djellouli@esi.dz	0
269	\N	Firane	\N	Nadjat	F	1967-12-22	N	Non Definie	\N	\N	8	M	Ramdane	Souiki	Zehour	Firane Nadjat 22/12/1967	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22121967frnnjtrmdnskzhr	0672167575	h_djellouli@esi.dz	0
270	\N	Nouichi	\N	Hakim	M	1975-07-28	N	Sour El Ghozlane	\N	\N	8	M	Mohammed	Belkacem	Aida	Nouichi Hakim 28/07/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28071975nchhkmmhmdblkcmd	0672167575	h_djellouli@esi.dz	0
271	\N	Dahmane	\N	Benziane	M	1979-08-27	N	Oued El Djemaa	\N	\N	8	M	Abdelkader	Mennad	Mahdjouba	Dahmane Benziane 27/08/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27081979dhmnbnznbdlkdrmndmhjb	0672167575	h_djellouli@esi.dz	0
272	\N	Otmane	\N	Mohamed	M	1983-02-25	N	Non Definie	\N	\N	8	M	Abdelaziz	Benabderahmane	Kabja	Otmane Mohamed 25/02/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25021983tmnmhmdbdlzzbnbdrhmnkbj	0672167575	h_djellouli@esi.dz	0
273	\N	Chougrani	\N	Abdelfattah	M	1992-01-29	N	Non Definie	\N	\N	8	M	Abdelkader	Merabti	Khadidja	Chougrani Abdelfattah 29/01/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29011992chgrnbdlfthbdlkdrmrbtkhdj	0672167575	h_djellouli@esi.dz	0
274	\N	Kaid Gharbi	\N	Ali	M	1983-06-28	N	Mohammadia	\N	\N	8	M	Beghachem	Benslimane	Yamina	Kaid Gharbi Ali 28/06/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28061983kdghrblbghchmbnslmnmn	0672167575	h_djellouli@esi.dz	0
275	\N	Boulekma	\N	Mouloud	M	1966-11-01	N	Skikda	\N	\N	8	M	Boudjemaa	Chakroun	Bahidja	Boulekma Mouloud 01/11/1966	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01111966blkmmldbjmchkrnbhj	0672167575	h_djellouli@esi.dz	0
276	\N	Nemer	\N	Soufyane	M	1989-12-21	N	Ain Babouche	\N	\N	8	M	Mokhtar	Lounadi	Djamila	Nemer Soufyane 21/12/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21121989nmrsfnmkhtrlndjml	0672167575	h_djellouli@esi.dz	0
277	\N	Zehir	\N	Zineddine	M	1986-05-28	N	Oued Zenati	\N	\N	8	M	Abd Elhak	Said	Meriem	Zehir Zineddine 28/05/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28051986zhrzndnbdlhksdmrm	0672167575	h_djellouli@esi.dz	0
278	\N	Zerzour	\N	Hani	M	1988-03-26	N	Oum Bouaghi	\N	\N	8	M	Azzeddine	Akran	Malika	Zerzour Hani 26/03/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26031988zrzrhnzdnkrnmlk	0672167575	h_djellouli@esi.dz	0
279	\N	Briki	\N	Mohammed Amine	M	1990-03-27	N	Non Definie	\N	\N	8	C	Houssine	Nabi	Sabira	Briki Mohammed Amine 27/03/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27031990brkmhmdmnhsnnbsbr	0672167575	h_djellouli@esi.dz	0
280	\N	Kheddar	\N	Ali	M	1984-02-21	N	Ain Babouche	\N	\N	8	M	Lahfidh	Zouaoui	Bahria	Kheddar Ali 21/02/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21021984khdrllhfdzbhr	0672167575	h_djellouli@esi.dz	0
281	\N	Touati	\N	Amor	M	1965-08-22	N	El Malabiod	\N	\N	8	M	Brahim	Merah	Zina	Touati Amor 22/08/1965	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22081965ttmrbrhmmrhzn	0672167575	h_djellouli@esi.dz	0
282	\N	Beghou	\N	Hichem	M	1986-10-09	N	Oum Bouaghi	\N	\N	8	M	Maache	Kadem	Khedoudja	Beghou Hichem 09/10/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09101986bghhchmmchkdmkhdj	0672167575	h_djellouli@esi.dz	0
283	\N	Bounadjati	\N	Rachid	M	1983-11-13	N	Ain Boucif	\N	\N	8	M	Mohamed	Baizid	Zouhra	Bounadjati Rachid 13/11/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13111983bnjtrchdmhmdbzdzhr	0672167575	h_djellouli@esi.dz	0
284	\N	Goual	\N	Hanane	F	1987-04-19	N	Non Definie	\N	\N	8	M	Rabah	Cheddad	Kheira	Goual Hanane 19/04/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19041987glhnnrbhchddkhr	0672167575	h_djellouli@esi.dz	0
285	\N	Bouchendouka	\N	Slimane	M	1953-07-17	N	Dirah	\N	\N	8	M	Abdelkader	Belabbes	Oumennoun	Bouchendouka Slimane 17/07/1953	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17071953bchndkslmnbdlkdrblbsmnn	0672167575	h_djellouli@esi.dz	0
286	\N	Chouat	\N	Mohammed	M	1974-05-15	N	Non Definie	\N	\N	8	M	Mohammed	Hadji	Fatma	Chouat Mohammed 15/05/1974	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15051974chtmhmdmhmdhjftm	0672167575	h_djellouli@esi.dz	0
287	\N	Hachemaoui	\N	Khaled	M	1985-10-06	N	El Hassassna	\N	\N	8	C	Abdelkader	Debbas	Setti	Hachemaoui Khaled 06/10/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06101985hchmkhldbdlkdrdbsst	0672167575	h_djellouli@esi.dz	0
288	\N	Hadjali	\N	Houari	M	1980-08-11	N	Non Definie	\N	\N	8	M	Ahmed	Hadjali	Fatiha	Hadjali Houari 11/08/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11081980hjlhrhmdhjlfth	0672167575	h_djellouli@esi.dz	0
289	\N	Bouderris	\N	Amina	F	1989-09-13	N	Mostafa Ben Brahim	\N	\N	8	C	Yahia	Talby	Malika	Bouderris Amina 13/09/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13091989bdrsmnhtlbmlk	0672167575	h_djellouli@esi.dz	0
290	\N	Belfrinette	\N	Imed	M	1996-02-01	N	Tebessa	\N	\N	8	C	Mohamed	Lemita	Mabrouka	Belfrinette Imed 01/02/1996	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01021996blfrntmdmhmdlmtmbrk	0672167575	h_djellouli@esi.dz	0
292	\N	Belhaouchet	\N	Lotfi	M	1984-05-02	N	Oued Zenati	\N	\N	8	M	Ahmed	Belhaouchet	Deloula	Belhaouchet Lotfi 02/05/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02051984blhchtltfhmdblhchtdll	0672167575	h_djellouli@esi.dz	0
293	\N	Mousselmal	\N	Rostom	M	1984-07-07	N	Berriane	\N	\N	8	D	Bakir	Fara	Aicha	Mousselmal Rostom 07/07/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07071984mslmlrstmbkrfrch	0672167575	h_djellouli@esi.dz	0
294	\N	Belarbi	\N	Samir	M	1986-08-26	N	El Bayadh	\N	\N	8	C	Benaissa	Messaoudi	Djamila	Belarbi Samir 26/08/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26081986blrbsmrbnsmsdjml	0672167575	h_djellouli@esi.dz	0
295	\N	Zaidi	\N	Zineb	F	1970-01-01	N	El Bayadh	\N	\N	8	D	Mohamed	Mahi	Rekia	Zaidi Zineb 01/01/1970	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01011970zdznbmhmdmhrk	0672167575	h_djellouli@esi.dz	0
296	\N	Chelghaf	\N	Messaouda	F	1981-02-18	N	El Bayadh	\N	\N	8	C	Laredje	Benkhada	Fatma Zohra	Chelghaf Messaouda 18/02/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18021981chlghfmsdlrjbnkhdftmzhr	0672167575	h_djellouli@esi.dz	0
297	\N	Hakimi	\N	Nasser Elddine	M	1994-03-11	N	Guelma	\N	\N	8	C	Med Elarbi	Amara Madi	Horia	Hakimi Nasser Elddine 11/03/1994	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11031994hkmnsrldnmdlrbmrmdhr	0672167575	h_djellouli@esi.dz	0
298	\N	Sedadka	\N	Samira	F	1981-12-05	N	El Bayadh	\N	\N	8	C	Naceur	Nouar	Messaouda	Sedadka Samira 05/12/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05121981sddksmrncrnrmsd	0672167575	h_djellouli@esi.dz	0
299	\N	Merine	\N	Younes	M	1993-10-08	N	Ben Badis	\N	\N	8	C	Menaouer	Zeriouh	Khadidja	Merine Younes 08/10/1993	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08101993mrnnsmnrzrhkhdj	0672167575	h_djellouli@esi.dz	0
300	\N	Ammour	\N	Karim	M	1982-07-10	N	Tenira	\N	\N	8	M	Mohamed	Kerroucha	Badra	Ammour Karim 10/07/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10071982mrkrmmhmdkrchbdr	0672167575	h_djellouli@esi.dz	0
301	\N	Marouf	\N	Mohamed	M	1988-06-20	N	Mohammadia	\N	\N	8	M	Ali	Rafaa	Djeouher	Marouf Mohamed 20/06/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20061988mrfmhmdlrfjhr	0672167575	h_djellouli@esi.dz	0
302	\N	Khlef	\N	El Hachemi	M	1987-09-16	N	Stitten	\N	\N	8	C	Cheikh	Djebbar	Aicha	Khlef El Hachemi 16/09/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16091987khlflhchmchkhjbrch	0672167575	h_djellouli@esi.dz	0
303	\N	Boukoullab	\N	Talia Habiba	F	1983-01-04	N	El Bayadh	\N	\N	8	D	Abdelkader	Belabbes	Khadidja	Boukoullab Talia Habiba 04/01/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04011983bklbtlhbbbdlkdrblbskhdj	0672167575	h_djellouli@esi.dz	0
304	\N	Sellami	\N	Salima	F	1965-10-12	N	El Bayadh	\N	\N	8	C	Cheikh	Hafed	Yamina	Sellami Salima 12/10/1965	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12101965slmslmchkhhfdmn	0672167575	h_djellouli@esi.dz	0
305	\N	Kaci Ousalah	\N	Yamina	F	1966-02-05	N	Berriane	\N	\N	8	D	Salah	Lassakeur	Menna	Kaci Ousalah Yamina 05/02/1966	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05021966kcslhmnslhlskrmn	0672167575	h_djellouli@esi.dz	0
306	\N	Benaida	\N	Mohamed	M	1993-10-16	N	El Bayadh	\N	\N	8	C	Kadda	Chargui	Fatima	Benaida Mohamed 16/10/1993	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16101993bndmhmdkdchrgftm	0672167575	h_djellouli@esi.dz	0
307	\N	Medjaldi	\N	Mounir	M	1978-02-26	N	Oued Zenati	\N	\N	8	M	Messaoud	Adjimi	Djemaa	Medjaldi Mounir 26/02/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26021978mjldmnrmsdjmjm	0672167575	h_djellouli@esi.dz	0
308	\N	Ali Cherif	\N	Khalid	M	1992-11-02	N	Guelma	\N	\N	8	C	Saleh	Ouenesse	Tayba	Ali Cherif Khalid 02/11/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02111992lchrfkhldslhnstb	0672167575	h_djellouli@esi.dz	0
309	\N	Ziainia	\N	Youcef	M	1984-01-18	N	Ksar Boukhari	\N	\N	8	C	Amouri	Boukahlfa	Barkahoum	Ziainia Youcef 18/01/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18011984zncfmrbkhlfbrkhm	0672167575	h_djellouli@esi.dz	0
310	\N	Boukhellad	\N	Djilali	M	1954-07-05	N	Hacine	\N	\N	8	M	Abdelkader	Bensahla	Yamina	Boukhellad Djilali 05/07/1954	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05071954bkhldjllbdlkdrbnchlmn	0672167575	h_djellouli@esi.dz	0
311	\N	Salhi	\N	Fethi	M	1978-08-30	N	Ben Badis	\N	\N	8	C	Mohamed	Ramdani	Rekia	Salhi Fethi 30/08/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30081978slhfthmhmdrmdnrk	0672167575	h_djellouli@esi.dz	0
312	\N	Saiah	\N	Ali	M	1988-11-15	N	Mohammadia	\N	\N	8	M	Dahou	Morsli	Noura	Saiah Ali 15/11/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15111988chldhmrslnr	0672167575	h_djellouli@esi.dz	0
313	\N	Tadjine	\N	Karima	F	1981-08-30	N	Saida	\N	\N	8	C	Djelloul	Baouch	Aicha	Tadjine Karima 30/08/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30081981tjnkrmjllbchch	0672167575	h_djellouli@esi.dz	0
314	\N	Belghachi	\N	Fadhila	F	1982-12-26	N	El Abiodh Sidi Cheikh	\N	\N	8	C	Tahar	Benaouda	Fatna	Belghachi Fadhila 26/12/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26121982blghchfdlthrbndftn	0672167575	h_djellouli@esi.dz	0
315	\N	Khene	\N	Lotfi	M	1993-11-03	N	Berriane	\N	\N	8	C	Salah	Mimouni	Zehour	Khene Lotfi 03/11/1993	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03111993khnltfslhmmnzhr	0672167575	h_djellouli@esi.dz	0
316	\N	Tadjine	\N	Fatiha	F	1983-08-03	N	Saida	\N	\N	8	C	Djelloul	Baouch	Aicha	Tadjine Fatiha 03/08/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03081983tjnfthjllbchch	0672167575	h_djellouli@esi.dz	0
317	\N	Hadjali	\N	Malika	F	1988-03-02	N	Ain Oussera	\N	\N	8	C	Mohammed	Hadjali	Khadra	Hadjali Malika 02/03/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02031988hjlmlkmhmdhjlkhdr	0672167575	h_djellouli@esi.dz	0
319	\N	Talhi	\N	Benattou	M	1986-02-08	N	Ben Badis	\N	\N	8	C	Abdelkader	Djoudi	Attaouia	Talhi Benattou 08/02/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08021986tlhbntbdlkdrjdt	0672167575	h_djellouli@esi.dz	0
320	\N	Nouasri	\N	Abdelali Ridallah	M	1968-01-04	N	Mohammadia	\N	\N	8	M	Bekada	Zerouali	Abbassia	Nouasri Abdelali Ridallah 04/01/1968	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04011968nsrbdllrdlhbkdzrlbs	0672167575	h_djellouli@esi.dz	0
321	\N	Ziani	\N	Houcine	M	1987-10-23	N	El Bayadh	\N	\N	8	C	Mohamed	Boudaoud	Meriem	Ziani Houcine 23/10/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23101987znhcnmhmdbddmrm	0672167575	h_djellouli@esi.dz	0
322	\N	Nasri	\N	Yasine	M	1985-02-10	N	El Bayadh	\N	\N	8	C	Miloud	Nasri	Bekhta	Nasri Yasine 10/02/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10021985nsrsnmldnsrbkht	0672167575	h_djellouli@esi.dz	0
323	\N	Sehibi	\N	Nour El Houda	F	1993-04-25	N	Saida	\N	\N	8	C	Bouanani	Bendjbara	Kheira	Sehibi Nour El Houda 25/04/1993	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25041993chbnrlhdbnnbnjbrkhr	0672167575	h_djellouli@esi.dz	0
324	\N	Ouragh	\N	Mohammed Lamine	M	1989-09-07	N	Berriane	\N	\N	8	M	Abderrahmane	Baheddi	Chikha	Ouragh Mohammed Lamine 07/09/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07091989rghmhmdlmnbdrhmnbhdchkh	0672167575	h_djellouli@esi.dz	0
325	109750334005340009	Gasmi	\N	Ahmed	M	1975-08-16	N	Bechloul	\N	\N	8	M	Ahmed	Chebout	Saada	Gasmi Ahmed 16/08/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16081975gsmhmdhmdchbtsd	0672167575	h_djellouli@esi.dz	0
326	\N	Habet	\N	Moussa	M	1981-09-25	N	Bechloul	\N	\N	8	M	Abderrahmane	Rabia	Zineb	Habet Moussa 25/09/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25091981hbtmsbdrhmnrbznb	0672167575	h_djellouli@esi.dz	0
327	\N	Kaciousalah	\N	Bakir	M	1966-09-28	N	Berriane	\N	\N	8	M	Mohammed	Lassakeur	Lalla	Kaciousalah Bakir 28/09/1966	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28091966kcslhbkrmhmdlskrll	0672167575	h_djellouli@esi.dz	0
328	\N	Mahboubi	\N	Hanane	F	1990-04-29	N	El Bayadh	\N	\N	8	C	Mohamed	Mahboubi	Rouba	Mahboubi Hanane 29/04/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29041990mhbbhnnmhmdmhbbrb	0672167575	h_djellouli@esi.dz	0
329	\N	Chagtmi	\N	Malika	F	1974-03-11	N	Tebessa	\N	\N	8	D	Mosbah	Lili	Ouarda	Chagtmi Malika 11/03/1974	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11031974chgtmmlkmsbhllrd	0672167575	h_djellouli@esi.dz	0
330	\N	Boudebous	\N	Abdelhakim	M	1979-07-30	N	El Kouif	\N	\N	8	D	Youcef	Attia	Amra	Boudebous Abdelhakim 30/07/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30071979bdbsbdlhkmcftmr	0672167575	h_djellouli@esi.dz	0
331	\N	Belbachir	\N	Amra	F	1982-03-07	N	Rogassa	\N	\N	8	C	Ramdane	Rabhallah	Fadhila	Belbachir Amra 07/03/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07031982blbchrmrrmdnrbhlhfdl	0672167575	h_djellouli@esi.dz	0
332	\N	Bensaad	\N	Aissa	M	1972-08-29	N	Laghouat	\N	\N	8	C	Lakmari	Djilali	Kheira	Bensaad Aissa 29/08/1972	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29081972bnsdslkmrjllkhr	0672167575	h_djellouli@esi.dz	0
333	\N	Bokhari	\N	Aboubakr	M	1991-01-21	N	Ksar Boukhari	\N	\N	8	C	Moustafa	Benhadjouja	Halima	Bokhari Aboubakr 21/01/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21011991bkhrbbkrmstfbnhjjhlm	0672167575	h_djellouli@esi.dz	0
334	\N	Lamri	\N	Hafsa	F	1989-10-29	N	Ain Sefra	\N	\N	8	D	Elaid	Daoudi	Yamina	Lamri Hafsa 29/10/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29101989lmrhfsldddmn	0672167575	h_djellouli@esi.dz	0
335	\N	Baouchi	\N	Abdallah	M	1987-04-29	N	Berriane	\N	\N	8	M	Brahim	Kaci Ousalah	Fatiha	Baouchi Abdallah 29/04/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29041987bchbdlhbrhmkcslhfth	0672167575	h_djellouli@esi.dz	0
336	\N	Lebbad	\N	Nadjat	F	1987-03-12	N	Tablat	\N	\N	8	M	Mokhtar	Bouguemra	Khadoudja	Lebbad Nadjat 12/03/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12031987lbdnjtmkhtrbgmrkhdj	0672167575	h_djellouli@esi.dz	0
337	\N	Abboud	\N	Fatima Zohra	F	1986-07-04	N	Berriane	\N	\N	8	D	Salah	Oulad Daoud	Fatiha	Abboud Fatima Zohra 04/07/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04071986bdftmzhrslhldddfth	0672167575	h_djellouli@esi.dz	0
338	\N	Zebir	\N	Nawal	F	1980-11-27	N	Ben Badis	\N	\N	8	C	Abdelkader	Saous	Taouia	Zebir Nawal 27/11/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27111980zbrnwlbdlkdrsst	0672167575	h_djellouli@esi.dz	0
339	\N	Fellah	\N	Chabane	M	1964-05-30	N	Sidi Lakhdar	\N	\N	8	M	Lakhdar	Fellah	Saadia	Fellah Chabane 30/05/1964	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30051964flhchbnlkhdrflhsd	0672167575	h_djellouli@esi.dz	0
340	\N	Benyammi	\N	Bachir	M	1987-10-25	N	Berriane	\N	\N	8	M	Bayoub	Dabouz	Nanna	Benyammi Bachir 25/10/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25101987bnmbchrbbdbznn	0672167575	h_djellouli@esi.dz	0
341	\N	Nouri	\N	Fatma	F	1979-09-01	N	Saida	\N	\N	8	D	Bachir	Belakhder	Hora	Nouri Fatma 01/09/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01091979nrftmbchrblkhdrhr	0672167575	h_djellouli@esi.dz	0
342	\N	Belarbi	\N	Aicha	F	1990-10-16	N	Sidi Tifour	\N	\N	8	C	Laredj	Haddi	Friha	Belarbi Aicha 16/10/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16101990blrbchlrjhdfrh	0672167575	h_djellouli@esi.dz	0
343	\N	Bachir Bouiadjra	\N	Bouziane	M	1970-10-16	N	Sidi Bel Abbes	\N	\N	8	M	Dris	Tayeb Cherif	Oum El Djillali	Bachir Bouiadjra Bouziane 16/10/1970	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16101970bchrbjrbzndrstbchrfmljll	0672167575	h_djellouli@esi.dz	0
344	\N	Zenati	\N	Yamen	M	1978-06-26	N	Sigus	\N	\N	8	M	Mohamed El Cherif	Mahboub	Halima	Zenati Yamen 26/06/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26061978zntmnmhmdlchrfmhbbhlm	0672167575	h_djellouli@esi.dz	0
345	\N	Djouad	\N	Ahlem	F	1990-05-02	N	Souk Ahras	\N	\N	8	M	Saddek	Djouad	Mira	Djouad Ahlem 02/05/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02051990jdhlmsdkjdmr	0672167575	h_djellouli@esi.dz	0
346	\N	Yousfi	\N	Wafaa	F	1992-04-15	N	El Bayadh	\N	\N	8	C	Toumi	Abdellali	Aicha	Yousfi Wafaa 15/04/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15041992sfwftmbdllch	0672167575	h_djellouli@esi.dz	0
347	\N	Ferrah	\N	Mohamed	M	1982-01-08	N	Ain Boucif	\N	\N	8	M	Abdelhafid	Benmeraissi	Barkahou	Ferrah Mohamed 08/01/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08011982frhmhmdbdlhfdbnmrsbrkh	0672167575	h_djellouli@esi.dz	0
348	\N	Cheghib	\N	Samir	M	1974-07-14	N	Annaba	\N	\N	8	M	Abdelbaki	Touazit	Mahbouba	Cheghib Samir 14/07/1974	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	14071974chghbsmrbdlbktztmhbb	0672167575	h_djellouli@esi.dz	0
350	\N	Daghboudj	\N	Boutaina	F	1984-02-16	N	Tebessa	\N	\N	8	M	Tahar	Belgacem	Fatma	Daghboudj Boutaina 16/02/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16021984dghbjbtnthrblgcmftm	0672167575	h_djellouli@esi.dz	0
351	\N	Medghoul	\N	Abdelhafid	M	1982-01-05	N	Arris	\N	\N	8	M	Ahmed	Souanef	Fatma	Medghoul Abdelhafid 05/01/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05011982mdghlbdlhfdhmdsnfftm	0672167575	h_djellouli@esi.dz	0
352	\N	Kherroubi	\N	Hacene	M	1966-07-31	N	Ain Boucif	\N	\N	8	M	Aissa	Sebssi	Nakhla	Kherroubi Hacene 31/07/1966	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	31071966khrbhcnssbsnkhl	0672167575	h_djellouli@esi.dz	0
353	\N	Bensaha	\N	Meriem	F	1970-02-23	N	Tlemcen	\N	\N	8	C	Yahia	Bendellaa	Khara	Bensaha Meriem 23/02/1970	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23021970bnchmrmhbndlkhr	0672167575	h_djellouli@esi.dz	0
354	\N	Djellab	\N	Sebti	M	1967-09-17	N	Doukane	\N	\N	8	M	Ali	Sifaoui	Zaara	Djellab Sebti 17/09/1967	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17091967jlbsbtlsfzr	0672167575	h_djellouli@esi.dz	0
355	\N	Sais	\N	Mohamed	M	1982-07-01	N	Blida	\N	\N	8	M	Ali	Sedira	Aicha	Sais Mohamed 01/07/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01071982ssmhmdlsdrch	0672167575	h_djellouli@esi.dz	0
356	\N	Meslem	\N	Zouaoui	M	1976-01-05	N	Ben Badis	\N	\N	8	M	Mohamed	Djabbour	Fatma	Meslem Zouaoui 05/01/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05011976mslmzmhmdjbrftm	0672167575	h_djellouli@esi.dz	0
357	\N	Bouras	\N	Miloud	M	1973-05-09	N	El Bayadh	\N	\N	8	M	Bouhafs	Mahi	Fatima	Bouras Miloud 09/05/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09051973brsmldbhfsmhftm	0672167575	h_djellouli@esi.dz	0
358	\N	Hamidat	\N	Ahmed	M	1971-03-15	N	Rogassa	\N	\N	8	M	Abdelkader	Hakmi	Lalia	Hamidat Ahmed 15/03/1971	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15031971hmdthmdbdlkdrhkmll	0672167575	h_djellouli@esi.dz	0
359	\N	Guettatfi	\N	Mohamed	M	1993-12-17	N	El Bayadh	\N	\N	8	C	Abid	Kouar	Rekia	Guettatfi Mohamed 17/12/1993	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17121993gttfmhmdbdkrrk	0672167575	h_djellouli@esi.dz	0
360	\N	Benaouda	\N	Harrat	M	1966-10-19	N	Zemmoura	\N	\N	8	M	Abdelkader	Adda Benyoucef	Djazia	Benaouda Harrat 19/10/1966	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19101966bndhrtbdlkdrdbncfjz	0672167575	h_djellouli@esi.dz	0
361	\N	Hakkoum	\N	Rabia	F	1982-07-04	N	El Bayadh	\N	\N	8	C	Bachir	Abdoun	Fatima	Hakkoum Rabia 04/07/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04071982hkmrbbchrbdnftm	0672167575	h_djellouli@esi.dz	0
362	\N	Bouras	\N	Samira	F	1985-08-24	N	El Bayadh	\N	\N	8	M	Kebir	Bouras	Khadidja	Bouras Samira 24/08/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24081985brssmrkbrbrskhdj	0672167575	h_djellouli@esi.dz	0
363	\N	Hamadi	\N	Saliha	F	1984-01-02	N	Boghni	\N	\N	8	M	Mohamed Said	Attab	Ouiza	Hamadi Saliha 02/01/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02011984hmdslhmhmdsdtbz	0672167575	h_djellouli@esi.dz	0
364	\N	Meneceur	\N	Mawloud	M	1988-10-24	N	Sidi Lakhdar	\N	\N	8	M	Ahmed	Menaceur	Halima	Meneceur Mawloud 24/10/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24101988mncrmwldhmdmncrhlm	0672167575	h_djellouli@esi.dz	0
365	\N	Lahmar	\N	Houaria	F	1978-10-30	N	Sidi Bel Abbes	\N	\N	8	M	Mohamed	Mouket	Fatma	Lahmar Houaria 30/10/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30101978lhmrhrmhmdmktftm	0672167575	h_djellouli@esi.dz	0
366	\N	Bekhaled	\N	Zakarya	M	1986-08-25	N	Tlemcen	\N	\N	8	M	Mohammed	Hazel	Bent Ahmed	Bekhaled Zakarya 25/08/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25081986bkhldzkrmhmdhzlbnthmd	0672167575	h_djellouli@esi.dz	0
367	\N	El Mestari	\N	Kamel	M	1975-11-18	N	Sidi Ali Boussidi	\N	\N	8	M	Bekhaled	Miloud Bida	Aicha	El Mestari Kamel 18/11/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18111975lmstrkmlbkhldmldbdch	0672167575	h_djellouli@esi.dz	0
368	\N	Adjoudj	\N	Youcef	M	1982-06-17	N	Ben Badis	\N	\N	8	M	Abdesselam	El Mehadji	Yamina	Adjoudj Youcef 17/06/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17061982jjcfbdslmlmhjmn	0672167575	h_djellouli@esi.dz	0
369	\N	Meskine	\N	Toufik	M	1985-09-08	N	Laghouat	\N	\N	8	M	Mhamed	Gueddouh	Gamra	Meskine Toufik 08/09/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08091985mskntfkmhmdgdhgmr	0672167575	h_djellouli@esi.dz	0
370	\N	Amarouche	\N	Nadjouia	F	1979-08-22	N	Sidi Bel Abbes	\N	\N	8	M	Miloud	Hadba	Fatima	Amarouche Nadjouia 22/08/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22081979mrchnjmldhdbftm	0672167575	h_djellouli@esi.dz	0
371	\N	Besseghir	\N	Elhadj	M	1980-02-15	N	Mendes	\N	\N	8	M	Menaouar	Maya	Kheira	Besseghir Elhadj 15/02/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15021980bsghrlhjmnrmkhr	0672167575	h_djellouli@esi.dz	0
372	\N	Zanat	\N	Mohammed Abdelkrim	M	1979-05-01	N	Oued Zenati	\N	\N	8	M	Abdelatif	Dorbani	Ouarda	Zanat Mohammed Abdelkrim 01/05/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01051979zntmhmdbdlkrmbdltfdrbnrd	0672167575	h_djellouli@esi.dz	0
373	\N	Bougherara	\N	Faycal	M	1970-02-26	N	Sedrata	\N	\N	8	M	Essadi	Debache	Leila	Bougherara Faycal 26/02/1970	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26021970bghrrfclsddbchll	0672167575	h_djellouli@esi.dz	0
374	\N	Hafiane	\N	Fatima Zohra	F	1978-11-17	N	Ain Skhouna	\N	\N	8	M	Abdelkader	Salami	Zohra	Hafiane Fatima Zohra 17/11/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17111978hfnftmzhrbdlkdrslmzhr	0672167575	h_djellouli@esi.dz	0
375	\N	Besseghier	\N	Mohamed	M	1968-03-03	N	Mendes	\N	\N	8	M	Kaddour	Taifour	Badra	Besseghier Mohamed 03/03/1968	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03031968bsghrmhmdkdrtfrbdr	0672167575	h_djellouli@esi.dz	0
376	\N	Bekkadour	\N	Madjid	M	1983-12-27	N	Mendes	\N	\N	8	M	Abdelkader	Benfraiha	Zohra	Bekkadour Madjid 27/12/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27121983bkdrmjdbdlkdrbnfrhzhr	0672167575	h_djellouli@esi.dz	0
377	\N	Medjdoub	\N	Mohamed Reda	M	1989-06-16	N	Ben Badis	\N	\N	8	M	Mohamed	Deham	Abbassia	Medjdoub Mohamed Reda 16/06/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16061989mjdbmhmdrdmhmddhmbs	0672167575	h_djellouli@esi.dz	0
379	\N	Boukhatmi	\N	Abdelhadi	M	1993-01-20	N	Mostafa Ben Brahim	\N	\N	8	C	Mohamed	Ennemiche	Khadidja	Boukhatmi Abdelhadi 20/01/1993	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20011993bkhtmbdlhdmhmdnmchkhdj	0672167575	h_djellouli@esi.dz	0
380	\N	Yarou	\N	Okacha	M	1986-09-09	N	Sidi Bel Abbes	\N	\N	8	M	Bouziane	Belabbes	Badra	Yarou Okacha 09/09/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09091986rkchbznblbsbdr	0672167575	h_djellouli@esi.dz	0
381	\N	Djabba	\N	Samia	F	1985-12-10	N	Annaba	\N	\N	8	C	Mohamed Etahar	Belkahla	Fatiha	Djabba Samia 10/12/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10121985jbsmmhmdthrblkhlfth	0672167575	h_djellouli@esi.dz	0
382	\N	Smala	\N	Amina	F	1989-05-13	N	Sigus	\N	\N	8	M	Ali	Djaber	Saida	Smala Amina 13/05/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13051989smlmnljbrsd	0672167575	h_djellouli@esi.dz	0
383	\N	Sidoumou	\N	Mounira Fatma	F	1977-01-06	N	Hadjout	\N	\N	8	M	Mohamed	Bouamra Souma	Fetoum	Sidoumou Mounira Fatma 06/01/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06011977sdmmnrftmmhmdbmrsmftm	0672167575	h_djellouli@esi.dz	0
384	\N	Harabi	\N	Mohamed Hichame	M	1988-08-03	N	Ain Boucif	\N	\N	8	M	Abdelouaheb	Zaoui	Fatiha	Harabi Mohamed Hichame 03/08/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03081988hrbmhmdhchmbdlhbzfth	0672167575	h_djellouli@esi.dz	0
385	\N	Adim	\N	Ahmed	M	1959-08-15	N	Mostafa Ben Brahim	\N	\N	8	M	Abdelkader	Didaoui	Zohra	Adim Ahmed 15/08/1959	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15081959dmhmdbdlkdrddzhr	0672167575	h_djellouli@esi.dz	0
386	\N	Benmoussa	\N	Omar	M	1987-04-06	N	Zahana	\N	\N	8	M	Kada	Bensedjad	Yamina	Benmoussa Omar 06/04/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06041987bnmsmrkdbnsjdmn	0672167575	h_djellouli@esi.dz	0
387	\N	Aoukhalouf	\N	Sohbi Benali	M	1976-08-30	N	Sidi Ali Boussidi	\N	\N	8	M	Maachou	Baghdoud	Setti	Aoukhalouf Sohbi Benali 30/08/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30081976khlfchbbnlmchbghddst	0672167575	h_djellouli@esi.dz	0
388	\N	Delhoum	\N	Sidi Mohamed	M	1976-07-28	N	Sidi Bel Abbes	\N	\N	8	M	Lakhdar	Laradji	Yamina	Delhoum Sidi Mohamed 28/07/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28071976dlhmsdmhmdlkhdrlrjmn	0672167575	h_djellouli@esi.dz	0
389	\N	Khabez	\N	Lakhdar	M	1981-11-08	N	Sidi Bel Abbes	\N	\N	8	M	Abdelkader	Bengerine	Khadra	Khabez Lakhdar 08/11/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08111981khbzlkhdrbdlkdrbngrnkhdr	0672167575	h_djellouli@esi.dz	0
390	\N	Garoui	\N	Khalid	M	1985-03-16	N	Sedrata	\N	\N	8	M	Mohamed Nacer	Marouf	Nouara	Garoui Khalid 16/03/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16031985grkhldmhmdncrmrfnr	0672167575	h_djellouli@esi.dz	0
391	\N	Benyoub	\N	Nehed	F	1986-01-11	N	Sedrata	\N	\N	8	M	Ammar	Bouisri	Fatiha	Benyoub Nehed 11/01/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11011986bnbnhdmrbsrfth	0672167575	h_djellouli@esi.dz	0
392	\N	Ridal	\N	Mohamed	M	1975-01-29	N	Sidi Bel Abbes	\N	\N	8	M	Abdelkader	Hebri	Kheira	Ridal Mohamed 29/01/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29011975rdlmhmdbdlkdrhbrkhr	0672167575	h_djellouli@esi.dz	0
393	\N	Boulares	\N	Souad	F	1978-08-29	N	Annaba	\N	\N	8	D	Moussa	Kheladi	Ouria	Boulares Souad 29/08/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29081978blrssdmskhldr	0672167575	h_djellouli@esi.dz	0
394	\N	Sekkoum	\N	Zouaoui	M	1985-01-09	N	Sidi Bel Abbes	\N	\N	8	M	Mohamed	Benhamouda	Zoulikha	Sekkoum Zouaoui 09/01/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09011985skmzmhmdbnhmdzlkh	0672167575	h_djellouli@esi.dz	0
395	\N	Bouacha	\N	Loubna	F	1987-09-24	N	Annaba	\N	\N	8	C	Lekhmissi	Ferdi	Badiaa	Bouacha Loubna 24/09/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24091987bchlbnlkhmsfrdbd	0672167575	h_djellouli@esi.dz	0
396	\N	Bentayeb	\N	Kaddour	M	1992-04-11	N	Sidi Bel Abbes	\N	\N	8	C	Mohamed	Allam	Attaouia	Bentayeb Kaddour 11/04/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11041992bntbkdrmhmdlmt	0672167575	h_djellouli@esi.dz	0
397	\N	Boudjenah	\N	Habib	M	1992-12-21	N	Hamri	\N	\N	8	M	Amar	Merzougui	Aicha	Boudjenah Habib 21/12/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21121992bjnhhbbmrmrzgch	0672167575	h_djellouli@esi.dz	0
398	\N	Ziani	\N	Farid	M	1987-09-12	N	Oued Zenati	\N	\N	8	M	Abdelkarim	Mrad	Seghira	Ziani Farid 12/09/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12091987znfrdbdlkrmmrdsghr	0672167575	h_djellouli@esi.dz	0
399	\N	Bittour	\N	Iman	F	1985-08-08	N	Souk Ahras	\N	\N	8	M	Kamel	Djebablia	Chafika	Bittour Iman 08/08/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08081985btrmnkmljbblchfk	0672167575	h_djellouli@esi.dz	0
400	\N	Zidane	\N	Mohammed Essaleh	M	1994-01-07	N	Oued Zenati	\N	\N	8	C	Ali	Hadouche	Hadda	Zidane Mohammed Essaleh 07/01/1994	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07011994zdnmhmdslhlhdchhd	0672167575	h_djellouli@esi.dz	0
401	\N	Si Larbi	\N	Omar	M	1986-06-25	N	Ramka	\N	\N	8	M	Bettahar	Djelouli	Fatma	Si Larbi Omar 25/06/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25061986slrbmrbthrjllftm	0672167575	h_djellouli@esi.dz	0
402	\N	Gaid	\N	Mohamed	M	1982-09-25	N	Ben Badis	\N	\N	8	M	Ahmed	Saim	Fatiha	Gaid Mohamed 25/09/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25091982gdmhmdhmdsmfth	0672167575	h_djellouli@esi.dz	0
403	\N	Beldjiriouet	\N	Yamina	F	1973-03-26	N	Mostafa Ben Brahim	\N	\N	8	M	Larbi	Sahih	Chemssa	Beldjiriouet Yamina 26/03/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26031973bljrtmnlrbchhchms	0672167575	h_djellouli@esi.dz	0
404	\N	Benaissa	\N	Ahmed	M	1965-06-28	N	Ben Badis	\N	\N	8	M	Larbi	Taibi	Djemaa	Benaissa Ahmed 28/06/1965	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28061965bnshmdlrbtbjm	0672167575	h_djellouli@esi.dz	0
405	\N	Smichette	\N	Karim	M	1976-02-06	N	Souk Ahras	\N	\N	8	D	Abdellaziz	Bendous	Fatima	Smichette Karim 06/02/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06021976smchtkrmbdlzzbndsftm	0672167575	h_djellouli@esi.dz	0
406	\N	Keciba	\N	Ahmed	M	1988-06-03	N	Laghouat	\N	\N	8	M	Djamaleddine	Talbi	Mamma	Keciba Ahmed 03/06/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03061988kcbhmdjmldntlbmm	0672167575	h_djellouli@esi.dz	0
407	\N	Miloudi	\N	Abdelkader	M	1973-11-14	N	Sidi Bel Abbes	\N	\N	8	M	Mohamed	Bouchenafi	Badra	Miloudi Abdelkader 14/11/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	14111973mldbdlkdrmhmdbchnfbdr	0672167575	h_djellouli@esi.dz	0
408	\N	Otmani	\N	Amar	M	1974-08-01	N	Telagh	\N	\N	8	M	Ahmed	Hallouche	Fatna	Otmani Amar 01/08/1974	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01081974tmnmrhmdhlchftn	0672167575	h_djellouli@esi.dz	0
409	\N	Nouar	\N	Ghalem	M	1972-08-24	N	Sidi Bel Abbes	\N	\N	8	M	Ali	Achour	Sadia	Nouar Ghalem 24/08/1972	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24081972nrghlmlchrsd	0672167575	h_djellouli@esi.dz	0
410	\N	Douba	\N	Ahmed	M	1966-05-23	N	Rouina	\N	\N	8	C	Omar	Ferrah	Fatma	Douba Ahmed 23/05/1966	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23051966dbhmdmrfrhftm	0672167575	h_djellouli@esi.dz	0
411	\N	Hammou	\N	Dalila	F	1969-03-02	N	Sidi Bel Abbes	\N	\N	8	D	Lakhdar	Sahali	Zoulikha	Hammou Dalila 02/03/1969	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02031969hmdlllkhdrchlzlkh	0672167575	h_djellouli@esi.dz	0
412	\N	Anani	\N	Kadda	M	1965-03-18	N	Boukadir	\N	\N	8	M	Abdelkader	Anani	Zohra	Anani Kadda 18/03/1965	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18031965nnkdbdlkdrnnzhr	0672167575	h_djellouli@esi.dz	0
413	\N	Slimani	\N	Smain	M	1983-05-02	N	Houari Boumedien	\N	\N	8	M	Mohammed	Hanache	Zbida	Slimani Smain 02/05/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02051983slmnsmnmhmdhnchzbd	0672167575	h_djellouli@esi.dz	0
414	\N	Boumazza	\N	Abdelkader	M	1965-03-29	N	Ben Badis	\N	\N	8	M	Mohamed	Kadri	Yamina	Boumazza Abdelkader 29/03/1965	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29031965bmzbdlkdrmhmdkdrmn	0672167575	h_djellouli@esi.dz	0
415	\N	Elbagui	\N	Mohamed	M	1972-06-07	N	Saida	\N	\N	8	M	Laradj	Ziad	Fatima	Elbagui Mohamed 07/06/1972	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07061972lbgmhmdlrjzdftm	0672167575	h_djellouli@esi.dz	0
416	\N	Meddah	\N	Bachir	M	1980-10-07	N	Mecheria	\N	\N	8	M	Ali	Negadi	Djemaa	Meddah Bachir 07/10/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07101980mdhbchrlngdjm	0672167575	h_djellouli@esi.dz	0
417	\N	Ameur	\N	Ameur	M	1980-08-20	N	Ain Boucif	\N	\N	8	M	Mohamed	Mechri	Ouarkia	Ameur Ameur 20/08/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20081980mrmrmhmdmchrrk	0672167575	h_djellouli@esi.dz	0
418	\N	Zegrar	\N	Lakhdar	M	1970-06-01	N	Ghardaia	\N	\N	8	M	Saad	Heriz	Meriem	Zegrar Lakhdar 01/06/1970	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01061970zgrrlkhdrsdhrzmrm	0672167575	h_djellouli@esi.dz	0
419	\N	Djilali	\N	Menouer	M	1968-05-30	N	Mohammadia	\N	\N	8	C	Abdelkader	Kalbaz	Zineb	Djilali Menouer 30/05/1968	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30051968jllmnrbdlkdrklbzznb	0672167575	h_djellouli@esi.dz	0
420	\N	Bekkouche Benziane	\N	Djilali	M	1979-08-25	N	Boukadir	\N	\N	8	M	Abdelkader	Galfout	Fatma	Bekkouche Benziane Djilali 25/08/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25081979bkchbnznjllbdlkdrglftftm	0672167575	h_djellouli@esi.dz	0
421	\N	Abid	\N	Djamal	M	1961-06-30	N	Nedroma	\N	\N	8	M	Lakhdar	Tekkouk	Amara	Abid Djamal 30/06/1961	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30061961bdjmllkhdrtkkmr	0672167575	h_djellouli@esi.dz	0
422	\N	Achi	\N	Karima	F	1972-10-16	N	Morsott	\N	\N	8	M	Rebiai	Abrane	Hizia	Achi Karima 16/10/1972	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16101972chkrmrbbrnhz	0672167575	h_djellouli@esi.dz	0
423	\N	Benchikha	\N	Khelifa	M	1978-01-09	N	Sigus	\N	\N	8	M	Hacene	Benamra	Fatma	Benchikha Khelifa 09/01/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09011978bnchkhkhlfhcnbnmrftm	0672167575	h_djellouli@esi.dz	0
424	\N	Abeidallah	\N	Mustapha	M	1984-02-28	N	Ben Badis	\N	\N	8	M	Mohamed	Hamdache	Kheira	Abeidallah Mustapha 28/02/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28021984bdlhmstphmhmdhmdchkhr	0672167575	h_djellouli@esi.dz	0
425	\N	Nouadri	\N	Rabeh	M	1982-04-27	N	Ksar Sbahi	\N	\N	8	M	Abdelaziz	Nouadri	Bariza	Nouadri Rabeh 27/04/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27041982ndrrbhbdlzzndrbrz	0672167575	h_djellouli@esi.dz	0
426	\N	Abbou	\N	Amel	F	1990-01-04	N	Sidi Bel Abbes	\N	\N	8	M	Cheikh	Mezroui	Malika	Abbou Amel 04/01/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04011990bmlchkhmzrmlk	0672167575	h_djellouli@esi.dz	0
427	\N	Aggoun	\N	Besma	F	1982-09-12	N	Sigus	\N	\N	8	M	Noreddine	Adjnef	Oumhani	Aggoun Besma 12/09/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12091982gnbsmnrdnjnfmhn	0672167575	h_djellouli@esi.dz	0
428	\N	Remache	\N	Malek	M	1975-12-04	N	Annaba	\N	\N	8	M	Houcine	Remache	Jaghmouma	Remache Malek 04/12/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04121975rmchmlkhcnrmchjghmm	0672167575	h_djellouli@esi.dz	0
429	\N	Kenz	\N	Chafiq	M	1983-01-02	N	Sigus	\N	\N	8	M	Derradji	Hemil	Hadhria	Kenz Chafiq 02/01/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02011983knzchfqdrjhmlhdr	0672167575	h_djellouli@esi.dz	0
430	\N	Aissaoui	\N	Mourad	M	1974-06-03	N	Tlemcen	\N	\N	8	M	Mohammed	Aissaoui	Kheira	Aissaoui Mourad 03/06/1974	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03061974smrdmhmdskhr	0672167575	h_djellouli@esi.dz	0
431	\N	Bensada	\N	Rafik	M	1980-03-03	N	El Kouif	\N	\N	8	M	Mohammed	Khemaissia	Kheira	Bensada Rafik 03/03/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03031980bnsdrfkmhmdkhmskhr	0672167575	h_djellouli@esi.dz	0
432	\N	Batoul	\N	Zoubir	M	1976-02-03	N	Berriche	\N	\N	8	M	Ammar	Bouslah	Rouba	Batoul Zoubir 03/02/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03021976btlzbrmrbslhrb	0672167575	h_djellouli@esi.dz	0
433	\N	Zerroug	\N	Fateh Eddine	M	1970-10-18	N	Constantine	\N	\N	8	M	Abdallah	Messikh	Chemama	Zerroug Fateh Eddine 18/10/1970	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18101970zrgfthdnbdlhmskhchmm	0672167575	h_djellouli@esi.dz	0
434	\N	Djaffri	\N	Mohammed Anis	M	1985-07-09	N	Tlemcen	\N	\N	8	M	Nasreddine	Radjaa	Nacera	Djaffri Mohammed Anis 09/07/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09071985jfrmhmdnsnsrdnrjncr	0672167575	h_djellouli@esi.dz	0
435	\N	Keddar	\N	Achour	M	1983-10-15	N	Tlemcen	\N	\N	8	M	Miloud	Malek	Rabia	Keddar Achour 15/10/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15101983kdrchrmldmlkrb	0672167575	h_djellouli@esi.dz	0
436	\N	Berrais	\N	Assam	M	1987-04-20	N	El Kouif	\N	\N	8	M	Mohammed	Berrais	Henia	Berrais Assam 20/04/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20041987brssmmhmdbrshn	0672167575	h_djellouli@esi.dz	0
437	\N	Belbachir	\N	Farah	F	1984-02-24	N	Sidi Bel Abbes	\N	\N	8	M	Abdelkader	Dani El Kebir	Karima	Belbachir Farah 24/02/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24021984blbchrfrhbdlkdrdnlkbrkrm	0672167575	h_djellouli@esi.dz	0
438	\N	Nouadri	\N	Hemza	M	1984-10-28	N	Ksar Sbahi	\N	\N	8	M	Lamri	Boujmar	Malika	Nouadri Hemza 28/10/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28101984ndrhmzlmrbjmrmlk	0672167575	h_djellouli@esi.dz	0
439	\N	Malti	\N	Mohammed Yassine	M	1988-07-27	N	Tlemcen	\N	\N	8	C	Abderrazzek	Technar	Nadera	Malti Mohammed Yassine 27/07/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27071988mltmhmdsnbdrzktchnrndr	0672167575	h_djellouli@esi.dz	0
440	\N	Belhamiti	\N	Mohammed	M	1985-06-30	N	Sidi Ali	\N	\N	8	M	El Hadj Mostefa	Belhamiti	Nacera	Belhamiti Mohammed 30/06/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30061985blhmtmhmdlhjmstfblhmtncr	0672167575	h_djellouli@esi.dz	0
441	\N	Bensalah	\N	Boumediene	M	1972-10-22	N	Tlemcen	\N	\N	8	M	Mohammed	Bensalah	Fatma	Bensalah Boumediene 22/10/1972	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22101972bnslhbmdnmhmdbnslhftm	0672167575	h_djellouli@esi.dz	0
442	\N	Hammou Tani	\N	Sarra Kawther	F	1990-03-30	N	Tlemcen	\N	\N	8	M	Nasreddine	Radjaa	Leila	Hammou Tani Sarra Kawther 30/03/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30031990hmtnsrkwthrnsrdnrjll	0672167575	h_djellouli@esi.dz	0
443	\N	Lounissi	\N	Nour Eddine	M	1978-07-07	N	Bir Bouhouche	\N	\N	8	M	Abdelmadjid	Harath	Aicha	Lounissi Nour Eddine 07/07/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07071978lnsnrdnbdlmjdhrthch	0672167575	h_djellouli@esi.dz	0
444	\N	Zoghmar	\N	Hayet	F	1981-01-01	N	Ain M'Lila	\N	\N	8	M	Achour	Bouaita	Fatma	Zoghmar Hayet 01/01/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01011981zghmrhtchrbtftm	0672167575	h_djellouli@esi.dz	0
445	\N	Boumendjel	\N	Habib	M	1977-01-01	N	Gouray	\N	\N	8	M	Mesbah	Bouechma	Djouhra	Boumendjel Habib 01/01/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01011977bmnjlhbbmsbhbchmjhr	0672167575	h_djellouli@esi.dz	0
446	\N	Alioui	\N	Samira	F	1985-07-19	N	Tlemcen	\N	\N	8	M	Ahmed	Allioui	Bakhta	Alioui Samira 19/07/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19071985lsmrhmdlbkht	0672167575	h_djellouli@esi.dz	0
447	\N	Salmi	\N	Achour	M	1973-02-20	N	Sigus	\N	\N	8	M	Ammar	Soudani	Torkia	Salmi Achour 20/02/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20021973slmchrmrsdntrk	0672167575	h_djellouli@esi.dz	0
448	\N	Abdelali	\N	Karim	M	1969-07-25	N	Tlemcen	\N	\N	8	M	Mohammed Abdelouahab	Khaouani	Rabia	Abdelali Karim 25/07/1969	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25071969bdllkrmmhmdbdlhbkhnrb	0672167575	h_djellouli@esi.dz	0
449	\N	Bouteraa	\N	Sami	M	1993-02-19	N	El Kouif	\N	\N	8	M	Abdallah	Taamallah	Naoua	Bouteraa Sami 19/02/1993	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19021993btrsmbdlhtmlhn	0672167575	h_djellouli@esi.dz	0
450	\N	Boudouaia	\N	Amar	M	1985-10-29	N	Sidi Bel Abbes	\N	\N	8	M	Bouhous	Hakmi	Djamaa	Boudouaia Amar 29/10/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29101985bdmrbhshkmjm	0672167575	h_djellouli@esi.dz	0
451	\N	Khedim	\N	Yahia	M	1990-09-01	N	Sfisef	\N	\N	8	M	Aissa	Merabet	Malika	Khedim Yahia 01/09/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01091990khdmhsmrbtmlk	0672167575	h_djellouli@esi.dz	0
452	\N	Ammari	\N	Errabei	M	1977-12-18	N	Arris	\N	\N	8	M	Said	Ammari	Rekia	Ammari Errabei 18/12/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18121977mrrbsdmrrk	0672167575	h_djellouli@esi.dz	0
453	\N	Sassi	\N	Salim	M	1986-05-01	N	El Kouif	\N	\N	8	M	Bouzid	Bouchiha	Mariem	Sassi Salim 01/05/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01051986ssslmbzdbchhmrm	0672167575	h_djellouli@esi.dz	0
454	\N	Khelaifia	\N	Madjid	M	1986-08-31	N	Guelma	\N	\N	8	M	Youssef	Alioui	Halima	Khelaifia Madjid 31/08/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	31081986khlfmjdsflhlm	0672167575	h_djellouli@esi.dz	0
455	\N	Sidi Moussa	\N	Ilyas	M	1985-03-26	N	Tlemcen	\N	\N	8	M	Boumediene	Boumeddane	Fatma	Sidi Moussa Ilyas 26/03/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26031985sdmslsbmdnbmdnftm	0672167575	h_djellouli@esi.dz	0
456	\N	Dehamna	\N	Amel	M	1976-06-05	N	Constantine	\N	\N	8	M	Amor	Halimi	Malika	Dehamna Amel 05/06/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05061976dhmnmlmrhlmmlk	0672167575	h_djellouli@esi.dz	0
457	\N	Aouragh	\N	Nadia	F	1983-11-02	N	Arris	\N	\N	8	M	Mebarek	Zaouche	Djamaa	Aouragh Nadia 02/11/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02111983rghndmbrkzchjm	0672167575	h_djellouli@esi.dz	0
458	\N	Delhoume	\N	Mahi	M	1970-02-13	N	Oran	\N	\N	8	M	Djillali	Haddad	Halima	Delhoume Mahi 13/02/1970	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13021970dlhmmhjllhddhlm	0672167575	h_djellouli@esi.dz	0
459	\N	Mouhoub	\N	Fatih	M	1987-01-29	N	Guelma	\N	\N	8	M	Azzouz	Hasnaoui	Khadidja	Mouhoub Fatih 29/01/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29011987mhbfthzzhsnkhdj	0672167575	h_djellouli@esi.dz	0
460	\N	Charef	\N	Fares	M	1975-12-09	N	Constantine	\N	\N	8	M	Sayeh	Guendouz	Zoubida	Charef Fares 09/12/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09121975chrffrschgndzzbd	0672167575	h_djellouli@esi.dz	0
461	\N	Belkerrouche	\N	Zahia	F	1963-10-01	N	Sigus	\N	\N	8	M	Zeghdar	Belkerrouche	Rebiha	Belkerrouche Zahia 01/10/1963	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01101963blkrchzhzghdrblkrchrbh	0672167575	h_djellouli@esi.dz	0
462	\N	Laoufi	\N	Mhammed	M	1975-03-18	N	Aougrout	\N	\N	8	M	Messaoud	Yaichaoui	Messaouda	Laoufi Mhammed 18/03/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18031975lfmhmdmsdchmsd	0672167575	h_djellouli@esi.dz	0
463	\N	Djelti	\N	Mohamed El Mehdi	M	1986-08-23	N	Sidi Bel Abbes	\N	\N	8	M	Zine Eddine	Bouhadji	Zoulikha	Djelti Mohamed El Mehdi 23/08/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23081986jltmhmdlmhdzndnbhjzlkh	0672167575	h_djellouli@esi.dz	0
464	\N	Berriche	\N	Zouaouia	F	1990-01-16	N	Sidi Bel Abbes	\N	\N	8	M	Mohamed	Askour	Fatima	Berriche Zouaouia 16/01/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16011990brchzmhmdskrftm	0672167575	h_djellouli@esi.dz	0
465	\N	Lahcene	\N	Walid	M	1981-08-23	N	Ksar Sbahi	\N	\N	8	M	Ambarek	Saadoune	Safia	Lahcene Walid 23/08/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23081981lhcnwldmbrksdnsf	0672167575	h_djellouli@esi.dz	0
466	\N	Benchenafi	\N	Chakib	M	1986-03-09	N	Tlemcen	\N	\N	8	M	Azzedine	Bouchnak Khalladi	Nacera	Benchenafi Chakib 09/03/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09031986bnchnfchkbzdnbchnkkhldncr	0672167575	h_djellouli@esi.dz	0
467	\N	Djemil	\N	Zouaouia	F	1986-05-26	N	Sidi Bel Abbes	\N	\N	8	M	Ahmed	Benhamou	Khadidja	Djemil Zouaouia 26/05/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26051986jmlzhmdbnhmkhdj	0672167575	h_djellouli@esi.dz	0
468	\N	Bourega	\N	Bachir	M	1980-12-23	N	Sebdou	\N	\N	8	M	Ali	Bouazzi	Fatma	Bourega Bachir 23/12/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23121980brgbchrlbzftm	0672167575	h_djellouli@esi.dz	0
469	\N	Guergueb	\N	Lakhmissi	M	1971-03-04	N	Ksar Sbahi	\N	\N	8	M	Boudjemaa	Guergueb	Barika	Guergueb Lakhmissi 04/03/1971	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04031971grgblkhmsbjmgrgbbrk	0672167575	h_djellouli@esi.dz	0
470	\N	Difallah	\N	Bakhta	F	1987-05-15	N	Ben Badis	\N	\N	8	M	Zouaoui	Saidi	Mama	Difallah Bakhta 15/05/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15051987dflhbkhtzsdmm	0672167575	h_djellouli@esi.dz	0
471	\N	Barouhou	\N	Mohamed Tayeb	M	1987-09-29	N	Oum Bouaghi	\N	\N	8	M	Ahmed	Ibrahimi	Khemissa	Barouhou Mohamed Tayeb 29/09/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29091987brhmhmdtbhmdbrhmkhms	0672167575	h_djellouli@esi.dz	0
472	\N	Graa	\N	Abbes	M	1979-04-19	N	Sidi Bel Abbes	\N	\N	8	M	Maachou	Salem	Fafa	Graa Abbes 19/04/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19041979grbsmchslmff	0672167575	h_djellouli@esi.dz	0
473	\N	Bekkouche	\N	Oussama	M	1987-06-19	N	Ghazaouet	\N	\N	8	M	Abdelaziz	Ghaffour	Nouara	Bekkouche Oussama 19/06/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19061987bkchsmbdlzzghfrnr	0672167575	h_djellouli@esi.dz	0
474	\N	Hammad	\N	Milouda	F	1962-08-04	N	Maghnia	\N	\N	8	D	Mohammed	Belhadi	Raghda	Hammad Milouda 04/08/1962	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04081962hmdmldmhmdblhdrghd	0672167575	h_djellouli@esi.dz	0
475	\N	Bouzouina	\N	Kheira	F	1963-06-15	N	Hassi Zahana	\N	\N	8	M	Lakhdar	Benchaib	Zineb	Bouzouina Kheira 15/06/1963	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15061963bznkhrlkhdrbnchbznb	0672167575	h_djellouli@esi.dz	0
476	\N	Dib	\N	Samia	F	1982-10-10	N	Sigus	\N	\N	8	M	Rahal	Maamache	Elcherifa	Dib Samia 10/10/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10101982dbsmrhlmmchlchrf	0672167575	h_djellouli@esi.dz	0
477	\N	Belhafsi	\N	Meryem	F	1985-10-16	N	Sigus	\N	\N	8	M	Amar	Ghoul	Houria	Belhafsi Meryem 16/10/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16101985blhfsmrmmrghlhr	0672167575	h_djellouli@esi.dz	0
478	\N	Belourghi	\N	Hemza	M	1992-08-12	N	Arris	\N	\N	8	C	Elhaddi	Belourghi	Fatma	Belourghi Hemza 12/08/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12081992blrghhmzlhdblrghftm	0672167575	h_djellouli@esi.dz	0
479	\N	Salah	\N	Nassima	F	1986-12-23	N	Ghazaouet	\N	\N	8	M	Abdeldjalil	Sefraoui	Amaria	Salah Nassima 23/12/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23121986slhnsmbdljllsfrmr	0672167575	h_djellouli@esi.dz	0
480	\N	Lakhdar Chaouch	\N	Abdelkader	M	1983-09-13	N	Sidi Bel Abbes	\N	\N	8	M	Mohamed	Kourchi	Fatima	Lakhdar Chaouch Abdelkader 13/09/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13091983lkhdrchchbdlkdrmhmdkrchftm	0672167575	h_djellouli@esi.dz	0
481	\N	Rouibah	\N	Zouaoui	M	1975-01-07	N	Sidi Bel Abbes	\N	\N	8	M	Mohamed	Gotni	Kheira	Rouibah Zouaoui 07/01/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07011975rbhzmhmdgtnkhr	0672167575	h_djellouli@esi.dz	0
482	\N	Hathat	\N	Moussa	M	1968-10-08	N	Ouargla	\N	\N	8	M	Bachir	Hathat	Milouda	Hathat Moussa 08/10/1968	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08101968hthtmsbchrhthtmld	0672167575	h_djellouli@esi.dz	0
483	\N	Hadjara	\N	Layachi	M	1970-08-25	N	Tamokra	\N	\N	8	C	Ahcene	Lalaoui	Rekia	Hadjara Layachi 25/08/1970	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25081970hjrlchhcnllrk	0672167575	h_djellouli@esi.dz	0
484	\N	Rahmani	\N	Safa	F	1981-12-14	N	El Khroub	\N	\N	8	M	Smail	Rahmani	Nassira	Rahmani Safa 14/12/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	14121981rhmnsfsmlrhmnnsr	0672167575	h_djellouli@esi.dz	0
485	\N	Sadouki	\N	Chadli	M	1979-12-17	N	Saida	\N	\N	8	M	Benyounes	Sadouki	Yakout	Sadouki Chadli 17/12/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17121979sdkchdlbnnssdkkt	0672167575	h_djellouli@esi.dz	0
487	\N	Halimi	\N	Lekhemissi	M	1976-06-07	N	Sigus	\N	\N	8	M	Khelifa	Halimi	Torkia	Halimi Lekhemissi 07/06/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07061976hlmlkhmskhlfhlmtrk	0672167575	h_djellouli@esi.dz	0
488	\N	Sahali	\N	Abdelkader	M	1976-10-11	N	Sidi Bel Abbes	\N	\N	8	M	Mohamed	Bendida	Halima	Sahali Abdelkader 11/10/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11101976chlbdlkdrmhmdbnddhlm	0672167575	h_djellouli@esi.dz	0
489	\N	Boummaraf	\N	Radouane	M	1980-08-22	N	Ksar Sbahi	\N	\N	8	M	Hamoudi	Belabed	Biya	Boummaraf Radouane 22/08/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22081980bmrfrdnhmdblbdb	0672167575	h_djellouli@esi.dz	0
490	\N	Bayaza	\N	Houda	F	1980-03-10	N	Tebessa	\N	\N	8	M	Mahmoud	Hamham	Oum Hani	Bayaza Houda 10/03/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10031980bzhdmhmdhmhmmhn	0672167575	h_djellouli@esi.dz	0
491	\N	Gourai	\N	Fatiha	F	1975-09-25	N	Ben Badis	\N	\N	8	M	Miloud	Smahat	El Hachemia	Gourai Fatiha 25/09/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25091975grfthmldsmhtlhchm	0672167575	h_djellouli@esi.dz	0
492	\N	Djellab	\N	Habib	M	1988-10-24	N	Mostafa Ben Brahim	\N	\N	8	C	Mohamed	Bouras	Zoulikha	Djellab Habib 24/10/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24101988jlbhbbmhmdbrszlkh	0672167575	h_djellouli@esi.dz	0
493	\N	Moumni	\N	Noureddine	M	1972-01-11	N	Sidi Bel Abbes	\N	\N	8	M	Mimoun	Sahraoui	Lalia	Moumni Noureddine 11/01/1972	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11011972mmnnrdnmmnchrll	0672167575	h_djellouli@esi.dz	0
494	\N	Yousfi	\N	Youcef	M	1967-08-29	N	Marhoum	\N	\N	8	M	Miloud	Rezoug	Halima	Yousfi Youcef 29/08/1967	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29081967sfcfmldrzghlm	0672167575	h_djellouli@esi.dz	0
495	\N	Debache	\N	Mohamed Laid	M	1983-04-30	N	Oum Bouaghi	\N	\N	8	M	Abderezak	Khadim Allah	Saraya	Debache Mohamed Laid 30/04/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30041983dbchmhmdldbdrzkkhdmlhsr	0672167575	h_djellouli@esi.dz	0
496	\N	Belarbi	\N	Hicham	M	1982-11-17	N	Tlemcen	\N	\N	8	M	Miloud	Kari	Yamina	Belarbi Hicham 17/11/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17111982blrbhchmmldkrmn	0672167575	h_djellouli@esi.dz	0
497	\N	Habis	\N	Slimane	M	1987-12-25	N	Ben Badis	\N	\N	8	M	Cheikh	Guemmour	Fatma	Habis Slimane 25/12/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25121987hbsslmnchkhgmrftm	0672167575	h_djellouli@esi.dz	0
498	\N	Ennemiche	\N	Mohamed Amin	M	1984-08-07	N	Mostafa Ben Brahim	\N	\N	8	M	Mokadem	Benhaddou	Kheira	Ennemiche Mohamed Amin 07/08/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07081984nmchmhmdmnmkdmbnhdkhr	0672167575	h_djellouli@esi.dz	0
499	\N	Laouar	\N	Nabila	F	1985-05-11	N	El Khroub	\N	\N	8	M	Amor	Bouchiaa	Malika	Laouar Nabila 11/05/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11051985lrnblmrbchmlk	0672167575	h_djellouli@esi.dz	0
500	\N	Mouhadi	\N	Mohammed	M	1984-09-28	N	Sedrata	\N	\N	8	M	Mouloud	Djeghmani	Fatima	Mouhadi Mohammed 28/09/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28091984mhdmhmdmldjghmnftm	0672167575	h_djellouli@esi.dz	0
501	\N	Saoudi	\N	Tadj Eddine	M	1977-01-02	N	Sigus	\N	\N	8	M	Athmane	Hamoudi	Aldjia	Saoudi Tadj Eddine 02/01/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02011977sdtjdnthmnhmdlj	0672167575	h_djellouli@esi.dz	0
502	\N	Berraoui	\N	Nabil	M	1983-07-31	N	Oum Bouaghi	\N	\N	8	M	Benader	Bouhalfaya	Dalila	Berraoui Nabil 31/07/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	31071983brnblbndrbhlfdll	0672167575	h_djellouli@esi.dz	0
503	\N	Ouddane	\N	Mohamed	M	1981-09-27	N	Sfisef	\N	\N	8	M	Yahia	Ridal	Malika	Ouddane Mohamed 27/09/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27091981dnmhmdhrdlmlk	0672167575	h_djellouli@esi.dz	0
504	\N	Houhou	\N	Lemkedem	M	1984-05-15	N	Tlemcen	\N	\N	8	M	Amrou	Rebbib	Rachida	Houhou Lemkedem 15/05/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15051984hhlmkdmmrrbbrchd	0672167575	h_djellouli@esi.dz	0
505	\N	Ghoul	\N	Ibrahim	M	1988-11-19	N	Sigus	\N	\N	8	M	Said	Remili	Zohra	Ghoul Ibrahim 19/11/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19111988ghlbrhmsdrmlzhr	0672167575	h_djellouli@esi.dz	0
506	\N	Abdelaoui	\N	Kemel	M	1984-05-17	N	Oum Bouaghi	\N	\N	8	M	Mohamed	Nouri	Rebaia	Abdelaoui Kemel 17/05/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17051984bdlkmlmhmdnrrb	0672167575	h_djellouli@esi.dz	0
507	\N	Haggoug	\N	Mourad	M	1978-12-09	N	Ben Badis	\N	\N	8	M	Kouider	Salhi	Khadra	Haggoug Mourad 09/12/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09121978hggmrdkdrslhkhdr	0672167575	h_djellouli@esi.dz	0
508	\N	Necib	\N	Hamza	M	1986-07-15	N	Oum Bouaghi	\N	\N	8	M	Abdelkader	Boubguira	Zineb	Necib Hamza 15/07/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15071986ncbhmzbdlkdrbbgrznb	0672167575	h_djellouli@esi.dz	0
509	\N	Laidi	\N	Mohamed Ilyes	M	1988-01-25	N	Constantine	\N	\N	8	M	Said	Belili	Saida	Laidi Mohamed Ilyes 25/01/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25011988ldmhmdlssdbllsd	0672167575	h_djellouli@esi.dz	0
510	\N	Toumi	\N	Djamel Eddine	M	1985-01-10	N	Oum Bouaghi	\N	\N	8	M	Hamid	Abbad	Zahira	Toumi Djamel Eddine 10/01/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10011985tmjmldnhmdbdzhr	0672167575	h_djellouli@esi.dz	0
511	\N	Dekkiche	\N	Faycal	M	1980-07-16	N	Sigus	\N	\N	8	M	Fodil	Dekkiche	Halima	Dekkiche Faycal 16/07/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16071980dkchfclfdldkchhlm	0672167575	h_djellouli@esi.dz	0
512	\N	Samet Kourdi	\N	Noureddine	M	1985-05-11	N	Ksar Sbahi	\N	\N	8	M	Cherif	Khadhraoui	Elouahma	Samet Kourdi Noureddine 11/05/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11051985smtkrdnrdnchrfkhdrlhm	0672167575	h_djellouli@esi.dz	0
513	\N	Hamed	\N	Walid	M	1986-08-02	N	Ain M'Lila	\N	\N	8	M	Said	Ben Djebar	Nafta	Hamed Walid 02/08/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02081986hmdwldsdbnjbrnft	0672167575	h_djellouli@esi.dz	0
514	\N	Sebihi	\N	Sofiane	M	1977-10-26	N	Sigus	\N	\N	8	M	Othmane	Benralia	Khedidja	Sebihi Sofiane 26/10/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26101977sbhsfnthmnbnrlkhdj	0672167575	h_djellouli@esi.dz	0
516	\N	Zahaf	\N	Farid	M	1988-11-07	N	Blida	\N	\N	8	M	Ahmed	Kerouche	Saliha	Zahaf Farid 07/11/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07111988zhffrdhmdkrchslh	0672167575	h_djellouli@esi.dz	0
517	\N	Matallah	\N	Ahmed	M	1987-08-09	N	Sfisef	\N	\N	8	M	Berrahal	Mekika	Lahouaria	Matallah Ahmed 09/08/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09081987mtlhhmdbrhlmkklhr	0672167575	h_djellouli@esi.dz	0
518	\N	Maouche	\N	Nacera	F	1991-08-21	N	Ain Bessam	\N	\N	8	M	Boualem	Djamil	Akila	Maouche Nacera 21/08/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21081991mchncrblmjmlkl	0672167575	h_djellouli@esi.dz	0
519	\N	Bouali	\N	Wehhab	M	1985-07-08	N	Arris	\N	\N	8	M	Mohammed	Bouali	Aida	Bouali Wehhab 08/07/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08071985blwhbmhmdbld	0672167575	h_djellouli@esi.dz	0
520	\N	Dekkiche	\N	Yamina	M	1987-03-04	N	Sigus	\N	\N	8	M	Mekki	Dekkiche	Melouka	Dekkiche Yamina 04/03/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04031987dkchmnmkdkchmlk	0672167575	h_djellouli@esi.dz	0
521	\N	Boubguira	\N	Soufyane	M	1984-11-07	N	Oum Bouaghi	\N	\N	8	M	Abdelhak	Boubguira	Farida	Boubguira Soufyane 07/11/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07111984bbgrsfnbdlhkbbgrfrd	0672167575	h_djellouli@esi.dz	0
522	\N	Mohand L'Hadj	\N	Tahar	M	1986-05-07	N	Ain El Hammam	\N	\N	8	M	Abdelaziz	Mouhoub	Saadia	Mohand L'Hadj Tahar 07/05/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07051986mhndlhjthrbdlzzmhbsd	0672167575	h_djellouli@esi.dz	0
523	\N	Boukaba	\N	Youssouf	M	1992-02-24	N	Arris	\N	\N	8	M	Houcine	Boukaba	Menina	Boukaba Youssouf 24/02/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24021992bkbsfhcnbkbmnn	0672167575	h_djellouli@esi.dz	0
524	\N	Krelil	\N	Fatma	F	1941-04-09	N	Mohammadia	\N	\N	8	V	Adda	Ouarets	Yamina	Krelil Fatma 09/04/1941	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09041941krllftmdrtsmn	0672167575	h_djellouli@esi.dz	0
525	\N	Necib	\N	Zakaria	M	1987-06-09	N	Meskiana	\N	\N	8	M	Abdellah	Chebout	Samira	Necib Zakaria 09/06/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09061987ncbzkrbdlhchbtsmr	0672167575	h_djellouli@esi.dz	0
526	\N	Seggar	\N	Badreddine	M	1987-01-23	N	Ksar Sbahi	\N	\N	8	M	Slimane	Guidoum	Mebarka	Seggar Badreddine 23/01/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23011987sgrbdrdnslmngdmmbrk	0672167575	h_djellouli@esi.dz	0
527	\N	Lemoui	\N	Djamel	M	1969-09-09	N	Sigus	\N	\N	8	M	Messaoud	Derradji	Louiza	Lemoui Djamel 09/09/1969	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09091969lmjmlmsddrjlz	0672167575	h_djellouli@esi.dz	0
528	\N	Ouaari	\N	Bilal	M	1991-08-10	N	Ksar Sbahi	\N	\N	8	M	Salah	Lamri	Noura	Ouaari Bilal 10/08/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10081991rbllslhlmrnr	0672167575	h_djellouli@esi.dz	0
529	\N	Cheriet	\N	Halim	M	1982-05-06	N	Constantine	\N	\N	8	M	Rebai	Messaouda	Cheriet	Cheriet Halim 06/05/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06051982chrthlmrbmsdchrt	0672167575	h_djellouli@esi.dz	0
530	\N	Mazaoui	\N	Abdelkader	M	1977-05-21	N	Sigus	\N	\N	8	M	Miloud	Mazaoui	Fadila	Mazaoui Abdelkader 21/05/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21051977mzbdlkdrmldmzfdl	0672167575	h_djellouli@esi.dz	0
531	\N	Necib	\N	Latifa	F	1984-07-09	N	Ain Beida	\N	\N	8	M	Rachid	Medkour	El Zahra	Necib Latifa 09/07/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09071984ncbltfrchdmdkrlzhr	0672167575	h_djellouli@esi.dz	0
532	\N	Rahmani	\N	Abdelkadir	M	1984-11-26	N	Sigus	\N	\N	8	M	Ibrahim	Rahmani	Houria	Rahmani Abdelkadir 26/11/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26111984rhmnbdlkdrbrhmrhmnhr	0672167575	h_djellouli@esi.dz	0
533	\N	Douh	\N	Lamia	F	1985-09-24	N	Tebessa	\N	\N	8	M	Medjahed	Sahnoun	Sabah	Douh Lamia 24/09/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24091985dhlmmjhdchnnsbh	0672167575	h_djellouli@esi.dz	0
534	\N	Mezoudj	\N	Abdelwahhab	M	1985-07-24	N	Arris	\N	\N	8	M	Ali	Toreche	Hizia	Mezoudj Abdelwahhab 24/07/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24071985mzjbdlwhbltrchhz	0672167575	h_djellouli@esi.dz	0
535	\N	Tarbint	\N	Hamza	M	1983-05-20	N	Arris	\N	\N	8	M	Ammar	Khirdja	Oum Hanni	Tarbint Hamza 20/05/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20051983trbnthmzmrkhrjmhn	0672167575	h_djellouli@esi.dz	0
536	\N	Messaoud	\N	Abderrahim	M	1985-11-26	N	Bekkaria	\N	\N	8	M	Tahar	Salhi	Rebiha	Messaoud Abderrahim 26/11/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26111985msdbdrhmthrslhrbh	0672167575	h_djellouli@esi.dz	0
537	\N	Raja	\N	Abdelhafid	M	1981-05-07	N	Tlemcen	\N	\N	8	M	Houari	Smahi	Djamila	Raja Abdelhafid 07/05/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07051981rjbdlhfdhrsmhjml	0672167575	h_djellouli@esi.dz	0
538	\N	Bendjeroudib	\N	Ayeman	M	1992-02-02	N	El Kouif	\N	\N	8	C	Houcine	Bendjeroudib	Dalila	Bendjeroudib Ayeman 02/02/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02021992bnjrdbmnhcnbnjrdbdll	0672167575	h_djellouli@esi.dz	0
539	\N	Mahcene	\N	Belkacem	M	1985-12-03	N	Ouargla	\N	\N	8	M	Ferhat	Sekhari	Naziha	Mahcene Belkacem 03/12/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03121985mhcnblkcmfrhtskhrnzh	0672167575	h_djellouli@esi.dz	0
540	\N	Cheref	\N	Walid	M	1994-07-05	N	Tlemcen	\N	\N	8	C	Omar	Ouraghi	Noura	Cheref Walid 05/07/1994	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05071994chrfwldmrrghnr	0672167575	h_djellouli@esi.dz	0
541	\N	Bendjaballah	\N	Yacine	M	1978-01-05	N	Souk Ahras	\N	\N	8	M	Elhadi	Benyahia	Mehania	Bendjaballah Yacine 05/01/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05011978bnjblhcnlhdbnhmhn	0672167575	h_djellouli@esi.dz	0
542	\N	Sadou	\N	Mostefa	M	1983-01-22	N	Sidi Ali Boussidi	\N	\N	8	C	Said	Elhenani	Khadidja	Sadou Mostefa 22/01/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22011983sdmstfsdlhnnkhdj	0672167575	h_djellouli@esi.dz	0
543	\N	Amara	\N	Mohammed	M	1975-12-30	N	Mecheria	\N	\N	8	M	Youcef	Hamdaoui	Fatna	Amara Mohammed 30/12/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30121975mrmhmdcfhmdftn	0672167575	h_djellouli@esi.dz	0
544	\N	Beloufa	\N	Nacera	F	1986-06-08	N	Sidi Bel Abbes	\N	\N	8	M	Belhadj	Benguerira	Mhadjia	Beloufa Nacera 08/06/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08061986blfncrblhjbngrrmhj	0672167575	h_djellouli@esi.dz	0
545	\N	Soufi	\N	Abdelkrim	M	1969-04-17	N	Tamaksalet	\N	\N	8	M	Mohammed	Moumeni	Karima	Soufi Abdelkrim 17/04/1969	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17041969sfbdlkrmmhmdmmnkrm	0672167575	h_djellouli@esi.dz	0
546	\N	Dey	\N	Sadia	F	1983-06-02	N	Sidi Ali Boussidi	\N	\N	8	C	Ahmed	Megharbi	Torkia	Dey Sadia 02/06/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02061983dsdhmdmghrbtrk	0672167575	h_djellouli@esi.dz	0
547	\N	Yagoub	\N	Fatna	M	1985-12-04	N	Sidi Bel Abbes	\N	\N	8	M	Tayeb	Bachar	Arbia	Yagoub Fatna 04/12/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04121985gbftntbbchrrb	0672167575	h_djellouli@esi.dz	0
548	\N	Zaoui	\N	Omar	M	1981-03-19	N	Sidi Ali Boussidi	\N	\N	8	M	Ali	Boughrara	Attaouia	Zaoui Omar 19/03/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19031981zmrlbghrrt	0672167575	h_djellouli@esi.dz	0
549	\N	Bouaricha	\N	Abdelhalim Rabie	M	1982-05-24	N	Sidi Ali Boussidi	\N	\N	8	M	Kaddour	Kandsi	Nania	Bouaricha Abdelhalim Rabie 24/05/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24051982brchbdlhlmrbkdrkndsnn	0672167575	h_djellouli@esi.dz	0
550	\N	Hadj Elmerabet	\N	Abderrahmane	M	1976-07-12	N	Sidi Bel Abbes	\N	\N	8	M	Mohamed	Hadj Elmerabet	Fatna	Hadj Elmerabet Abderrahmane 12/07/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12071976hjlmrbtbdrhmnmhmdhjlmrbtftn	0672167575	h_djellouli@esi.dz	0
551	\N	Benchaib	\N	Halima	F	1978-09-13	N	Mohammadia	\N	\N	8	M	Ali	Azzouz	Kheira	Benchaib Halima 13/09/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13091978bnchbhlmlzzkhr	0672167575	h_djellouli@esi.dz	0
552	\N	Habel	\N	Imane	F	1989-04-15	N	Tebessa	\N	\N	8	M	Ahmed	Askri	Sassia	Habel Imane 15/04/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15041989hblmnhmdskrss	0672167575	h_djellouli@esi.dz	0
553	\N	Amari	\N	Yahia	M	1967-06-10	N	Telagh	\N	\N	8	M	Cheikh	Saidi	Keltouma	Amari Yahia 10/06/1967	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10061967mrhchkhsdkltm	0672167575	h_djellouli@esi.dz	0
554	\N	Chala	\N	Samiha	F	1989-06-03	N	Ouled Djellal	\N	\N	8	M	Mohamed	El Mamoun	Fatima	Chala Samiha 03/06/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03061989chlsmhmhmdlmmnftm	0672167575	h_djellouli@esi.dz	0
555	\N	Zernini	\N	Youcef	M	1988-03-10	N	Hadjout	\N	\N	8	M	Maamar	Tifoura	Nabia	Zernini Youcef 10/03/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10031988zrnncfmmrtfrnb	0672167575	h_djellouli@esi.dz	0
556	\N	Alia	\N	Yacine	M	1967-04-15	N	Sedrata	\N	\N	8	M	Mohamed	Sahraoui	Zahia	Alia Yacine 15/04/1967	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15041967lcnmhmdchrzh	0672167575	h_djellouli@esi.dz	0
557	\N	Youcefi	\N	Saoussene	F	1983-06-18	N	Sidi Bel Abbes	\N	\N	8	D	Kouider	Youcefi	Kheira	Youcefi Saoussene 18/06/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18061983cfssnkdrcfkhr	0672167575	h_djellouli@esi.dz	0
558	\N	Ouari	\N	Sid Ahmed	M	1984-12-18	N	Sidi Bel Abbes	\N	\N	8	C	Ali	Bendjebara	Fatima	Ouari Sid Ahmed 18/12/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18121984rsdhmdlbnjbrftm	0672167575	h_djellouli@esi.dz	0
559	\N	Soufi	\N	Youcef	M	1981-03-15	N	Ben Badis	\N	\N	8	C	Mohamed	Foughali	Zerouala	Soufi Youcef 15/03/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15031981sfcfmhmdfghlzrl	0672167575	h_djellouli@esi.dz	0
560	\N	Farhi	\N	Bilel	M	1988-02-27	N	Sedrata	\N	\N	8	M	Abdelmajid	Ferhi	Beya	Farhi Bilel 27/02/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27021988frhbllbdlmjdfrhb	0672167575	h_djellouli@esi.dz	0
561	\N	Benmancer	\N	Torkia	F	1978-03-27	N	Sedrata	\N	\N	8	M	Ahmed	Benmancer	Mbarka	Benmancer Torkia 27/03/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27031978bnmncrtrkhmdbnmncrmbrk	0672167575	h_djellouli@esi.dz	0
562	109731330006860007	Hachouf	\N	Lazhar	M	1973-06-22	N	Sedrata	\N	\N	8	M	Ahmed	Merahi	Hadria	Hachouf Lazhar 22/06/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22061973hchflzhrhmdmrhhdr	0672167575	h_djellouli@esi.dz	0
563	\N	Soufi	\N	Khadra	F	1975-03-01	N	Ain Tellout	\N	\N	8	C	Ahmed	Benkhaled	Khadidja	Soufi Khadra 01/03/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01031975sfkhdrhmdbnkhldkhdj	0672167575	h_djellouli@esi.dz	0
564	\N	Abed	\N	Abdelkader	M	1974-08-09	N	Sidi Bel Abbes	\N	\N	8	M	Ahmed	Bekkai	Zohra	Abed Abdelkader 09/08/1974	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09081974bdbdlkdrhmdbkzhr	0672167575	h_djellouli@esi.dz	0
565	\N	Malti	\N	Ali	M	1994-07-28	N	Sfisef	\N	\N	8	C	Kouider	Malti	Mokhtaria	Malti Ali 28/07/1994	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28071994mltlkdrmltmkhtr	0672167575	h_djellouli@esi.dz	0
566	\N	Medjahdi	\N	Nadia	F	1986-04-24	N	Tlemcen	\N	\N	8	M	Ahmed	Medjahdi	Fatma	Medjahdi Nadia 24/04/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24041986mjhdndhmdmjhdftm	0672167575	h_djellouli@esi.dz	0
567	\N	Kerfouf	\N	Mourad	M	1990-05-07	N	Mascara	\N	\N	8	M	Amar	Hazem	Fatima	Kerfouf Mourad 07/05/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07051990krffmrdmrhzmftm	0672167575	h_djellouli@esi.dz	0
568	\N	Rouighi	\N	Souad Folla	F	1976-10-23	N	El Meniaa	\N	\N	8	M	Moulay Ahmed	Rouighi	Fatma	Rouighi Souad Folla 23/10/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23101976rghsdflmlhmdrghftm	0672167575	h_djellouli@esi.dz	0
569	\N	Louadji	\N	Atika	F	1989-11-20	N	Teghenif	\N	\N	8	M	Eldjilali	Raiek	Nadjia	Louadji Atika 20/11/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20111989ljtkljllrknj	0672167575	h_djellouli@esi.dz	0
570	\N	Abid	\N	Hanya	F	1984-02-09	N	El Hassassna	\N	\N	8	C	Hamza	Seddik	Meriem	Abid Hanya 09/02/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09021984bdhnhmzsdkmrm	0672167575	h_djellouli@esi.dz	0
571	\N	Benharzallah	\N	Haouari	M	1974-07-01	N	Seggana	\N	\N	8	M	Mahfoud	Benharzallah	Rebaia	Benharzallah Haouari 01/07/1974	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01071974bnhrzlhhrmhfdbnhrzlhrb	0672167575	h_djellouli@esi.dz	0
572	\N	Rabah	\N	Ghalem	M	1985-06-25	N	Sidi Bel Abbes	\N	\N	8	M	Mohamed	Bey	Kheira	Rabah Ghalem 25/06/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25061985rbhghlmmhmdbkhr	0672167575	h_djellouli@esi.dz	0
573	\N	Zidane	\N	Talha	M	1981-08-24	N	Sidi Bel Abbes	\N	\N	8	M	Zouaoui	Khenous	Aouali	Zidane Talha 24/08/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24081981zdntlhzkhnsl	0672167575	h_djellouli@esi.dz	0
574	\N	Meguellati	\N	Imane	F	1991-06-23	N	Boumagueur	\N	\N	8	M	Ammar	Henniche	Dalila	Meguellati Imane 23/06/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23061991mgltmnmrhnchdll	0672167575	h_djellouli@esi.dz	0
575	\N	Zahil	\N	Aoumeria	F	1974-05-05	N	Mascara	\N	\N	8	V	M'Hamed	Affia	Mokhtaria	Zahil Aoumeria 05/05/1974	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05051974zhlmrmhmdfmkhtr	0672167575	h_djellouli@esi.dz	0
576	\N	Abderrahmane	\N	Zohra	F	1956-01-01	N	El Ghomri	\N	\N	8	V	Djilali	Abderrahmane	Kheira	Abderrahmane Zohra 01/01/1956	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01011956bdrhmnzhrjllbdrhmnkhr	0672167575	h_djellouli@esi.dz	0
577	\N	Soltani	\N	Malika	F	1979-05-05	N	Sidi Bel Abbes	\N	\N	8	M	Kouider	Boutaiba	Abbassia	Soltani Malika 05/05/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05051979sltnmlkkdrbtbbs	0672167575	h_djellouli@esi.dz	0
578	\N	Haidas	\N	Samira	F	1977-03-03	N	Mascara	\N	\N	8	D	Abdelkader	Chachoua	Fafa	Haidas Samira 03/03/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03031977hdssmrbdlkdrchchff	0672167575	h_djellouli@esi.dz	0
579	\N	Benouareth	\N	Badi	M	1981-07-29	N	Souk Ahras	\N	\N	8	M	Brahim	Benouareth	Mebarka	Benouareth Badi 29/07/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29071981bnrthbdbrhmbnrthmbrk	0672167575	h_djellouli@esi.dz	0
580	\N	Belarbi	\N	Salim	M	1977-06-08	N	Oued Rhiou	\N	\N	8	M	Lakhdar	Benyamina	Rekia	Belarbi Salim 08/06/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08061977blrbslmlkhdrbnmnrk	0672167575	h_djellouli@esi.dz	0
701	\N	Megherbi	\N	Djilali	M	1979-02-07	N	Non Definie	\N	\N	8	M	Habib	Rahou	Bedra	Megherbi Djilali 07/02/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07021979mghrbjllhbbrhbdr	0672167575	h_djellouli@esi.dz	0
581	\N	Timziouine	\N	Amel	F	1983-12-12	N	Sidi Bel Abbes	\N	\N	8	M	Djillali	Elmahdi	Halima	Timziouine Amel 12/12/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12121983tmznmljlllmhdhlm	0672167575	h_djellouli@esi.dz	0
582	\N	Grich	\N	Ali	M	1973-03-05	N	Mohammadia	\N	\N	8	M	Laid	Meliani	Fatma	Grich Ali 05/03/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05031973grchlldmlnftm	0672167575	h_djellouli@esi.dz	0
583	\N	Bouhaba	\N	Laounia Amel	F	1986-08-21	N	Mascara	\N	\N	8	M	Boudjelal	Belkhira	Houria	Bouhaba Laounia Amel 21/08/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21081986bhblnmlbjllblkhrhr	0672167575	h_djellouli@esi.dz	0
584	\N	Elgoutni	\N	Amar	M	1980-07-13	N	Mascara	\N	\N	8	M	Abdelkader	Tenni	Yamina	Elgoutni Amar 13/07/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13071980lgtnmrbdlkdrtnmn	0672167575	h_djellouli@esi.dz	0
585	\N	Abou Mostafa	\N	Mohamed El Amine	M	1983-10-04	N	Mohammadia	\N	\N	8	M	Aoudellah	Belani	Malika	Abou Mostafa Mohamed El Amine 04/10/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04101983bmstfmhmdlmndlhblnmlk	0672167575	h_djellouli@esi.dz	0
586	109750558015530007	Bouchenaf	\N	Salim	M	1975-05-07	N	Bab El Oued	\N	\N	8	M	Taher	Hezam	Badra	Bouchenaf Salim 07/05/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07051975bchnfslmthrhzmbdr	0672167575	h_djellouli@esi.dz	0
587	\N	Khemaissia	\N	Samiya	M	1985-10-08	N	Oued Cheham	\N	\N	8	M	Brahim	Zouainia	Fatima	Khemaissia Samiya 08/10/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08101985khmssmbrhmznftm	0672167575	h_djellouli@esi.dz	0
588	\N	Chenoui	\N	Mokhtar	M	1978-04-27	N	Mascara	\N	\N	8	M	Abdelkader	Chorfi	Fatma	Chenoui Mokhtar 27/04/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27041978chnmkhtrbdlkdrchrfftm	0672167575	h_djellouli@esi.dz	0
589	\N	Merine	\N	Mohamed	M	1987-09-07	N	Ghriss	\N	\N	8	M	Abdelkader	Merine	Djamila	Merine Mohamed 07/09/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07091987mrnmhmdbdlkdrmrnjml	0672167575	h_djellouli@esi.dz	0
590	\N	Benameur	\N	Hachemi	M	1991-08-31	N	Oran	\N	\N	8	M	Miloud	Remal	Houria	Benameur Hachemi 31/08/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	31081991bnmrhchmmldrmlhr	0672167575	h_djellouli@esi.dz	0
592	\N	Kherbouche	\N	Mokhtar	M	1979-02-23	N	Mascara	\N	\N	8	M	Abdellah	Kherbouche	Melha	Kherbouche Mokhtar 23/02/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23021979khrbchmkhtrbdlhkhrbchmlh	0672167575	h_djellouli@esi.dz	0
593	\N	Elfares	\N	Mohamed Amine	M	1990-10-02	N	Sidi Bel Abbes	\N	\N	8	M	Djelloul	Sahraoui	Naima	Elfares Mohamed Amine 02/10/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02101990lfrsmhmdmnjllchrnm	0672167575	h_djellouli@esi.dz	0
594	\N	Belkarbi	\N	Khedidja	F	1979-02-22	N	Ghardaia	\N	\N	8	C	Tahar	Tahri	Fatma	Belkarbi Khedidja 22/02/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22021979blkrbkhdjthrthrftm	0672167575	h_djellouli@esi.dz	0
595	\N	Ouzaa	\N	Khalid	M	1985-05-25	N	Oued Rhiou	\N	\N	8	M	Mohamed	Anani	Bedra	Ouzaa Khalid 25/05/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25051985zkhldmhmdnnbdr	0672167575	h_djellouli@esi.dz	0
596	\N	Tirenifi	\N	Mohammed	M	1991-05-14	N	Mascara	\N	\N	8	M	Abdellah	Soukhal	Malika	Tirenifi Mohammed 14/05/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	14051991trnfmhmdbdlhskhlmlk	0672167575	h_djellouli@esi.dz	0
597	\N	Sarradj	\N	Imad	M	1984-09-05	N	Sidi Bel Abbes	\N	\N	8	M	Baghedad	Benhadou	Zoubida	Sarradj Imad 05/09/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05091984srjmdbghddbnhdzbd	0672167575	h_djellouli@esi.dz	0
598	\N	Sabri	\N	Mourad	M	1984-12-07	N	Oum Bouaghi	\N	\N	8	M	Belkacem	Naadja	Noura	Sabri Mourad 07/12/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07121984sbrmrdblkcmnjnr	0672167575	h_djellouli@esi.dz	0
599	\N	Chelghaf	\N	Mahdi	M	1991-12-10	N	Sidi Bel Abbes	\N	\N	8	M	Miloud	Boumia	Rahma	Chelghaf Mahdi 10/12/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10121991chlghfmhdmldbmrhm	0672167575	h_djellouli@esi.dz	0
600	\N	Bidi	\N	Nadia	F	1984-03-31	N	Ghriss	\N	\N	8	M	Habib	Larbaoui	Melouka	Bidi Nadia 31/03/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	31031984bdndhbblrbmlk	0672167575	h_djellouli@esi.dz	0
601	\N	Abdelhamid	\N	Mustapha	M	1987-11-08	N	Mostafa Ben Brahim	\N	\N	8	C	Benabdallah	Lout	Zouaouia	Abdelhamid Mustapha 08/11/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08111987bdlhmdmstphbnbdlhltz	0672167575	h_djellouli@esi.dz	0
602	\N	Abbou	\N	Mourad	M	1979-12-24	N	Sidi Bel Abbes	\N	\N	8	M	Abdelkader	Fessaha	Kheira	Abbou Mourad 24/12/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24121979bmrdbdlkdrfchkhr	0672167575	h_djellouli@esi.dz	0
603	\N	Bareche	\N	Yaakoub	M	1994-01-24	N	Sefiane	\N	\N	8	C	Youcef	Bareche	Nassira	Bareche Yaakoub 24/01/1994	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24011994brchkbcfbrchnsr	0672167575	h_djellouli@esi.dz	0
604	\N	Boulafraou	\N	Rouchdi	M	1977-03-18	N	Souk Ahras	\N	\N	8	M	Mohamed	Hadjaji	Fatma Zohra	Boulafraou Rouchdi 18/03/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18031977blfrrchdmhmdhjjftmzhr	0672167575	h_djellouli@esi.dz	0
605	\N	Dahak	\N	Salim	M	1977-10-28	N	Souk Ahras	\N	\N	8	M	Saleh	Ouartani	Naziha	Dahak Salim 28/10/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28101977dhkslmslhrtnnzh	0672167575	h_djellouli@esi.dz	0
756	\N	Sari	\N	Hassen	M	1988-11-05	N	Sigus	\N	\N	8	M	Abdellah	Hallak	Houria	Sari Hassen 05/11/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05111988srhsnbdlhhlkhr	0672167575	h_djellouli@esi.dz	0
606	\N	Menaouta	\N	Abdelkader	M	1982-09-03	N	Oued Rhiou	\N	\N	8	M	Salem	Boukhetache	Aicha	Menaouta Abdelkader 03/09/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03091982mntbdlkdrslmbkhtchch	0672167575	h_djellouli@esi.dz	0
607	\N	Aissani	\N	Mohamed Amine	M	1984-10-28	N	Sidi Bel Abbes	\N	\N	8	M	Ahmed	Bouziane Meflah	Fatiha	Aissani Mohamed Amine 28/10/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28101984snmhmdmnhmdbznmflhfth	0672167575	h_djellouli@esi.dz	0
608	\N	Djebbar	\N	Ahmed	M	1975-04-27	N	Mostafa Ben Brahim	\N	\N	8	V	Brahim	Hamel	Bakhta	Djebbar Ahmed 27/04/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27041975jbrhmdbrhmhmlbkht	0672167575	h_djellouli@esi.dz	0
609	\N	Hocini	\N	Khayra	F	1984-01-02	N	Maamora	\N	\N	8	C	Belkacem	Kebir	Khadra	Hocini Khayra 02/01/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02011984hcnkhrblkcmkbrkhdr	0672167575	h_djellouli@esi.dz	0
610	\N	Rittab	\N	Djamal Eddine	M	1989-04-05	N	Oued Rhiou	\N	\N	8	M	Mohamed	Dimia	Soltana	Rittab Djamal Eddine 05/04/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05041989rtbjmldnmhmddmsltn	0672167575	h_djellouli@esi.dz	0
611	\N	Belkarcha	\N	Amar	M	1967-05-26	N	Oran	\N	\N	8	M	Abdelkader	El Karoui	Halima	Belkarcha Amar 26/05/1967	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26051967blkrchmrbdlkdrlkrhlm	0672167575	h_djellouli@esi.dz	0
612	\N	Bouras	\N	Ahmed	M	1972-08-18	N	Relizane	\N	\N	8	M	Mohamed	Bouhassoun	Saadia	Bouras Ahmed 18/08/1972	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18081972brshmdmhmdbhsnsd	0672167575	h_djellouli@esi.dz	0
613	\N	Lahreche	\N	Fatima Zohra	F	1971-03-03	N	Mascara	\N	\N	8	C	Benameur	Boukada	Keltouma	Lahreche Fatima Zohra 03/03/1971	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03031971lhrchftmzhrbnmrbkdkltm	0672167575	h_djellouli@esi.dz	0
614	\N	Settouti	\N	Benattou	M	1979-04-24	N	Sidi Bel Abbes	\N	\N	8	M	Mohamed	Zegai	Halima	Settouti Benattou 24/04/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24041979sttbntmhmdzghlm	0672167575	h_djellouli@esi.dz	0
615	\N	Rahmani	\N	Rahim	M	1984-08-30	N	Bejaia	\N	\N	8	M	Cherif	Belaid	Zahia	Rahmani Rahim 30/08/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30081984rhmnrhmchrfbldzh	0672167575	h_djellouli@esi.dz	0
616	\N	Nedjar	\N	Amine	M	1982-07-13	N	Sidi Bel Abbes	\N	\N	8	M	Kaddour	Malek	Aouali	Nedjar Amine 13/07/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13071982njrmnkdrmlkl	0672167575	h_djellouli@esi.dz	0
617	\N	Allou	\N	Mostapha	M	1983-10-03	N	Mohammadia	\N	\N	8	M	Benaouda	Mehraz	Fatima	Allou Mostapha 03/10/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03101983lmstphbndmhrzftm	0672167575	h_djellouli@esi.dz	0
618	\N	Ottmani	\N	Benabdellah	M	1979-02-13	N	Sidi Brahim	\N	\N	8	M	Serghane	Hamida	Badra	Ottmani Benabdellah 13/02/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13021979tmnbnbdlhsrghnhmdbdr	0672167575	h_djellouli@esi.dz	0
619	\N	Bourahla	\N	Ahmed	M	1977-06-13	N	Sidi Hamadouche	\N	\N	8	M	Mohamed	Bendjeda	Djaouhar	Bourahla Ahmed 13/06/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13061977brhlhmdmhmdbnjdjhr	0672167575	h_djellouli@esi.dz	0
620	\N	Boudaa	\N	Mohamed Rafik	M	1990-07-30	N	Mascara	\N	\N	8	M	Sidi Mohamed	Gherbi	Keltouma	Boudaa Mohamed Rafik 30/07/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30071990bdmhmdrfksdmhmdghrbkltm	0672167575	h_djellouli@esi.dz	0
621	\N	Halimi	\N	Bouabdallah	M	1982-02-22	N	Oued Rhiou	\N	\N	8	M	Houari	Rouai	Zoulikha	Halimi Bouabdallah 22/02/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22021982hlmbbdlhhrrzlkh	0672167575	h_djellouli@esi.dz	0
657	\N	Bouafia	\N	Horya	F	1984-06-17	N	Beni Slimane	\N	\N	8	M	Ali	Selmi	Fatma	Bouafia Horya 17/06/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17061984bfhrlslmftm	0672167575	h_djellouli@esi.dz	0
622	\N	Reriballah	\N	Belqassim Karim	M	1990-05-01	N	Oued Rhiou	\N	\N	8	M	Bouabdellah	Reriballah	Teghrinia	Reriballah Belqassim Karim 01/05/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01051990rrblhblqsmkrmbbdlhrrblhtghrn	0672167575	h_djellouli@esi.dz	0
623	\N	Bekhedda	\N	Brahim	M	1989-08-18	N	Merdja Sidi Abed	\N	\N	8	M	Ouadah	Beghalia	Fatma	Bekhedda Brahim 18/08/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18081989bkhdbrhmdhbghlftm	0672167575	h_djellouli@esi.dz	0
624	\N	Kecis	\N	Nadia	F	1984-05-19	N	Sfisef	\N	\N	8	M	Miloud	Marok	Malika	Kecis Nadia 19/05/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19051984kcsndmldmrkmlk	0672167575	h_djellouli@esi.dz	0
625	\N	Bellal	\N	Khadidja	F	1958-04-24	N	Saida	\N	\N	8	C	Abdelkader	Bent Lahcene	Kheira	Bellal Khadidja 24/04/1958	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24041958bllkhdjbdlkdrbntlhcnkhr	0672167575	h_djellouli@esi.dz	0
626	\N	Lagroum	\N	Abdellah	M	1981-09-29	N	Ouled Defelten	\N	\N	8	M	Mohamed	Sehli	Kheira	Lagroum Abdellah 29/09/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29091981lgrmbdlhmhmdchlkhr	0672167575	h_djellouli@esi.dz	0
627	\N	Derrar	\N	Fatima	F	1981-05-21	N	El Hassassna	\N	\N	8	C	Boualem	Bakhtaoui	Fatma	Derrar Fatima 21/05/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21051981drrftmblmbkhtftm	0672167575	h_djellouli@esi.dz	0
628	\N	Kra	\N	Djilali	M	1977-02-02	N	Mostafa Ben Brahim	\N	\N	8	M	Hadj	Bouamama	Aicha	Kra Djilali 02/02/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02021977krjllhjbmmch	0672167575	h_djellouli@esi.dz	0
629	\N	Hakiki	\N	Baghdad	M	1972-03-02	N	Sig	\N	\N	8	M	Benahmed	Ghali Galloua	Zohra	Hakiki Baghdad 02/03/1972	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02031972hkkbghddbnhmdghlglzhr	0672167575	h_djellouli@esi.dz	0
630	\N	Dalache	\N	Mahfoud	M	1980-05-04	N	Mohammadia	\N	\N	8	M	Mohamed	Hamchouche	Badra	Dalache Mahfoud 04/05/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04051980dlchmhfdmhmdhmchchbdr	0672167575	h_djellouli@esi.dz	0
631	\N	Cherifi	\N	Miloud	M	1974-04-15	N	Lahlef	\N	\N	8	M	Djilali	Bouchelaghem	Nedjma	Cherifi Miloud 15/04/1974	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15041974chrfmldjllbchlghmnjm	0672167575	h_djellouli@esi.dz	0
632	\N	Ziat	\N	Mohammed El Amine	M	1988-12-29	N	Mostaganem	\N	\N	8	M	Abdelkader	Hiba	Meriem	Ziat Mohammed El Amine 29/12/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29121988ztmhmdlmnbdlkdrhbmrm	0672167575	h_djellouli@esi.dz	0
633	\N	Fatah	\N	Abed	M	1985-01-09	N	El Hamri	\N	\N	8	M	Miloud	Khourif	Aicha	Fatah Abed 09/01/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09011985fthbdmldkhrfch	0672167575	h_djellouli@esi.dz	0
634	\N	Bengrira	\N	Mecheri	M	1966-05-07	N	Oued Rhiou	\N	\N	8	M	Mohamed	Agboubi	Badra	Bengrira Mecheri 07/05/1966	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07051966bngrrmchrmhmdgbbbdr	0672167575	h_djellouli@esi.dz	0
635	\N	Belyamani	\N	Cheikh	M	1979-08-08	N	Ben Badis	\N	\N	8	M	Slimane	Larbi	Halima	Belyamani Cheikh 08/08/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08081979blmnchkhslmnlrbhlm	0672167575	h_djellouli@esi.dz	0
636	\N	Feghouli	\N	Moulay Ahmed	M	1980-05-11	N	Oued Rhiou	\N	\N	8	M	Feghoul	Meliani	Lalia	Feghouli Moulay Ahmed 11/05/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11051980fghlmlhmdfghlmlnll	0672167575	h_djellouli@esi.dz	0
637	\N	Sari	\N	Djawad	M	1985-04-06	N	Tlemcen	\N	\N	8	M	Omar	Taleb	Rachida	Sari Djawad 06/04/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06041985srjwdmrtlbrchd	0672167575	h_djellouli@esi.dz	0
638	\N	Benouis	\N	Omar	M	1976-04-19	N	Maoussa	\N	\N	8	M	Habib	Benbekkar	Mokhtaria	Benouis Omar 19/04/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19041976bnsmrhbbbnbkrmkhtr	0672167575	h_djellouli@esi.dz	0
639	\N	Neggaz	\N	Djelloul	M	1987-02-16	N	Meknasa	\N	\N	8	M	Ramdane	Achab	Fatma	Neggaz Djelloul 16/02/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16021987ngzjllrmdnchbftm	0672167575	h_djellouli@esi.dz	0
640	\N	Koumichi	\N	Tayeb	M	1984-03-07	N	Mohammadia	\N	\N	8	M	Abdelkader	Kaddour Betchim	Fatma	Koumichi Tayeb 07/03/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07031984kmchtbbdlkdrkdrbtchmftm	0672167575	h_djellouli@esi.dz	0
641	\N	Rezoug	\N	Mohammed	M	1974-01-15	N	Oued Rhiou	\N	\N	8	M	Abdelkader	Hamama	Fatima Zohra	Rezoug Mohammed 15/01/1974	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15011974rzgmhmdbdlkdrhmmftmzhr	0672167575	h_djellouli@esi.dz	0
642	\N	Ouddane	\N	Fatiha	F	1984-01-21	N	Sfisef	\N	\N	8	M	Elhabib	Bouguenaya	Houria	Ouddane Fatiha 21/01/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21011984dnfthlhbbbgnhr	0672167575	h_djellouli@esi.dz	0
643	\N	Moussadek	\N	Menaouer	M	1989-01-09	N	Mascara	\N	\N	8	M	Habib	Mansour	Fouzia	Moussadek Menaouer 09/01/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09011989msdkmnrhbbmnsrfz	0672167575	h_djellouli@esi.dz	0
644	\N	Zerrouki	\N	Abderrahmen	M	1986-06-10	N	Oued Rhiou	\N	\N	8	M	Abdelkader	Khelifa	Fatma	Zerrouki Abderrahmen 10/06/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10061986zrkbdrhmnbdlkdrkhlfftm	0672167575	h_djellouli@esi.dz	0
645	\N	Rais	\N	Serkhane	M	1966-04-13	N	Mostafa Ben Brahim	\N	\N	8	D	Baghdad	Benhaddou	Ourouba	Rais Serkhane 13/04/1966	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13041966rssrkhnbghddbnhdrb	0672167575	h_djellouli@esi.dz	0
646	\N	Dilmi	\N	Mohcene	M	1989-09-08	N	Oued Zenati	\N	\N	8	M	Laid	Boumendjel	Malika	Dilmi Mohcene 08/09/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08091989dlmmhcnldbmnjlmlk	0672167575	h_djellouli@esi.dz	0
647	\N	Benaceur	\N	Benamar	M	1986-01-22	N	Mascara	\N	\N	8	M	M'Hammed	Yerou	Yamina	Benaceur Benamar 22/01/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22011986bncrbnmrmhmdrmn	0672167575	h_djellouli@esi.dz	0
648	\N	Larabi	\N	Belkacem	M	1988-05-08	N	Mascara	\N	\N	8	M	Mohamed	Zegaou	Zoulikha	Larabi Belkacem 08/05/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08051988lrbblkcmmhmdzgzlkh	0672167575	h_djellouli@esi.dz	0
649	\N	Bouchikhi	\N	Houari	M	1979-01-31	N	Hassi Zahana	\N	\N	8	M	Boudjemaa	Rahmani	Mimouna	Bouchikhi Houari 31/01/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	31011979bchkhhrbjmrhmnmmn	0672167575	h_djellouli@esi.dz	0
650	\N	Baroudi	\N	Ishaq	M	1990-06-24	N	Oued Rhiou	\N	\N	8	M	Abdelkader	Bettahar	Fatma	Baroudi Ishaq 24/06/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24061990brdchqbdlkdrbthrftm	0672167575	h_djellouli@esi.dz	0
651	\N	Bouchiba	\N	Amina	F	1984-01-30	N	Mohammadia	\N	\N	8	M	Mohamed	Bordji	Mokhtaria	Bouchiba Amina 30/01/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30011984bchbmnmhmdbrjmkhtr	0672167575	h_djellouli@esi.dz	0
652	\N	Chaala	\N	Abderrahmane	M	1988-09-30	N	Saida	\N	\N	8	C	Lehcen	Kasem	Zohra	Chaala Abderrahmane 30/09/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30091988chlbdrhmnlhcnksmzhr	0672167575	h_djellouli@esi.dz	0
653	\N	Ykhlef	\N	Nadia	F	1981-05-08	N	Mascara	\N	\N	8	C	Bachir	Ykhlef	Fatima	Ykhlef Nadia 08/05/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08051981khlfndbchrkhlfftm	0672167575	h_djellouli@esi.dz	0
654	\N	Djelailia	\N	Bahia	F	1973-02-06	N	Ouled Brahim	\N	\N	8	M	Mohamed	Djelailia	Aicha	Djelailia Bahia 06/02/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06021973jllbhmhmdjllch	0672167575	h_djellouli@esi.dz	0
655	\N	Sassi	\N	Sid Ahmed Benmazouni	M	1976-05-24	N	Mascara	\N	\N	8	M	Ahmed	Benarara	Aoumeria	Sassi Sid Ahmed Benmazouni 24/05/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24051976sssdhmdbnmznhmdbnrrmr	0672167575	h_djellouli@esi.dz	0
656	\N	Belhacene	\N	Benali	M	1986-11-17	N	Mascara	\N	\N	8	M	Mohamed	Tenni	Yamina	Belhacene Benali 17/11/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17111986blhcnbnlmhmdtnmn	0672167575	h_djellouli@esi.dz	0
658	\N	Cherrad	\N	Houssem Eddine	M	1987-01-01	N	Ain Fakroun	\N	\N	8	M	Belkacem	Saaou	Yamina	Cherrad Houssem Eddine 01/01/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01011987chrdhsmdnblkcmsmn	0672167575	h_djellouli@esi.dz	0
659	\N	Fratil	\N	Hamza	M	1991-06-12	N	Sidi Bel Abbes	\N	\N	8	C	Mohamed	Lalimi	Lalia	Fratil Hamza 12/06/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12061991frtlhmzmhmdllmll	0672167575	h_djellouli@esi.dz	0
660	\N	Houchdi	\N	Sid Ahmed	M	1979-01-26	N	Sidi Bel Abbes	\N	\N	8	M	Youcef	Boualam	Fatna	Houchdi Sid Ahmed 26/01/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26011979hchdsdhmdcfblmftn	0672167575	h_djellouli@esi.dz	0
661	\N	Belfekroun	\N	Bouziane	M	1970-02-09	N	Zerouala	\N	\N	8	M	Abdelkader	Kadid	Mestoura	Belfekroun Bouziane 09/02/1970	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09021970blfkrnbznbdlkdrkddmstr	0672167575	h_djellouli@esi.dz	0
662	\N	Baghdadi	\N	Bousaid	M	1971-07-26	N	Sidi Bel Abbes	\N	\N	8	M	Abdelkader	Saadoune	Yamina	Baghdadi Bousaid 26/07/1971	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26071971bghddbsdbdlkdrsdnmn	0672167575	h_djellouli@esi.dz	0
663	\N	Reba	\N	Hadj Habib	M	1984-07-17	N	Mascara	\N	\N	8	M	Mohamed Kheir Eddine	Sedjal	Fatiha	Reba Hadj Habib 17/07/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17071984rbhjhbbmhmdkhrdnsjlfth	0672167575	h_djellouli@esi.dz	0
664	\N	Abdelouahad	\N	Ahmed	M	1982-05-03	N	Tebessa	\N	\N	8	M	Slimane	Abdelouahad	Djamila	Abdelouahad Ahmed 03/05/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03051982bdlhdhmdslmnbdlhdjml	0672167575	h_djellouli@esi.dz	0
665	\N	Amri	\N	Abderraouf	M	1976-08-15	N	Sidi Bel Abbes	\N	\N	8	M	Aouad	Badreddine	Fatima	Amri Abderraouf 15/08/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15081976mrbdrfdbdrdnftm	0672167575	h_djellouli@esi.dz	0
666	\N	Allam	\N	Houari	M	1977-10-18	N	Teghenif	\N	\N	8	M	Mohamed	Aiboud	Meriem	Allam Houari 18/10/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18101977lmhrmhmdbdmrm	0672167575	h_djellouli@esi.dz	0
667	\N	Benbeghdad	\N	Mohammed	M	1971-04-14	N	Sidi Bel Abbes	\N	\N	8	M	Belkheir	Regad	Yamina	Benbeghdad Mohammed 14/04/1971	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	14041971bnbghddmhmdblkhrrgdmn	0672167575	h_djellouli@esi.dz	0
668	\N	Badri	\N	Ahmed	M	1986-02-27	N	Youb	\N	\N	8	C	Yahia	Boudenna	Alia	Badri Ahmed 27/02/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27021986bdrhmdhbdnl	0672167575	h_djellouli@esi.dz	0
669	\N	Bachir Chelaoua	\N	Ali	M	1978-01-28	N	Non Definie	\N	\N	8	M	Mohamed	Amiri	Yakoubia	Bachir Chelaoua Ali 28/01/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28011978bchrchllmhmdmrkb	0672167575	h_djellouli@esi.dz	0
670	\N	Berahime Meftah	\N	Soria	F	1977-12-11	N	Non Definie	\N	\N	8	M	Hebib	Boukrai Djeoul Saih	Khaira	Berahime Meftah Soria 11/12/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11121977brhmmfthsrhbbbkrjlchkhr	0672167575	h_djellouli@esi.dz	0
671	\N	Bousahla	\N	Abdelkader	M	1974-11-01	N	Non Definie	\N	\N	8	M	Mohamed	Malek	Bedra	Bousahla Abdelkader 01/11/1974	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01111974bchlbdlkdrmhmdmlkbdr	0672167575	h_djellouli@esi.dz	0
672	\N	Bousta	\N	Amar	M	1980-04-02	N	Non Definie	\N	\N	8	M	Abdelkader	Benfriha	Naima	Bousta Amar 02/04/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02041980bstmrbdlkdrbnfrhnm	0672167575	h_djellouli@esi.dz	0
673	\N	Aouissi	\N	Benali	M	1960-09-01	N	Sidi Hamadouche	\N	\N	8	M	Boufeldja	Sayah	Lalia	Aouissi Benali 01/09/1960	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01091960sbnlbfljchll	0672167575	h_djellouli@esi.dz	0
674	\N	Boutaous	\N	Miloud	M	1969-06-05	N	Non Definie	\N	\N	8	M	Habib	Derbel	Kheira	Boutaous Miloud 05/06/1969	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05061969btsmldhbbdrblkhr	0672167575	h_djellouli@esi.dz	0
675	\N	Soltani	\N	Mostepha	M	1983-01-18	N	Oum Bouaghi	\N	\N	8	M	Laid	Soltani	Ouarda	Soltani Mostepha 18/01/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18011983sltnmstphldsltnrd	0672167575	h_djellouli@esi.dz	0
676	\N	Ikhlef	\N	Warda	F	1988-08-17	N	Bejaia	\N	\N	8	M	Malek	Abbaci	Nadira	Ikhlef Warda 17/08/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17081988khlfwrdmlkbcndr	0672167575	h_djellouli@esi.dz	0
677	\N	Benhamou	\N	Khaled	M	1992-01-10	N	Telagh	\N	\N	8	C	Hadj	Rachdi	Yassia	Benhamou Khaled 10/01/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10011992bnhmkhldhjrchds	0672167575	h_djellouli@esi.dz	0
678	\N	Sellam	\N	Houssameddine Mostefa	M	1984-09-28	N	Oum Bouaghi	\N	\N	8	M	Abedlaziz	Maamri	Choufa	Sellam Houssameddine Mostefa 28/09/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28091984slmhsmdnmstfbdlzzmmrchf	0672167575	h_djellouli@esi.dz	0
679	\N	Chabane Chaouch	\N	Nawel	F	1981-06-03	N	Non Definie	\N	\N	8	M	Ahmed	Guesmi	Zohra	Chabane Chaouch Nawel 03/06/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03061981chbnchchnwlhmdgsmzhr	0672167575	h_djellouli@esi.dz	0
680	\N	Kherraz	\N	Sofiane	M	1988-01-09	N	Bejaia	\N	\N	8	M	Smail	Mammeri	Taous	Kherraz Sofiane 09/01/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09011988khrzsfnsmlmmrts	0672167575	h_djellouli@esi.dz	0
681	\N	Benhaddou	\N	Abderrahmane	M	1976-08-02	N	Mostafa Ben Brahim	\N	\N	8	M	Abdelkader	Tounsi	Khadidja	Benhaddou Abderrahmane 02/08/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02081976bnhdbdrhmnbdlkdrtnskhdj	0672167575	h_djellouli@esi.dz	0
682	\N	Chahed	\N	Abbes	M	1979-02-23	N	Non Definie	\N	\N	8	M	Hadj	Dif Ellah	Saadia	Chahed Abbes 23/02/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23021979chhdbshjdflhsd	0672167575	h_djellouli@esi.dz	0
683	\N	Chakri	\N	Noureddine	M	1985-02-23	N	Non Definie	\N	\N	8	M	Mohamed	Bouzidi	Fadila	Chakri Noureddine 23/02/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23021985chkrnrdnmhmdbzdfdl	0672167575	h_djellouli@esi.dz	0
684	\N	Choucha	\N	Kamel	M	1982-07-12	N	Non Definie	\N	\N	8	M	Mokhtar	Besaigher	Halima	Choucha Kamel 12/07/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12071982chchkmlmkhtrbsghrhlm	0672167575	h_djellouli@esi.dz	0
685	\N	Benbakour	\N	Nabil	M	1979-02-24	N	Tlemcen	\N	\N	8	M	Mohamed	Laaradj	Khadra	Benbakour Nabil 24/02/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24021979bnbkrnblmhmdlrjkhdr	0672167575	h_djellouli@esi.dz	0
686	\N	Ben Naoum	\N	Benali	M	1973-12-01	N	Sidi Ali Benyoub	\N	\N	8	M	Habib	Sebaibi	Badra	Ben Naoum Benali 01/12/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01121973bnnmbnlhbbsbbbdr	0672167575	h_djellouli@esi.dz	0
687	\N	Feddal	\N	Mourad Amine	M	1982-06-22	N	Non Definie	\N	\N	8	M	Mohamed	Aouradi	Ouda	Feddal Mourad Amine 22/06/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22061982fdlmrdmnmhmdrdd	0672167575	h_djellouli@esi.dz	0
688	\N	Boukhira	\N	Abbes	M	1979-01-20	N	Sidi Hamadouche	\N	\N	8	M	Tayeb	Saoudi	Keltouma	Boukhira Abbes 20/01/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20011979bkhrbstbsdkltm	0672167575	h_djellouli@esi.dz	0
689	\N	Fellous	\N	Fouad	M	1977-09-19	N	Non Definie	\N	\N	8	M	Miloud	Berahma	Sohbia	Fellous Fouad 19/09/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19091977flsfdmldbrhmchb	0672167575	h_djellouli@esi.dz	0
690	\N	Zaouia	\N	Mohamed	M	1982-03-21	N	El Biar	\N	\N	8	M	Ferhat	Zaouia	Zerfa	Zaouia Mohamed 21/03/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21031982zmhmdfrhtzzrf	0672167575	h_djellouli@esi.dz	0
691	\N	Bourouh	\N	Boubakeur	M	1976-01-13	N	Non Definie	\N	\N	8	M	Ahmed	Sahki	Djemaa	Bourouh Boubakeur 13/01/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13011976brhbbkrhmdchkjm	0672167575	h_djellouli@esi.dz	0
692	\N	Bouhassoun	\N	Ali	M	1959-05-12	N	Sidi Bel Abbes	\N	\N	8	M	Sohbi	Hadri	Rahmouna	Bouhassoun Ali 12/05/1959	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12051959bhsnlchbhdrrhmn	0672167575	h_djellouli@esi.dz	0
693	\N	Latreche	\N	Nassim	M	1983-01-08	N	Kherrata	\N	\N	8	M	Lamri	Benzid	Fatma	Latreche Nassim 08/01/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08011983ltrchnsmlmrbnzdftm	0672167575	h_djellouli@esi.dz	0
694	\N	Benbouhadja	\N	Ammar	M	1989-05-13	N	Annaba	\N	\N	8	C	Kamel	Baaziz	Malika	Benbouhadja Ammar 13/05/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13051989bnbhjmrkmlbzzmlk	0672167575	h_djellouli@esi.dz	0
695	\N	Aouine	\N	Nour Esadet	M	1977-08-12	N	El Ogla	\N	\N	8	M	Mohammed Serir	Guerdi	Mebarka	Aouine Nour Esadet 12/08/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12081977nnrsdtmhmdsrrgrdmbrk	0672167575	h_djellouli@esi.dz	0
696	\N	Hamou	\N	Abdelkader	M	1981-08-16	N	Non Definie	\N	\N	8	M	Omar	Derbel	Djamila	Hamou Abdelkader 16/08/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16081981hmbdlkdrmrdrbljml	0672167575	h_djellouli@esi.dz	0
697	\N	Khatir	\N	Reda	M	1972-04-11	N	Non Definie	\N	\N	8	M	Miloud	Khatir	Kheira	Khatir Reda 11/04/1972	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11041972khtrrdmldkhtrkhr	0672167575	h_djellouli@esi.dz	0
698	\N	Khellafi	\N	Abdelkader	M	1969-06-01	N	Non Definie	\N	\N	8	M	Mohamed	Talbi	Taoues	Khellafi Abdelkader 01/06/1969	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01061969khlfbdlkdrmhmdtlbts	0672167575	h_djellouli@esi.dz	0
699	\N	Lebid	\N	Samira	F	1975-03-18	N	Non Definie	\N	\N	8	M	Kada	Lebid	Zouaouia	Lebid Samira 18/03/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18031975lbdsmrkdlbdz	0672167575	h_djellouli@esi.dz	0
700	\N	Mahdjouba	\N	Benali	M	1980-01-17	N	Non Definie	\N	\N	8	M	Djeloul	Laouedj	Safia	Mahdjouba Benali 17/01/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17011980mhjbbnljllljsf	0672167575	h_djellouli@esi.dz	0
702	\N	Benslama	\N	Schahrazed	F	1977-01-14	N	Sidi Bel Abbes	\N	\N	8	M	Talha	Merabet	Fatima	Benslama Schahrazed 14/01/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	14011977bnslmschhrzdtlhmrbtftm	0672167575	h_djellouli@esi.dz	0
703	\N	Bessini	\N	Mostefa	M	1986-05-27	N	Boudjebha El Bordj	\N	\N	8	M	Blaha	Bental	Kheira	Bessini Mostefa 27/05/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27051986bsnmstfblhbntlkhr	0672167575	h_djellouli@esi.dz	0
704	\N	Mestari	\N	Jamila	F	1973-08-27	N	Non Definie	\N	\N	8	M	Mohamed	Taibi	Yamina	Mestari Jamila 27/08/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27081973mstrjmlmhmdtbmn	0672167575	h_djellouli@esi.dz	0
705	\N	Boucherih	\N	Ali	M	1991-04-29	N	Sidi Bel Abbes	\N	\N	8	M	Slimane	Chadli	Khadidja	Boucherih Ali 29/04/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29041991bchrhlslmnchdlkhdj	0672167575	h_djellouli@esi.dz	0
706	\N	Hadji	\N	Mokhtar	M	1990-08-29	N	Seggana	\N	\N	8	M	Slimane	Hadji	Zakia	Hadji Mokhtar 29/08/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29081990hjmkhtrslmnhjzk	0672167575	h_djellouli@esi.dz	0
707	\N	Karabadja	\N	Nabil	M	1985-11-18	N	Non Definie	\N	\N	8	C	Keddour	Kirati	Saliha	Karabadja Nabil 18/11/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18111985krbjnblkdrkrtslh	0672167575	h_djellouli@esi.dz	0
708	\N	Boumehdi	\N	Djilali	M	1967-01-02	N	Sidi Lakhdar	\N	\N	8	M	Lakehal	Boumehdi	Fatma	Boumehdi Djilali 02/01/1967	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02011967bmhdjlllkhlbmhdftm	0672167575	h_djellouli@esi.dz	0
709	\N	Chambazi	\N	Ayache	M	1984-03-13	N	Ain Oulmane	\N	\N	8	M	Abdelmadjid	Djaber	Houria	Chambazi Ayache 13/03/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13031984chmbzchbdlmjdjbrhr	0672167575	h_djellouli@esi.dz	0
710	\N	Zouggar	\N	Benattou	M	1979-06-20	N	Non Definie	\N	\N	8	M	Boualam	Benchikhe	Mebarka	Zouggar Benattou 20/06/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20061979zgrbntblmbnchkhmbrk	0672167575	h_djellouli@esi.dz	0
711	\N	Talbi	\N	Mohammed Amine	M	1978-08-19	N	Oran	\N	\N	8	M	Kada	Belkendouci	Fatima	Talbi Mohammed Amine 19/08/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19081978tlbmhmdmnkdblkndcftm	0672167575	h_djellouli@esi.dz	0
712	\N	Mamouni	\N	Djamel	M	1967-08-20	N	Oum Bouaghi	\N	\N	8	M	Laid	Aoulmi	Sakina	Mamouni Djamel 20/08/1967	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20081967mmnjmlldlmskn	0672167575	h_djellouli@esi.dz	0
713	109841343003680002	Menai	\N	Abderrezzaq	M	1984-06-25	N	Merahna	\N	\N	8	M	Mohammed Chrife	Amarnia	Nadia	Menai Abderrezzaq 25/06/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25061984mnbdrzqmhmdchrfmrnnd	0672167575	h_djellouli@esi.dz	0
714	\N	Chelef	\N	Kadaouia	F	1985-09-05	N	Oued Taria	\N	\N	8	M	Djillali	Mokaddem	Mokhtaria	Chelef Kadaouia 05/09/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05091985chlfkdjllmkdmmkhtr	0672167575	h_djellouli@esi.dz	0
715	\N	Mammeri	\N	Sofiane	M	1990-08-04	N	El Kseur	\N	\N	8	C	Tayeb	Mameri	Samia	Mammeri Sofiane 04/08/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04081990mmrsfntbmmrsm	0672167575	h_djellouli@esi.dz	0
716	\N	Kaid	\N	Benyoucef	M	1986-10-12	N	Sidi Bel Abbes	\N	\N	8	M	Mohamed	Kaid	Zohra	Kaid Benyoucef 12/10/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12101986kdbncfmhmdkdzhr	0672167575	h_djellouli@esi.dz	0
717	\N	Boubekri	\N	Khadidja	F	1991-01-26	N	El Bayadh	\N	\N	8	M	Moradj	Maamri	Fatma	Boubekri Khadidja 26/01/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26011991bbkrkhdjmrjmmrftm	0672167575	h_djellouli@esi.dz	0
718	\N	Bennour	\N	Kamel	M	1983-02-27	N	Sidi Bel Abbes	\N	\N	8	M	Kouider	Hamel	Talia	Bennour Kamel 27/02/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27021983bnrkmlkdrhmltl	0672167575	h_djellouli@esi.dz	0
719	\N	Kassoul	\N	Abdallah	M	1976-06-30	N	Oued Fodda	\N	\N	8	M	Ahmed	Delimi Bouras	Zohra	Kassoul Abdallah 30/06/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30061976kslbdlhhmddlmbrszhr	0672167575	h_djellouli@esi.dz	0
720	\N	Habri	\N	Fatiha	F	1981-04-29	N	Sidi Bel Abbes	\N	\N	8	M	Mohamed	Boudjerar	Rachida	Habri Fatiha 29/04/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29041981hbrfthmhmdbjrrrchd	0672167575	h_djellouli@esi.dz	0
721	\N	Allaoua	\N	Fatima Zohra	F	1989-10-11	N	Oum Bouaghi	\N	\N	8	M	Lyamine	Zouaoui	Zehira	Allaoua Fatima Zohra 11/10/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11101989lftmzhrlmnzzhr	0672167575	h_djellouli@esi.dz	0
722	109821343001430008	Menai	\N	Boudjemaa	M	1982-03-07	N	Merahna	\N	\N	8	M	Ali	Menai	Teber	Menai Boudjemaa 07/03/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07031982mnbjmlmntbr	0672167575	h_djellouli@esi.dz	0
723	\N	Djaafri	\N	Abd Erraouf	M	1987-06-27	N	Relizane	\N	\N	8	M	Abdelkader	Aouad	Badra	Djaafri Abd Erraouf 27/06/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27061987jfrbdrfbdlkdrdbdr	0672167575	h_djellouli@esi.dz	0
724	\N	Boucif	\N	Abdelkader	M	1974-10-21	N	Sidi Bel Abbes	\N	\N	8	M	Brahim	Fodil	Gadra	Boucif Abdelkader 21/10/1974	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21101974bcfbdlkdrbrhmfdlgdr	0672167575	h_djellouli@esi.dz	0
725	\N	Koucha	\N	Omar	M	1984-09-13	N	Sidi Lakhdar	\N	\N	8	M	Abdelkader	Douane	Fatma	Koucha Omar 13/09/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13091984kchmrbdlkdrdnftm	0672167575	h_djellouli@esi.dz	0
726	\N	Mahdid	\N	Lakhdar	M	1987-04-23	N	Sidi Lakhdar	\N	\N	8	M	Mohamed	Kadri	Aicha	Mahdid Lakhdar 23/04/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23041987mhddlkhdrmhmdkdrch	0672167575	h_djellouli@esi.dz	0
727	\N	Bennour	\N	Toufik	M	1980-07-13	N	Sidi Bel Abbes	\N	\N	8	M	Mohamed	Bennour	Arbia	Bennour Toufik 13/07/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13071980bnrtfkmhmdbnrrb	0672167575	h_djellouli@esi.dz	0
728	\N	Arar	\N	Salah	M	1985-12-19	N	Tebessa	\N	\N	8	M	Larbi	Nar	Mebarka	Arar Salah 19/12/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19121985rrslhlrbnrmbrk	0672167575	h_djellouli@esi.dz	0
729	\N	Adnane	\N	Hacene	M	1989-08-27	N	Mascara	\N	\N	8	M	Hachemi	Benhari	Zohra	Adnane Hacene 27/08/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27081989dnnhcnhchmbnhrzhr	0672167575	h_djellouli@esi.dz	0
730	\N	Assal	\N	Mohammed	M	1993-11-18	N	Tebessa	\N	\N	8	M	Baghdadi	Abrane	Rachida	Assal Mohammed 18/11/1993	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18111993slmhmdbghddbrnrchd	0672167575	h_djellouli@esi.dz	0
731	\N	Hachemane	\N	Noureddine	M	1988-12-25	N	El Hassassna	\N	\N	8	C	Hocine	Seghier	Rekia	Hachemane Noureddine 25/12/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25121988hchmnnrdnhcnsghrrk	0672167575	h_djellouli@esi.dz	0
732	\N	Fekirini	\N	Hichem	M	1982-02-20	N	Sidi Bel Abbes	\N	\N	8	M	Ibrahim	Mokrane	Kheira	Fekirini Hichem 20/02/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20021982fkrnhchmbrhmmkrnkhr	0672167575	h_djellouli@esi.dz	0
733	\N	Boumesla	\N	Madani	M	1979-11-23	N	El Hachem	\N	\N	8	M	Laid	Boumesla	Fatima	Boumesla Madani 23/11/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23111979bmslmdnldbmslftm	0672167575	h_djellouli@esi.dz	0
734	\N	Zerrouak	\N	Abdeslem	M	1962-12-08	N	Hassi Zahana	\N	\N	8	M	Ghaouti	Benattouche	Setti	Zerrouak Abdeslem 08/12/1962	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08121962zrkbdslmghtbntchst	0672167575	h_djellouli@esi.dz	0
735	\N	Khemissi	\N	Djamel	M	1980-05-08	N	Oum Bouaghi	\N	\N	8	M	Laiche	Mahdi	Kroufa	Khemissi Djamel 08/05/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08051980khmsjmllchmhdkrf	0672167575	h_djellouli@esi.dz	0
736	\N	Touche	\N	Razika	F	1984-06-18	N	Amizour	\N	\N	8	M	Bachir	Yahiaoui	Fatiha	Touche Razika 18/06/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18061984tchrzkbchrhfth	0672167575	h_djellouli@esi.dz	0
737	\N	Sengouga	\N	Samia	F	1972-12-25	N	Sefiane	\N	\N	8	M	Amor	Krimil	Khadidja	Sengouga Samia 25/12/1972	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25121972snggsmmrkrmlkhdj	0672167575	h_djellouli@esi.dz	0
738	\N	Mahdi	\N	Halim	M	1987-01-24	N	Oum Bouaghi	\N	\N	8	M	Smail	Khemissi	Noura	Mahdi Halim 24/01/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24011987mhdhlmsmlkhmsnr	0672167575	h_djellouli@esi.dz	0
739	\N	Boudelal	\N	Houaria	F	1979-01-31	N	Ben Badis	\N	\N	8	M	Said	Fatima	Bent Ahmed	Boudelal Houaria 31/01/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	31011979bdllhrsdftmbnthmd	0672167575	h_djellouli@esi.dz	0
740	\N	Merouani	\N	Abdelghani	M	1978-12-28	N	Oum Bouaghi	\N	\N	8	M	Mohaed Elkamel	Irid	Hadda	Merouani Abdelghani 28/12/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28121978mrnbdlghnmhdlkmlrdhd	0672167575	h_djellouli@esi.dz	0
741	\N	Ghadjatti	\N	Med Amine	M	1994-03-04	N	Tlemcen	\N	\N	8	C	Kamel	Bahluol	Saliha	Ghadjatti Med Amine 04/03/1994	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04031994ghjtmdmnkmlbhllslh	0672167575	h_djellouli@esi.dz	0
742	\N	Belalem	\N	Karim	M	1984-02-18	N	Sfisef	\N	\N	8	C	Ahmed	Boussouifa	Soltana	Belalem Karim 18/02/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18021984bllmkrmhmdbsfsltn	0672167575	h_djellouli@esi.dz	0
743	\N	Boumelik	\N	Ahmed	M	1967-06-15	N	Sidi Brahim	\N	\N	8	M	Mohamed	Bakhti	Fatima	Boumelik Ahmed 15/06/1967	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15061967bmlkhmdmhmdbkhtftm	0672167575	h_djellouli@esi.dz	0
744	\N	Hamel	\N	Abdelaali	M	1986-06-03	N	Ain Beida	\N	\N	8	M	Hmana	Mameri	Ouarda	Hamel Abdelaali 03/06/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03061986hmlbdllhmnmmrrd	0672167575	h_djellouli@esi.dz	0
745	\N	Saadi	\N	Samira	F	1987-02-20	N	Bejaia	\N	\N	8	M	Mohand Arezki	Medkour	Nouria	Saadi Samira 20/02/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20021987sdsmrmhndrzkmdkrnr	0672167575	h_djellouli@esi.dz	0
746	\N	Hadef	\N	Djamel Eddine	M	1988-02-11	N	Oum Bouaghi	\N	\N	8	M	Tahar	Hamza	Djemaa	Hadef Djamel Eddine 11/02/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11021988hdfjmldnthrhmzjm	0672167575	h_djellouli@esi.dz	0
747	\N	Assal	\N	Moussa	M	1976-07-12	N	El Malabiod	\N	\N	8	M	Mohammed Sassi	Assal	Khadhra	Assal Moussa 12/07/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12071976slmsmhmdssslkhdr	0672167575	h_djellouli@esi.dz	0
748	\N	Chabbi	\N	Abbes	M	1980-09-21	N	Sidi Bel Abbes	\N	\N	8	M	Abdelkader	Lashoub	Zohra	Chabbi Abbes 21/09/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21091980chbbsbdlkdrlchbzhr	0672167575	h_djellouli@esi.dz	0
749	\N	Chaoui	\N	Abdelaziz	M	1977-05-23	N	Tilatou	\N	\N	8	M	Ammar	Debbache	Delloula	Chaoui Abdelaziz 23/05/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23051977chbdlzzmrdbchdll	0672167575	h_djellouli@esi.dz	0
750	\N	Bougrini	\N	Hichem	M	1986-12-11	N	Sidi Bel Abbes	\N	\N	8	M	Said	Raddi	Zerhounia	Bougrini Hichem 11/12/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11121986bgrnhchmsdrdzrhn	0672167575	h_djellouli@esi.dz	0
751	\N	Maouche	\N	Allaoua	M	1978-02-09	N	Bejaia	\N	\N	8	M	Lachemi	Mezhoud	Khokha	Maouche Allaoua 09/02/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09021978mchllchmmzhdkhkh	0672167575	h_djellouli@esi.dz	0
752	\N	Otmani	\N	Abdellatif	M	1990-10-04	N	Djamaa	\N	\N	8	C	Belgacem	Otmani	Zakia	Otmani Abdellatif 04/10/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04101990tmnbdltfblgcmtmnzk	0672167575	h_djellouli@esi.dz	0
753	\N	Bouzouina	\N	Djelloul	M	1980-07-23	N	Ben Badis	\N	\N	8	M	Tahar	Benabdelkader	Erkia	Bouzouina Djelloul 23/07/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23071980bznjllthrbnbdlkdrrk	0672167575	h_djellouli@esi.dz	0
754	\N	Malou	\N	Fatima	F	1980-08-10	N	Oran	\N	\N	8	M	Abdelhamid	Bouchama	Yamina	Malou Fatima 10/08/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10081980mlftmbdlhmdbchmmn	0672167575	h_djellouli@esi.dz	0
755	\N	Meskine	\N	Salim	M	1982-10-30	N	Sidi Bel Abbes	\N	\N	8	M	Kada	Maalem	Ghalmia	Meskine Salim 30/10/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30101982msknslmkdmlmghlm	0672167575	h_djellouli@esi.dz	0
757	\N	Lazreg	\N	Khadidja	F	1984-05-18	N	Sidi Bel Abbes	\N	\N	8	M	Tadj	Bounoua	Rahmouna	Lazreg Khadidja 18/05/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18051984lzrgkhdjtjbnrhmn	0672167575	h_djellouli@esi.dz	0
758	\N	Sennour	\N	Nawel	F	1978-04-24	N	Non Definie	\N	\N	8	M	Boloufa	Benmoussa	Khadra	Sennour Nawel 24/04/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24041978snrnwlblfbnmskhdr	0672167575	h_djellouli@esi.dz	0
759	\N	Madani	\N	Bouamama	M	1989-01-13	N	Sidi Bel Abbes	\N	\N	8	M	Yahia	Ben Abdellah	Hadjira	Madani Bouamama 13/01/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13011989mdnbmmhbnbdlhhjr	0672167575	h_djellouli@esi.dz	0
760	\N	Sid Elmrabet	\N	Naima	F	1973-06-03	N	Sidi Bel Abbes	\N	\N	8	C	Djillali	Chebbab	Hania	Sid Elmrabet Naima 03/06/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03061973sdlmrbtnmjllchbbhn	0672167575	h_djellouli@esi.dz	0
761	\N	Derras	\N	Mohamed	M	1981-09-02	N	Ben Badis	\N	\N	8	M	Mohamed	Mohela	Ezahraa	Derras Mohamed 02/09/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02091981drsmhmdmhmdmhlzhr	0672167575	h_djellouli@esi.dz	0
762	\N	Tergou	\N	Atmane	M	1979-04-03	N	Non Definie	\N	\N	8	M	Bouziane	Lebka	Abbassia	Tergou Atmane 03/04/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03041979trgtmnbznlbkbs	0672167575	h_djellouli@esi.dz	0
763	\N	Hiadsi	\N	Mokhtar	M	1972-02-17	N	Mascara	\N	\N	8	M	Habib	Belahdja	Fatima	Hiadsi Mokhtar 17/02/1972	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17021972hdsmkhtrhbbblhjftm	0672167575	h_djellouli@esi.dz	0
764	\N	Yahiaoui	\N	Mohammed	M	1958-03-15	N	Non Definie	\N	\N	8	M	Abdelkader	Merabet	Zohra	Yahiaoui Mohammed 15/03/1958	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15031958hmhmdbdlkdrmrbtzhr	0672167575	h_djellouli@esi.dz	0
765	\N	Cherour	\N	Zouaouia	F	1980-11-12	N	Sidi Bel Abbes	\N	\N	8	M	Mohamed	Aissani	Labbassia	Cherour Zouaouia 12/11/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12111980chrrzmhmdsnlbs	0672167575	h_djellouli@esi.dz	0
766	\N	Zeblah	\N	Mostefa	M	1983-10-24	N	Sidi Bel Abbes	\N	\N	8	M	Bouhadjla	Khaloufi	Mokhtaria	Zeblah Mostefa 24/10/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24101983zblhmstfbhjlkhlfmkhtr	0672167575	h_djellouli@esi.dz	0
767	\N	Kamel	\N	Hamou	M	1988-05-07	N	Sidi Bel Abbes	\N	\N	8	M	Benattou	Khadraoui	Khadra	Kamel Hamou 07/05/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07051988kmlhmbntkhdrkhdr	0672167575	h_djellouli@esi.dz	0
768	\N	Hidoussi	\N	Samir	M	1980-08-01	N	Chemora	\N	\N	8	M	Azzouz	Hidoussi	Houria	Hidoussi Samir 01/08/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01081980hdssmrzzhdshr	0672167575	h_djellouli@esi.dz	0
769	\N	Zougagh	\N	Baghdad	M	1984-07-06	N	Non Definie	\N	\N	8	M	Belabbes	Moura	Mama	Zougagh Baghdad 06/07/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06071984zgghbghddblbsmrmm	0672167575	h_djellouli@esi.dz	0
770	\N	Bouchriha	\N	Abdelghani	M	1973-03-06	N	Mostafa Ben Brahim	\N	\N	8	M	Mokhtar	Benhamouda	Aicha	Bouchriha Abdelghani 06/03/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06031973bchrhbdlghnmkhtrbnhmdch	0672167575	h_djellouli@esi.dz	0
771	\N	Boumeslout	\N	Nour Elhouda	F	1994-06-16	N	Mascara	\N	\N	8	M	Mohamed	Bendjarbou	Aicha	Boumeslout Nour Elhouda 16/06/1994	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16061994bmsltnrlhdmhmdbnjrbch	0672167575	h_djellouli@esi.dz	0
772	\N	Moussi	\N	Ali	M	1952-09-02	N	Non Definie	\N	\N	8	M	Moussa	Hadouche	Fatima	Moussi Ali 02/09/1952	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02091952mslmshdchftm	0672167575	h_djellouli@esi.dz	0
773	\N	Mebarki	\N	Abdelkader	M	1976-04-07	N	Sidi Bel Abbes	\N	\N	8	M	Tayeb	Kaaloul	Attaouia	Mebarki Abdelkader 07/04/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07041976mbrkbdlkdrtbkllt	0672167575	h_djellouli@esi.dz	0
774	\N	Saoula	\N	Mohammed	M	1956-12-25	N	Non Definie	\N	\N	8	M	Hocine	Dellal	Zohra	Saoula Mohammed 25/12/1956	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25121956slmhmdhcndllzhr	0672167575	h_djellouli@esi.dz	0
775	\N	Djebrane	\N	Mohammed	M	1969-06-08	N	Sidi Bel Abbes	\N	\N	8	M	Abdelkader	Faraoun	Yamina	Djebrane Mohammed 08/06/1969	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08061969jbrnmhmdbdlkdrfrnmn	0672167575	h_djellouli@esi.dz	0
776	\N	Mebarkou	\N	Ouari	M	1979-03-16	N	Kendira	\N	\N	8	M	Makhlouf	Izbaten	Oum Elaz	Mebarkou Ouari 16/03/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16031979mbrkrmkhlfzbtnmlz	0672167575	h_djellouli@esi.dz	0
777	\N	Saraoui	\N	Mohamed	M	1978-04-16	N	Non Definie	\N	\N	8	M	Kouider	Abdali	Rachida	Saraoui Mohamed 16/04/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16041978srmhmdkdrbdlrchd	0672167575	h_djellouli@esi.dz	0
778	\N	Azizi	\N	Tarek	M	1984-09-06	N	Tebessa	\N	\N	8	M	Mohammed	Trad	Chahrazed	Azizi Tarek 06/09/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06091984zztrkmhmdtrdchhrzd	0672167575	h_djellouli@esi.dz	0
779	\N	Bahloul	\N	Nadir	M	1983-08-17	N	Tebessa	\N	\N	8	M	Khelifa	Djabri	Meriem	Bahloul Nadir 17/08/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17081983bhllndrkhlfjbrmrm	0672167575	h_djellouli@esi.dz	0
780	\N	Mecheri	\N	Lynda	F	1989-02-15	N	Bejaia	\N	\N	8	C	Hamou	Zaichi	Sahra	Mecheri Lynda 15/02/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15021989mchrlndhmzchchr	0672167575	h_djellouli@esi.dz	0
781	\N	Daoud	\N	Abdel Illah	M	1994-06-30	N	Sidi Brahim	\N	\N	8	C	Ali	Chebab	Kheira	Daoud Abdel Illah 30/06/1994	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30061994ddbdllhlchbbkhr	0672167575	h_djellouli@esi.dz	0
782	\N	Salhi	\N	Faris	M	1982-05-23	N	Guelma	\N	\N	8	M	Salah	Salhi	Aicha	Salhi Faris 23/05/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23051982slhfrsslhslhch	0672167575	h_djellouli@esi.dz	0
783	\N	Hebali	\N	Redhouane	M	1983-02-17	N	Mascara	\N	\N	8	M	Mohamed	Benadela	Mokhtaria	Hebali Redhouane 17/02/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17021983hblrdnmhmdbndlmkhtr	0672167575	h_djellouli@esi.dz	0
784	\N	Bouguenaya	\N	Yahia	M	1982-06-09	N	Sfisef	\N	\N	8	M	Abdelkader	Bouguenaya	Mokhtaria Melouka	Bouguenaya Yahia 09/06/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09061982bgnhbdlkdrbgnmkhtrmlk	0672167575	h_djellouli@esi.dz	0
785	\N	Laggoune	\N	Djamila	F	1977-04-20	N	Barika	\N	\N	8	C	Hocine	Mebani	Saliha	Laggoune Djamila 20/04/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20041977lgnjmlhcnmbnslh	0672167575	h_djellouli@esi.dz	0
786	\N	Belkharchouche	\N	Lebiba	F	1988-09-03	N	Ain Beida	\N	\N	8	M	Lamine	Khiari	Fatima	Belkharchouche Lebiba 03/09/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03091988blkhrchchlbblmnkhrftm	0672167575	h_djellouli@esi.dz	0
787	\N	Ikkache	\N	Youcef	M	1973-11-23	N	Tizi	\N	\N	8	M	Djillali	Senouci	Zohra	Ikkache Youcef 23/11/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23111973kchcfjllsnczhr	0672167575	h_djellouli@esi.dz	0
788	\N	Elhadri	\N	Bouazza	M	1976-01-29	N	Non Definie	\N	\N	8	M	Bekhaled	Elkrerafi	Kheira	Elhadri Bouazza 29/01/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29011976lhdrbzbkhldlkrrfkhr	0672167575	h_djellouli@esi.dz	0
789	\N	Boukhatmi	\N	Kada	M	1981-08-23	N	Sidi Bel Abbes	\N	\N	8	M	Ahmed	Rais	Kheira	Boukhatmi Kada 23/08/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23081981bkhtmkdhmdrskhr	0672167575	h_djellouli@esi.dz	0
790	\N	Sahel	\N	Larbi	M	1972-08-16	N	Oum Bouaghi	\N	\N	8	M	Yahia	Zeroual	Hakima	Sahel Larbi 16/08/1972	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16081972chllrbhzrlhkm	0672167575	h_djellouli@esi.dz	0
791	\N	Elkadi	\N	Houari	M	1984-11-01	N	Non Definie	\N	\N	8	M	Kadouir	Khyar	Kheira	Elkadi Houari 01/11/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01111984lkdhrkdrkhrkhr	0672167575	h_djellouli@esi.dz	0
792	\N	Meskine	\N	Bouhadi	M	1986-11-02	N	Sidi Hamadouche	\N	\N	8	M	Yahia	Lalimi	Aounia	Meskine Bouhadi 02/11/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02111986msknbhdhllmn	0672167575	h_djellouli@esi.dz	0
793	\N	Djebbari	\N	Rabie	M	1981-08-07	N	Sidi Bel Abbes	\N	\N	8	M	El Hachemi	Sidi Ali Cherif	Halima	Djebbari Rabie 07/08/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07081981jbrrblhchmsdlchrfhlm	0672167575	h_djellouli@esi.dz	0
794	\N	Bouhi	\N	Abdelillah	M	1986-10-06	N	Mascara	\N	\N	8	M	Ali	Boukhaloua	Fatima	Bouhi Abdelillah 06/10/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06101986bhbdllhlbkhlftm	0672167575	h_djellouli@esi.dz	0
795	\N	Rezgane	\N	Mourad	M	1978-08-21	N	Belarbi	\N	\N	8	M	Kouider	Hamdoun	Fatiha	Rezgane Mourad 21/08/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21081978rzgnmrdkdrhmdnfth	0672167575	h_djellouli@esi.dz	0
796	\N	Mezoughi	\N	Rachid	M	1983-05-13	N	Mascara	\N	\N	8	M	Habib	Benlebna	Zoulikha	Mezoughi Rachid 13/05/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13051983mzghrchdhbbbnlbnzlkh	0672167575	h_djellouli@esi.dz	0
797	\N	Khadraoui	\N	Messaoud	M	1992-09-24	N	Ain Bessam	\N	\N	8	M	Said	Kaidi	Fatiha	Khadraoui Messaoud 24/09/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24091992khdrmsdsdkdfth	0672167575	h_djellouli@esi.dz	0
798	\N	Mekhazni	\N	Abidine	M	1990-05-22	N	El Kseur	\N	\N	8	M	Rabah	Belaid	Mebrouka	Mekhazni Abidine 22/05/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22051990mkhznbdnrbhbldmbrk	0672167575	h_djellouli@esi.dz	0
799	\N	Hellal	\N	Reda	M	1986-10-02	N	Sidi Bel Abbes	\N	\N	8	M	Talha	Ferradji	Khadra	Hellal Reda 02/10/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02101986hllrdtlhfrjkhdr	0672167575	h_djellouli@esi.dz	0
800	\N	Kemouche	\N	Abderrezzaq	M	1985-08-04	N	Guelma	\N	\N	8	M	Houcine	Mimouni	Dalila	Kemouche Abderrezzaq 04/08/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04081985kmchbdrzqhcnmmndll	0672167575	h_djellouli@esi.dz	0
801	\N	Rezgane	\N	Mhamed	M	1970-05-15	N	Belarbi	\N	\N	8	M	Djillali	Bouteraa	Kheira	Rezgane Mhamed 15/05/1970	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15051970rzgnmhmdjllbtrkhr	0672167575	h_djellouli@esi.dz	0
802	                  	Ghaoui	\N	Liamine	M	1978-01-21	N	Djezar	\N	\N	8	M	Ammar	Brahimi	Halima	Ghaoui Liamine 21/01/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21011978ghlmnmrbrhmhlm	0672167575	h_djellouli@esi.dz	0
803	\N	Boukoberine	\N	Abdelhak	M	1994-04-17	N	Laghouat	\N	\N	8	C	Djelloul	Boukoberine	Melouka	Boukoberine Abdelhak 17/04/1994	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17041994bkbrnbdlhkjllbkbrnmlk	0672167575	h_djellouli@esi.dz	0
804	\N	Kheffous	\N	Mohamed El Amine	M	1984-06-13	N	Sidi Bel Abbes	\N	\N	8	M	Ibrahim	Guermit Meftah	Choucha	Kheffous Mohamed El Amine 13/06/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13061984khfsmhmdlmnbrhmgrmtmfthchch	0672167575	h_djellouli@esi.dz	0
805	\N	Berkani	\N	Djeber	M	1988-07-21	N	Oum Bouaghi	\N	\N	8	M	Rachid	Berkane	Souad	Berkani Djeber 21/07/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21071988brknjbrrchdbrknsd	0672167575	h_djellouli@esi.dz	0
806	\N	Doudou	\N	Samir	M	1980-08-30	N	Bounoura	\N	\N	8	M	Daoued	Doudou	Aicha	Doudou Samir 30/08/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30081980ddsmrddddch	0672167575	h_djellouli@esi.dz	0
807	\N	Merabet	\N	Akli	M	1977-12-08	N	Bejaia	\N	\N	8	M	Layachi	Rezgui	Louiza	Merabet Akli 08/12/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08121977mrbtkllchrzglz	0672167575	h_djellouli@esi.dz	0
808	\N	Kadi Belgaid	\N	Mourad	M	1976-12-28	N	Sidi Ali Boussidi	\N	\N	8	M	Kaddour	Gouasmi	Kheira	Kadi Belgaid Mourad 28/12/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28121976kdblgdmrdkdrgsmkhr	0672167575	h_djellouli@esi.dz	0
809	\N	Belaid	\N	Aicha	F	1951-06-20	N	Negrine	\N	\N	8	V	Abdallah	Belaid	Fatma	Belaid Aicha 20/06/1951	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20061951bldchbdlhbldftm	0672167575	h_djellouli@esi.dz	0
810	\N	Douar	\N	Kouider	M	1984-06-03	N	Sidi Brahim	\N	\N	8	M	Djillali Abdelkader	Benghafour	Nacera	Douar Kouider 03/06/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03061984drkdrjllbdlkdrbnghfrncr	0672167575	h_djellouli@esi.dz	0
811	\N	Mestar	\N	Mostefa	M	1970-06-25	N	Sidi Hamadouche	\N	\N	8	M	Kaddour	Mestour	Ghalia	Mestar Mostefa 25/06/1970	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25061970mstrmstfkdrmstrghl	0672167575	h_djellouli@esi.dz	0
812	\N	Haidagacem	\N	Mebarka	F	1995-01-16	N	Timimoun	\N	\N	8	C	Ahmed	Taheri	Messaouda	Haidagacem Mebarka 16/01/1995	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16011995hdgcmmbrkhmdthrmsd	0672167575	h_djellouli@esi.dz	0
813	\N	Salhi	\N	Nabila	F	1981-01-02	N	Seggana	\N	\N	8	C	Mohamed	Salhi	Saadia	Salhi Nabila 02/01/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02011981slhnblmhmdslhsd	0672167575	h_djellouli@esi.dz	0
814	\N	Douina	\N	Boudaoud	M	1981-05-20	N	Moulay Larbi	\N	\N	8	M	Maamar	Rais	Oum El Kheir	Douina Boudaoud 20/05/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20051981dnbddmmrrsmlkhr	0672167575	h_djellouli@esi.dz	0
94	\N	Nasri	\N	Assia	F	1975-02-28	N	Souk Ahras	\N	\N	8	D	Cheriet	Messaadi	Fatiha	Nasri Assia 28/02/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28021975nsrschrtmsdfth	0672167575	h_djellouli@esi.dz	0
95	\N	Mokhtar	\N	Mohammed	M	1973-04-05	N	Sig	\N	\N	8	D	Ali Cherif	Mokhtar	Keltoum	Mokhtar Mohammed 05/04/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05041973mkhtrmhmdlchrfmkhtrkltm	0672167575	h_djellouli@esi.dz	0
815	\N	Ogab	\N	Djamel	M	1972-05-24	N	Oum Bouaghi	\N	\N	8	M	Ounisse	Mazar	Rebaia	Ogab Djamel 24/05/1972	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24051972gbjmlnsmzrrb	0672167575	h_djellouli@esi.dz	0
816	\N	Kebiri	\N	Mohamed	M	1973-01-18	N	Hassi Zahana	\N	\N	8	M	Abdelkader	Antar	Fatima	Kebiri Mohamed 18/01/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18011973kbrmhmdbdlkdrntrftm	0672167575	h_djellouli@esi.dz	0
817	\N	Kheffous	\N	Chahrazed	F	1981-07-15	N	Sidi Bel Abbes	\N	\N	8	M	Ibrahim	Guermit Meftah	Choucha	Kheffous Chahrazed 15/07/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15071981khfschhrzdbrhmgrmtmfthchch	0672167575	h_djellouli@esi.dz	0
818	\N	Azzoug	\N	Kahina	F	1981-03-20	N	Bejaia	\N	\N	8	M	Mohammed	Chelhab	Aicha	Azzoug Kahina 20/03/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20031981zgkhnmhmdchlhbch	0672167575	h_djellouli@esi.dz	0
819	\N	Naz	\N	Nidal	M	1978-08-27	N	Ain Bessam	\N	\N	8	M	Aissa	Guertoubi	Hafida	Naz Nidal 27/08/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27081978nzndlsgrtbhfd	0672167575	h_djellouli@esi.dz	0
820	\N	Ada Hanifi	\N	Abderrahmane	M	1968-06-21	N	Mascara	\N	\N	8	M	Mecherki	Layadi	Zohra	Ada Hanifi Abderrahmane 21/06/1968	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21061968dhnfbdrhmnmchrkldzhr	0672167575	h_djellouli@esi.dz	0
821	\N	Aziez	\N	Khaled	M	1986-11-11	N	Sefiane	\N	\N	8	M	Amor	Akakba	Louiza	Aziez Khaled 11/11/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11111986zzkhldmrkkblz	0672167575	h_djellouli@esi.dz	0
822	\N	Boumaza	\N	Mohamed	M	1991-04-03	N	Mostafa Ben Brahim	\N	\N	8	M	Bachir	Guermoud	Fatima	Boumaza Mohamed 03/04/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03041991bmzmhmdbchrgrmdftm	0672167575	h_djellouli@esi.dz	0
823	\N	Kedadra	\N	Seif Elislam	M	1992-01-17	N	Oum Bouaghi	\N	\N	8	M	Tayeb	Guareh	Saliha	Kedadra Seif Elislam 17/01/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17011992kddrsflslmtbgrhslh	0672167575	h_djellouli@esi.dz	0
824	\N	Youcef Khodja	\N	Nazih	M	1980-01-05	N	Oum Bouaghi	\N	\N	8	M	Allaoua	Youcef Khodja	Zohra	Youcef Khodja Nazih 05/01/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05011980cfkhjnzhlcfkhjzhr	0672167575	h_djellouli@esi.dz	0
825	\N	Nezzar	\N	Nadir	M	1981-11-07	N	Constantine	\N	\N	8	M	Allaoua	Hadji	Elaarfa	Nezzar Nadir 07/11/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07111981nzrndrlhjlrf	0672167575	h_djellouli@esi.dz	0
826	\N	Bendaha	\N	Soria	F	1985-05-08	N	Khenchela	\N	\N	8	M	Said	Lahouel	Djamila	Bendaha Soria 08/05/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08051985bndhsrsdlhljml	0672167575	h_djellouli@esi.dz	0
827	\N	Milane	\N	Faiza	F	1976-05-25	N	Bejaia	\N	\N	8	C	Ahmed	Ouaret	Djamila	Milane Faiza 25/05/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25051976mlnfzhmdrtjml	0672167575	h_djellouli@esi.dz	0
828	\N	Bekhouche	\N	Abdallah	M	1976-02-24	N	Sefiane	\N	\N	8	M	Aissa	Bekhouche	Messaouda	Bekhouche Abdallah 24/02/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24021976bkhchbdlhsbkhchmsd	0672167575	h_djellouli@esi.dz	0
829	\N	Elhelali	\N	Mourad	M	1982-09-08	N	Sidi Bel Abbes	\N	\N	8	M	Abdelkader	Boussebha	Mahdjouba	Elhelali Mourad 08/09/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08091982lhllmrdbdlkdrbsbhmhjb	0672167575	h_djellouli@esi.dz	0
830	\N	Difi	\N	Mounira	F	1978-06-08	N	Souk Ahras	\N	\N	8	M	Belkacem	Ben Wadah	Fatima	Difi Mounira 08/06/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08061978dfmnrblkcmbnwdhftm	0672167575	h_djellouli@esi.dz	0
831	\N	Mouhoub	\N	Salima	F	1990-05-03	N	Zitouna	\N	\N	8	M	Mahmoud	Boulgnafed	Cherifa	Mouhoub Salima 03/05/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03051990mhbslmmhmdblgnfdchrf	0672167575	h_djellouli@esi.dz	0
832	\N	Lachlak	\N	Mohammed Oussama	M	1998-06-08	N	Sidi Bel Abbes	\N	\N	8	C	Abbes	Othmani	Kheira	Lachlak Mohammed Oussama 08/06/1998	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08061998lchlkmhmdsmbsthmnkhr	0672167575	h_djellouli@esi.dz	0
833	\N	Lachlak	\N	Kadi	M	1967-08-20	N	Sidi Bel Abbes	\N	\N	8	M	Serghane	Bensekrane	Sakina	Lachlak Kadi 20/08/1967	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20081967lchlkkdsrghnbnskrnskn	0672167575	h_djellouli@esi.dz	0
834	\N	Chalabi	\N	Souhila	F	1985-07-04	N	Mascara	\N	\N	8	M	Kada	Chergui	Djamila	Chalabi Souhila 04/07/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04071985chlbchlkdchrgjml	0672167575	h_djellouli@esi.dz	0
835	\N	Kalli	\N	Sabrina	F	1975-09-16	N	Oum Bouaghi	\N	\N	8	M	Abdellah	Dahdouh	Nakhela	Kalli Sabrina 16/09/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16091975klsbrnbdlhdhdhnkhl	0672167575	h_djellouli@esi.dz	0
836	\N	Nemir	\N	Samir	M	1977-06-04	N	Amizour	\N	\N	8	M	Slimane	Retaa	Aicha	Nemir Samir 04/06/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04061977nmrsmrslmnrtch	0672167575	h_djellouli@esi.dz	0
837	\N	Boutlilis	\N	Hayat	F	1978-10-13	N	Maamora	\N	\N	8	C	Lakhdar	Nouari	Fatma	Boutlilis Hayat 13/10/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13101978btllshtlkhdrnrftm	0672167575	h_djellouli@esi.dz	0
838	\N	Heniche	\N	Derradji	M	1961-01-01	N	Sefiane	\N	\N	8	M	Mohamed	Kechkeche	Zohra	Heniche Derradji 01/01/1961	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01011961hnchdrjmhmdkchkchzhr	0672167575	h_djellouli@esi.dz	0
839	\N	Merioua	\N	Aissa	M	1982-01-11	N	Ben Badis	\N	\N	8	M	Mohamed	Mansouri	Halima	Merioua Aissa 11/01/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11011982mrsmhmdmnsrhlm	0672167575	h_djellouli@esi.dz	0
840	\N	Tahri	\N	Mohamed	M	1970-01-18	N	Hammam Bouhadjar	\N	\N	8	M	Abdelkader	Zenague	Henia	Tahri Mohamed 18/01/1970	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18011970thrmhmdbdlkdrznghn	0672167575	h_djellouli@esi.dz	0
841	\N	Saridj	\N	Ismahane	F	1985-06-02	N	Oran	\N	\N	8	M	Lhouari	Magherbi	Oumeria	Saridj Ismahane 02/06/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02061985srjsmhnlhrmghrbmr	0672167575	h_djellouli@esi.dz	0
842	\N	Chalaoua	\N	Lahcen	M	1980-01-17	N	Non Definie	\N	\N	8	M	Slimane	Maoul	Mira	Chalaoua Lahcen 17/01/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17011980chllhcnslmnmlmr	0672167575	h_djellouli@esi.dz	0
843	\N	Liazid	\N	Khaled	M	1987-10-26	N	Oum Bouaghi	\N	\N	8	M	Abdelatif	Harath	Farida	Liazid Khaled 26/10/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26101987lzdkhldbdltfhrthfrd	0672167575	h_djellouli@esi.dz	0
844	\N	Djedid	\N	Ilyase	M	1988-09-05	N	El Bayadh	\N	\N	8	C	Abdelkader	Allami	Lalia	Djedid Ilyase 05/09/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05091988jddlsbdlkdrlmll	0672167575	h_djellouli@esi.dz	0
845	\N	Boutema	\N	Lahssen	M	1987-07-20	N	Mostafa Ben Brahim	\N	\N	8	M	Lakhdar	Boutema	Mama	Boutema Lahssen 20/07/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20071987btmlhsnlkhdrbtmmm	0672167575	h_djellouli@esi.dz	0
1049	\N	Djellouli	\N	Hicham	M	1989-11-11	N	Bchar	Hussein Dey Alger,Algerie	572	16	M	\N	\N	\N	Djellouli Hicham 11/11/1989	2020-11-19 19:48:27.526676	1	2020-11-19 19:48:27.526676	1	t	11111989jllhchm	0213 67 21 67	h_djellouli@esi.dz	0
1055	\N	Ssss	\N	Hicham	M	2010-11-11	N	\N	Hussein Dey Alger,Algerie	573	16	M	\N	\N	\N	Ssss Hicham 11/11/2010	2020-11-27 11:13:56.100163	1	2020-11-27 11:13:56.100163	1	t	11112010shchm	0213 67 21 67	h_djellouli@esi.dz	0
1056	\N	Vvvvvv	\N	Hicham	M	2010-11-11	N	\N	Hussein Dey Alger,Algerie	\N	\N	C	\N	\N	\N	Vvvvvv Hicham 11/11/2010	2020-11-27 11:19:26.01361	1	2020-11-27 11:19:26.01361	1	t	11112010vhchm	0213 67 21 67	h_djellouli@esi.dz	0
1050	\N	Vvvvvvvv	\N	Hicham	M	2010-11-11	N	\N	Hussein Dey Alger,Algerie	\N	\N	C	\N	\N	\N	Vvvvvvvv Hicham 11/11/2010	2020-12-08 10:50:39.448507	1	2020-12-08 10:50:39.448507	1	t	11112010vhchm	0213 67 21 67	h_djellouli@esi.dz	0
1051	\N	Xxxxdjellouli	\N	Hicham	M	1999-11-11	N	\N	Hussein Dey Alger,Algerie	\N	\N	C	\N	\N	\N	Xxxxdjellouli Hicham 11/11/1999	2020-11-20 11:30:56.623216	1	2020-11-20 11:30:56.623216	1	t	11111999xjllhchm	0213 67 21 68	h_djellouli@esi.dz	0
1057	\N	Bbbbbb	\N	Hicham	M	1989-11-11	N	\N	Hussein Dey Alger,Algerie	\N	\N	C	\N	\N	\N	Bbbbbb Hicham 11/11/1989	2020-11-27 11:21:42.565979	1	2020-11-27 11:21:42.565979	1	t	11111989bhchm	0213 67 21 67	h_djellouli@esi.dz	0
1052	\N	Djellouli	\N	Hicham	F	1989-11-11	P	\N	Hussein Dey Alger,Algerie	\N	\N	C	\N	\N	\N	Djellouli Hicham 11/11/1989	2020-11-20 23:51:46.768876	1	2020-11-20 23:51:46.768876	1	t	11111989jllhchm	\N	h_djellouli@esi.dz	0
1058	\N	Hhhhhhh	\N	Hicham	M	1989-11-11	N	Aaaaaa	Hussein Dey Alger,Algerie	\N	\N	C	\N	\N	\N	Hhhhhhh Hicham 11/11/1989	2020-11-27 11:22:23.520795	1	2020-11-27 11:22:23.520795	1	t	11111989hhchm	0213 67 21 67	h_djellouli@esi.dz	0
99	\N	Ben Moussa	\N	Boubaker	M	2005-01-06	N	El Oued	\N	\N	8	M	Lamine	Necib	Khadidja	Ben Moussa Boubaker 06/01/2005	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06012005bnmsbbkrlmnncbkhdj	0672167575	h_djellouli@esi.dz	0
119	\N	Bellima	\N	Adel	M	2005-07-09	N	El Oued	\N	\N	8	M	Mohammed	Chayeb	Fatma Zahra	Bellima Adel 09/07/2005	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09072005blmdlmhmdchbftmzhr	0672167575	h_djellouli@esi.dz	0
130	\N	Khelil Cherfi	\N	Nesrine	F	2005-08-08	N	Medea	\N	\N	8	M	Mohamed	Boukhatem	Zineb	Khelil Cherfi Nesrine 08/08/2005	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08082005khllchrfnsrnmhmdbkhtmznb	0672167575	h_djellouli@esi.dz	0
146	\N	Sidhoum	\N	Kadda	M	2005-12-19	N	Sidi Bel Abbes	\N	\N	8	M	Benattou	Djelloul	Khadra	Sidhoum Kadda 19/12/2005	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19122005sdmkdbntjllkhdr	0672167575	h_djellouli@esi.dz	0
175	\N	Bouri	\N	Imen	F	2005-08-29	N	Es Senia	\N	\N	8	C	Abdelkader	Belazil	Mama	Bouri Imen 29/08/2005	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29082005brmnbdlkdrblzlmm	0672167575	h_djellouli@esi.dz	0
211	\N	Ziad	\N	Moussa	M	2005-05-20	N	Ain Beida	\N	\N	8	M	Khouthir	Chebouti	Akila	Ziad Moussa 20/05/2005	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20052005zdmskhthrchbtkl	0672167575	h_djellouli@esi.dz	0
239	\N	Darabid	\N	Mohammed	M	2005-02-03	N	Non Definie	\N	\N	8	C	Mohammed	Rabah	Rabia	Darabid Mohammed 03/02/2005	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03022005drbdmhmdmhmdrbhrb	0672167575	h_djellouli@esi.dz	0
263	\N	Ouanzar	\N	Mohammed	M	2005-10-05	N	Oum Bouaghi	\N	\N	8	M	Seddik	Zeghoud	Tourkia	Ouanzar Mohammed 05/10/2005	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05102005nzrmhmdsdkzghdtrk	0672167575	h_djellouli@esi.dz	0
291	\N	Benraima	\N	Farid	M	2005-07-22	N	Ben Badis	\N	\N	8	M	Abdessalem	Chercheb	Saadia	Benraima Farid 22/07/2005	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22072005bnrmfrdbdslmchrchbsd	0672167575	h_djellouli@esi.dz	0
318	\N	Yahiaoui	\N	Lahcen	M	2005-02-03	N	Ben Badis	\N	\N	8	C	Yahia	Moualid	Yamna	Yahiaoui Lahcen 03/02/2005	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03022005hlhcnhmldmn	0672167575	h_djellouli@esi.dz	0
349	\N	Bourouh	\N	Rachid	M	2005-09-07	N	Arris	\N	\N	8	M	Mohammed	Balla	Mebrouka	Bourouh Rachid 07/09/2005	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07092005brhrchdmhmdblmbrk	0672167575	h_djellouli@esi.dz	0
378	\N	Abbaci	\N	Fedhila	F	2005-09-30	N	El Bayadh	\N	\N	8	M	Ali	Djalil	Fatiha	Abbaci Fedhila 30/09/2005	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30092005bcfdlljllfth	0672167575	h_djellouli@esi.dz	0
486	\N	Mezada	\N	Reda	M	2005-05-22	N	Sidi Bel Abbes	\N	\N	8	M	Mohamed	Hamri	Kheira	Mezada Reda 22/05/2005	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22052005mzdrdmhmdhmrkhr	0672167575	h_djellouli@esi.dz	0
515	\N	Bardjak	\N	Ishak	M	2005-03-08	N	Constantine	\N	\N	8	M	Lazhar	Ouachtati	Akila	Bardjak Ishak 08/03/2005	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08032005brjkchklzhrchttkl	0672167575	h_djellouli@esi.dz	0
591	\N	Khenata	\N	Tayeb	M	2005-03-25	N	El Hachem	\N	\N	8	M	Djilali	Zouaneb	Zohra	Khenata Tayeb 25/03/2005	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25032005khnttbjllznbzhr	0672167575	h_djellouli@esi.dz	0
47	\N	Guermis	\N	Aida	F	2005-06-11	N	Stidia	\N	20	1	D	Benaouda	Hadda	Aicha	Guermis Aida 11/06/2005	2020-12-08 10:04:41.221344	1	2020-12-08 10:04:41.221344	1	t	11062005grmsdbndhdch	0672167575	h_djellouli@esi.dz	0
1074	\N	Djellouli	\N	Hicham	M	1989-11-11	N	\N		\N	\N	C	\N	\N	\N	Djellouli Hicham 11/11/1989	2021-01-10 17:53:48.464964	1	2021-01-10 17:53:48.464964	1	t	11111989jllhchm			1
1076	\N	Xxxxxxx	\N	Hicham	M	1989-11-11	N	\N	Hussein Dey Alger,Algerie	\N	\N	C	\N	\N	\N	Xxxxxxx Hicham 11/11/1989	2021-01-22 19:21:05.054468	1	2021-01-22 19:21:05.054468	1	t	11111989xhchm	0213 67 21 67	h_djellouli@esi.dz	1
1059	\N	Teeeeestdjellouli	\N	Hicham	M	1989-11-11	N	\N	Hussein Dey Alger,Algerie	\N	\N	C	\N	\N	\N	Teeeeestdjellouli Hicham 11/11/1989	2020-12-07 17:05:39.229488	1	2020-12-07 17:05:39.229488	1	t	11111989tstjllhchm	0213 67 21 67	h_djellouli@esi.dz	1
1075	\N	Tessss	\N	Tessss	M	1989-11-11	N	\N	\N	\N	\N	C	\N	\N	\N	Tessss Tessss 11/11/1989	2021-01-18 19:38:22.792903	1	2021-01-18 19:38:22.792903	1	t	11111989tsts	\N	\N	1
1077	\N	Eeeeeee	\N	Eeeeeee	M	1989-11-11	N	\N	\N	\N	\N	C	\N	\N	\N	Eeeeeee Eeeeeee 11/11/1989	2021-01-22 19:25:58.260923	1	2021-01-22 19:25:58.260923	1	t	11111989	\N	\N	1
1060	\N	Sss	\N	Sss	M	2010-11-11	N	\N	Hussein Dey Alger,Algerie	\N	\N	C	\N	\N	\N	Sss Sss 11/11/2010	2020-12-08 10:45:33.207564	1	2020-12-08 10:45:33.207564	1	t	11112010ss	0213 67 21 67	h_djellouli@esi.dz	1
1078	\N	Ssss	\N	Hicham	M	1989-11-11	N	\N	Hussein Dey Alger,Algerie	\N	\N	C	\N	\N	\N	Ssss Hicham 11/11/1989	2021-01-22 19:29:55.502656	1	2021-01-22 19:29:55.502656	1	t	11111989shchm	+213672167575	h_djellouli@esi.dz	1
1061	\N	Djelloulixxxxxxx	\N	Hicham	M	1989-11-11	N	\N	Hussein Dey Alger,Algerie	\N	\N	C	\N	\N	\N	Djelloulixxxxxxx Hicham 11/11/1989	2020-12-07 17:10:01.873962	1	2020-12-07 17:10:01.873962	1	t	11111989jllxhchm	0213 67 21 67	h_djellouli@esi.dz	1
1079	\N	Vvvvvv	\N	Vvvvvvvvv	M	1989-11-11	N	\N	\N	\N	\N	C	\N	\N	\N	Vvvvvv Vvvvvvvvv 11/11/1989	2021-01-22 19:30:55.260266	1	2021-01-22 19:30:55.260266	1	t	11111989vv	\N	\N	1
1080	\N	Dvdvdvdvd	\N	Dvdvdvdvd	M	1989-11-11	N	\N	\N	\N	\N	C	\N	\N	\N	Dvdvdvdvd Dvdvdvdvd 11/11/1989	2021-01-22 19:31:25.731557	1	2021-01-22 19:31:25.731557	1	t	11111989dvdvdvdvddvdvdvdvd	\N	\N	1
1062	\N	Cccopopopxx	\N	Test	M	1989-11-11	P	Aaaaaa	Hussein Dey Alger,Algerie	630	17	C	\N	\N	\N	Cccopopopxx Test 11/11/1989	2020-12-08 10:28:06.216612	1	2020-12-08 10:28:06.216612	1	t	11111989cpppxtst	0213 67 21 67	h_djellouli@esi.dz	1
1081	\N	Ooooooorr	\N	Ooooooorr	F	1999-11-11	N	\N	\N	\N	\N	C	\N	\N	\N	Ooooooorr Ooooooorr 11/11/1999	2021-01-22 19:53:59.145639	1	2021-01-22 19:53:59.145639	1	t	11111999rr	\N	\N	1
1082	\N	Bbbbbbbb	\N	Bbbbbbbb	M	2010-11-11	N	\N	\N	\N	\N	C	\N	\N	\N	Bbbbbbbb Bbbbbbbb 11/11/2010	2021-01-22 20:11:51.442551	1	2021-01-22 20:11:51.442551	1	t	11112010bb	\N	\N	1
1000	\N	Benslamas	\N	Faouzis	M	1980-08-30	N	Mohammadia	\N	\N	8	M	Kaddour	Benslama	Taouas	Benslamas Faouzis 30/08/1980	2020-12-08 10:34:45.684293	1	2020-12-08 10:34:45.684293	1	t	30081980bnslmsfzskdrbnslmts	0672167575	h_djellouli@esi.dz	0
1083	\N	Wwwww	\N	Wwww	M	1989-11-11	N	\N	\N	\N	\N	C	\N	\N	\N	Wwwww Wwww 11/11/1989	2021-01-22 20:13:06.716295	1	2021-01-22 20:13:06.716295	1	t	11111989ww	\N	\N	1
1063	\N	Xxxxdjellouli	\N	Xxxxhicham	M	2010-11-11	N	\N	Hussein Dey Alger,Algerie	504	15	M	\N	\N	\N	Xxxxdjellouli Xxxxhicham 11/11/2010	2020-12-08 10:47:04.219517	1	2020-12-08 10:47:04.219517	1	t	11112010xjllxhchm	0213 67 21 67	h_djellouli@esi.dz	1
1064	\N	Bbbb	\N	Bbbb	M	2010-11-11	N	\N	\N	\N	16	C	\N	\N	\N	Bbbb Bbbb 11/11/2010	2020-12-08 10:54:43.50516	1	2020-12-08 10:54:43.50516	1	t	11112010bb	0333 33 33 33	\N	1
1065	\N	Djellouli	\N	Hicham	M	1989-11-11	N	\N	Hussein Dey Alger,Algerie	573	16	C	\N	\N	\N	Djellouli Hicham 11/11/1989	2020-12-08 10:55:18.084063	1	2020-12-08 10:55:18.084063	1	t	11111989jllhchm	0213 67 21 67	h_djellouli@esi.dz	1
1066	\N	Djellouli	\N	Hicham	M	1989-11-11	N	\N	Hussein Dey Alger,Algerie	36	2	C	\N	\N	\N	Djellouli Hicham 11/11/1989	2020-12-08 10:59:18.728846	1	2020-12-08 10:59:18.728846	1	t	11111989jllhchm	0213 67 21 67	h_djellouli@esi.dz	1
1067	\N	Djellouli	\N	Hicham	M	1999-11-11	N	\N	Hussein Dey Alger,Algerie	629	17	C	\N	\N	\N	Djellouli Hicham 11/11/1999	2020-12-08 11:01:58.757784	1	2020-12-08 11:01:58.757784	1	t	11111999jllhchm	0213 67 21 67	h_djellouli@esi.dz	1
1068	\N	Djellouli	\N	Hicham	M	1989-11-11	N	\N	Hussein Dey Alger,Algerie	\N	\N	C	\N	\N	\N	Djellouli Hicham 11/11/1989	2020-12-12 10:53:19.338079	1	2020-12-12 10:53:19.338079	1	t	11111989jllhchm	0213 67 21 67	h_djellouli@esi.dz	1
1069	\N	Ssss	\N	Hicham	M	1989-11-11	N	\N	Hussein Dey Alger,Algerie	\N	\N	C	\N	\N	\N	Ssss Hicham 11/11/1989	2020-12-12 10:54:42.897266	1	2020-12-12 10:54:42.897266	1	t	11111989shchm	0213 67 21 67	h_djellouli@esi.dz	1
1070	\N	Xxx	\N	Xxx	M	1989-11-11	N	Aaaaaa	Hussein Dey Alger,Algerie	\N	\N	C	\N	\N	\N	Xxx Xxx 11/11/1989	2020-12-13 12:28:18.385209	1	2020-12-13 12:28:18.385209	1	t	11111989xx	0213 67 21 67	h_djellouli@esi.dz	1
1071	\N	Djellouli	\N	Aek	M	1954-10-01	N	\N	Hussein Dey Alger,Algerie	9	1	M	\N	\N	\N	Djellouli Aek 01/10/1954	2020-12-14 21:42:03.006671	1	2020-12-14 21:42:03.006671	1	t	01101954jllk	0672 16 75 75	aekdje1954@gmail.com	1
1072	\N	Djellouli	\N	Nawel	F	1986-08-16	N	\N	Hussein Dey Alger,Algerie	9	1	M	\N	\N	\N	Djellouli Nawel 16/08/1986	2020-12-14 21:42:54.602919	1	2020-12-14 21:42:54.602919	1	t	16081986jllnwl	0213 67 21 67	nawal.dj@hotmail.com	1
1073	\N	Djellouli	\N	Hicham	F	1954-10-01	N	\N	Hussein Dey Alger,Algerie	272	8	C	\N	\N	\N	Djellouli Hicham 01/10/1954	2020-12-17 14:07:34.670198	1	2020-12-17 14:07:34.670198	1	t	01101954jllhchm	0672 16 75 75	h_djellouli@esi.dz	1
846	\N	Merabet	\N	Amal	F	1984-01-08	N	Bejaia	\N	\N	8	M	Hassen	Kitoune	Louiza	Merabet Amal 08/01/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08011984mrbtmlhsnktnlz	0672167575	h_djellouli@esi.dz	0
847	\N	Moudjeb	\N	Mohamed	M	1977-11-01	N	Oum Bouaghi	\N	\N	8	M	Mostefa	Medkour	Zakia	Moudjeb Mohamed 01/11/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01111977mjbmhmdmstfmdkrzk	0672167575	h_djellouli@esi.dz	0
848	\N	Guerrab	\N	Mohamed	M	1984-07-12	N	Sidi Bel Abbes	\N	\N	8	M	Cheikh	Benhaddou	Melouka	Guerrab Mohamed 12/07/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12071984grbmhmdchkhbnhdmlk	0672167575	h_djellouli@esi.dz	0
849	\N	Makehour	\N	Zouaoui	M	1978-09-30	N	Sidi Bel Abbes	\N	\N	8	M	Abdelkader	Kadari	Aicha	Makehour Zouaoui 30/09/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30091978mkhrzbdlkdrkdrch	0672167575	h_djellouli@esi.dz	0
850	\N	Tigri	\N	Kaddour	M	1985-09-05	N	Sidi Bel Abbes	\N	\N	8	M	Miloud	Bakhti	Tebra	Tigri Kaddour 05/09/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05091985tgrkdrmldbkhttbr	0672167575	h_djellouli@esi.dz	0
851	\N	Mortada	\N	Kheira	F	1982-10-30	N	El Hassassna	\N	\N	8	C	Kouider	Semai	Mebarka	Mortada Kheira 30/10/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30101982mrtdkhrkdrsmmbrk	0672167575	h_djellouli@esi.dz	0
852	\N	Djebbar	\N	Mohamed	M	1988-05-21	N	Mostafa Ben Brahim	\N	\N	8	M	Boudjemaa	Ougadi	Fatima Zohra	Djebbar Mohamed 21/05/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21051988jbrmhmdbjmgdftmzhr	0672167575	h_djellouli@esi.dz	0
853	\N	Hadj Abdelkader	\N	Hadjera	F	1980-07-08	N	Sidi Bel Abbes	\N	\N	8	M	Menaouar	Liani	Aicha	Hadj Abdelkader Hadjera 08/07/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08071980hjbdlkdrhjrmnrlnch	0672167575	h_djellouli@esi.dz	0
854	                  	Bouakaz	\N	Oussama	M	1987-07-16	N	Sefiane	\N	\N	8	M	Salah	Zerouni	Ouarda	Bouakaz Oussama 16/07/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16071987bkzsmslhzrnrd	0672167575	h_djellouli@esi.dz	0
855	\N	Badi	\N	Rabie	M	1988-03-03	N	N'Gaous	\N	\N	8	M	Abdallah	Louifi	Fatma	Badi Rabie 03/03/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03031988bdrbbdlhlfftm	0672167575	h_djellouli@esi.dz	0
856	\N	Chaida	\N	Abbes	M	1979-09-07	N	Non Definie	\N	\N	8	M	Bekhaled	Hamach	Abbasia	Chaida Abbes 07/09/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07091979chdbsbkhldhmchbs	0672167575	h_djellouli@esi.dz	0
857	\N	Ghouar	\N	Afif	M	1979-10-21	N	Sidi Ali	\N	\N	8	C	Habib	Djidel	Fatma	Ghouar Afif 21/10/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21101979ghrffhbbjdlftm	0672167575	h_djellouli@esi.dz	0
858	\N	Raiah	\N	Laredj	M	1977-02-16	N	Hassi Zahana	\N	\N	8	M	Mohamed	Slimani	Fatiha	Raiah Laredj 16/02/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16021977rhlrjmhmdslmnfth	0672167575	h_djellouli@esi.dz	0
859	\N	Amiri	\N	Hoda	F	1991-08-06	N	Sefiane	\N	\N	8	M	Abdelmadjid	Louifi	Ghania	Amiri Hoda 06/08/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06081991mrhdbdlmjdlfghn	0672167575	h_djellouli@esi.dz	0
860	\N	Abderrahmane	\N	Hichem	M	1977-06-29	N	Tebessa	\N	\N	8	M	Saddek	Merah	Henia	Abderrahmane Hichem 29/06/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29061977bdrhmnhchmsdkmrhhn	0672167575	h_djellouli@esi.dz	0
861	\N	Achouri	\N	Radouane	M	1989-03-23	N	Ain Nehala	\N	\N	8	M	Mohamed	Zaidi	Aicha	Achouri Radouane 23/03/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23031989chrrdnmhmdzdch	0672167575	h_djellouli@esi.dz	0
862	\N	Abdellaoui	\N	Mohamed	M	1981-03-24	N	Hassi Zahana	\N	\N	8	M	Mimoun	Kared	Fatna	Abdellaoui Mohamed 24/03/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24031981bdlmhmdmmnkrdftn	0672167575	h_djellouli@esi.dz	0
863	\N	Saker	\N	Hamza	M	1983-03-14	N	Oum Bouaghi	\N	\N	8	M	Hamdane	Saker	Fatima	Saker Hamza 14/03/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	14031983skrhmzhmdnskrftm	0672167575	h_djellouli@esi.dz	0
864	\N	Mebarki	\N	Abbas	M	1971-04-24	N	Marhoum	\N	\N	8	M	Cheikh	Mebarki	Nedjma	Mebarki Abbas 24/04/1971	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24041971mbrkbschkhmbrknjm	0672167575	h_djellouli@esi.dz	0
865	\N	Elaouedj	\N	Merouane	M	1988-02-17	N	Sidi Bel Abbes	\N	\N	8	M	Yahia	Haouch	Aicha	Elaouedj Merouane 17/02/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17021988ljmrnhhchch	0672167575	h_djellouli@esi.dz	0
866	\N	Tounsi	\N	Boulares	M	1969-07-09	N	Berriche	\N	\N	8	M	Said	Bouakaz	Fatma	Tounsi Boulares 09/07/1969	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09071969tnsblrssdbkzftm	0672167575	h_djellouli@esi.dz	0
867	\N	Messabih	\N	Ghalem	M	1981-09-26	N	Sidi Bel Abbes	\N	\N	8	M	Mohamed	Bouchaoui	Kheira	Messabih Ghalem 26/09/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26091981msbhghlmmhmdbchkhr	0672167575	h_djellouli@esi.dz	0
868	\N	Benmerdja	\N	Abdallah	M	1985-08-21	N	Relizane	\N	\N	8	M	Hamou	Bouras	Fatma	Benmerdja Abdallah 21/08/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21081985bnmrjbdlhhmbrsftm	0672167575	h_djellouli@esi.dz	0
869	\N	Fanani	\N	Rachid	M	1982-11-17	N	Sfisef	\N	\N	8	C	Mohamed	Fanani	Mehadjia	Fanani Rachid 17/11/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17111982fnnrchdmhmdfnnmhj	0672167575	h_djellouli@esi.dz	0
870	\N	Outerbah	\N	Rabah	M	1971-09-25	N	Amizour	\N	\N	8	M	Bachir	Ihadjaren	Djida	Outerbah Rabah 25/09/1971	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25091971trbhrbhbchrhjrnjd	0672167575	h_djellouli@esi.dz	0
871	\N	Beloufa	\N	Mohammed	M	1975-01-29	N	Non Definie	\N	\N	8	M	Mimoun	Abdelli	Afia	Beloufa Mohammed 29/01/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29011975blfmhmdmmnbdlf	0672167575	h_djellouli@esi.dz	0
872	\N	Ferhane	\N	Boumediene	M	1980-01-22	N	Mostafa Ben Brahim	\N	\N	8	M	Abdelkader	Berkani	Rekia	Ferhane Boumediene 22/01/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22011980frhnbmdnbdlkdrbrknrk	0672167575	h_djellouli@esi.dz	0
873	\N	Nehila	\N	Sara	F	1990-06-20	N	El Hassassna	\N	\N	8	C	Miloud	Belarbi	Hmama	Nehila Sara 20/06/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20061990nhlsrmldblrbhmm	0672167575	h_djellouli@esi.dz	0
874	\N	Lahouel	\N	Souad	F	1996-06-30	N	Mascara	\N	\N	8	M	Benykhlef	Rachedi	Fatiha	Lahouel Souad 30/06/1996	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30061996lhlsdbnkhlfrchdfth	0672167575	h_djellouli@esi.dz	0
875	\N	Benabboun	\N	Elhabib	M	1984-09-18	N	Non Definie	\N	\N	8	M	Hanifi	Demouche	Djamila	Benabboun Elhabib 18/09/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18091984bnbnlhbbhnfdmchjml	0672167575	h_djellouli@esi.dz	0
876	\N	Ghafour	\N	Bouziane	M	1992-06-26	N	Relizane	\N	\N	8	M	Abdelkader	Adda	Zarka	Ghafour Bouziane 26/06/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26061992ghfrbznbdlkdrdzrk	0672167575	h_djellouli@esi.dz	0
877	\N	Ghalamallah	\N	Abderrahmane	M	1971-09-05	N	Sidi Khettab	\N	\N	8	M	Tayeb	Bessoltane	Kheira	Ghalamallah Abderrahmane 05/09/1971	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05091971ghlmlhbdrhmntbbsltnkhr	0672167575	h_djellouli@esi.dz	0
878	\N	Lemdjadi	\N	Houari	M	1977-12-02	N	Relizane	\N	\N	8	M	Mohamed	Aisset	Yamina	Lemdjadi Houari 02/12/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02121977lmjdhrmhmdstmn	0672167575	h_djellouli@esi.dz	0
879	\N	Ziane	\N	Miloud	M	1973-07-24	N	Sidi Brahim	\N	\N	8	M	Lahbib	Berrahma	Fatma	Ziane Miloud 24/07/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24071973znmldlhbbbrhmftm	0672167575	h_djellouli@esi.dz	0
880	\N	Nasri	\N	Seif Eddine	M	1989-06-05	N	Oum Bouaghi	\N	\N	8	M	Djemouai	Ben Abdenour	Mahbouba	Nasri Seif Eddine 05/06/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05061989nsrsfdnjmbnbdnrmhbb	0672167575	h_djellouli@esi.dz	0
881	\N	Chikh	\N	Mohamed El Amine	M	1993-07-15	N	El Hassassna	\N	\N	8	C	Bouziane	Cheikh	Kheira	Chikh Mohamed El Amine 15/07/1993	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15071993chkhmhmdlmnbznchkhkhr	0672167575	h_djellouli@esi.dz	0
882	\N	Ghalioui	\N	Fatima Zohra	M	1984-10-09	N	Mostafa Ben Brahim	\N	\N	8	C	Mohamed	Didane	Sida	Ghalioui Fatima Zohra 09/10/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09101984ghlftmzhrmhmdddnsd	0672167575	h_djellouli@esi.dz	0
883	\N	Zebir	\N	Youcef	M	1971-04-06	N	Hassi Zahana	\N	\N	8	M	Maamar	Khadem	Adel	Zebir Youcef 06/04/1971	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06041971zbrcfmmrkhdmdl	0672167575	h_djellouli@esi.dz	0
884	\N	Yahiaoui	\N	Mohammed	M	1942-10-20	N	Sefiane	\N	\N	8	M	Ahmed	Yahiaoui	Messaouda	Yahiaoui Mohammed 20/10/1942	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20101942hmhmdhmdhmsd	0672167575	h_djellouli@esi.dz	0
885	\N	Khaldi	\N	Benamar	M	1984-10-06	N	Mascara	\N	\N	8	M	Boualem	Houari	Khedidja	Khaldi Benamar 06/10/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06101984khldbnmrblmhrkhdj	0672167575	h_djellouli@esi.dz	0
886	\N	Belkenadil	\N	Mohamed	M	1982-10-16	N	Non Definie	\N	\N	8	M	Habib	Djebbar	Yagoubia	Belkenadil Mohamed 16/10/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16101982blkndlmhmdhbbjbrgb	0672167575	h_djellouli@esi.dz	0
887	\N	Khendek	\N	Leila	F	1985-11-23	N	Oran	\N	\N	8	M	Ahmed	Chaib	Karima	Khendek Leila 23/11/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23111985khndkllhmdchbkrm	0672167575	h_djellouli@esi.dz	0
888	\N	Merouane	\N	Mohamed	M	1975-07-09	N	Relizane	\N	\N	8	M	Hamza	Belhadj	Zohra	Merouane Mohamed 09/07/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09071975mrnmhmdhmzblhjzhr	0672167575	h_djellouli@esi.dz	0
889	\N	Redjem	\N	Bouzid	M	1982-02-17	N	Sidi Khettab	\N	\N	8	M	Ahmed	Sekrane	Kheira	Redjem Bouzid 17/02/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17021982rjmbzdhmdskrnkhr	0672167575	h_djellouli@esi.dz	0
890	\N	Redjem	\N	Mustapha	M	1970-09-14	N	Sidi Khettab	\N	\N	8	M	Moufak	Benhamou	Fatma	Redjem Mustapha 14/09/1970	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	14091970rjmmstphmfkbnhmftm	0672167575	h_djellouli@esi.dz	0
891	\N	Sekrane	\N	Abdallah	M	1981-10-01	N	Sidi Khettab	\N	\N	8	M	Tayeb	Hilouf	Aicha	Sekrane Abdallah 01/10/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01101981skrnbdlhtbhlfch	0672167575	h_djellouli@esi.dz	0
892	\N	Tchiko	\N	Nasreddine	M	1982-07-28	N	Mascara	\N	\N	8	M	Ahmed	Megaiez	Aicha	Tchiko Nasreddine 28/07/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28071982tchknsrdnhmdmgzch	0672167575	h_djellouli@esi.dz	0
893	\N	Lakhdar Chaouch	\N	Elhachemi	M	1987-02-20	N	Sidi Bel Abbes	\N	\N	8	M	Mohamed	Korich	Fatima	Lakhdar Chaouch Elhachemi 20/02/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20021987lkhdrchchlhchmmhmdkrchftm	0672167575	h_djellouli@esi.dz	0
894	\N	Mahdi	\N	Djamel	M	1987-07-29	N	Oum Bouaghi	\N	\N	8	M	Rabeh	Mebarki	El Khamssa	Mahdi Djamel 29/07/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29071987mhdjmlrbhmbrklkhms	0672167575	h_djellouli@esi.dz	0
895	\N	Bouzid	\N	Naoual	F	1980-07-13	N	Maamora	\N	\N	8	C	Baghdad	Benaouda	Djaouhar	Bouzid Naoual 13/07/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13071980bzdnlbghddbndjhr	0672167575	h_djellouli@esi.dz	0
896	\N	Zebir	\N	Mohamed	M	1977-12-06	N	Hassi Zahana	\N	\N	8	M	Moussa	Kerzazi	Kheira	Zebir Mohamed 06/12/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06121977zbrmhmdmskrzzkhr	0672167575	h_djellouli@esi.dz	0
897	\N	Ouali	\N	Abdelmadjid	M	1981-07-14	N	Sidi Bel Abbes	\N	\N	8	M	Mohamed	Allal	Khadidja	Ouali Abdelmadjid 14/07/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	14071981lbdlmjdmhmdllkhdj	0672167575	h_djellouli@esi.dz	0
898	\N	Arioua	\N	Mohamed	M	1981-11-03	N	Annaba	\N	\N	8	M	Aboud	Samaai	Akila	Arioua Mohamed 03/11/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03111981rmhmdbdsmkl	0672167575	h_djellouli@esi.dz	0
899	\N	Meftah	\N	Lakhdar	M	1979-01-01	N	El Hassassna	\N	\N	8	M	Abdelkader	Meftah	Bakhta	Meftah Lakhdar 01/01/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01011979mfthlkhdrbdlkdrmfthbkht	0672167575	h_djellouli@esi.dz	0
900	\N	Aissani	\N	Nouredine	M	1970-01-18	N	Oum Bouaghi	\N	\N	8	M	Messaoud	Baadachi	Nouna	Aissani Nouredine 18/01/1970	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18011970snnrdnmsdbdchnn	0672167575	h_djellouli@esi.dz	0
901	\N	Mouhtadi	\N	Khatir	M	1968-04-17	N	Mohammadia	\N	\N	8	M	Ali	Bettahar	Fatima	Mouhtadi Khatir 17/04/1968	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17041968mhtdkhtrlbthrftm	0672167575	h_djellouli@esi.dz	0
902	\N	Maachou	\N	Karima	F	1977-01-24	N	Mascara	\N	\N	8	M	Benameur	Boussada	Fatma	Maachou Karima 24/01/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24011977mchkrmbnmrbsdftm	0672167575	h_djellouli@esi.dz	0
903	\N	Laggoune	\N	Mounia	F	1977-08-31	N	Barika	\N	\N	8	D	Mohamed	Sellami	Salima	Laggoune Mounia 31/08/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	31081977lgnmnmhmdslmslm	0672167575	h_djellouli@esi.dz	0
904	\N	Mammeri	\N	Kadda	M	1975-02-04	N	Saida	\N	\N	8	M	Abdelkader	Benchikh	Meriem	Mammeri Kadda 04/02/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04021975mmrkdbdlkdrbnchkhmrm	0672167575	h_djellouli@esi.dz	0
905	\N	Maaziz	\N	Abdenacer	M	1991-03-07	N	Oum Bouaghi	\N	\N	8	M	Cherif	Goudjil	Dalila	Maaziz Abdenacer 07/03/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07031991mzzbdncrchrfgjldll	0672167575	h_djellouli@esi.dz	0
906	\N	Elkaroui	\N	Mohammed El Amine	M	1987-03-24	N	Belacel Bouzegza	\N	\N	8	M	Abdellah	Seghara	Zohra	Elkaroui Mohammed El Amine 24/03/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24031987lkrmhmdlmnbdlhsghrzhr	0672167575	h_djellouli@esi.dz	0
907	\N	Khaled	\N	Faycal	M	1992-03-13	N	Relizane	\N	\N	8	M	Habib	Adda Ben Ameur	Meriem	Khaled Faycal 13/03/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13031992khldfclhbbdbnmrmrm	0672167575	h_djellouli@esi.dz	0
908	\N	Belaribi	\N	Omar	M	1978-10-02	N	Gdyel	\N	\N	8	M	Mohamed	Moula	Zohra	Belaribi Omar 02/10/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02101978blrbmrmhmdmlzhr	0672167575	h_djellouli@esi.dz	0
909	\N	Hamel	\N	Mimoun	M	1976-01-27	N	Mostafa Ben Brahim	\N	\N	8	M	Mohamed	Brahimi	Chaia	Hamel Mimoun 27/01/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27011976hmlmmnmhmdbrhmch	0672167575	h_djellouli@esi.dz	0
910	\N	Benkamla	\N	Ghania	F	1993-03-11	N	Mascara	\N	\N	8	M	Benaoumeur	Kiouef	Nacera	Benkamla Ghania 11/03/1993	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11031993bnkmlghnbnmrkfncr	0672167575	h_djellouli@esi.dz	0
911	\N	Sayah	\N	Badreddine	M	1982-09-11	N	Mohammadia	\N	\N	8	M	Mohamed	Yekhlef	Fatiha	Sayah Badreddine 11/09/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11091982chbdrdnmhmdkhlffth	0672167575	h_djellouli@esi.dz	0
912	\N	Ouhiba	\N	Zouaoui	M	1976-11-19	N	Sidi Brahim	\N	\N	8	M	Habib	Kadari	Fatiha	Ouhiba Zouaoui 19/11/1976	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19111976hbzhbbkdrfth	0672167575	h_djellouli@esi.dz	0
913	\N	Addi	\N	Halima	F	1973-01-01	N	Sefiane	\N	\N	8	D	Ammar	Bouadelhai	Zohra	Addi Halima 01/01/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01011973dhlmmrbdlhzhr	0672167575	h_djellouli@esi.dz	0
914	\N	Boukhatemi	\N	Ali	M	1980-07-24	N	Mohammadia	\N	\N	8	M	Djilali	Mokhtari	Fatiha	Boukhatemi Ali 24/07/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24071980bkhtmljllmkhtrfth	0672167575	h_djellouli@esi.dz	0
915	\N	Foughali	\N	Amal	F	1975-07-22	N	Non Definie	\N	\N	8	M	Mohamed	Taibi	Fatima	Foughali Amal 22/07/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22071975fghlmlmhmdtbftm	0672167575	h_djellouli@esi.dz	0
916	\N	Yessad	\N	Ali	M	1983-01-10	N	Amizour	\N	\N	8	M	Hacene	Amzal	Malika	Yessad Ali 10/01/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10011983sdlhcnmzlmlk	0672167575	h_djellouli@esi.dz	0
917	\N	Maziz	\N	Said	M	1974-01-22	N	Oum Bouaghi	\N	\N	8	M	Moussa	Boudjemaa	Aziza	Maziz Said 22/01/1974	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22011974mzzsdmsbjmzz	0672167575	h_djellouli@esi.dz	0
918	\N	Boudaa	\N	Karim	M	1986-06-07	N	Mascara	\N	\N	8	M	Sidi Mohamed	Gherbi	Keltouma	Boudaa Karim 07/06/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07061986bdkrmsdmhmdghrbkltm	0672167575	h_djellouli@esi.dz	0
919	\N	Taoueche	\N	Fatima Thamina	F	1984-05-15	N	Mascara	\N	\N	8	D	Kada	Rezk Ellah	Zohra	Taoueche Fatima Thamina 15/05/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15051984tchftmthmnkdrzklhzhr	0672167575	h_djellouli@esi.dz	0
920	\N	Saida	\N	Ahmed	M	1986-09-17	N	Belacel Bouzegza	\N	\N	8	M	Bachir	Aouf	Mokhtaria	Saida Ahmed 17/09/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17091986sdhmdbchrfmkhtr	0672167575	h_djellouli@esi.dz	0
921	\N	Zahaf	\N	Djillali	M	1985-03-30	N	Belacel Bouzegza	\N	\N	8	M	Djillali	Saida	Aicha	Zahaf Djillali 30/03/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30031985zhfjlljllsdch	0672167575	h_djellouli@esi.dz	0
922	\N	Terki	\N	Mohamed	M	1981-04-21	N	Sidi Bel Abbes	\N	\N	8	M	Abdelkader	Benghafour	Fatima	Terki Mohamed 21/04/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21041981trkmhmdbdlkdrbnghfrftm	0672167575	h_djellouli@esi.dz	0
923	\N	Nouri	\N	Taqiyeddine	M	1988-09-20	N	Ain Beida	\N	\N	8	M	Mohamed	Sawli	Zohra	Nouri Taqiyeddine 20/09/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20091988nrtqdnmhmdswlzhr	0672167575	h_djellouli@esi.dz	0
924	\N	Zaidi	\N	Djamal	M	1973-06-29	N	Amizour	\N	\N	8	M	Hocine	Semsar	Zina	Zaidi Djamal 29/06/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29061973zdjmlhcnsmsrzn	0672167575	h_djellouli@esi.dz	0
925	\N	Yousfi	\N	Yasmina	F	1989-07-08	N	Barika	\N	\N	8	C	Nacire	Belhadi	Akila	Yousfi Yasmina 08/07/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08071989sfsmnncrblhdkl	0672167575	h_djellouli@esi.dz	0
926	\N	Sahbi	\N	Lamine	M	1982-11-04	N	Oum Bouaghi	\N	\N	8	M	Hocine	Sahbi	Barika	Sahbi Lamine 04/11/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04111982chblmnhcnchbbrk	0672167575	h_djellouli@esi.dz	0
927	\N	Hakiki	\N	Mostefa Yacine	M	1987-02-27	N	Mohammadia	\N	\N	8	C	Hacene	Azroug	Fatima	Hakiki Mostefa Yacine 27/02/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27021987hkkmstfcnhcnzrgftm	0672167575	h_djellouli@esi.dz	0
928	\N	Tebib	\N	Reda	M	1981-05-31	N	Sidi Bel Abbes	\N	\N	8	M	El Mahi	Lechlak	Khadra	Tebib Reda 31/05/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	31051981tbbrdlmhlchlkkhdr	0672167575	h_djellouli@esi.dz	0
929	\N	Zaikh	\N	Yamina	F	1974-12-28	N	Sidi Brahim	\N	\N	8	D	Miloud	Bent Maachou	Mehadjia	Zaikh Yamina 28/12/1974	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28121974zkhmnmldbntmchmhj	0672167575	h_djellouli@esi.dz	0
930	\N	Khitri	\N	Ismail	M	1983-09-17	N	Mecheria	\N	\N	8	M	Mohamed	Belouahrani	Rahma	Khitri Ismail 17/09/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17091983khtrsmlmhmdblhrnrhm	0672167575	h_djellouli@esi.dz	0
931	\N	Grireh	\N	Faical	M	1982-08-30	N	El Oued	\N	\N	8	M	Hamza	Gasmi	Aicha	Grireh Faical 30/08/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30081982grrhfclhmzgsmch	0672167575	h_djellouli@esi.dz	0
932	\N	Haissi	\N	Sofiane	M	1986-12-19	N	Mohammadia	\N	\N	8	C	Habib	Fellil	Khadra	Haissi Sofiane 19/12/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19121986hssfnhbbfllkhdr	0672167575	h_djellouli@esi.dz	0
933	\N	Abed	\N	Mounir	M	1977-07-28	N	Oum Bouaghi	\N	\N	8	M	Mokhtar	Abed	Saliha	Abed Mounir 28/07/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28071977bdmnrmkhtrbdslh	0672167575	h_djellouli@esi.dz	0
934	\N	Hachemane	\N	Zohra	F	1984-07-22	N	El Hassassna	\N	\N	8	C	Mohamed	Fatmi	Fatouma	Hachemane Zohra 22/07/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22071984hchmnzhrmhmdftmftm	0672167575	h_djellouli@esi.dz	0
935	\N	Hamidi	\N	Farid	M	1979-07-15	N	Barika	\N	\N	8	M	Ali	Hamidi	Hadda	Hamidi Farid 15/07/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15071979hmdfrdlhmdhd	0672167575	h_djellouli@esi.dz	0
936	\N	Benzakoura	\N	Mokhtar	M	1977-04-25	N	Mascara	\N	\N	8	M	Mohamed	Dormane	Mania	Benzakoura Mokhtar 25/04/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25041977bnzkrmkhtrmhmddrmnmn	0672167575	h_djellouli@esi.dz	0
937	\N	Tires	\N	Kada	M	1975-12-07	N	Mostafa Ben Brahim	\N	\N	8	M	Slimane	Bousbaa	Kheira	Tires Kada 07/12/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07121975trskdslmnbsbkhr	0672167575	h_djellouli@esi.dz	0
938	\N	Zeblah	\N	Mohammed Nabil	M	1989-10-17	N	Sidi Bel Abbes	\N	\N	8	C	Ibrahim	Boutenzar	Fatiha	Zeblah Mohammed Nabil 17/10/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17101989zblhmhmdnblbrhmbtnzrfth	0672167575	h_djellouli@esi.dz	0
939	\N	Taharou	\N	Dalila	F	1985-08-09	N	Mascara	\N	\N	8	C	Benameur	Larabi	Mokhtaria	Taharou Dalila 09/08/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09081985thrdllbnmrlrbmkhtr	0672167575	h_djellouli@esi.dz	0
940	\N	Guiroud	\N	Saddek	M	1994-04-03	N	Barika	\N	\N	8	C	Said	Guiroud	Hadda	Guiroud Saddek 03/04/1994	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03041994grdsdksdgrdhd	0672167575	h_djellouli@esi.dz	0
941	\N	Dahmane	\N	Abdelhadi	M	1983-11-26	N	El Guerrara	\N	\N	8	M	Aissa	Lakas	Khedidja	Dahmane Abdelhadi 26/11/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26111983dhmnbdlhdslkskhdj	0672167575	h_djellouli@esi.dz	0
942	\N	Khitri	\N	El Khadim	F	1991-05-25	N	Oran	\N	\N	8	M	Abdelkader	Khitri	Djida	Khitri El Khadim 25/05/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25051991khtrlkhdmbdlkdrkhtrjd	0672167575	h_djellouli@esi.dz	0
943	\N	Ziad	\N	Abdelkader	M	1968-11-22	N	Mohammadia	\N	\N	8	M	Djelloul	Chaibi	Ghezala	Ziad Abdelkader 22/11/1968	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22111968zdbdlkdrjllchbghzl	0672167575	h_djellouli@esi.dz	0
944	\N	Oughlis	\N	Massinissa	M	1984-10-18	N	Bejaia	\N	\N	8	C	Abdelaziz	Haddad	Houria	Oughlis Massinissa 18/10/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18101984ghlsmsnsbdlzzhddhr	0672167575	h_djellouli@esi.dz	0
945	\N	Boukaffoussa	\N	Kadda	M	1974-02-07	N	Mohammadia	\N	\N	8	M	Seghir	Goudjili	Yamina	Boukaffoussa Kadda 07/02/1974	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07021974bkfskdsghrgjlmn	0672167575	h_djellouli@esi.dz	0
946	\N	Guenouni	\N	Hanane	F	1990-08-29	N	Mascara	\N	\N	8	D	Ahmed	Abbes	Ghrissia	Guenouni Hanane 29/08/1990	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29081990gnnhnnhmdbsghrs	0672167575	h_djellouli@esi.dz	0
947	\N	Maachou	\N	Mokhtar	M	1994-11-27	N	Mostafa Ben Brahim	\N	\N	8	C	Kada	Boumaza	Fatiha	Maachou Mokhtar 27/11/1994	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27111994mchmkhtrkdbmzfth	0672167575	h_djellouli@esi.dz	0
948	\N	Abouanza	\N	Rami	M	1972-07-24	N	Etranger	\N	\N	8	M	Ismail	Zaki Abdelaziz Faredj	Mirvet	Abouanza Rami 24/07/1972	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24071972bnzrmsmlzkbdlzzfrjmrvt	0672167575	h_djellouli@esi.dz	0
949	\N	Matallah	\N	Mokhtar	M	1978-03-06	N	Mostafa Ben Brahim	\N	\N	8	M	Mohamed	Matallah	Fatima	Matallah Mokhtar 06/03/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06031978mtlhmkhtrmhmdmtlhftm	0672167575	h_djellouli@esi.dz	0
950	\N	Matallah	\N	Bouazza	M	1984-05-13	N	Sidi Bel Abbes	\N	\N	8	M	Lakhdar	Benzatar	Zouaouia	Matallah Bouazza 13/05/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13051984mtlhbzlkhdrbnztrz	0672167575	h_djellouli@esi.dz	0
951	\N	Arfi	\N	Zohra	F	1984-06-06	N	Mascara	\N	\N	8	M	Dahou	Djebbar	Fatma	Arfi Zohra 06/06/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06061984rfzhrdhjbrftm	0672167575	h_djellouli@esi.dz	0
952	\N	Abdelhadi	\N	Noureddine	M	1977-08-10	N	Mohammadia	\N	\N	8	M	Ahmed	Moulai Arbi	Kheira	Abdelhadi Noureddine 10/08/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10081977bdlhdnrdnhmdmlrbkhr	0672167575	h_djellouli@esi.dz	0
953	\N	Sadat	\N	Mouloud	M	1973-04-19	N	Mohammadia	\N	\N	8	M	Dahou	Sadat	El Khadem	Sadat Mouloud 19/04/1973	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19041973sdtmlddhsdtlkhdm	0672167575	h_djellouli@esi.dz	0
954	\N	Mendenkes	\N	Zouaoui	M	1979-08-05	N	Sidi Bel Abbes	\N	\N	8	M	Miloud	Mendenkes	Aichouche	Mendenkes Zouaoui 05/08/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05081979mndnkszmldmndnkschch	0672167575	h_djellouli@esi.dz	0
955	\N	Merabet	\N	Ahmed	M	1978-09-16	N	Mostafa Ben Brahim	\N	\N	8	M	Bendida	Boutaleb	Achoura	Merabet Ahmed 16/09/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	16091978mrbthmdbnddbtlbchr	0672167575	h_djellouli@esi.dz	0
956	\N	Mesboub	\N	Miloud	M	1977-04-08	N	Sfisef	\N	\N	8	M	Yahia	Mouhaouch	Zohra	Mesboub Miloud 08/04/1977	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08041977msbbmldhmhchzhr	0672167575	h_djellouli@esi.dz	0
957	\N	Lakhdar	\N	Malika	F	1964-11-25	N	Teghenif	\N	\N	8	M	Kada	Djemili	Yamina	Lakhdar Malika 25/11/1964	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25111964lkhdrmlkkdjmlmn	0672167575	h_djellouli@esi.dz	0
958	\N	Bouzid	\N	Faycal	M	1991-12-29	N	Mascara	\N	\N	8	M	Kada	Djeffel	Khedidja	Bouzid Faycal 29/12/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29121991bzdfclkdjflkhdj	0672167575	h_djellouli@esi.dz	0
959	\N	Mokadem	\N	Fatima Zohra	F	1988-10-19	N	Relizane	\N	\N	8	M	Belahouel	Rezki	Aicha	Mokadem Fatima Zohra 19/10/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19101988mkdmftmzhrblhlrzkch	0672167575	h_djellouli@esi.dz	0
960	\N	Bouataous Brahim	\N	Lakhdar	M	1959-11-13	N	Mohammadia	\N	\N	8	M	Mohamed	Sayah	Yamina	Bouataous Brahim Lakhdar 13/11/1959	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13111959btsbrhmlkhdrmhmdchmn	0672167575	h_djellouli@esi.dz	0
961	\N	Sobt	\N	Ouahiba	F	1989-12-10	N	Oued Taria	\N	\N	8	M	Elhbib	Hamas	Mokhtaria	Sobt Ouahiba 10/12/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10121989sbthblhbbhmsmkhtr	0672167575	h_djellouli@esi.dz	0
962	\N	Rais	\N	Brahim	M	1984-10-08	N	Mostafa Ben Brahim	\N	\N	8	M	Bensaid	Bouasria	Zoulikha	Rais Brahim 08/10/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08101984rsbrhmbnsdbsrzlkh	0672167575	h_djellouli@esi.dz	0
963	\N	Bouziane	\N	Nabil	M	1987-07-08	N	Mahdia	\N	\N	8	M	Mohamed	Slimani	Nadjia	Bouziane Nabil 08/07/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08071987bznnblmhmdslmnnj	0672167575	h_djellouli@esi.dz	0
964	\N	Rais	\N	Belabbas	M	1960-10-19	N	Sidi Bel Abbes	\N	\N	8	M	Ghalem	Rais	Melouka	Rais Belabbas 19/10/1960	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19101960rsblbsghlmrsmlk	0672167575	h_djellouli@esi.dz	0
965	\N	Benhamida	\N	Razia	F	1986-07-19	N	Mohammadia	\N	\N	8	M	Boumediene	Benaraba	Fatiha	Benhamida Razia 19/07/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19071986bnhmdrzbmdnbnrbfth	0672167575	h_djellouli@esi.dz	0
966	\N	Boubkar	\N	Mokhtar	M	1980-10-17	N	Mohammadia	\N	\N	8	M	Abdelkader	Bouadjeb	Cherguia	Boubkar Mokhtar 17/10/1980	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17101980bbkrmkhtrbdlkdrbjbchrg	0672167575	h_djellouli@esi.dz	0
967	\N	Touab	\N	Beghdad	M	1974-06-13	N	Mostafa Ben Brahim	\N	\N	8	M	Ahmed	Boucherit	Yamina	Touab Beghdad 13/06/1974	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13061974tbbghddhmdbchrtmn	0672167575	h_djellouli@esi.dz	0
968	\N	Belhaouari	\N	Kheira	F	1988-05-28	N	Oued Tlelat	\N	\N	8	M	Tayeb	Zine	Rekia	Belhaouari Kheira 28/05/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28051988blhrkhrtbznrk	0672167575	h_djellouli@esi.dz	0
969	\N	Kouadri	\N	Hamza	M	1989-01-02	N	Mascara	\N	\N	8	M	Boudjelal	Gherib	Fatima	Kouadri Hamza 02/01/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02011989kdrhmzbjllghrbftm	0672167575	h_djellouli@esi.dz	0
970	\N	Touilou	\N	Kada	M	1968-03-17	N	Mostafa Ben Brahim	\N	\N	8	M	Miloud	Djirouni	Keltouma	Touilou Kada 17/03/1968	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17031968tlkdmldjrnkltm	0672167575	h_djellouli@esi.dz	0
971	\N	Kouadri	\N	Mohamed	M	1986-06-05	N	Mascara	\N	\N	8	M	Boudjelal	Gherib	Fatima	Kouadri Mohamed 05/06/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05061986kdrmhmdbjllghrbftm	0672167575	h_djellouli@esi.dz	0
972	\N	Boukhalfa	\N	Khaled	M	1978-10-08	N	Mocta Douz	\N	\N	8	M	Moumen	Khalfallah	Yamina	Boukhalfa Khaled 08/10/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08101978bkhlfkhldmmnkhlflhmn	0672167575	h_djellouli@esi.dz	0
973	\N	Bouchelil	\N	Ahmed	M	1981-07-01	N	Mascara Centre	\N	\N	8	M	Mostafa	Benzina	Kheira	Bouchelil Ahmed 01/07/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01071981bchllhmdmstfbnznkhr	0672167575	h_djellouli@esi.dz	0
974	\N	Abdelaziz	\N	Hachemi	M	1983-02-22	N	Sfisef	\N	\N	8	M	Belabbes	Boutatoua	Djouher	Abdelaziz Hachemi 22/02/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22021983bdlzzhchmblbsbttjhr	0672167575	h_djellouli@esi.dz	0
975	\N	Hamadouche	\N	Hamid	M	1983-01-19	N	Mohammadia	\N	\N	8	M	Mohamed	Taleb	Khadidja	Hamadouche Hamid 19/01/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19011983hmdchhmdmhmdtlbkhdj	0672167575	h_djellouli@esi.dz	0
976	\N	Zekri	\N	Sidi Mohammed	M	1978-11-09	N	Nedroma	\N	\N	8	M	Abdelaziz	Zekri	Djamila	Zekri Sidi Mohammed 09/11/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09111978zkrsdmhmdbdlzzzkrjml	0672167575	h_djellouli@esi.dz	0
977	\N	Bengala	\N	Sid Ahmed	M	1984-02-06	N	Mascara	\N	\N	8	M	Youcef	Ahmed Elhadj	Aoumeria	Bengala Sid Ahmed 06/02/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06021984bnglsdhmdcfhmdlhjmr	0672167575	h_djellouli@esi.dz	0
978	\N	Amrani	\N	Abdelkader	M	1970-09-15	N	Mohammadia	\N	\N	8	M	Miloud	Rouai	Badra	Amrani Abdelkader 15/09/1970	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15091970mrnbdlkdrmldrbdr	0672167575	h_djellouli@esi.dz	0
979	\N	Ghaffour	\N	Radia	F	1988-01-26	N	Oran	\N	\N	8	M	Mohamed	Ghaffour	Fatima	Ghaffour Radia 26/01/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26011988ghfrrdmhmdghfrftm	0672167575	h_djellouli@esi.dz	0
980	\N	Mecherfi	\N	Abdelkader	M	1981-07-17	N	Mohammadia	\N	\N	8	M	Kada	Bousebaa	Salima	Mecherfi Abdelkader 17/07/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	17071981mchrfbdlkdrkdbsbslm	0672167575	h_djellouli@esi.dz	0
981	\N	Kouadri	\N	Ismail	M	1992-06-13	N	Mascara	\N	\N	8	M	Abdelkader	Si Moussa	Malika	Kouadri Ismail 13/06/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13061992kdrsmlbdlkdrsmsmlk	0672167575	h_djellouli@esi.dz	0
982	\N	Ledjedel	\N	Sid Ahmed	M	1988-08-15	N	Mascara	\N	\N	8	M	Abderrahmane	Benyahlou	Fatma	Ledjedel Sid Ahmed 15/08/1988	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	15081988ljdlsdhmdbdrhmnbnhlftm	0672167575	h_djellouli@esi.dz	0
983	\N	Abdelhadi	\N	Nacera	F	1978-07-01	N	Mohammadia	\N	\N	8	M	Boualem	Moulai Arbi	Zohra	Abdelhadi Nacera 01/07/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01071978bdlhdncrblmmlrbzhr	0672167575	h_djellouli@esi.dz	0
984	\N	Henkouche	\N	Malika	F	1986-04-02	N	Mascara	\N	\N	8	M	Abdelkader	Benzahaf	Fatima	Henkouche Malika 02/04/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02041986hnkchmlkbdlkdrbnzhfftm	0672167575	h_djellouli@esi.dz	0
985	\N	Berno	\N	Sofiane	M	1994-05-12	N	Sidi Bel Abbes	\N	\N	8	M	Abdelkader	Bayoud	Fatima	Berno Sofiane 12/05/1994	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12051994brnsfnbdlkdrbdftm	0672167575	h_djellouli@esi.dz	0
986	\N	Zaim	\N	Benamar	M	1984-11-22	N	Mascara	\N	\N	8	M	Chikh	Si Moussa	Rachida	Zaim Benamar 22/11/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22111984zmbnmrchkhsmsrchd	0672167575	h_djellouli@esi.dz	0
987	\N	Meghraoui	\N	Hanifi	M	1965-02-19	N	Sig	\N	\N	8	M	Tayeb	Hakiki	Aicha	Meghraoui Hanifi 19/02/1965	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19021965mghrhnftbhkkch	0672167575	h_djellouli@esi.dz	0
988	\N	Atmani	\N	Kheira	F	1983-04-12	N	Mascara	\N	\N	8	M	Ahmed	Atmani	Saadia	Atmani Kheira 12/04/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	12041983tmnkhrhmdtmnsd	0672167575	h_djellouli@esi.dz	0
989	\N	Medmoun	\N	Bachir	M	1984-07-30	N	Mascara	\N	\N	8	M	Mohamed	Titous	Zohra	Medmoun Bachir 30/07/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30071984mdmnbchrmhmdttszhr	0672167575	h_djellouli@esi.dz	0
990	\N	Hacherouf	\N	Tarek	M	1987-02-09	N	Ain Fares	\N	\N	8	M	Noureddine	Senouci	Fatma	Hacherouf Tarek 09/02/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	09021987hchrftrknrdnsncftm	0672167575	h_djellouli@esi.dz	0
991	\N	Galloua	\N	Mohamed	M	1986-02-21	N	Mohammadia	\N	\N	8	M	Hamadouche	Ahmed Baiche	Mokhtaria	Galloua Mohamed 21/02/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21021986glmhmdhmdchhmdbchmkhtr	0672167575	h_djellouli@esi.dz	0
992	\N	Ould Yerou	\N	Kheira	F	1981-04-08	N	Mascara	\N	\N	8	M	Mohamed	Ben Yerou	Zohra	Ould Yerou Kheira 08/04/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08041981ldrkhrmhmdbnrzhr	0672167575	h_djellouli@esi.dz	0
993	\N	Boumesjed	\N	Youcef	M	1981-08-11	N	Sfisef	\N	\N	8	M	Yahia	Mahroug	Malika	Boumesjed Youcef 11/08/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11081981bmsjdcfhmhrgmlk	0672167575	h_djellouli@esi.dz	0
994	\N	Benzabia	\N	Laouni	M	1978-01-01	N	Mascara	\N	\N	8	M	Ali	Bounoua	Aoumeria	Benzabia Laouni 01/01/1978	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	01011978bnzblnlbnmr	0672167575	h_djellouli@esi.dz	0
995	\N	Lahouel	\N	Bouchra	F	1993-08-20	N	Mascara	\N	\N	8	M	Benyekhlef	Rachedi	Fatiha	Lahouel Bouchra 20/08/1993	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	20081993lhlbchrbnkhlfrchdfth	0672167575	h_djellouli@esi.dz	0
996	\N	Mokhfi	\N	Mohamed Amine	M	1982-06-11	N	Mohammadia	\N	\N	8	M	Abderrahim	Azzedine	Kheira	Mokhfi Mohamed Amine 11/06/1982	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11061982mkhfmhmdmnbdrhmzdnkhr	0672167575	h_djellouli@esi.dz	0
997	\N	Idda	\N	M'Hammed	M	1993-11-18	N	Timimoun	\N	\N	8	C	Mohammed Elmessaoud	Idda	Fatma	Idda M'Hammed 18/11/1993	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18111993dmhmdmhmdlmsddftm	0672167575	h_djellouli@esi.dz	0
998	\N	Bettahar	\N	Mostefa	M	1981-05-06	N	Mohammadia	\N	\N	8	M	Habib	Mokhtar	Fatima	Bettahar Mostefa 06/05/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06051981bthrmstfhbbmkhtrftm	0672167575	h_djellouli@esi.dz	0
1034	\N	Madoun	\N	Amine	M	1979-08-23	N	Mascara	\N	\N	8	M	Bachir	Sayah	Kheira	Madoun Amine 23/08/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23081979mdnmnbchrchkhr	0672167575	h_djellouli@esi.dz	0
999	\N	Gombri	\N	Mokhtaria	F	1991-08-22	N	Mascara	\N	\N	8	M	Abderrahmane	Maarouf	Alia	Gombri Mokhtaria 22/08/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22081991gmbrmkhtrbdrhmnmrfl	0672167575	h_djellouli@esi.dz	0
1001	\N	Bekhti	\N	Fatima	F	1984-12-06	N	Mohammadia	\N	\N	8	M	Abdelkader	Berriahi	Bartia	Bekhti Fatima 06/12/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	06121984bkhtftmbdlkdrbrhbrt	0672167575	h_djellouli@esi.dz	0
1002	\N	Benfreha	\N	Mohamed	M	1985-12-03	N	Mascara	\N	\N	8	M	Abdelkader	Djalti	Fatma	Benfreha Mohamed 03/12/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03121985bnfrhmhmdbdlkdrjltftm	0672167575	h_djellouli@esi.dz	0
1003	\N	Mehenni	\N	Tahar	M	1972-11-29	N	El Hachem	\N	\N	8	M	Brahim	Mehenni	Zohra	Mehenni Tahar 29/11/1972	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29111972mhnthrbrhmmhnzhr	0672167575	h_djellouli@esi.dz	0
1004	\N	Tenni	\N	Mustapha	M	1983-12-22	N	Mascara	\N	\N	8	M	Boudjelal	Lahouel	Aoumeria	Tenni Mustapha 22/12/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	22121983tnmstphbjlllhlmr	0672167575	h_djellouli@esi.dz	0
1005	\N	Amar	\N	Didia	F	1981-10-18	N	Mohammadia	\N	\N	8	M	Hmaden	Hamidi	Yamina	Amar Didia 18/10/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18101981mrddhmdnhmdmn	0672167575	h_djellouli@esi.dz	0
1006	\N	Benaiad	\N	Ghezali	M	1983-10-28	N	Mascara	\N	\N	8	M	Ali	Djedid	Zohra	Benaiad Ghezali 28/10/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28101983bndghzlljddzhr	0672167575	h_djellouli@esi.dz	0
1007	\N	Doumi	\N	Abdelkader	M	1985-02-03	N	Mascara	\N	\N	8	M	Miloud	Bahri	Malika	Doumi Abdelkader 03/02/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03021985dmbdlkdrmldbhrmlk	0672167575	h_djellouli@esi.dz	0
1008	\N	Bachik	\N	Nacera	F	1969-10-05	N	Mohammadia	\N	\N	8	M	Miloud	Kalloua	Sadia	Bachik Nacera 05/10/1969	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05101969bchkncrmldklsd	0672167575	h_djellouli@esi.dz	0
1009	\N	Bouteghaghit	\N	Fatiha	F	1979-06-18	N	Mascara	\N	\N	8	C	Dahou	Ould Ahcene	Fatma	Bouteghaghit Fatiha 18/06/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18061979btghghtfthdhldhcnftm	0672167575	h_djellouli@esi.dz	0
1010	\N	Si Tayeb	\N	Mohammed	M	1987-02-02	N	Teghenif	\N	\N	8	M	Tayeb	Benbekkar	Yamina	Si Tayeb Mohammed 02/02/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02021987stbmhmdtbbnbkrmn	0672167575	h_djellouli@esi.dz	0
1011	\N	Rehamnia	\N	Dalila	F	1966-08-30	N	Souk Ahras	\N	\N	8	C	Younes	Rehamnia	Mabrouka	Rehamnia Dalila 30/08/1966	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	30081966rhmndllnsrhmnmbrk	0672167575	h_djellouli@esi.dz	0
1012	\N	Bendenia	\N	Abdelhak	M	1981-04-07	N	Mohammadia	\N	\N	8	M	Ahmed	Mostefa Hanchour	Kheroufa	Bendenia Abdelhak 07/04/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07041981bndnbdlhkhmdmstfhnchrkhrf	0672167575	h_djellouli@esi.dz	0
1013	\N	Tabeti	\N	Mohammed Amine	M	1979-03-25	N	Mascara	\N	\N	8	M	Mohamed	Tabeti	Fatma	Tabeti Mohammed Amine 25/03/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	25031979tbtmhmdmnmhmdtbtftm	0672167575	h_djellouli@esi.dz	0
1014	\N	Ziani	\N	Khedidja	F	1968-07-31	N	Mohammadia	\N	\N	8	M	Dahmane	Abderrahmane	Aicha	Ziani Khedidja 31/07/1968	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	31071968znkhdjdhmnbdrhmnch	0672167575	h_djellouli@esi.dz	0
1015	\N	Megherbi	\N	Zakaria	M	1995-08-28	N	Teghenif	\N	\N	8	C	Mhamed	Boukhlif	Kheira	Megherbi Zakaria 28/08/1995	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28081995mghrbzkrmhmdbkhlfkhr	0672167575	h_djellouli@esi.dz	0
1016	\N	Boudraa	\N	Abdeladim	M	1987-04-27	N	Mascara	\N	\N	8	M	Mohamed	Medjaheri	Fatima Mokhtaria	Boudraa Abdeladim 27/04/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27041987bdrbdldmmhmdmjhrftmmkhtr	0672167575	h_djellouli@esi.dz	0
1017	\N	Boukhalfa	\N	Adel Cherif	M	1989-12-08	N	Mascara	\N	\N	8	M	Lakhdar	Bouramla	Malika	Boukhalfa Adel Cherif 08/12/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	08121989bkhlfdlchrflkhdrbrmlmlk	0672167575	h_djellouli@esi.dz	0
1018	\N	Medjahedine	\N	Lakhdar	M	1975-04-27	N	Mohammadia	\N	\N	8	M	Mohamed	Gharich	Aicha	Medjahedine Lakhdar 27/04/1975	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27041975mjhdnlkhdrmhmdghrchch	0672167575	h_djellouli@esi.dz	0
1019	\N	Cheddad	\N	Abdelkader	M	1981-10-26	N	Mascara	\N	\N	8	M	Kada	Dahmani	Kheira	Cheddad Abdelkader 26/10/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	26101981chddbdlkdrkddhmnkhr	0672167575	h_djellouli@esi.dz	0
1020	\N	Aras	\N	Asmaa	F	1991-05-04	N	Mascara	\N	\N	8	M	Habib	Ouis	Mokhtaria	Aras Asmaa 04/05/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	04051991rssmhbbsmkhtr	0672167575	h_djellouli@esi.dz	0
1021	\N	Meziane	\N	Zohra	F	1972-11-24	N	El Ghomri	\N	\N	8	M	Mohamed	Benali	Kheira	Meziane Zohra 24/11/1972	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	24111972mznzhrmhmdbnlkhr	0672167575	h_djellouli@esi.dz	0
1022	\N	Tounsi	\N	Djilali Adel	M	1983-05-02	N	Mohammadia	\N	\N	8	M	Djilali	Saad	Fatma	Tounsi Djilali Adel 02/05/1983	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	02051983tnsjlldljllsdftm	0672167575	h_djellouli@esi.dz	0
1023	\N	Bellouti	\N	Kaddour	M	1984-06-21	N	Mascara	\N	\N	8	M	Ali	Deraiche	Fatima	Bellouti Kaddour 21/06/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21061984bltkdrldrchftm	0672167575	h_djellouli@esi.dz	0
1024	\N	Mebarkia	\N	Abel Illah	M	1984-10-23	N	Mascara	\N	\N	8	M	Mohamed	Charef	Zohra	Mebarkia Abel Illah 23/10/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23101984mbrkbllhmhmdchrfzhr	0672167575	h_djellouli@esi.dz	0
1025	\N	Benlekhal	\N	Belaid	M	1984-05-14	N	Mascara	\N	\N	8	M	Kada	Benlekhal	Djemaia	Benlekhal Belaid 14/05/1984	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	14051984bnlkhlbldkdbnlkhljm	0672167575	h_djellouli@esi.dz	0
1026	\N	Mayou	\N	Mohamed	M	1986-08-11	N	Sidi Abdelmoumene	\N	\N	8	C	Bilal	Benallou	Hadja	Mayou Mohamed 11/08/1986	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	11081986mmhmdbllbnlhj	0672167575	h_djellouli@esi.dz	0
1027	\N	Bouredja	\N	Fouzia	F	1981-04-14	N	Tenira	\N	\N	8	M	Miloud	Bouredja	Aicha	Bouredja Fouzia 14/04/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	14041981brjfzmldbrjch	0672167575	h_djellouli@esi.dz	0
1028	\N	Abdeslam	\N	Kada	M	1987-10-23	N	Mascara	\N	\N	8	M	Ahmed	Bentelfouf	Fatma	Abdeslam Kada 23/10/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	23101987bdslmkdhmdbntlffftm	0672167575	h_djellouli@esi.dz	0
1029	\N	Ferhaoui	\N	Mostefa	M	1971-08-29	N	Mohammadia	\N	\N	8	M	Habib	Mostefa	Kheira	Ferhaoui Mostefa 29/08/1971	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29081971frhmstfhbbmstfkhr	0672167575	h_djellouli@esi.dz	0
1030	\N	Ziad	\N	Dahou	M	1981-05-07	N	Mohammadia	\N	\N	8	M	Abdelkader	Ziad	Fadila	Ziad Dahou 07/05/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	07051981zddhbdlkdrzdfdl	0672167575	h_djellouli@esi.dz	0
1031	\N	Reguieg	\N	Djamel	M	1989-08-05	N	Tiaret	\N	\N	8	M	Benaouda	Benmelha	Aouda	Reguieg Djamel 05/08/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	05081989rggjmlbndbnmlhd	0672167575	h_djellouli@esi.dz	0
1032	\N	Chaouch	\N	Hadja Kheira Fatma Zohra	F	1985-05-03	N	Mohammadia	\N	\N	8	M	Abdelkader	Lakjae	Setti	Chaouch Hadja Kheira Fatma Zohra 03/05/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	03051985chchhjkhrftmzhrbdlkdrlkjst	0672167575	h_djellouli@esi.dz	0
1033	\N	Kadri	\N	Nouba	M	1981-05-28	N	Sig	\N	\N	8	M	Bouhabs	Belhadadji	Fatma	Kadri Nouba 28/05/1981	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	28051981kdrnbbhbsblhdjftm	0672167575	h_djellouli@esi.dz	0
1035	\N	Echchikh	\N	Mohammed Elamine	M	1987-06-10	N	Mascara	\N	\N	8	M	Salah	Taha	Mouldjillali	Echchikh Mohammed Elamine 10/06/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	10061987chchkhmhmdlmnslhthmljll	0672167575	h_djellouli@esi.dz	0
1036	\N	Rahal	\N	Mohammed	M	1968-06-21	N	Ain Fares	\N	\N	8	M	Benhacena	Bouhelal	Fatma	Rahal Mohammed 21/06/1968	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	21061968rhlmhmdbnhcnbhllftm	0672167575	h_djellouli@esi.dz	0
1037	\N	Moktaf	\N	Adda	M	1979-09-19	N	Mascara	\N	\N	8	M	Mohammed	Boutaleb	Cherifa	Moktaf Adda 19/09/1979	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19091979mktfdmhmdbtlbchrf	0672167575	h_djellouli@esi.dz	0
1038	\N	Ben Mimoun	\N	Abd Elkader	M	1961-12-13	N	Mascara	\N	\N	8	M	Hachemi	Dahmani	Zaza	Ben Mimoun Abd Elkader 13/12/1961	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13121961bnmmnbdlkdrhchmdhmnzz	0672167575	h_djellouli@esi.dz	0
1039	\N	Chettouane	\N	Mohamed	M	1985-11-14	N	Mohammadia	\N	\N	8	M	Missoum	Chettouane	Khadra	Chettouane Mohamed 14/11/1985	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	14111985chtnmhmdmsmchtnkhdr	0672167575	h_djellouli@esi.dz	0
1040	\N	Bechiri	\N	Rida	M	1971-01-19	N	Non Definie	\N	\N	8	M	Lahcen	Aouissi	Bariza	Bechiri Rida 19/01/1971	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	19011971bchrrdlhcnsbrz	0672167575	h_djellouli@esi.dz	0
1041	\N	Khelil	\N	Lalia	F	1969-06-18	N	Chlef	\N	\N	8	M	Mokhtar	Azzedine	Fatima	Khelil Lalia 18/06/1969	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18061969khllllmkhtrzdnftm	0672167575	h_djellouli@esi.dz	0
1042	\N	Benddine	\N	Ahmed	M	1989-07-13	N	Teghenif	\N	\N	8	M	Elhbib	Benasela	Nacera	Benddine Ahmed 13/07/1989	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13071989bndnhmdlhbbbnslncr	0672167575	h_djellouli@esi.dz	0
1043	\N	Kherraz	\N	Kada	M	1974-06-13	N	Mohammadia	\N	\N	8	M	Mhmaed	Bouhada	Oumelkhir	Kherraz Kada 13/06/1974	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	13061974khrzkdmhmdbhdmlkhr	0672167575	h_djellouli@esi.dz	0
1044	\N	Guechmi	\N	Abdelkader	M	1992-02-27	N	Mascara	\N	\N	8	M	Hadj	Maamar	Fatiha	Guechmi Abdelkader 27/02/1992	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	27021992gchmbdlkdrhjmmrfth	0672167575	h_djellouli@esi.dz	0
1045	\N	Garah	\N	Abdelhalim	M	1987-05-29	N	Berriche	\N	\N	8	M	Khelil	Gareh	Fatiha	Garah Abdelhalim 29/05/1987	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	29051987grhbdlhlmkhllgrhfth	0672167575	h_djellouli@esi.dz	0
1046	\N	Abdessamed	\N	Fatima Zohra	F	1991-10-18	N	Mascara	\N	\N	8	M	Farid	Benallel	Aoumeria	Abdessamed Fatima Zohra 18/10/1991	2020-11-16 10:01:59.262034	1	2020-11-16 10:01:59.262034	1	t	18101991bdsmdftmzhrfrdbnllmr	0672167575	h_djellouli@esi.dz	0
54	\N	Djellouli	\N	Hicham	F	1978-04-02	N	El Bayadh	Hussein Dey Alger,Algerie	\N	8	C	Mohamed	Bouab	Fatma	Djellouli Hicham 02/04/1978	2020-11-16 10:05:46.555388	1	2020-11-16 10:05:46.555388	1	t	02041978jllhchmmhmdbbftm	0672167575	h_djellouli@esi.dz	0
1086	\N	Xxxxxjellouli	\N	Hicham	M	1989-11-11	N	Bchar	Hussein Dey Alger,Algerie	\N	\N	C	\N	\N	\N	Xxxxxjellouli Hicham 11/11/1989	2021-01-28 19:12:28.655382	1	2021-01-28 19:12:28.655382	1	t	11111989xjllhchm	+213672167575	h_djellouli@esi.dz	1
\.


--
-- Data for Name: procedures; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.procedures (id, designation, definition, created, createdby, updated, updatedby, active, code) FROM stdin;
1	Consultation	\N	2020-11-17 14:06:57.253288	0	2020-11-17 14:06:57.253288	0	t	\N
2	Diagnostic	\N	2020-11-17 14:07:03.770004	0	2020-11-17 14:07:03.770004	0	t	\N
3	Radiographie	\N	2020-11-17 14:07:53.547198	0	2020-11-17 14:07:53.547198	0	t	\N
4	Anesthésie	\N	2020-11-17 14:08:15.981599	0	2020-11-17 14:08:15.981599	0	t	\N
5	Restauration	\N	2020-11-17 14:08:20.228087	0	2020-11-17 14:08:20.228087	0	t	\N
6	Canal radiculaire	\N	2020-11-17 14:08:45.468561	0	2020-11-17 14:08:45.468561	0	t	\N
7	Hygiène	\N	2020-11-17 14:09:05.273295	0	2020-11-17 14:09:05.273295	0	t	\N
8	Blanchiment	\N	2020-11-17 14:09:20.40147	0	2020-11-17 14:09:20.40147	0	t	\N
9	Couronnes	\N	2020-11-17 14:09:35.255756	0	2020-11-17 14:09:35.255756	0	t	\N
10	Implants	\N	2020-11-17 14:10:24.066043	0	2020-11-17 14:10:24.066043	0	t	\N
11	Orthodontie	\N	2020-11-17 14:10:33.622247	0	2020-11-17 14:10:33.622247	0	t	\N
12	Chirurgie	\N	2020-11-17 14:10:47.593284	0	2020-11-17 14:10:47.593284	0	t	\N
\.


--
-- Data for Name: produit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.produit (id, designation, created, createdby, updated, updatedby, active, code) FROM stdin;
\.


--
-- Data for Name: radiographies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.radiographies (id, designation, definition, created, createdby, updated, updatedby, active, code) FROM stdin;
3	Radiographie Panoramique	Montre une vue des dents, des mâchoires, de la zone nasale, des sinus et des articulations de la mâchoire, et est généralement prise lorsqu'un patient peut avoir besoin d'un traitement orthodontique ou imploffre une vue des dents, des mâchoires, de la région nasale, des sinus et des articulations de la mâchoire; Elle est généralement prise en charge lorsqu'un patient pourrait avoir besoin d'un traitement orthodontique ou d'un implant.	2020-11-16 11:11:55.911165	0	2020-11-16 11:11:55.911165	0	t	\N
1	Radiographie Périapicale	Permet de voir la dent dans son ensemble, de la couronne à l’os qui contribue à la soutenir.	2020-11-16 11:05:31.473286	0	2020-11-16 11:05:31.473286	0	t	\N
2	Radiographie Interproximale	Permet de voir les dents postérieures inférieures et supérieures. Ce type de radiographie permet au dentiste d’étudier la manière dont ces dents se touchent (occlusion) et de déterminer la présence de caries entre les dents arrière.	2020-11-16 11:10:20.70894	0	2020-11-16 11:10:20.70894	0	t	\N
4	Radiographie Occlusale	Offre une vue claire du plancher de la bouche pour étudier l’occlusion des mâchoires inférieure et supérieure. Ce type de radiographie permet de visualiser le développement dentaire chez l’enfant et de voir les dents temporaires (bébé) et permanentes (adulte).	2020-11-16 11:12:28.612988	0	2020-11-16 11:12:28.612988	0	t	\N
\.


--
-- Data for Name: resultat_controle_cnas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.resultat_controle_cnas (id, demande_controle_id, postulant_id, result_cnas, result_cnas_cjt, created, createdby, updated, updatedby, active) FROM stdin;
36	212	101	Statut: Assuré actif| R.S: CNL| Date effet: 2013-04-20| Date Sortie: 2021-03-31	Statut: Assuré actif| R.S: CNL| Date effet: 2017-10-15| Date Sortie: 2021-03-31	2020-10-08 09:57:52.192	1	2020-10-08 09:57:52.192	1	t
37	212	105	Statut: Assuré introuvable !	\N	2020-10-08 09:57:52.192	1	2020-10-08 09:57:52.192	1	t
38	212	103	Statut: Assuré introuvable !	\N	2020-10-08 09:57:52.192	1	2020-10-08 09:57:52.192	1	t
39	212	104	Statut: Assuré actif| R.S: DIRECTION DE L'EDUCATION| Date effet: 2011-01-12| Date Sortie: 2021-06-30	\N	2020-10-08 09:57:52.192	1	2020-10-08 09:57:52.192	1	t
40	212	102	Statut: Date fin de droit expirée, Veuillez déposer l'ATS| R.S: CNR CAISSE NATIONALE RETRAITE| Date effet: 1981-01-01| Date Sortie: 2008-10-15	\N	2020-10-08 09:57:52.192	1	2020-10-08 09:57:52.192	1	t
41	212	101	Statut: Assuré actif| R.S: CNL| Date effet: 2013-04-20| Date Sortie: 2021-03-31	Statut: Assuré actif| R.S: CNL| Date effet: 2017-10-15| Date Sortie: 2021-03-31	2020-10-08 15:10:32.366	1	2020-10-08 15:10:32.366	1	t
42	212	105	Statut: Assuré introuvable !	\N	2020-10-08 15:10:32.366	1	2020-10-08 15:10:32.366	1	t
43	212	103	Statut: Assuré introuvable !	\N	2020-10-08 15:10:32.366	1	2020-10-08 15:10:32.366	1	t
44	212	104	Statut: Assuré actif| R.S: DIRECTION DE L'EDUCATION| Date effet: 2011-01-12| Date Sortie: 2021-06-30	\N	2020-10-08 15:10:32.366	1	2020-10-08 15:10:32.366	1	t
45	212	102	Statut: Date fin de droit expirée, Veuillez déposer l'ATS| R.S: CNR CAISSE NATIONALE RETRAITE| Date effet: 1981-01-01| Date Sortie: 2008-10-15	\N	2020-10-08 15:10:32.366	1	2020-10-08 15:10:32.366	1	t
\.


--
-- Data for Name: resultat_controle_cnr; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.resultat_controle_cnr (id, demande_controle_id, postulant_id, result_cnr, result_cnr_cjt, created, createdby, updated, updatedby, active) FROM stdin;
36	212	101	Aucune pension ne correspond aux parametres saisis	Aucune pension ne correspond aux parametres saisis	2020-10-08 09:58:02.357	1	2020-10-08 09:58:02.357	1	t
37	212	105	Aucune pension ne correspond aux parametres saisis	\N	2020-10-08 09:58:02.357	1	2020-10-08 09:58:02.357	1	t
38	212	103	Aucune pension ne correspond aux parametres saisis	\N	2020-10-08 09:58:02.357	1	2020-10-08 09:58:02.357	1	t
39	212	104	N° pension: A73552988 | Etat: en paiement | Net Mensuel: Inferieur à 30.000 da	\N	2020-10-08 09:58:02.357	1	2020-10-08 09:58:02.357	1	t
40	212	102	N° pension: B11125984 | Etat: décès | Net Mensuel: Supperieur ou égal à 30.000 da	\N	2020-10-08 09:58:02.357	1	2020-10-08 09:58:02.357	1	t
41	212	101	Aucune pension ne correspond aux parametres saisis	Aucune pension ne correspond aux parametres saisis	2020-10-08 15:10:49.861	1	2020-10-08 15:10:49.861	1	t
42	212	105	Aucune pension ne correspond aux parametres saisis	\N	2020-10-08 15:10:49.861	1	2020-10-08 15:10:49.861	1	t
43	212	103	Aucune pension ne correspond aux parametres saisis	\N	2020-10-08 15:10:49.861	1	2020-10-08 15:10:49.861	1	t
44	212	104	N° pension: A73552988 | Etat: en paiement | Net Mensuel: Inferieur à 30.000 da	\N	2020-10-08 15:10:49.861	1	2020-10-08 15:10:49.861	1	t
45	212	102	N° pension: B11125984 | Etat: décès | Net Mensuel: Supperieur ou égal à 30.000 da	\N	2020-10-08 15:10:49.861	1	2020-10-08 15:10:49.861	1	t
\.


--
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role (id, designation, created, createdby, updated, updatedby, active) FROM stdin;
0	System	16:30:27.756+02	0	16:30:27.756+02	0	t
1	Administrateur Central	16:33:55.989+02	0	16:33:55.989+02	0	t
2	Administrateur Local	16:31:05.93+02	0	16:31:05.93+02	0	t
3	Consultation	22:57:56.281+02	0	22:57:56.281+02	0	t
\.


--
-- Data for Name: severites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.severites (id, designation, created, createdby, updated, updatedby, active) FROM stdin;
1	Légère	2020-11-23 14:19:20.920277	0	2020-11-23 14:19:20.920277	0	t
2	Inquiétante	2020-11-23 14:19:42.302697	0	2020-11-23 14:19:42.302697	0	t
3	Grave	2020-11-23 14:20:00.125255	0	2020-11-23 14:20:00.125255	0	t
\.


--
-- Data for Name: types_paiements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.types_paiements (id, designation, created, createdby, updated, updatedby, active) FROM stdin;
1	Espèce	2020-11-28 14:55:18.512407	0	2020-11-28 14:55:18.512407	0	t
2	chèque CCP	2020-11-28 14:55:18.512407	0	2020-11-28 14:55:18.512407	0	t
3	Chèque de banque	2020-11-28 14:55:18.512407	0	2020-11-28 14:55:18.512407	0	t
4	Carte Edahabia	2020-11-28 14:55:18.512407	0	2020-11-28 14:55:18.512407	0	t
5	Carte CIB	2020-11-28 14:55:18.512407	0	2020-11-28 14:55:18.512407	0	t
7	Carte Visa	2020-11-29 20:37:06.824029	1	2020-11-29 20:37:06.824029	1	t
6	Autres	2020-11-28 15:16:49.993531	1	2020-12-16 10:30:45.527003	1	t
\.


--
-- Data for Name: types_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.types_transactions (id, designation, created, createdby, updated, updatedby, active, operation, cible) FROM stdin;
1	Versement d'un patient	2020-11-29 10:54:52.182178	0	2020-11-29 22:02:59.787458	1	t	credit	patient
2	Payer un fournisseur	2020-11-29 10:54:52.182178	0	2020-11-29 22:02:12.156676	1	t	debit	partenaire
3	Rembourser un patient	2020-11-29 10:54:52.182178	0	2020-11-29 22:02:11.694708	1	t	debit	patient
4	Rembourser un fournisseur	2020-11-29 16:27:28.778257	1	2020-11-29 22:02:13.841616	1	t	debit	partenaire
8	Facture d'électrictié et du gaz	2020-11-29 20:35:21.588979	1	2021-01-28 19:29:02.566219	1	t	debit	partenaire
9	Facture d'eau	2021-01-28 19:28:36.877384	1	2021-01-28 19:29:18.20386	1	t	debit	partenaire
10	Salaire	2021-01-28 19:29:30.216402	1	2021-01-28 19:29:39.004349	1	t	debit	partenaire
11	Prime	2021-01-28 19:29:54.876512	1	2021-01-28 19:29:56.470271	1	t	debit	partenaire
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, fname, lname, gender, address, email, password, createdby, updatedby, active, token, wilaya_id, org_id, org_directions_id, first_visit, created, updated, lib, org_profession_id, file_name) FROM stdin;
0	System	System	M	\N	system@dzental.com	admin	0	0	t	\N	1	0	0	t	\N	\N	System System	\N	man.png
3	Demo2	Demo2	M	\N	demo2@dzental.com	demo2	1	1	t	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRlX3Rva2VuIjoiMjAyMC0xMi0xMVQxNjowOTowMC42MjRaIiwia2V5IjpbIkZOTCJdLCJpZCI6MTA0LCJlbWFpbCI6ImFkbWluQGVzaS5keiIsImlhdCI6MTYwNzcwMjk0MH0.V5UIGyLXBaRVHIgFjJvNDyCx66qYBBuAT6V6UCV4VOU	\N	1	\N	f	2020-12-09 11:55:18.917016	2020-12-09 11:55:18.917016	Demo2 Demo2	3	man.png
4	Demo3	Demo3	F	\N	demo3@dzental.com	demo3	1	\N	t	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRlX3Rva2VuIjoiMjAyMC0xMi0xN1QxNzoxNTo1MC4zMzNaIiwia2V5IjpbIkR6ZW50YWwiXSwiaWQiOjEwNSwiZW1haWwiOiJoZGplbGxvdWxpZHpAb3V0bG9vay5mciIsImlhdCI6MTYwODIyNTM1MH0.HKEujJlGzi9CpVoXKdno88KvFvFI_Euwi4ny2iyZkHc	\N	1	\N	f	2020-12-13 17:28:07.594	2021-01-28 19:16:45.079173	Demo3 Demo3	3	women.png
2	Demo1	Demo1	F	\N	demo1@dzental.com	demo1	1	\N	t	\N	\N	1	\N	t	2020-12-09 08:54:36.354	2021-01-28 19:16:52.342062	Demo1 Demo1	1	women.png
1	Demo	Demo	M	\N	demo@dzental.com	demo	0	\N	t	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRlX3Rva2VuIjoiMjAyMS0wMS0zMVQxNzozOToxNC42OTdaIiwia2V5IjpbIkR6ZW50YWwiXSwiaWQiOjEsImVtYWlsIjoiZGVtb0BkemVudGFsLmNvbSIsImlhdCI6MTYxMjExNDc1NH0.s4ArgdUrVJzTHHxQrPWAcgukAVMRq4NG24QTmxYvEsQ	1	1	1	f	\N	2021-01-09 18:21:23.956888	Demo Demo	1	avatar_1_9_0_2021_18_21_23.png
\.


--
-- Data for Name: users_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_messages (id, read, created, createdby, to_user_id, message, updatedby, active, updated) FROM stdin;
38	f	2020-12-08 21:01:15.099155	1	2	Wa Alikom salam\nJe m'appelle Amira	1	t	2020-12-08 21:01:15.099155
41	f	2020-12-08 21:04:19.515632	1	2	ok Treba7, wa rani za3fana	1	t	2020-12-08 21:04:19.515632
43	f	2020-12-08 21:17:27.014613	1	2	test	1	t	2020-12-08 21:17:27.014613
52	f	2020-12-09 16:09:56.985269	1	2	salam wehdek	104	t	2020-12-09 16:09:56.985269
53	f	2020-12-09 16:10:16.448003	2	3	salam wehdek	104	t	2020-12-09 16:10:16.448003
54	f	2020-12-09 16:10:53.074563	3	4	salam wehdek	104	t	2020-12-09 16:10:53.074563
56	f	2020-12-09 16:16:14.211325	1	2	salam wehdek	104	t	2020-12-09 16:16:14.211325
57	f	2020-12-09 16:16:56.309557	2	3	salam ghir rohek	104	t	2020-12-09 16:16:56.309557
58	f	2020-12-09 16:17:59.210052	3	4	salam ghir rohek	104	t	2020-12-09 16:17:59.210052
60	f	2020-12-09 16:19:16.362315	1	4	rtezr	104	t	2020-12-09 16:19:16.362315
61	f	2020-12-09 16:19:43.613309	2	3	test	104	t	2020-12-09 16:19:43.613309
84	t	2020-12-09 17:27:03.652211	3	2	kiraki dayra chwiya	104	t	2020-12-09 17:27:03.652211
86	t	2020-12-09 17:29:37.295788	1	1	nta samet	104	t	2020-12-09 17:29:37.295788
88	t	2020-12-09 17:30:26.719684	2	3	emshiii	1	t	2020-12-09 17:30:26.719684
89	t	2020-12-09 17:33:15.834788	3	2	aje test	104	t	2020-12-09 17:33:15.834788
91	t	2020-12-09 17:34:53.561789	1	2	dsqdqs	104	t	2020-12-09 17:34:53.561789
92	t	2020-12-09 17:38:55.992207	2	4	ffff	104	t	2020-12-09 17:38:55.992207
94	t	2020-12-09 17:39:33.104372	3	2	fdfd	104	t	2020-12-09 17:39:33.104372
104	t	2020-12-09 18:29:17.761928	1	4	test	1	t	2020-12-09 18:29:17.761928
105	t	2020-12-09 18:32:59.625051	1	3	teset	1	t	2020-12-09 18:32:59.625051
106	t	2020-12-09 18:33:44.635149	1	2	fcf	1	t	2020-12-09 18:33:44.635149
107	t	2020-12-09 18:33:54.446996	1	4	fdgd	1	t	2020-12-09 18:33:54.446996
109	t	2020-12-11 17:08:23.704572	1	2	test	1	t	2020-12-11 17:08:23.704572
110	t	2020-12-11 17:14:28.324494	3	4	salaaam	104	t	2020-12-11 17:14:28.324494
111	t	2020-12-17 14:08:33.150908	1	2	teest	105	t	2020-12-17 14:08:33.150908
112	t	2020-12-17 14:09:15.965409	1	3	Salut toi	1	t	2020-12-17 14:09:15.965409
114	t	2020-12-17 14:09:33.160337	1	2	Oui hamdoullah	1	t	2020-12-17 14:09:33.160337
115	t	2020-12-17 15:14:27.735197	2	4	Hamdoullah	105	t	2020-12-17 15:14:27.735197
116	t	2020-12-17 16:00:53.012777	3	1	Ok	105	t	2020-12-17 16:00:53.012777
37	t	2020-12-08 21:00:57.800523	2	1	Salam\nje suis Hicham	2	t	2020-12-08 21:00:57.800523
40	t	2020-12-08 21:02:51.930839	2	1	ok treb7i	2	t	2020-12-08 21:02:51.930839
108	t	2020-12-10 22:08:10.96413	2	1	test	104	t	2020-12-10 22:08:10.96413
55	t	2020-12-09 16:10:59.087104	4	1	salam wehdek	104	t	2020-12-09 16:10:59.087104
59	t	2020-12-09 16:18:19.036634	4	1	test	104	t	2020-12-09 16:18:19.036634
85	t	2020-12-09 17:29:20.597422	4	1	test	1	t	2020-12-09 17:29:20.597422
90	t	2020-12-09 17:34:49.114634	4	1	ssss	104	t	2020-12-09 17:34:49.114634
113	t	2020-12-17 14:09:25.622691	4	1	cv	105	t	2020-12-17 14:09:25.622691
117	t	2020-12-17 16:05:28.509899	4	1	Faites entre le patients svp	105	t	2020-12-17 16:05:28.509899
\.


--
-- Data for Name: users_notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_notifications (id, user_id, broadcast, expiration_date, message, createdby, updatedby, active, read, header, created, updated, org_id) FROM stdin;
1	0	f	2010-03-21 17:34:13.791+01	Bienvenue	0	0	t	f	notif1	2020-08-13 01:02:21.356	2020-08-13 01:02:21.356	\N
7	2	f	2020-12-12 00:00:00+01	Nouvelle notification	0	30	t	f	notif4	2020-08-13 01:02:21.356	2020-08-13 01:02:21.356	\N
5	0	f	2020-12-12 00:00:00+01	Nouvelle notification	0	0	t	f	notif4	2020-08-13 01:02:21.356	2020-08-13 01:02:21.356	\N
16	1	t	2020-12-18 00:00:00+01	Un mail automarique a été envoyé à M. Bahloul Salima pour lui rappeler son RDV du <b>18/12/2020 à 07:00</b>	1	105	t	t	Rappel M.Bahloul Salima	2020-12-17 08:27:08.758276	2020-12-17 16:15:05.260444	1
3	2	f	2020-12-12 00:00:00+01	salam <b>Alikom</b> j'espère que vous allez bien, ceci est un exemple de <u>notification</u> qu'on peut envoyer à des utilisateurs de notre applications 	0	30	t	f	notif3	2020-08-13 01:02:21.356	2020-08-13 01:02:21.356	\N
9	2	f	2020-12-12 00:00:00+01	Nouvelle notification	0	2	t	f	notif4	2020-08-13 01:02:21.356	2020-08-15 22:31:51.261	\N
8	1	f	2020-12-12 00:00:00+01	Nouvelle notification	0	1	t	f	notif4	2020-08-13 01:02:21.356	2020-09-21 16:28:22.719	\N
18	1	t	2020-12-18 00:00:00+01	Un mail automarique a été envoyé à M. Bessai Sofiane pour lui rappeler son RDV du <b>18/12/2020 à 07:00</b>	1	105	t	t	Rappel M.Bessai Sofiane	2020-12-17 08:27:11.692636	2020-12-17 15:20:19.944529	1
17	1	t	2020-12-18 00:00:00+01	Un mail automarique a été envoyé à M. Latri Boubaker pour lui rappeler son RDV du <b>18/12/2020 à 07:00</b>	1	105	t	t	Rappel M.Latri Boubaker	2020-12-17 08:27:09.350636	2020-12-17 15:20:19.944805	1
2	1	t	2020-12-12 00:00:00+01	Ceci est un message braodcast	0	1	t	f	notif2	2020-08-13 01:02:21.356	2020-12-08 16:01:00.364246	\N
6	1	f	2020-12-12 00:00:00+01	Nouvelle notification	0	1	t	f	notif4	2020-08-13 01:02:21.356	2020-12-08 16:01:06.290134	\N
11	1	t	2020-12-17 00:00:00+01	Un mail automarique a été envoyé à M. Setti Abdelhakim pour lui rappeler son RDV du <b>17/12/2020 à 09:00</b>	1	1	t	f	Rappel M.Setti Abdelhakim	2020-12-16 13:49:02.528355	2020-12-16 13:51:54.57038	1
10	1	t	2020-12-17 00:00:00+01	Un mail automarique a été envoyé à M. Mezioud Mohamed pour lui rappeler son RDV du <b>17/12/2020 à 07:00</b>	1	1	t	f	Rappel M.Mezioud Mohamed	2020-12-16 13:49:01.823016	2020-12-16 13:52:40.657194	1
13	1	t	2020-12-17 00:00:00+01	Un mail automarique a été envoyé à M. Guermis Aida pour lui rappeler son RDV du <b>16/12/2020 à 03:00</b>	1	1	t	f	Rappel M.Guermis Aida	2020-12-16 13:50:16.653446	2020-12-16 13:52:43.781207	1
12	1	t	2020-12-17 00:00:00+01	Un mail automarique a été envoyé à M. Guermis Aida pour lui rappeler son RDV du <b>09/12/2020 à 07:00</b>	1	1	t	f	Rappel M.Guermis Aida	2020-12-16 13:50:16.10352	2020-12-16 13:52:46.474407	1
14	1	t	2020-12-17 00:00:00+01	Un mail automarique a été envoyé à M. Sadeg Mohammed Elamine pour lui rappeler son RDV du <b>16/12/2020 à 12:30</b>	1	1	t	f	Rappel M.Sadeg Mohammed Elamine	2020-12-16 13:50:17.675242	2020-12-16 13:52:49.488114	1
15	1	t	2020-12-17 00:00:00+01	Un mail automarique a été envoyé à M. Messaoud Ammar pour lui rappeler son RDV du <b>16/12/2020 à 13:00</b>	1	1	t	f	Rappel M.Messaoud Ammar	2020-12-16 13:50:18.197754	2020-12-16 13:52:52.166691	1
19	1	t	2020-12-18 00:00:00+01	Un mail automatique a été envoyé à M. Bessai Sofiane pour lui rappeler son RDV du <b>18/12/2020 à 09:50</b>	1	105	t	t	Rappel <b>M.Bessai Sofiane</b>	2020-12-17 08:37:14.230922	2020-12-17 15:20:20.032197	1
20	1	t	2020-12-18 00:00:00+01	Un mail automatique a été envoyé à M.<b>Setti Abdelhakim</b> pour lui rappeler son RDV du <b>18/12/2020 à 06:00</b>	1	105	t	t	Rappel M.Setti Abdelhakim	2020-12-17 08:38:09.935066	2020-12-17 15:20:20.034064	1
21	1	t	2021-01-29 00:00:00+01	Un mail automatique a été envoyé à <b>M.Xxxxxxx Hicham</b> pour lui rappeler son RDV du <b>22/01/2021 à 21:10</b>	1	1	t	f	Rappel M.Xxxxxxx Hicham	2021-01-28 19:10:13.722172	2021-01-28 19:10:13.722172	1
22	1	t	2021-01-29 00:00:00+01	Un mail automatique a été envoyé à <b>M.Xxxxxxx Hicham</b> pour lui rappeler son RDV du <b>22/01/2021 à 21:10</b>	1	1	t	f	Rappel M.Xxxxxxx Hicham	2021-01-28 19:10:14.272925	2021-01-28 19:10:14.272925	1
23	1	t	2021-01-29 00:00:00+01	Un mail automatique a été envoyé à <b>M.Xxxxxxx Hicham</b> pour lui rappeler son RDV du <b>22/01/2021 à 21:10</b>	1	1	t	f	Rappel M.Xxxxxxx Hicham	2021-01-28 19:10:20.420922	2021-01-28 19:10:20.420922	1
\.


--
-- Data for Name: users_produits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_produits (id, user_id, produit_id, createdby, updatedby, active, created, updated) FROM stdin;
\.


--
-- Data for Name: users_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_roles (id, user_id, role_id, createdby, updatedby, active, created, updated) FROM stdin;
1	0	0	0	0	t	\N	\N
\.


--
-- Data for Name: users_roles_access_control; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_roles_access_control (id, user_id, role_id, table_name, can_create, can_read, can_update, can_delete, createdby, updatedby, active, created, updated, org_id) FROM stdin;
21	2	\N	patients	f	t	f	f	0	1	t	2021-01-18 20:26:53.169094	2021-01-18 20:39:32.468871	1
22	2	\N	patients_vitals	f	t	f	f	0	1	t	2021-01-18 20:26:53.169094	2021-01-18 20:39:32.468871	1
23	2	\N	patients_pathologies	f	t	f	f	0	1	t	2021-01-18 20:26:53.169094	2021-01-18 20:39:32.468871	1
24	2	\N	patients_radiographies	f	t	f	f	0	1	t	2021-01-18 20:26:53.169094	2021-01-18 20:39:32.468871	1
25	2	\N	patients_traitements	f	t	f	f	0	1	t	2021-01-18 20:26:53.169094	2021-01-18 20:39:32.468871	1
26	2	\N	patients_ordonnances	f	t	f	f	0	1	t	2021-01-18 20:26:53.169094	2021-01-18 20:39:32.468871	1
27	2	\N	patients_certificats	f	t	f	f	0	1	t	2021-01-18 20:26:53.169094	2021-01-18 20:39:32.468871	1
28	2	\N	patients_rdvs	f	f	f	f	0	1	t	2021-01-18 20:26:53.169094	2021-01-18 20:39:32.468871	1
29	2	\N	patients_versements	f	f	f	f	0	1	t	2021-01-18 20:26:53.169094	2021-01-18 20:39:32.468871	1
30	2	\N	patients_transactions	f	f	f	f	0	1	t	2021-01-18 20:26:53.169094	2021-01-18 20:39:32.468871	1
31	2	\N	static_tables	f	f	f	f	0	1	t	2021-01-18 20:26:53.169094	2021-01-18 20:39:32.468871	1
32	2	\N	reports	f	f	f	f	0	1	t	2021-01-18 20:26:53.169094	2021-01-18 20:39:32.468871	1
33	2	\N	annuaire	f	f	f	f	0	1	t	2021-01-18 20:26:53.169094	2021-01-18 20:39:32.468871	1
34	2	\N	compte	f	f	f	f	0	1	t	2021-01-18 20:26:53.169094	2021-01-18 20:39:32.468871	1
35	2	\N	clinique	f	f	f	f	0	1	t	2021-01-18 20:26:53.169094	2021-01-18 20:39:32.468871	1
36	2	\N	utilisateurs	f	f	f	f	0	1	t	2021-01-18 20:26:53.169094	2021-01-18 20:39:32.468871	1
1	1	\N	patients	t	t	t	t	\N	1	t	2021-01-17 17:28:07.923019	2021-01-28 19:17:17.005111	1
2	1	\N	patients_vitals	t	t	t	t	\N	1	t	2021-01-17 17:28:07.923019	2021-01-28 19:17:17.005111	1
4	1	\N	patients_pathologies	t	t	t	t	\N	1	t	2021-01-17 17:28:07.923019	2021-01-28 19:17:17.005111	1
5	1	\N	patients_radiographies	t	t	t	t	\N	1	t	2021-01-17 17:28:07.923019	2021-01-28 19:17:17.005111	1
6	1	\N	patients_traitements	t	t	t	t	\N	1	t	2021-01-17 17:28:07.923019	2021-01-28 19:17:17.005111	1
7	1	\N	patients_ordonnances	t	t	t	t	\N	1	t	2021-01-17 17:28:07.923019	2021-01-28 19:17:17.005111	1
8	1	\N	patients_certificats	t	t	t	t	\N	1	t	2021-01-17 17:28:07.923019	2021-01-28 19:17:17.005111	1
9	1	\N	patients_rdvs	t	t	t	t	\N	1	t	2021-01-17 17:28:07.923019	2021-01-28 19:17:17.005111	1
10	1	\N	patients_versements	t	t	t	t	\N	1	t	2021-01-17 17:28:07.923019	2021-01-28 19:17:17.005111	1
11	1	\N	static_tables	t	t	t	t	\N	1	t	2021-01-17 17:28:07.923019	2021-01-28 19:17:17.005111	1
12	1	\N	patients_transactions	t	t	t	t	\N	1	t	2021-01-17 17:28:07.923019	2021-01-28 19:17:17.005111	1
13	1	\N	reports	t	t	t	t	\N	1	t	2021-01-17 17:28:07.923019	2021-01-28 19:17:17.005111	1
14	1	\N	annuaire	t	t	t	t	\N	1	t	2021-01-17 17:28:07.923019	2021-01-28 19:17:17.005111	1
15	1	\N	compte	t	t	t	t	\N	1	t	2021-01-17 17:28:07.923019	2021-01-28 19:17:17.005111	1
16	1	\N	clinique	t	t	t	t	\N	1	t	2021-01-17 17:28:07.923019	2021-01-28 19:17:17.005111	1
17	1	\N	utilisateurs	t	t	t	t	\N	1	t	2021-01-17 17:28:07.923019	2021-01-28 19:17:17.005111	1
\.


--
-- Data for Name: users_session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_session (id, user_id, email, hostname, remote_adresse, remote_port, localisation, browser_name, browser_version, os_name, os_version, devise_name, devise_version, token, date_online, date_exit, online, createdby, updatedby, active, created, updated) FROM stdin;
1	1	demo@dzental.com	127.0.0.1:3000	\N	\N	null	chrome	88.0.4324.104	windows	10.0	Unknown	Unknown	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRlX3Rva2VuIjoiMjAyMS0wMS0zMVQxNzozOToxNC42OTdaIiwia2V5IjpbIkR6ZW50YWwiXSwiaWQiOjEsImVtYWlsIjoiZGVtb0BkemVudGFsLmNvbSIsImlhdCI6MTYxMjExNDc1NH0.s4ArgdUrVJzTHHxQrPWAcgukAVMRq4NG24QTmxYvEsQ	2021-01-31 18:39:14.702271	\N	t	1	1	t	2021-01-31 18:39:14.702271	2021-01-31 18:39:14.702271
\.


--
-- Data for Name: vitals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vitals (id, designation, definition, created, createdby, updated, updatedby, active, code) FROM stdin;
2	Respiration	\N	2020-12-08 11:32:08.535237	1	2020-12-08 11:32:08.535237	1	t	\N
3	Tension artérielle	\N	2020-12-08 11:32:20.997334	1	2020-12-08 11:32:20.997334	1	t	\N
4	Fréquences cardiaques	\N	2020-12-08 11:32:30.24801	1	2020-12-08 12:14:38.507333	1	t	\N
5	Température	\N	2020-12-08 12:14:39.381828	1	2020-12-08 12:14:39.381828	1	t	\N
1	Poid	\N	2020-12-08 11:31:58.090187	1	2020-12-16 10:26:52.538302	1	t	\N
7	Autre	\N	2020-12-16 10:34:35.860284	1	2020-12-17 16:06:44.654369	105	t	\N
\.


--
-- Data for Name: wilaya; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wilaya (id, code, designation, createdby, updatedby, active, created, updated) FROM stdin;
3	03	LAGHOUAT	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
4	04	OUM EL BOUAGHI	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
5	05	BATNA	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
6	06	BEJAIA	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
7	07	BISKRA	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
8	08	BECHAR	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
9	09	BLIDA	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
10	10	BOUIRA	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
11	11	TAMANRASSET	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
12	12	TEBESSA	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
13	13	TELEMCEN	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
14	14	TIARET	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
15	15	TIZI OUZOU	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
16	16	ALGER	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
17	17	DJELFA	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
18	18	JIJEL	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
19	19	SETIF	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
20	20	SAIDA	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
21	21	SKIKDA	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
22	22	SIDI BEL ABBES	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
23	23	ANNABA	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
24	24	GUELMA	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
25	25	CONSTANTINE	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
26	26	MEDEA	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
27	27	MOSTAGANEM	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
28	28	M'SILA	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
29	29	MASCARA	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
30	30	OUARGLA	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
31	31	ORAN	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
32	32	EL BAYADH	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
33	33	ILLIZI	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
34	34	B-B-ARRIREDJ	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
35	35	BOUMERDES	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
36	36	EL TARF	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
37	37	TINDOUF	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
38	38	TISSEMSILT	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
39	39	EL OUED	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
40	40	KHENCHELA	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
41	41	SOUK AHRAS	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
42	42	TIPAZA	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
43	43	MILA	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
44	44	AIN DEFLA	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
45	45	NAAMA	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
46	46	AIN TEMOUCHENT	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
47	47	GHARDAIA	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
48	48	RELIZANE	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
1	01	ADRAR	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
2	02	CHLEF	0	0	t	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
0	00	LA CENTRALE	0	0	f	2020-08-11 23:38:18.138	2020-08-11 23:38:18.138
\.


--
-- Name: actes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.actes_id_seq', 13, false);


--
-- Name: certificat_motifs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.certificat_motifs_id_seq', 3, false);


--
-- Name: commune_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.commune_id_seq', 1544, false);


--
-- Name: commune_wilaya_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.commune_wilaya_id_seq', 1, false);


--
-- Name: etats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.etats_id_seq', 6, false);


--
-- Name: medicaments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.medicaments_id_seq', 12, false);


--
-- Name: motifs_rdv_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.motifs_rdv_id_seq', 5, false);


--
-- Name: ordonnance_posologies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ordonnance_posologies_id_seq', 5, false);


--
-- Name: org_annuaire_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.org_annuaire_id_seq', 20, true);


--
-- Name: org_directions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.org_directions_id_seq', 1, true);


--
-- Name: org_horraires_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.org_horraires_id_seq', 3, true);


--
-- Name: org_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.org_id_seq', 2, false);


--
-- Name: org_produits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.org_produits_id_seq', 90, true);


--
-- Name: org_professions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.org_professions_id_seq', 5, false);


--
-- Name: org_sales_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.org_sales_id_seq', 1, false);


--
-- Name: org_transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.org_transactions_id_seq', 81, true);


--
-- Name: pathologies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pathologies_id_seq', 392, false);


--
-- Name: patient_certificats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patient_certificats_id_seq', 3, true);


--
-- Name: patient_consultations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patient_consultations_id_seq', 3053, false);


--
-- Name: patient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patient_id_seq', 1086, true);


--
-- Name: patient_ordonnances_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patient_ordonnances_details_id_seq', 58, true);


--
-- Name: patient_ordonnances_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patient_ordonnances_id_seq', 64, true);


--
-- Name: patient_pathologies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patient_pathologies_id_seq', 99, true);


--
-- Name: patient_radiographies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patient_radiographies_id_seq', 76, true);


--
-- Name: patient_rdv_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patient_rdv_id_seq', 273, true);


--
-- Name: patient_traitements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patient_traitements_id_seq', 46, true);


--
-- Name: patient_vitals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patient_vitals_id_seq', 25, true);


--
-- Name: procedures_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.procedures_id_seq', 13, false);


--
-- Name: radiographies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.radiographies_id_seq', 5, false);


--
-- Name: resultat_controle_cnas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.resultat_controle_cnas_id_seq', 45, true);


--
-- Name: resultat_controle_cnr_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.resultat_controle_cnr_id_seq', 45, true);


--
-- Name: role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.role_id_seq', 2, true);


--
-- Name: severites_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.severites_id_seq', 4, false);


--
-- Name: types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.types_id_seq', 8, false);


--
-- Name: types_transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.types_transactions_id_seq', 11, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 5, false);


--
-- Name: users_messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_messages_id_seq', 118, false);


--
-- Name: users_notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_notifications_id_seq', 24, false);


--
-- Name: users_produits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_produits_id_seq', 54, true);


--
-- Name: users_roles_access_control_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_roles_access_control_id_seq', 37, false);


--
-- Name: users_roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_roles_id_seq', 47, true);


--
-- Name: users_session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_session_id_seq', 1, true);


--
-- Name: vitals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vitals_id_seq', 8, false);


--
-- Name: wilaya_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wilaya_id_seq', 49, false);


--
-- Name: actes pk_actes; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actes
    ADD CONSTRAINT pk_actes PRIMARY KEY (id);


--
-- Name: certificat_motifs pk_certificat_motifs; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.certificat_motifs
    ADD CONSTRAINT pk_certificat_motifs PRIMARY KEY (id);


--
-- Name: commune pk_commune; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commune
    ADD CONSTRAINT pk_commune PRIMARY KEY (id);


--
-- Name: dents pk_dent; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dents
    ADD CONSTRAINT pk_dent PRIMARY KEY (num);


--
-- Name: etats pk_etats_rdv; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.etats
    ADD CONSTRAINT pk_etats_rdv PRIMARY KEY (id);


--
-- Name: medicaments pk_medicaments; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicaments
    ADD CONSTRAINT pk_medicaments PRIMARY KEY (id);


--
-- Name: motifs pk_motifs_rdv; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.motifs
    ADD CONSTRAINT pk_motifs_rdv PRIMARY KEY (id);


--
-- Name: ordonnance_posologies pk_ordonnance_posologies_rdv; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ordonnance_posologies
    ADD CONSTRAINT pk_ordonnance_posologies_rdv PRIMARY KEY (id);


--
-- Name: org pk_org; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.org
    ADD CONSTRAINT pk_org PRIMARY KEY (id);


--
-- Name: partenaires pk_org_annuaire; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.partenaires
    ADD CONSTRAINT pk_org_annuaire PRIMARY KEY (id);


--
-- Name: org_directions pk_org_directions; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.org_directions
    ADD CONSTRAINT pk_org_directions PRIMARY KEY (id);


--
-- Name: org_horraires pk_org_horraires; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.org_horraires
    ADD CONSTRAINT pk_org_horraires PRIMARY KEY (id);


--
-- Name: org_produits pk_org_produits; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.org_produits
    ADD CONSTRAINT pk_org_produits PRIMARY KEY (id);


--
-- Name: org_professions pk_org_professions; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.org_professions
    ADD CONSTRAINT pk_org_professions PRIMARY KEY (id);


--
-- Name: org_sales pk_org_sales; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.org_sales
    ADD CONSTRAINT pk_org_sales PRIMARY KEY (id);


--
-- Name: org_transactions pk_org_transactions; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.org_transactions
    ADD CONSTRAINT pk_org_transactions PRIMARY KEY (id);


--
-- Name: pathologies pk_pathologies; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pathologies
    ADD CONSTRAINT pk_pathologies PRIMARY KEY (id);


--
-- Name: patients pk_patient; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT pk_patient PRIMARY KEY (id);


--
-- Name: patient_certificats pk_patient_certificats; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_certificats
    ADD CONSTRAINT pk_patient_certificats PRIMARY KEY (id);


--
-- Name: patient_consultations pk_patient_consultations; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_consultations
    ADD CONSTRAINT pk_patient_consultations PRIMARY KEY (id);


--
-- Name: patient_ordonnances pk_patient_ordonnances; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_ordonnances
    ADD CONSTRAINT pk_patient_ordonnances PRIMARY KEY (id);


--
-- Name: patient_ordonnances_details pk_patient_ordonnances_details; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_ordonnances_details
    ADD CONSTRAINT pk_patient_ordonnances_details PRIMARY KEY (id);


--
-- Name: patient_pathologies pk_patient_pathologies; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_pathologies
    ADD CONSTRAINT pk_patient_pathologies PRIMARY KEY (id);


--
-- Name: patient_radiographies pk_patient_radiographies; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_radiographies
    ADD CONSTRAINT pk_patient_radiographies PRIMARY KEY (id);


--
-- Name: patient_rdvs pk_patient_rdv; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_rdvs
    ADD CONSTRAINT pk_patient_rdv PRIMARY KEY (id);


--
-- Name: patient_traitements pk_patient_traitements; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_traitements
    ADD CONSTRAINT pk_patient_traitements PRIMARY KEY (id);


--
-- Name: patient_vitals pk_patient_vitals; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_vitals
    ADD CONSTRAINT pk_patient_vitals PRIMARY KEY (id);


--
-- Name: procedures pk_procedures; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.procedures
    ADD CONSTRAINT pk_procedures PRIMARY KEY (id);


--
-- Name: produit pk_produit; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produit
    ADD CONSTRAINT pk_produit PRIMARY KEY (id);


--
-- Name: radiographies pk_radiographies; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.radiographies
    ADD CONSTRAINT pk_radiographies PRIMARY KEY (id);


--
-- Name: resultat_controle_cnas pk_resultat_controle_cnas; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resultat_controle_cnas
    ADD CONSTRAINT pk_resultat_controle_cnas PRIMARY KEY (id);


--
-- Name: resultat_controle_cnr pk_resultat_controle_cnr; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resultat_controle_cnr
    ADD CONSTRAINT pk_resultat_controle_cnr PRIMARY KEY (id);


--
-- Name: role pk_role; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT pk_role PRIMARY KEY (id);


--
-- Name: severites pk_severites; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.severites
    ADD CONSTRAINT pk_severites PRIMARY KEY (id);


--
-- Name: types_paiements pk_types_rdv; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.types_paiements
    ADD CONSTRAINT pk_types_rdv PRIMARY KEY (id);


--
-- Name: types_transactions pk_types_transactions_rdv; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.types_transactions
    ADD CONSTRAINT pk_types_transactions_rdv PRIMARY KEY (id);


--
-- Name: users pk_user; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT pk_user PRIMARY KEY (id);


--
-- Name: users_messages pk_users_messages; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_messages
    ADD CONSTRAINT pk_users_messages PRIMARY KEY (id);


--
-- Name: users_notifications pk_users_notifications; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_notifications
    ADD CONSTRAINT pk_users_notifications PRIMARY KEY (id);


--
-- Name: users_produits pk_users_produits; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_produits
    ADD CONSTRAINT pk_users_produits PRIMARY KEY (id);


--
-- Name: users_roles pk_users_roles; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_roles
    ADD CONSTRAINT pk_users_roles PRIMARY KEY (id);


--
-- Name: users_roles_access_control pk_users_roles_access_control; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_roles_access_control
    ADD CONSTRAINT pk_users_roles_access_control PRIMARY KEY (id);


--
-- Name: users_session pk_users_session; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_session
    ADD CONSTRAINT pk_users_session PRIMARY KEY (id);


--
-- Name: vitals pk_vitals; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vitals
    ADD CONSTRAINT pk_vitals PRIMARY KEY (id);


--
-- Name: wilaya pk_wilaya; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wilaya
    ADD CONSTRAINT pk_wilaya PRIMARY KEY (id);


--
-- Name: unique_org_produit; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_org_produit ON public.org_produits USING btree (org_id, produit_id);


--
-- Name: unique_user_produit; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_user_produit ON public.users_produits USING btree (user_id, produit_id);


--
-- Name: uniquer_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uniquer_email ON public.users USING btree (email);


--
-- Name: org_produits org_produits_after_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER org_produits_after_delete AFTER DELETE ON public.org_produits FOR EACH ROW EXECUTE FUNCTION public.org_produits_after_delete();


--
-- Name: patients patient_before_insert_tr; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER patient_before_insert_tr BEFORE INSERT ON public.patients FOR EACH ROW EXECUTE FUNCTION public.patient_before_insert();


--
-- Name: patients patient_before_update_tr; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER patient_before_update_tr BEFORE UPDATE ON public.patients FOR EACH ROW EXECUTE FUNCTION public.patient_before_update();


--
-- Name: patient_rdvs rdv_before_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER rdv_before_update BEFORE UPDATE ON public.patient_rdvs FOR EACH ROW EXECUTE FUNCTION public.rdv_before_update();


--
-- Name: users users_after_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER users_after_insert AFTER INSERT ON public.users FOR EACH ROW EXECUTE FUNCTION public.users_after_insert();


--
-- Name: users users_befor_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER users_befor_update BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.users_before_update();


--
-- Name: users users_before_insert_tr; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER users_before_insert_tr BEFORE INSERT ON public.users FOR EACH ROW EXECUTE FUNCTION public.users_before_insert();


--
-- PostgreSQL database dump complete
--

