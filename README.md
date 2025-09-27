# Chinook Database Setup

This setup provides a PostgreSQL database with the Chinook sample database and pgAdmin for database management, all running in Docker containers.

## Prerequisites

- docker 
- docker-compose
- curl or wget

## Quick Start

1. **Make sure Docker is running** 

2. **Start the services:**
   ```bash
   ./start.sh
   ```

3. **Access pgAdmin:**
   - Open your browser and go to: http://localhost:8080
   - Login with:
     - Email: admin@chinook.com
     - Password: password

4. **Connect to PostgreSQL in pgAdmin:**
   - http://localhost:8080
   - When prompted for a password, just use "password" every time.

5. **Direct PostgreSQL connection:**
   - Host: localhost
   - Port: 5432
   - Database: chinook
   - Username: postgres
   - Password: password

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
