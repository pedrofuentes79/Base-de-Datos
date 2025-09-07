#!/bin/bash

echo "Starting Chinook Database Setup..."
echo "=================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop and try again."
    echo "   On macOS: Open Docker Desktop from Applications"
    exit 1
fi

echo "✅ Docker is running"

# Start the services
echo "🚀 Starting PostgreSQL and pgAdmin..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 5

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Services started successfully!"
    echo ""


    # Check if database needs initialization
    TABLE_COUNT=$(docker-compose exec -T postgres psql -U postgres -d chinook -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | tr -d ' ')

    if [ "$TABLE_COUNT" = "0" ] || [ -z "$TABLE_COUNT" ]; then
        echo "📦 Initializing Chinook database..."

        # Download Chinook SQL file on host and copy to container
        CHINOOK_URL="https://raw.githubusercontent.com/lerocha/chinook-database/master/ChinookDatabase/DataSources/Chinook_PostgreSql.sql"
        HOST_SQL_FILE="/tmp/Chinook_PostgreSql.sql"

        if [ ! -f "$HOST_SQL_FILE" ]; then
            echo "📥 Downloading Chinook database schema..."
            if command -v curl >/dev/null 2>&1; then
                curl -s -f -o "$HOST_SQL_FILE" "$CHINOOK_URL"
            elif command -v wget >/dev/null 2>&1; then
                wget -q -O "$HOST_SQL_FILE" "$CHINOOK_URL"
            else
                echo "❌ ERROR: Neither curl nor wget is available on host. Please install one of them."
                exit 1
            fi

            if [ ! -s "$HOST_SQL_FILE" ]; then
                echo "❌ ERROR: Failed to download Chinook database schema."
                exit 1
            fi
        fi

        # Copy SQL file to PostgreSQL container
        echo "📋 Copying SQL file to PostgreSQL container..."
        docker cp "$HOST_SQL_FILE" chinook_postgres:/tmp/Chinook_PostgreSql.sql

        # Run the initialization script
        docker-compose exec postgres /docker-entrypoint-initdb.d/init-chinook.sh
        echo "✅ Database initialized!"
        echo ""
    fi

    echo "📊 Access your services:"
    echo "   PostgreSQL: localhost:5432"
    echo "   pgAdmin:    http://localhost:8080"
    echo ""
    echo "🔑 pgAdmin credentials:"
    echo "   Email: admin@chinook.com"
    echo "   Password: admin"
    echo ""
    echo "🎯 Pre-configured server:"
    echo "   The 'Chinook Database' server is ready to use in pgAdmin!"
    echo "   Just expand 'Servers' → 'Chinook Database' and click to connect."
    echo "   No password required - everything is pre-configured!"
    echo ""
    echo "🔑 PostgreSQL credentials:"
    echo "   Host: localhost (from host machine)"
    echo "   Host: postgres (from pgAdmin container)"
    echo "   Port: 5432"
    echo "   Database: chinook"
    echo "   Username: postgres"
    echo "   Password: password"
    echo ""
    echo "📝 To stop services: docker-compose down"
    echo "📝 To view logs: docker-compose logs -f"
else
    echo "❌ Failed to start services. Check logs with: docker-compose logs"
    exit 1
fi
