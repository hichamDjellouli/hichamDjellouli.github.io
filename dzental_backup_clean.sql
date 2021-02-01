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
1	demo	0555 55 55 55	demo@dzental.com	\N	demo adresse	18:37:54.090643+01	0	18:23:10.30573+01	1	t	logo_1_9_0_2021_18_23_10.png	logo_1_9_0_2021_18_23_10.jpg	00 00 00 00 00	8	24	t
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
\.


--
-- Data for Name: partenaires; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.partenaires (id, org_id, designation, adresse, email, tel, fax, created, createdby, updated, updatedby, active, color) FROM stdin;
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
\.


--
-- Data for Name: patient_consultations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patient_consultations (id, patient_id, date_consultation, duree, observation, created, createdby, updated, updatedby, active, consulte_par, startsat, endsat) FROM stdin;
\.


--
-- Data for Name: patient_ordonnances; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patient_ordonnances (id, patient_id, numero_ordonnance, date_ordonnance, observation, created, createdby, updated, updatedby, active) FROM stdin;
\.


--
-- Data for Name: patient_ordonnances_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patient_ordonnances_details (id, ordonnance_id, medicament_id, observation, created, createdby, updated, updatedby, active, ordonnance_posologies_id) FROM stdin;
\.


--
-- Data for Name: patient_pathologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patient_pathologies (id, patient_id, pathologie_id, gravite, explicatif, created, createdby, updated, updatedby, active, severite_id) FROM stdin;
\.


--
-- Data for Name: patient_radiographies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patient_radiographies (id, patient_id, radiographie_id, gravite, explicatif, created, createdby, updated, updatedby, active, file_name) FROM stdin;
\.


--
-- Data for Name: patient_rdvs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patient_rdvs (id, patient_id, etat_id, title, color, startsat, endsat, draggable, resizable, created, createdby, updated, updatedby, active, motif_id, reminder_sent) FROM stdin;
\.


--
-- Data for Name: patient_traitements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patient_traitements (id, patient_id, date_traitement, dent_num, procedure_id, acte_id, montant, observation, created, createdby, updated, updatedby, active) FROM stdin;
\.


--
-- Data for Name: patient_vitals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patient_vitals (id, patient_id, vital_id, valeur, created, createdby, updated, updatedby, active) FROM stdin;
\.


--
-- Data for Name: patients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patients (id, nin, nom, nom_jeune_fille, prenom, sexe, date_naiss, type_date_naiss, lieu_naiss, adresse, commune_id, wilaya_id, situation_familiale, ppere, nmere, pmere, lib, created, createdby, updated, updatedby, active, uuid, tel, email, org_id) FROM stdin;
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
\.


--
-- Data for Name: users_notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_notifications (id, user_id, broadcast, expiration_date, message, createdby, updatedby, active, read, header, created, updated, org_id) FROM stdin;
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

SELECT pg_catalog.setval('public.org_annuaire_id_seq', 1, false);


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

SELECT pg_catalog.setval('public.org_transactions_id_seq', 1, false);


--
-- Name: pathologies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pathologies_id_seq', 392, false);


--
-- Name: patient_certificats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patient_certificats_id_seq', 1, false);


--
-- Name: patient_consultations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patient_consultations_id_seq', 1, false);


--
-- Name: patient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patient_id_seq', 1, false);


--
-- Name: patient_ordonnances_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patient_ordonnances_details_id_seq', 1, false);


--
-- Name: patient_ordonnances_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patient_ordonnances_id_seq', 1, false);


--
-- Name: patient_pathologies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patient_pathologies_id_seq', 1, false);


--
-- Name: patient_radiographies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patient_radiographies_id_seq', 1, false);


--
-- Name: patient_rdv_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patient_rdv_id_seq', 1, false);


--
-- Name: patient_traitements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patient_traitements_id_seq', 1, false);


--
-- Name: patient_vitals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patient_vitals_id_seq', 1, false);


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

SELECT pg_catalog.setval('public.types_transactions_id_seq', 12, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 5, false);


--
-- Name: users_messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_messages_id_seq', 1, false);


--
-- Name: users_notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_notifications_id_seq', 1, false);


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

SELECT pg_catalog.setval('public.users_session_id_seq', 1, false);


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

