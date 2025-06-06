{ writeShellApplication
, coreutils
, bash
, postgresql
} : writeShellApplication {
    name = "quickdb-postgresql-${postgresql.version}";
    runtimeInputs = [ coreutils postgresql bash ];
    text = ''
        db_name_with_version="${postgresql.pname} ${postgresql.version}"
        db_dir=""

        if [ "$#" -eq 1 ]
        then
            db_dir="$1"
        fi

        if [ "$db_dir" == "" ]
        then
            echo "Entering BASH shell with $db_name_with_version client utils in the PATH."
            echo "Enter 'exit' to leave the shell."
            env PS1="quickdb $ " bash --norc -i
        else
            if [ -d "$db_dir" ]
            then
                echo "Starting $db_name_with_version using data directory $(realpath "$db_dir")" 
                echo "Press CTRL+C to terminate."
                postgres -D "$db_dir" -k "$db_dir/run"
            else
                echo "Initializing $db_name_with_version data directory $(realpath "$db_dir")..."
                mkdir -p "$db_dir"
                initdb -D "$db_dir"
                mkdir -p "$db_dir/run"

                echo "To start the database, simply run this script again with the same arguments."
                echo "Done."
            fi
        fi
    '';
}
