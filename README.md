# Chinook Database Setup

This setup provides a PostgreSQL database with the Chinook sample database and pgAdmin for database management, all running in Docker containers.

## Prerequisites

- docker 
- docker-compose
- curl or wget

## Quick Start

1. **Make sure Docker is running** 

2. **Build the services:**
   ```bash
   docker-compose build --no-cache
   ```

3. **Start the services:**
   ```bash
   ./start.sh
   ```

4. **Access pgAdmin:**
   - Open your browser and go to: http://localhost:8080
   - Login with:
     - Email: admin@chinook.com
     - Password: password

## If something doesn't work
Try a hard-reset
```bash
docker-compose down --remove-orphans
docker volume rm base-de-datos_pgadmin_data
docker volume rm base-de-datos_postgres_data
docker-compose build --no-cache
./start.sh
```
Otherwise try to debug or open an issue :D

## Manual Connection Setup (if needed)

If you need to manually add a server connection in pgAdmin:

**Connection Details:**
- **Host**: `postgres` (not localhost!)
- **Port**: `5432`
- **Maintenance Database**: `chinook`
- **Username**: `postgres`
- **Password**: `password`


## Data Persistence

- PostgreSQL data is persisted in the `postgres_data` Docker volume
- pgAdmin configuration is persisted in the `pgadmin_data` Docker volume
- Your data will persist between container restarts
