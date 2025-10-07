#!/bin/bash

# Check if containers are running
if ! docker-compose ps | grep -q "Up"; then
    echo "Docker containers are not running. Please start them first with:"
    echo "   ./start.sh"
    exit 1
fi

echo "This script manually initializes the databases."
echo ""

# Initialize Chinook
echo "Initializing Chinook database..."
CHINOOK_URL="https://raw.githubusercontent.com/lerocha/chinook-database/master/ChinookDatabase/DataSources/Chinook_SqlServer.sql"
HOST_SQL_FILE="/tmp/Chinook_SqlServer.sql"

if [ ! -f "$HOST_SQL_FILE" ]; then
    echo "Downloading Chinook database script..."
    if command -v curl >/dev/null 2>&1; then
        curl -s -f -o "$HOST_SQL_FILE" "$CHINOOK_URL"
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$HOST_SQL_FILE" "$CHINOOK_URL"
    else
        echo "ERROR: Neither curl nor wget is available. Please install one of them."
        exit 1
    fi
fi

docker cp "$HOST_SQL_FILE" sqlserver_db:/tmp/Chinook_SqlServer.sql
docker-compose exec sqlserver /docker-entrypoint-initdb.d/init-chinook.sh

# Initialize AdventureWorks
echo ""
echo "Restoring AdventureWorks2017 database..."
docker-compose exec sqlserver /docker-entrypoint-initdb.d/init-adventureworks.sh

echo ""
echo "Database initialization complete!"
echo ""
echo "Available databases:"
docker-compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "AguanteP0stgres!" -C -Q "SELECT name FROM sys.databases WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb');"
