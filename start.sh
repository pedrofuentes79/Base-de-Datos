#!/bin/bash

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Docker is not running. Please start Docker and try again."
    exit 1
fi

docker-compose up -d

# Wait for services to be ready
sleep 5

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    # Check if database needs initialization
    TABLE_COUNT=$(docker-compose exec -T postgres psql -U postgres -d chinook -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | tr -d ' ')

    if [ "$TABLE_COUNT" = "0" ] || [ -z "$TABLE_COUNT" ]; then
        # Download Chinook SQL file on host and copy to container
        CHINOOK_URL="https://raw.githubusercontent.com/lerocha/chinook-database/master/ChinookDatabase/DataSources/Chinook_PostgreSql.sql"
        HOST_SQL_FILE="/tmp/Chinook_PostgreSql.sql"

        if [ ! -f "$HOST_SQL_FILE" ]; then
            if command -v curl >/dev/null 2>&1; then
                curl -s -f -o "$HOST_SQL_FILE" "$CHINOOK_URL"
            elif command -v wget >/dev/null 2>&1; then
                wget -q -O "$HOST_SQL_FILE" "$CHINOOK_URL"
            else
                echo "ERROR: Neither curl nor wget is available. Please install one of them."
                exit 1
            fi

            if [ ! -s "$HOST_SQL_FILE" ]; then
                echo "ERROR: Failed to download database schema."
                exit 1
            fi
        fi

        # Copy SQL file to PostgreSQL container
        docker cp "$HOST_SQL_FILE" chinook_postgres:/tmp/Chinook_PostgreSql.sql

        # Run the initialization script
        docker-compose exec postgres /docker-entrypoint-initdb.d/init-chinook.sh
    fi

    echo "pgAdmin: http://localhost:8080"
    echo "Email: admin@chinook.com"
    echo "Password: password"
    echo ""
    echo "PostgreSQL (for manual connections):"
    echo "Host: localhost"
    echo "Port: 5432"
    echo "Database: chinook"
    echo "Username: postgres"
    echo "Password: password"
else
    echo "Failed to start services. Check logs with: docker-compose logs"
    exit 1
fi
