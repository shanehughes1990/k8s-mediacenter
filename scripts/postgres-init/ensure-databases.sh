#!/bin/bash
set -e

# Function to create user if it doesn't exist
create_user_if_missing() {
  local user=$1
  local password=$2
  if ! psql -U postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$user'" | grep -q 1; then
    psql -U postgres -c "CREATE USER \"$user\" WITH PASSWORD '$password';"
    echo "User $user created."
  else
    echo "User $user already exists. Updating password."
    psql -U postgres -c "ALTER USER \"$user\" WITH PASSWORD '$password';"
  fi
}

# Function to create database if it doesn't exist and grant permissions
setup_database() {
  local dbname=$1
  local owner=$2
  
  if ! psql -U postgres -lqt | cut -d \| -f 1 | grep -qw "$dbname"; then
    createdb -U postgres -O "$owner" "$dbname"
    echo "Database $dbname created with owner $owner."
  else
    echo "Database $dbname already exists."
    # Ensure permissions are correct even if DB exists
    psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE \"$dbname\" TO \"$owner\";"
    psql -U postgres -c "ALTER DATABASE \"$dbname\" OWNER TO \"$owner\";"
  fi
}

# Process the configuration from environment variables
# Looks for POSTGRESQL_APP_USERNAME_N, POSTGRESQL_APP_PASSWORD_N, POSTGRESQL_APP_DATABASES_N
i=1
while true; do
  user_var="POSTGRESQL_APP_USERNAME_$i"
  pass_var="POSTGRESQL_APP_PASSWORD_$i"
  dbs_var="POSTGRESQL_APP_DATABASES_$i"

  user="${!user_var}"
  pass="${!pass_var}"
  dbs="${!dbs_var}"

  if [ -z "$user" ]; then
    break
  fi

  echo "Processing configuration $i: User=$user"
  
  create_user_if_missing "$user" "$pass"
  
  IFS=',' read -ra DBS <<< "$dbs"
  for db in "${DBS[@]}"; do
    setup_database "$db" "$user"
  done

  ((i++))
done
