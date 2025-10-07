#!/bin/bash
set -e

echo "Restoring AdventureWorks2017 database..."

BAK_FILE="/var/opt/mssql/backup/AdventureWorks2017.bak"

# Check if backup file exists
if [ ! -f "$BAK_FILE" ]; then
    echo "ERROR: AdventureWorks2017.bak file not found at $BAK_FILE"
    exit 1
fi

echo "Found AdventureWorks2017.bak, proceeding with restore..."

# Get logical file names from the backup
echo "Getting logical file names from backup..."
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -C -Q "RESTORE FILELISTONLY FROM DISK = N'$BAK_FILE';" -h-1

# Restore the database
echo "Restoring database..."
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -C -Q "
RESTORE DATABASE AdventureWorks2017 
FROM DISK = N'$BAK_FILE' 
WITH 
    MOVE 'AdventureWorks2017' TO '/var/opt/mssql/data/AdventureWorks2017.mdf',
    MOVE 'AdventureWorks2017_log' TO '/var/opt/mssql/data/AdventureWorks2017_log.ldf',
    REPLACE,
    RECOVERY;
"

if [ $? -eq 0 ]; then
    echo "AdventureWorks2017 database restored successfully!"
else
    echo "Failed to restore AdventureWorks2017 database. Trying alternative approach..."
    
    # Try with different logical names (some versions use different names)
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -C -Q "
    RESTORE DATABASE AdventureWorks2017 
    FROM DISK = N'$BAK_FILE' 
    WITH 
        MOVE 'AdventureWorks2017_Data' TO '/var/opt/mssql/data/AdventureWorks2017.mdf',
        MOVE 'AdventureWorks2017_Log' TO '/var/opt/mssql/data/AdventureWorks2017_log.ldf',
        REPLACE,
        RECOVERY;
    "
fi

echo "Listing databases:"
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -C -Q "SELECT name FROM sys.databases WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb');"

