# Chinook Database Setup

This setup provides a PostgreSQL database with the Chinook sample database and pgAdmin for database management, all running in Docker containers.

## What's Included

- **PostgreSQL 15**: Database server with the Chinook sample database
- **pgAdmin 4**: Web-based database administration tool
- **Chinook Database**: Sample database representing a digital media store with tables for artists, albums, tracks, customers, invoices, etc.

## Prerequisites

- **Docker Desktop** must be installed and running
- On macOS: Download from https://www.docker.com/products/docker-desktop

## Quick Start

1. **Make sure Docker is running** (check Docker Desktop icon in menu bar)

2. **Start the services:**
   ```bash
   ./start.sh
   ```

   Or manually:
   ```bash
   docker-compose up -d
   ```

   **Note:** The Chinook database and pgAdmin server configuration will be automatically initialized on first startup.

3. **Access pgAdmin:**
   - Open your browser and go to: http://localhost:8080
   - Login with:
     - Email: admin@chinook.com
     - Password: admin

4. **Connect to PostgreSQL in pgAdmin:**
   - The Chinook database server is **pre-configured** and ready to use!
   - In the left sidebar, expand "Servers" → "Chinook Database"
   - Click to connect (no manual setup or password required)

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

**Important Note:** When connecting from pgAdmin running in Docker, use `postgres` as the host name to connect to the PostgreSQL container within the same Docker network. Using `localhost` will try to connect to pgAdmin itself.

## Database Schema

The Chinook database includes the following main tables:
- `Artist` - Artists information
- `Album` - Album information
- `Track` - Track information
- `Customer` - Customer information
- `Invoice` - Invoice information
- `InvoiceLine` - Invoice line items
- `Genre` - Music genres
- `MediaType` - Media types
- `Playlist` - Playlists
- `PlaylistTrack` - Playlist track associations
- `Employee` - Employee information

## Useful Commands

**Stop services:**
```bash
docker-compose down
```

**Stop services and remove volumes (will delete data):**
```bash
docker-compose down -v
```

**View logs:**
```bash
docker-compose logs -f
```

**Restart services:**
```bash
docker-compose restart
```

**Manually initialize/reinitialize database:**
```bash
./init-database.sh
```

## Connection Details

- **PostgreSQL**: localhost:5432
- **pgAdmin**: http://localhost:8080
- **Database**: chinook
- **Username**: postgres
- **Password**: password

## Data Persistence

- PostgreSQL data is persisted in the `postgres_data` Docker volume
- pgAdmin configuration is persisted in the `pgadmin_data` Docker volume
- Your data will persist between container restarts
