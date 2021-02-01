@echo off
for /f "tokens=1-4 delims=/ " %%i in ("%date%") do (
  set dow=%%i
  set month=%%j
  set day=%%k
  set year=%%l
)
set datestr=%date:/=%
echo datestr is %datestr%

set BACKUP_FILE=DZental_%datestr%_backup.sql
echo backup file name is %BACKUP_FILE%

CD C:\Program Files\PostgreSQL\13\bin
pg_dump  postgresql://postgres:08001688@127.0.0.1:5432/dzental  >"C:\DZental\backups\"%BACKUP_FILE%