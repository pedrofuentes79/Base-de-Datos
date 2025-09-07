#!/bin/bash
set -e

echo "Setting up Chinook PostgreSQL database..."

SQL_FILE="/tmp/Chinook_PostgreSql.sql"

# The SQL file should be downloaded and copied by the host script
# Check if SQL file exists in container
if [ ! -f "$SQL_FILE" ]; then
    echo "ERROR: Chinook SQL file not found in container. This should have been copied by the host script."
    exit 1
else
    echo "Using Chinook database schema..."
fi

echo "Importing Chinook database data..."

# Import the data (skip the database creation/dropping commands at the beginning)
# Start importing from the table creation section
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "
-- Clean up existing tables if they exist
DROP TABLE IF EXISTS playlist_track CASCADE;
DROP TABLE IF EXISTS playlist CASCADE;
DROP TABLE IF EXISTS invoice_line CASCADE;
DROP TABLE IF EXISTS invoice CASCADE;
DROP TABLE IF EXISTS track CASCADE;
DROP TABLE IF EXISTS album CASCADE;
DROP TABLE IF EXISTS artist CASCADE;
DROP TABLE IF EXISTS genre CASCADE;
DROP TABLE IF EXISTS media_type CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS employee CASCADE;
" 2>/dev/null || true

# Import only the table creation and data parts (skip database commands)
echo "Creating tables and importing data..."
# Skip the first 28 lines (database creation commands) and import the rest
tail -n +29 "$SQL_FILE" | psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB"

echo "Chinook database setup complete!"
echo "Available tables:"
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;"
