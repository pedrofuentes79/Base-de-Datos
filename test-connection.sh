#!/bin/bash

# SQL Server connection function
run_sqlcmd() {
    local query="$1"
    local additional_flags="$2"
    local database="$3"
    if [ -n "$database" ]; then
        docker-compose exec -T sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "AguanteP0stgres!" -C -d "$database" -Q "$query" $additional_flags
    else
        docker-compose exec -T sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "AguanteP0stgres!" -C -Q "$query" $additional_flags
    fi
}

echo "========================================"
echo "SQL Server Connection Test"
echo "========================================"
echo ""

# Check if container is running
if ! docker-compose ps | grep -q "sqlserver_db.*Up"; then
    echo "❌ SQL Server container is not running!"
    echo "Please start it with: ./start.sh"
    exit 1
fi

echo "✅ SQL Server container is running"
echo ""

# Test connection
echo "Testing SQL Server connection..."
if run_sqlcmd "SELECT @@VERSION;" > /dev/null 2>&1; then
    echo "✅ Connection successful"
else
    echo "❌ Connection failed"
    exit 1
fi

echo ""
echo "========================================"
echo "Available Databases"
echo "========================================"
run_sqlcmd "SELECT name FROM sys.databases WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb');" "-h-1"

echo ""
echo "========================================"
echo "Chinook Database - Sample Data"
echo "========================================"

# Check if Chinook exists
CHINOOK_EXISTS=$(run_sqlcmd "SELECT name FROM sys.databases WHERE name = 'Chinook'" "-h-1" 2>/dev/null | grep -o "Chinook" | head -1)

if [ "$CHINOOK_EXISTS" = "Chinook" ]; then
    echo "Chinook database found. Showing sample data:"
    echo ""
    echo "--- Top 5 Artists ---"
    run_sqlcmd "SELECT TOP 5 ArtistId, Name FROM Artist ORDER BY ArtistId;" "-h-1" "Chinook" 2>/dev/null
    
    echo ""
    echo "--- Top 5 Albums ---"
    run_sqlcmd "SELECT TOP 5 a.Title AS Album, ar.Name AS Artist FROM Album a JOIN Artist ar ON a.ArtistId = ar.ArtistId ORDER BY a.AlbumId;" "-h-1" "Chinook" 2>/dev/null
    
    echo ""
    echo "--- Table Count ---"
    TABLE_COUNT=$(run_sqlcmd "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';" "-h-1" "Chinook" 2>/dev/null | grep -o "[0-9]*" | head -1)
    echo "Total tables: $TABLE_COUNT"
else
    echo "❌ Chinook database not found"
fi

echo ""
echo "========================================"
echo "AdventureWorks2017 - Sample Data"
echo "========================================"

# Check if AdventureWorks2017 exists
AW_EXISTS=$(run_sqlcmd "SELECT name FROM sys.databases WHERE name = 'AdventureWorks2017'" "-h-1" 2>/dev/null | grep -o "AdventureWorks2017" | head -1)

if [ "$AW_EXISTS" = "AdventureWorks2017" ]; then
    echo "AdventureWorks2017 database found. Showing sample data:"
    echo ""
    echo "--- Top 5 Products ---"
    run_sqlcmd "SELECT TOP 5 ProductID, Name, ListPrice FROM Production.Product WHERE ListPrice > 0 ORDER BY ListPrice DESC;" "-h-1" "AdventureWorks2017" 2>/dev/null
    
    echo ""
    echo "--- Schema Count ---"
    SCHEMA_COUNT=$(run_sqlcmd "SELECT COUNT(*) FROM sys.schemas WHERE schema_id < 16384;" "-h-1" "AdventureWorks2017" 2>/dev/null | grep -o "[0-9]*" | head -1)
    echo "Total schemas: $SCHEMA_COUNT"
    
    echo ""
    echo "--- Table Count ---"
    TABLE_COUNT=$(run_sqlcmd "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';" "-h-1" "AdventureWorks2017" 2>/dev/null | grep -o "[0-9]*" | head -1)
    echo "Total tables: $TABLE_COUNT"
else
    echo "❌ AdventureWorks2017 database not found"
fi

echo ""
echo "========================================"
echo "Connection Details"
echo "========================================"
echo "Server: localhost,1433"
echo "Username: sa"
echo "Password: AguanteP0stgres!"
echo ""
echo "Connect using Azure Data Studio, SSMS, or any SQL Server client"
echo "========================================"

