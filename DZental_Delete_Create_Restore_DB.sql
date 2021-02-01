select pg_terminate_backend(pid) from pg_stat_activity where datname='dzental';
;
 
DROP DATABASE "dzental";

CREATE DATABASE "dzental"
  WITH OWNER = postgres
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       LC_COLLATE = 'French_France.1252'
       LC_CTYPE = 'French_France.1252'
       CONNECTION LIMIT = -1;


ALTER SCHEMA postgres OWNER TO postgres;
 