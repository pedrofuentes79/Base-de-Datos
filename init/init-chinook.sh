#!/bin/bash
set -e

echo "Setting up Chinook PostgreSQL database..."

SQL_FILE="/tmp/Chinook_PostgreSql.sql"

# Check if SQL file already exists (avoid re-downloading)
if [ ! -f "$SQL_FILE" ]; then
    echo "Downloading Chinook database schema..."

    # Try curl first, fallback to wget if curl fails
    if command -v curl >/dev/null 2>&1; then
        curl -s -f -o "$SQL_FILE" "https://raw.githubusercontent.com/lerocha/chinook-database/master/ChinookDatabase/DataSources/Chinook_PostgreSql.sql"
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$SQL_FILE" "https://raw.githubusercontent.com/lerocha/chinook-database/master/ChinookDatabase/DataSources/Chinook_PostgreSql.sql"
    else
        echo "ERROR: Neither curl nor wget is available. Please install one of them."
        exit 1
    fi

    # Verify download succeeded
    if [ ! -s "$SQL_FILE" ]; then
        echo "ERROR: Failed to download Chinook database schema."
        exit 1
    fi
else
    echo "Using existing Chinook database schema..."
fi

echo "Importing Chinook database data..."

# Import the data (skip DROP DATABASE commands that might cause issues)
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

# Now import the schema and data
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$SQL_FILE"

echo "Chinook database setup complete!"
echo "Available tables:"
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;"
