{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    haskell-flake.url = "github:srid/haskell-flake";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      # systems = nixpkgs.lib.systems.flakeExposed;
      systems = ["x86_64-linux"];
      imports = [
        inputs.haskell-flake.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

      perSystem = {
        self',
        pkgs,
        config,
        ...
      }: {
        haskellProjects.default = {
          packages = {};
          settings = {};

          devShell.hlsCheck.enable = false;

          autoWire = ["packages" "checks"];
        };

        treefmt.config = {
          projectRootFile = "flake.nix";

          programs.ormolu.enable = true;
          programs.alejandra.enable = true;
          programs.cabal-fmt.enable = true;
          programs.hlint.enable = true;
        };

        devShells.default = pkgs.mkShell {
          name = "default";
          inputsFrom = [
            config.haskellProjects.default.outputs.devShell
            config.treefmt.build.devShell
          ];
          nativeBuildInputs = with pkgs; [
            just
          ];
        };
      };
    };
}
