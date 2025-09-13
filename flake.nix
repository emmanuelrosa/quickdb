{
  description = "Run a database system as a portable application, using nothing but Nix.";

  inputs = {
    nixpkgs1.url = "github:nixos/nixpkgs/?ref=502151620cdde8fda50f1f05706caae833379754";
    nixpkgs2.url = "github:nixos/nixpkgs/?ref=23da0aa9ec413ed894af3fdc6313e6b8ff623833";
  };

  outputs = { self, nixpkgs1, nixpkgs2 }: let
    pkgs1 = nixpkgs1.legacyPackages.x86_64-linux;
    pkgs2 = nixpkgs2.legacyPackages.x86_64-linux;
  in {
    packages.x86_64-linux.quickdb-postgresql-17 = pkgs2.callPackage ./pkgs/postgresql/default.nix { postgresql = pkgs2.postgresql_17; };
    packages.x86_64-linux.quickdb-postgresql-18 = pkgs2.callPackage ./pkgs/postgresql/default.nix { postgresql = pkgs2.postgresql_18; };

    packages.x86_64-linux.quickdb-mariadb-114 = pkgs2.callPackage ./pkgs/mariadb/default.nix { mariadb = pkgs2.mariadb_114; };
    packages.x86_64-linux.quickdb-mariadb-118 = pkgs2.callPackage ./pkgs/mariadb/default.nix { mariadb = pkgs2.mariadb_118; };
    packages.x86_64-linux.quickdb-couchdb-3 = pkgs2.callPackage ./pkgs/couchdb/3.nix { couchdb = pkgs2.couchdb3; };
  };
}
