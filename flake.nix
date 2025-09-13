{
  description = "Run a database system as a portable application, using nothing but Nix.";

  inputs = {
    nixpkgs1.url = "github:nixos/nixpkgs/?ref=502151620cdde8fda50f1f05706caae833379754";
  };

  outputs = { self, nixpkgs1 }: let
    pkgs1 = nixpkgs1.legacyPackages.x86_64-linux;
  in {
    packages.x86_64-linux.quickdb-postgresql-17 = pkgs1.callPackage ./pkgs/postgresql/17.nix { postgresql = pkgs1.postgresql_17; };
    packages.x86_64-linux.quickdb-mariadb-114 = pkgs1.callPackage ./pkgs/mariadb/114.nix { mariadb = pkgs1.mariadb_114; };
    packages.x86_64-linux.quickdb-couchdb-3 = pkgs1.callPackage ./pkgs/couchdb/3.nix { couchdb = pkgs1.couchdb3; };
  };
}
