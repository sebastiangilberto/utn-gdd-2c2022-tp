#!/bin/bash

# Esto no va para el TP es para lo de practica
docker compose down

docker compose up -d

echo "waiting for sql server..."

while ! docker-compose exec gdd-practica /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'Gdd2022!' -Q "SELECT @@VERSION"; do sleep 1; done

echo "starting database bootstrap"

docker exec -it gdd-gdd-practica-1 /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'Gdd2022!' -Q 'CREATE DATABASE GD2C2022'

DATA=$(sudo docker exec -it gdd-gdd-practica-1 /opt/mssql-tools/bin/sqlcmd -S localhost \
    -U SA -P 'Gdd2022!' \
    -Q 'RESTORE FILELISTONLY FROM DISK = "/var/opt/mssql/backup/GD2015C1.bak"' |
    tr -s ' ' | cut -d " " -f 1 | sed '3q;d')

LOG=$(sudo docker exec -it gdd-gdd-practica-1 /opt/mssql-tools/bin/sqlcmd -S localhost \
    -U SA -P 'Gdd2022!' \
    -Q 'RESTORE FILELISTONLY FROM DISK = "/var/opt/mssql/backup/GD2015C1.bak"' |
    tr -s ' ' | cut -d " " -f 1 | sed '4q;d')

echo "Data file name: $DATA"
echo "Log file name: $LOG"

docker exec -it gdd-gdd-practica-1 /opt/mssql-tools/bin/sqlcmd -S localhost \
    -U SA -P 'Gdd2022!' \
    -Q 'RESTORE DATABASE GD2C2022 FROM DISK=N'/var/opt/mssql/backup/GD2015C1.bak' WITH MOVE '$DATA' to '/var/opt/mssql/data/GESTION2022.mdf', MOVE '$LOG' to '/var/opt/mssql/data/GESTION2022_log.ldf', REPLACE, NOUNLOAD, STATS=10'
