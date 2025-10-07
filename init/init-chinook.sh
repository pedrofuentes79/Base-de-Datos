#!/bin/bash
set -e

echo "Setting up Chinook SQL Server database..."

SQL_FILE="/tmp/Chinook_SqlServer.sql"

# Check if SQL file exists in container
if [ ! -f "$SQL_FILE" ]; then
    echo "ERROR: Chinook SQL file not found in container. This should have been copied by the host script."
    exit 1
else
    echo "Using Chinook SQL Server database schema..."
fi

echo "Importing Chinook database data..."

# Import the Chinook database using sqlcmd
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -C -i "$SQL_FILE"

echo "Chinook database setup complete!"
echo "Listing databases:"
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -C -Q "SELECT name FROM sys.databases WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb');"
