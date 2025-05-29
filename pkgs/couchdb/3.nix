{ writeShellApplication
, writeScript
, coreutils
, bash
, gnused
, couchdb
, couchdb-dump
, jq
, runit
} : let
    couchdbIni = builtins.toFile "couchdb.ini" ''
        ; This configuration file is regenerated every time you start couchdb.
        ; DONOT modify!
        ; Make your modifications in "@db_dir@/etc/local.ini" instead.
        [couchdb]
        database_dir = @db_dir@/var
        view_index_dir = @db_dir@/var
        uri_file = @db_dir@/run/couchdb.uri
        single_node = true
        [chttpd]
        port = 5984
        bind_address = 127.0.0.1
        [log]
        writer = stderr
    '';

    localIni = builtins.toFile "local.ini" ''
        [admins]
        admin = password
    '';

    epmdEnv = builtins.toFile "epmd.env" ''
        export ERL_EPMD_PORT=4369
    '';

    couchdbRun = writeScript "couchdb-run" ''
        #! ${bash}/bin/bash
        ${runit}/bin/sv check epmd > /dev/null || exit 1
        exec ${couchdb}/bin/couchdb -couch_ini "${couchdb}/etc/default.ini" "$db_dir/etc/couchdb.ini" "$db_dir/etc/local.ini"
    '';

    # Runs EPMD in the foreground so that the process can be managed by quickdb.
    # Without this, EPMD runs as a daemon and would not be terminated when quickdb exits.
    epmdRun = writeScript "epmd-run" ''
        #! ${bash}/bin/bash
        exec ${couchdb}/erts-15.2.7/bin/epmd
    '';
in writeShellApplication {
    name = "quickdb-couchdb-${couchdb.version}";
    runtimeInputs = [ coreutils gnused couchdb runit couchdb-dump jq bash ];
    text = ''
        db_name_with_version="${couchdb.pname} ${couchdb.version}"
        export db_dir=""

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
                echo "Updating couchdb.ini..."
                cat ${couchdbIni} > "$db_dir/etc/couchdb.ini"
                sed -i -e "s|@db_dir@|$db_dir|g" "$db_dir/etc/couchdb.ini"

                echo "Creating runit services..."

                if [ -d "$db_dir/service" ]
                then
                    rm -fR "$db_dir/service"
                fi

                mkdir -p "$db_dir/service/couchdb"
                mkdir -p "$db_dir/service/epmd"
                ln -s ${couchdbRun} "$db_dir/service/couchdb/run" 
                ln -s ${epmdRun} "$db_dir/service/epmd/run" 

                echo "Starting $db_name_with_version using data directory $(realpath "$db_dir")" 
                echo "Press CTRL+C to terminate."

                # shellcheck source=/dev/null
                source "$db_dir/etc/epmd.env"

                export COUCHDB_ARGS_FILE="${couchdb}/etc/vm.args"
                export HOME="$db_dir/var"
                export ERL_EPMD_ADDRESS=127.0.0.1
                export SVDIR="$db_dir/service"

                ${runit}/bin/runsvdir "$SVDIR"
            else
                echo "Initializing $db_name_with_version data directory $(realpath "$db_dir")..."
                mkdir -p "$db_dir/var"
                mkdir -p "$db_dir/etc"
                mkdir -p "$db_dir/run"
                
                cat ${localIni} > "$db_dir/etc/local.ini"
                cat ${epmdEnv} > "$db_dir/etc/epmd.env"

                touch "$db_dir/var/.erlang.cookie"
                chmod 600 "$db_dir/var/.erlang.cookie"
                dd if=/dev/random bs=16 count=1 | base64 > "$db_dir/var/.erlang.cookie"

                echo "To start the database, simply run this script again with the same arguments."
                echo "The admin user is 'admin' and the password is 'password'."
                echo "Done."
            fi
        fi
    '';
}
