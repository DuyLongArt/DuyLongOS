{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  # 1. Add postgresql package
  buildInputs = with pkgs;
    [
      nodejs_22
      openjdk21
      postgresql
    ] ;

  shellHook = ''
    # --- PostgreSQL Setup ---
    export PGDATA=$(mktemp -d)
    export PGHOST="$PGDATA" # Use the temporary data directory path as the host
    export PGUSER="${builtins.getEnv "USER"}" # Use current OS user name
    export PGDATABASE="app_db" # The database name

    # 2. Initialize DB if it doesn't exist (only runs once)
    if [ ! -f "$PGDATA/postgresql.conf" ]; then
      echo "Initializing PostgreSQL database..."
      initdb -U "$PGUSER" --auth=trust
    fi

    # 3. Start the PostgreSQL server in the background
    echo "Starting PostgreSQL server..."
    pg_ctl start -l $PGDATA/logfile -o "-c listen_addresses=''"

    # 4. Create the application database (if not already created)
    if ! psql -lqt | cut -d \| -f 1 | grep -qw "$PGDATABASE"; then
      echo "Creating application database: $PGDATABASE"
      createdb "$PGDATABASE"
    fi

    # --- Node.js App Execution ---
    echo "Node.js 22 environment ready!"
    # Ensure background processes are cleaned up when exiting the shell
    trap 'pg_ctl stop -m fast; rm -rf "$PGDATA"' EXIT 
    
    # Run the Node.js application
    node NodeApp/app.js
  '';
}