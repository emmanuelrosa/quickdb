{ writeShellApplication
, coreutils
, bash
, mariadb
} : let
    myCnf = builtins.toFile "my.cnf" ''
      [mysqld]
      port = 3306
      bind-address = 127.0.0.1
    '';

in writeShellApplication {
    name = "quickdb-mariadb-${mariadb.version}";
    runtimeInputs = [ coreutils mariadb bash ];
    text = ''
        db_name_with_version="${mariadb.pname} ${mariadb.version}"
        db_dir=""

        if [ "$#" -eq 1 ]
        then
            db_dir=$(realpath "$1")
        fi

        if [ "$db_dir" == "" ]
        then
            export MYSQL_UNIX_PORT="$db_dir/run/mariadb.sock"

            echo "Entering BASH shell with $db_name_with_version client utils in the PATH."
            echo "Enter 'exit' to leave the shell."
            env PS1="quickdb $ " bash --norc -i
        else
            if [ -d "$db_dir" ]
            then
                echo "Starting $db_name_with_version using data directory $(realpath "$db_dir")" 
                echo "Press CTRL+C to terminate."
                mariadbd --defaults-extra-file="$db_dir/etc/my.cnf" --socket="$db_dir/run/mariadb.sock" --datadir="$db_dir/var" --console --debug-gdb
            else
                echo "Initializing $db_name_with_version data directory $(realpath "$db_dir")..."
                mkdir -p "$db_dir/etc"
                mkdir -p "$db_dir/run"
                mkdir -p "$db_dir/var"
                cat ${myCnf} > "$db_dir/etc/my.cnf"
                sed -i -e "s|@db_dir@|$db_dir|g" "$db_dir/etc/my.cnf"
                mariadb-install-db --defaults-file="$db_dir/etc/my.cnf" --socket="$db_dir/run/mariadb.sock" --datadir="$db_dir/var"

                echo "To start the database, simply run this script again with the same arguments."
                echo "Done."
            fi
        fi
    '';
}
