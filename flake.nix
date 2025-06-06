{
  description = "Run a database system as a portable application, using nothing but Nix.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
  };

  outputs = { self, nixpkgs }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    packages.x86_64-linux.quickdb-postgresql-17 = pkgs.callPackage ./pkgs/postgresql/17.nix { postgresql = pkgs.postgresql_17; };
    packages.x86_64-linux.quickdb-couchdb-3 = pkgs.callPackage ./pkgs/couchdb/3.nix { couchdb = pkgs.couchdb3; };
  };
}
