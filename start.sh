#!/bin/bash

# SQL Server connection function
run_sqlcmd() {
    local query="$1"
    local additional_flags="$2"
    docker-compose exec -T sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "AguanteP0stgres!" -Q "$query" -C $additional_flags
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Docker is not running. Please start Docker and try again."
    exit 1
fi

echo "Starting SQL Server container..."
docker-compose up -d

# Wait for SQL Server to be ready
echo "Waiting for SQL Server to start (this may take some time)..."
sleep 15

MAX_RETRIES=30
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if run_sqlcmd "SELECT 1" > /dev/null 2>&1; then
        echo "SQL Server is ready!"
        break
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo "Waiting... (attempt $RETRY_COUNT/$MAX_RETRIES)"
    sleep 2
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "ERROR: SQL Server failed to start within expected time."
    echo "Check logs with: docker-compose logs sqlserver"
    exit 1
fi

# Check if Chinook database exists
echo ""
echo "Checking for Chinook database..."
CHINOOK_EXISTS=$(run_sqlcmd "SELECT name FROM sys.databases WHERE name = 'Chinook'" "-h-1" 2>/dev/null | tr -d ' \n\r')

if [ -z "$CHINOOK_EXISTS" ] || [ "$CHINOOK_EXISTS" != "Chinook" ]; then
    echo "Chinook database not found. Initializing..."
    
    # Download Chinook SQL Server file
    CHINOOK_URL="https://raw.githubusercontent.com/lerocha/chinook-database/master/ChinookDatabase/DataSources/Chinook_SqlServer.sql"
    HOST_SQL_FILE="/tmp/Chinook_SqlServer.sql"
    
    echo "Downloading Chinook database script..."
    if command -v curl >/dev/null 2>&1; then
        curl -s -f -o "$HOST_SQL_FILE" "$CHINOOK_URL"
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$HOST_SQL_FILE" "$CHINOOK_URL"
    else
        echo "ERROR: Neither curl nor wget is available. Please install one of them."
        exit 1
    fi
    
    if [ ! -s "$HOST_SQL_FILE" ]; then
        echo "ERROR: Failed to download Chinook database schema."
        exit 1
    fi
    
    # Copy SQL file to container
    docker cp "$HOST_SQL_FILE" sqlserver_db:/tmp/Chinook_SqlServer.sql
    
    # Initialize Chinook database
    docker-compose exec sqlserver /docker-entrypoint-initdb.d/init-chinook.sh
else
    echo "Chinook database already exists."
fi

# Check if AdventureWorks2017 database exists
echo ""
echo "Checking for AdventureWorks2017 database..."
ADVENTUREWORKS_EXISTS=$(run_sqlcmd "SELECT name FROM sys.databases WHERE name = 'AdventureWorks2017'" "-h-1" 2>/dev/null | tr -d ' \n\r')

if [ -z "$ADVENTUREWORKS_EXISTS" ] || [ "$ADVENTUREWORKS_EXISTS" != "AdventureWorks2017" ]; then
    echo "AdventureWorks2017 database not found. Restoring from backup..."
    docker-compose exec sqlserver /docker-entrypoint-initdb.d/init-adventureworks.sh
else
    echo "AdventureWorks2017 database already exists."
fi

echo ""
echo "============================================"
echo "SQL Server is ready!"
echo "============================================"
echo ""
echo "Connection Details:"
echo "  Server: localhost,1433"
echo "  Username: sa"
echo "  Password: AguanteP0stgres!"
echo ""
echo "Databases:"
echo "  - Chinook"
echo "  - AdventureWorks2017"
echo ""
echo "Connect using:"
echo "  - Azure Data Studio"
echo "  - SQL Server Management Studio (SSMS)"
echo "  - VS Code with SQL Server extension"
echo "  - Any SQL Server client"
echo ""
echo "To view logs: docker-compose logs sqlserver"
echo "To stop: docker-compose down"
echo "============================================"
