#!/bin/bash

docker-compose down

docker-compose up -d

echo "waiting for sql server..."

while ! docker-compose exec gdd-tp /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'Gdd2022!' -Q "SELECT @@VERSION"; do sleep 1; done

echo "starting database bootstrap"

docker-compose exec gdd-tp /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'Gdd2022!' -Q 'CREATE DATABASE GD2C2022'

docker-compose exec gdd-tp /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'Gdd2022!' -i /var/opt/tp/database/gd_esquema.Schema.sql -a 32767 -o resultado_esquema_output.txt
docker-compose exec gdd-tp /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'Gdd2022!' -i /var/opt/tp/database/gd_esquema.Maestra.sql -a 32767 -o resultado_table_output.txt
docker-compose exec gdd-tp /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'Gdd2022!' -i /var/opt/tp/database/gd_esquema.Maestra.Table.sql -a 32767 -o resultado_datos_output.txt

docker-compose exec gdd-tp /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'Gdd2022!' -Q "SELECT count(*) from GD2C2022.gd_esquema.Maestra"
