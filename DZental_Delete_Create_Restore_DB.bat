CD C:\Program Files\PostgreSQL\13\bin
psql postgresql://postgres:08001688@127.0.0.1:5432/postgres < "C:\DZental\DZental_Delete_Create_Restore_DB.sql"
psql postgresql://postgres:08001688@127.0.0.1:5432/dzental  < "C:\DZental\dzental_backup.sql"