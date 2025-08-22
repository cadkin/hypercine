{
  description = "A performance tuned library for reading .cine files";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/25.05";
    };

    parts = {
      url = "github:hercules-ci/flake-parts";
    };
  };

  outputs = inputs @ { self, parts, ... }: (
    parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem = { pkgs, ... }: {
        packages = rec {
          default = hypercine;

          hypercine = pkgs.callPackage ./nix/hypercine.nix {
            src = self;
            version = "master";
          };
        };
      };
    }
  );
}
