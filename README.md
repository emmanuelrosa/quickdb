# quickdb

`quickdb` is a suite of [Nix](https://nixos.org) packages to easily start development instances of PostgreSQL, MariaDB, or CouchDB on GNU Linux. 

## Features

- __No root needed__ - You need the [Nix](https://nixos.org) package manager to use `quickdb`, but if you don't already have it you can use the portable version [Nix portable](https://github.com/DavHau/nix-portable).
- __No additional dependencies__ - You don't need anything other than the [Nix](https://nixos.org) package manager.
- __Configured for development__ - The database is automatically configured to only listen on localhost, and (except for couchdb) you can just log right in without credentials.
- __Multi-instance__ - You can easily set up multiple instances of a given database; Just edit the config files to use different ports.
- __Portable__ - When combined with Nix portable, you can take your database with you on a flash drive.
- __Runs like a normal process__ - Stdout goes to the console, and a simple CTRL-C stops the database. No weird daemons to deal with.

## Demo

[![asciicast](https://asciinema.org/a/tfH8n3ALPkGMPE5avwIqVqGfG.svg)](https://asciinema.org/a/tfH8n3ALPkGMPE5avwIqVqGfG)

Note: In the demo I used localhost when connecting with `psql`. It's also possible to use a socket directory, which is the `run` directory within the database directory. ex` psql -h $PWD/testdb/run DBNAME`. However, `psql` doesn't seem to like relative paths, hence the `$PWD`.

## Use cases

- __Development__ - I developed `quickdb` in order to quickly and easily set up a database when I need it without having to have the database running 24/7. You can start a database the moment you need it, and shut it down the moment you're done. No root. No `sudo`.
- __Presentations/Demos__ - Take your database with you to demos.
- __Staging/testing__ - When your done with the database, just delete the directory.

## Usage

Each package has three modes of operation:

1. __Initialization__ - When executed with a path to a non-existent directory, the directory is created and the database system is initialized within the directory. After initialization, the database system can be configured by editing one or more configuration files.
2. __Execution__ - When executed with a path to an existent directory, it is assumed a database has been initialized within the directory, so the database is started in the foreground. This means standard output is printed to the screen, and a simple CTRL-C is all that's needed to stop the database.
3. __Shell__ - When executed without any arguments, a BASH shell is started with the database client tools in the PATH.

## Examples

### PostgreSQL

1. To create a PostgreSQL database, execute: `nix run github:emmanuelrosa/quickdb#quickdb-postgresql-17 -- ~/my-postgresql`
2. To configure the database, edit the `*.conf` files in `~/my-postgresql`. 
3. To run the database, execute the same command: `nix run github:emmanuelrosa/quickdb#quickdb-postgresql-17 -- ~/my-postgresql`
4. To access the postgresql client tools, using another terminal execute `nix run github:emmanuelrosa/quickdb#quickdb-postgresql-17`
5. To stop postgresql, press CTRL-C.

### MariaDB

1. To create a MariaDB database, execute: `nix run github:emmanuelrosa/quickdb#quickdb-mariadb-114 -- ~/my-mariadb`
2. To configure the database, edit `~/my-mariadb/etc/my.cnf`. 
3. To run the database, execute the same command: `nix run github:emmanuelrosa/quickdb#quickdb-mariadb-114 -- ~/my-mariadb`
4. To access the mariadb client tools, using another terminal execute `nix run github:emmanuelrosa/quickdb#quickdb-mariadb-114`. Before using the mariadb client, set the envirionment variable `MYSQL_UNIX_PORT` to the path to the socket file; ex. `export MYSQL_UNIX_PORT=~/my-mariadb/run/mariadb.sock`
5. To stop mariadb, press CTRL-C.

### CouchDB

1. To create a CouchDB database, execute: `nix run github:emmanuelrosa/quickdb#quickdb-couchdb-3 -- ~/my-couchdb`
2. To configure the database, edit `~/my-couchdb/etc/local.ini` and `~/my-couchdb/etc/epmd.env`. The default user name is _admin_ and the password is _password_. 
3. To run the database, execute the same command: `nix run github:emmanuelrosa/quickdb#quickdb-couchdb-3 -- ~/my-couchdb`
4. To use `curl` and `jq` with couchdb, from another terminal execute `nix run github:emmanuelrosa/quickdb#quickdb-couchdb-3`
5. To stop couchdb, press CTRL-C.
