{ lib
, writeShellApplication
, coreutils
, bash
, gnused
, neo4j
, disableAnonymousUsageReporting ? true
} : writeShellApplication {
    name = "quickdb-neo4j-${neo4j.version}";
    runtimeInputs = [ coreutils neo4j bash gnused ];
    text = ''
        db_name_with_version="${neo4j.pname} ${neo4j.version}"
        db_dir=""

        if [ "$#" -eq 1 ]
        then
            db_dir=$(realpath "$1")
        fi

        if [ "$db_dir" == "" ]
        then
            echo "Entering BASH shell with $db_name_with_version client utils in the PATH."
            echo "Enter 'exit' to leave the shell."
            env PS1="quickdb $ " bash --norc -i
        else
            export NEO4J_CONF="$db_dir"
            if [ -d "$db_dir" ]
            then
                echo "Starting $db_name_with_version using data directory $(realpath "$db_dir")" 
                echo "Press CTRL+C to terminate."
                neo4j console
            else
                echo "Initializing $db_name_with_version data directory $(realpath "$db_dir")..."
                mkdir -p "$db_dir/home"
                mkdir -p "$db_dir/data"
                mkdir -p "$db_dir/import"
                cp ${neo4j}/share/neo4j/conf/neo4j.conf "$db_dir/"
                chmod u+w "$db_dir/neo4j.conf"
                sed -i -e "s|#server\.directories\.data=data|server\.directories\.data=$db_dir|g" "$db_dir/neo4j.conf"
                sed -i -e "s|#server\.directories\.logs=logs|server\.directories\.logs=$db_dir/home/logs|g" "$db_dir/neo4j.conf"
                sed -i -e "s|#server\.directories\.run=run|server\.directories\.run=$db_dir/home/run|g" "$db_dir/neo4j.conf"
                sed -i -e "s|#server\.directories\.transaction\.logs\.root=data/transactions|server\.directories\.transaction\.logs\.root=$db_dir/data/transactions|g" "$db_dir/neo4j.conf"
                sed -i -e "s|server\.directories\.import=import|server\.directories\.import=$db_dir/import|g" "$db_dir/neo4j.conf"
                ${lib.optionalString disableAnonymousUsageReporting "sed -i -e \"s|#dbms\\.usage_report\\.enabled=false|dbms\\.usage_report\\.enabled=false|g\" \"$db_dir/neo4j.conf\""}

                echo "neo4j has been configured."
                echo "To change the configuration, edit $db_dir/neo4j.conf"
                echo "To log in use username and password 'neo4j'."
                echo "To start the database, simply run this script again with the same arguments."
                echo "Done."
            fi
        fi
    '';
}
