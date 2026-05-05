{
  description = "Kiru — transcription-driven video editor (Nix flake)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        kiru = pkgs.callPackage ./package.nix { };
      in
      {
        packages = {
          inherit kiru;
          default = kiru;
        };

        apps.default = {
          type = "app";
          program = "${kiru}/bin/kiru";
        };
      }
    );
}
