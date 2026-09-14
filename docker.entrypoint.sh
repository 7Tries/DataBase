#!/usr/bin/env bash
set -e  

POSTGRES_USER="${POSTGRES_USER:-app}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-app_password}"
POSTGRES_DB="${POSTGRES_DB:-app_db}"
PGDATA="${PGDATA:-/var/lib/postgresql/data}"

if ! id -u postgres > /dev/null 2>&1; then
    useradd -r -m -s /bin/bash postgres
fi

mkdir -p "$PGDATA"
chown -R postgres:postgres "$PGDATA"

if [ ! -s "$PGDATA/PG_VERSION" ]; then
    su - postgres -c "/usr/lib/postgresql/*/bin/initdb -D '$PGDATA'"

    cat >> "$PGDATA/postgresql.conf" <<'EOF'
listen_addresses = '*'
EOF

    cat >> "$PGDATA/pg_hba.conf" <<'EOF'
host all all 0.0.0.0/0 scram-sha-256
host all all ::/0 scram-sha-256
EOF

    su - postgres -c "/usr/lib/postgresql/*/bin/pg_ctl -D '$PGDATA' -o '-c listen_addresses=localhost' -w start"
    su - postgres -c "psql --username=postgres --dbname=postgres -c \"CREATE USER \\\"$POSTGRES_USER\\\" WITH PASSWORD '$POSTGRES_PASSWORD';\""
    su - postgres -c "psql --username=postgres --dbname=postgres -c \"CREATE DATABASE \\\"$POSTGRES_DB\\\" OWNER \\\"$POSTGRES_USER\\\";\""
    su - postgres -c "/usr/lib/postgresql/*/bin/pg_ctl -D '$PGDATA' -m fast -w stop"
fi

exec su - postgres -c "/usr/lib/postgresql/*/bin/postgres -D '$PGDATA'"
