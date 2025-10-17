# SQL Server Database Setup

This setup provides a Microsoft SQL Server 2022 (Developer Edition) database with the Chinook sample database and AdventureWorks2017 database, all running in a Docker container.

## Prerequisites

- Docker
- docker-compose
- curl or wget (for downloading Chinook database)

## What's Included

- **SQL Server 2022 Developer Edition** running in a Docker container
- **Chinook Database** 
- **AdventureWorks2017 Database** 

## Quick Start

1. **Make sure Docker is running**

2. **Start the services:**
   ```bash
   ./start.sh
   ```

   This script will:
   - Start the SQL Server container
   - Wait for SQL Server to be ready
   - Download and import the Chinook database (if not already present)
   - Restore the AdventureWorks2017 database (if not already present)

3. **Connect to the database:**
   
   Use any SQL Server client with these credentials:
   - **Server**: `localhost,1433` or `localhost`
   - **Username**: `sa`
   - **Password**: `AguanteP0stgres!`
   - **Databases**: `Chinook`, `AdventureWorks2017`

## If Something Doesn't Work

Try a hard-reset:
```bash
docker-compose down --remove-orphans
docker volume rm base-de-datos_sqlserver_data
docker-compose up -d
./start.sh
```

Check the logs:
```bash
docker-compose logs sqlserver
```


## Data Persistence

- SQL Server data is persisted in the `sqlserver_data` Docker volume
- Your data will persist between container restarts

- To completely remove data, delete the volume: `docker volume rm base-de-datos_sqlserver_data`
## Previous PostgreSQL Setup

The previous PostgreSQL/pgAdmin setup has been commented out in the `docker-compose.yml` file. You can restore it if needed by uncommenting those sections.
