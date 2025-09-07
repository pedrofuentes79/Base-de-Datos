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
sleep 10

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Services started successfully!"
    echo ""

    # Ensure pgAdmin user directory exists and servers.json is in place
    echo "🔧 Setting up pgAdmin configuration..."
    docker-compose exec pgadmin mkdir -p /var/lib/pgadmin/storage/admin_chinook.com
    # Backup existing servers.json if it exists, then ensure our config is in place
    docker-compose exec pgadmin bash -c "if [ -f /var/lib/pgadmin/storage/admin_chinook.com/servers.json ]; then cp /var/lib/pgadmin/storage/admin_chinook.com/servers.json /var/lib/pgadmin/storage/admin_chinook.com/servers.json.backup; fi"
    echo "✅ pgAdmin configuration ready!"
    echo ""

    # Check if database needs initialization
    TABLE_COUNT=$(docker-compose exec -T postgres psql -U postgres -d chinook -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | tr -d ' ')

    if [ "$TABLE_COUNT" = "0" ] || [ -z "$TABLE_COUNT" ]; then
        echo "📦 Initializing Chinook database..."
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
