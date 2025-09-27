#!/bin/bash

# Check if containers are running
if ! docker-compose ps | grep -q "Up"; then
    echo "Docker containers are not running. Please start them first with:"
    echo "   ./start.sh"
    exit 1
fi

# Check if database needs initialization
TABLE_COUNT=$(docker-compose exec -T postgres psql -U postgres -d chinook -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | tr -d ' ')

if [ "$TABLE_COUNT" = "0" ] || [ -z "$TABLE_COUNT" ]; then
    echo "Database is empty. Initializing Chinook database..."
    docker-compose exec postgres /docker-entrypoint-initdb.d/init-chinook.sh
    echo "Database initialization complete!"
else
    echo "Database already contains $TABLE_COUNT tables."
    echo "No initialization needed."
fi

echo ""
echo "Database tables:"
docker-compose exec postgres psql -U postgres -d chinook -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;" | cat
