#!/bin/bash

# Define your container name
CONTAINER_NAME="maven-database"

# Define your MySQL root password
MYSQL_ROOT_PASSWORD="mysql"

# SQL command to grant privileges to the 'mysql' user
SQL_QUERY="GRANT ALL PRIVILEGES ON *.* TO 'mysql'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"

# Execute the SQL query inside the MySQL container
docker exec -i $CONTAINER_NAME mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "$SQL_QUERY"

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "Successfully granted privileges to 'mysql' user."
else
    echo "Failed to grant privileges."
fi
