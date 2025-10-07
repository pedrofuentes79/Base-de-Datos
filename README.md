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

## Recommended SQL Server Clients

- **Azure Data Studio** (Cross-platform, free)
  - Download: https://azure.microsoft.com/en-us/products/data-studio/
  
- **SQL Server Management Studio (SSMS)** (Windows only, free)
  - Download: https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms
  
- **VS Code** with SQL Server extension
  - Extension: mssql

- **DBeaver** (Cross-platform, free)
  - Download: https://dbeaver.io/

## Connection String Examples

**ADO.NET:**
```
Server=localhost,1433;Database=Chinook;User Id=sa;Password=AguanteP0stgres!;TrustServerCertificate=True;
```

**JDBC:**
```
jdbc:sqlserver://localhost:1433;databaseName=Chinook;user=sa;password=AguanteP0stgres!;trustServerCertificate=true;
```

**Python (pyodbc):**
```python
import pyodbc
conn = pyodbc.connect(
    'DRIVER={ODBC Driver 17 for SQL Server};'
    'SERVER=localhost,1433;'
    'DATABASE=Chinook;'
    'UID=sa;'
    'PWD=AguanteP0stgres!;'
    'TrustServerCertificate=yes;'
)
```

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

## Manual Database Initialization

If you need to manually initialize the databases:

**Chinook:**
```bash
docker-compose exec sqlserver /docker-entrypoint-initdb.d/init-chinook.sh
```

**AdventureWorks2017:**
```bash
docker-compose exec sqlserver /docker-entrypoint-initdb.d/init-adventureworks.sh
```

## Data Persistence

- SQL Server data is persisted in the `sqlserver_data` Docker volume
- Your data will persist between container restarts
- To completely remove data, delete the volume: `docker volume rm base-de-datos_sqlserver_data`

## SQL Server Edition

This setup uses **SQL Server 2022 Developer Edition**, which is free and includes all the features of Enterprise Edition but is licensed for development and testing purposes only, not for production use.

## Troubleshooting

**Container won't start:**
- Make sure port 1433 is not already in use
- Check Docker has enough resources allocated (at least 2GB RAM for SQL Server)

**Can't connect to SQL Server:**
- Make sure the container is running: `docker-compose ps`
- Wait a bit longer - SQL Server can take 30-60 seconds to fully start
- Check logs: `docker-compose logs sqlserver`

**AdventureWorks2017 restore fails:**
- Check that the AdventureWorks2017.bak file exists in the project root
- The backup file must be compatible with SQL Server 2022

## Database Information

### Chinook Database
The Chinook database represents a digital media store, including tables for artists, albums, media tracks, invoices, and customers. It's a great database for learning and testing SQL queries.

Source: https://github.com/lerocha/chinook-database

### AdventureWorks2017 Database
AdventureWorks is a sample database from Microsoft that represents a fictional bicycle manufacturing company. It includes complex schemas for sales, purchasing, production, and human resources.

---

## Previous PostgreSQL Setup

The previous PostgreSQL/pgAdmin setup has been commented out in the `docker-compose.yml` file. You can restore it if needed by uncommenting those sections.
