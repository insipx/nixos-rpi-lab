{
  description = "secrets for nixos rpi homelab";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        self,
        withSystem,
        flake-parts-lib,
        ...
      }:
      let
        inherit (flake-parts-lib) importApply;
        flakeModules.default = importApply ./module.nix {
          inherit withSystem;
          inherit (inputs) sops-nix;
        };
      in
      {
        imports = [
          inputs.flake-parts.flakeModules.easyOverlay
        ];
        systems = import inputs.systems;
        perSystem =
          { pkgs, config, ... }:
          {
            overlayAttrs = {
              inherit (config.packages) keyscan;
            };
            packages.keyscan = pkgs.callPackage (
              { writeShellScriptBin }: writeShellScriptBin "keyscan" (builtins.readFile ./keyscan.sh)
            ) { };
            devShells.default = pkgs.mkShell {
              buildInputs = with pkgs; [
                sops
                rage
              ];
            };
          };
        flake = {
          inherit flakeModules;
          nixosModules.default = importApply ./module.nix {
            localFlake = self;
            inherit (inputs) sops-nix;
          };
        };
      }
    );
}
