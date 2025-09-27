FROM dpage/pgadmin4:9.8

USER root

# Create necessary directories with proper permissions
RUN mkdir -p /var/lib/pgadmin/storage/admin_chinook.com && \
    chmod -R 777 /var/lib/pgadmin

# Copy configuration files
COPY servers.json /pgadmin4/servers.json
COPY pgpass /var/lib/pgadmin/storage/admin_chinook.com/pgpass

# Set proper file permissions and ensure no trailing newlines in pgpass
RUN chmod 777 /pgadmin4/servers.json 
RUN chown -R pgadmin /var/lib/pgadmin/storage/admin_chinook.com

# Set environment variable for pgpass file location
# ENV PGPASSFILE=/var/lib/pgadmin/storage/admin_chinook.com/pgpass

USER pgadmin
RUN chmod 600 /var/lib/pgadmin/storage/admin_chinook.com/pgpass
