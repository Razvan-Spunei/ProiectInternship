#!/bin/bash

DB_NAME="company_db"
DB_USER="ituser"
DB_ADMIN_USER="admin_cee"
DB_PASSWORD="pass"
DUMP_FILE="./company_db_dump.sql"
LOG_FILE="./query_results.log"

# Container name
CONTAINER_NAME="bashtest"

echo "Starting database setup"

echo "Creating Container"
docker run --name bashtest -e POSTGRES_USER=$DB_USER -e POSTGRES_PASSWORD=$DB_PASSWORD -e POSTGRES_DB=$DB_NAME -d postgres

echo "Waiting for PostgreSQL to start..."
until docker exec -i $CONTAINER_NAME psql -U $DB_USER -d postgres -c "SELECT 1;" &>/dev/null; do
  sleep 1
done
echo "PostgreSQL is up and running!"

echo "Creating second admin user"
docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c "CREATE ROLE $DB_ADMIN_USER WITH SUPERUSER CREATEDB CREATEROLE LOGIN PASSWORD '$DB_PASSWORD';"

echo "Importing dataset from $DUMP_FILE"
docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME < $DUMP_FILE

echo "Executing queries and saving results"
docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c "SELECT first_name, last_name FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'IT');" > $LOG_FILE
docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c "SELECT d.department_name, MAX(s.salary) AS highest_salary, MIN(s.salary) AS lowest_salary FROM employees e JOIN departments d ON e.department_id = d.department_id JOIN salaries s ON e.employee_id = s.employee_id GROUP BY d.department_name;" >> $LOG_FILE

echo "Database setup complete! Results saved to $LOG_FILE"
