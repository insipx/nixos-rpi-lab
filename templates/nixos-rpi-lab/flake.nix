{
  description = "flake for managing rpi homelab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
    };
    lab-secrets = {
      # url = "github:insipx/your-lab-secrets-repo";
      url = "path:../nixos-rpi-lab-secrets";
    };
    disko = {
      # the fork is needed for partition attributes support
      url = "github:nvmd/disko/gpt-attrs";
      inputs.nixpkgs.follows = "nixos-raspberrypi/nixpkgs";
    };
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixos-raspberrypi/nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixos-raspberrypi/nixpkgs";
    };
    kubenix.url = "github:hall/kubenix";
    homelab.url = "github:insipx/nixos-lab";
  };
  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      nixos-raspberrypi,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (_: {
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
        ./nixos-configurations.nix
      ];
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      perSystem =
        {
          pkgs,
          system,
          inputs',
          ...
        }:
        let
          kubenixPkg = inputs'.kubenix.packages.default.override {
            module = import ./deployments/kubenix/default.nix;
            specialArgs = {
              flake = self;
            };
          };
        in
        {
          _module.args = import nixos-raspberrypi.inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.lab-secrets.overlays.default
            ];
          };
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [
              inputs'.nixos-anywhere.packages.default
              inputs'.colmena.packages.colmena
              pkgs.kubernetes-helm
              pkgs.sops
              pkgs.vals
              pkgs.age-plugin-yubikey
            ];
          };
          packages = {
            kubenix = kubenixPkg;
          };
        };
      flake = {
        lib = {
          hostname = "lab.lan";
          secrets = inputs.lab-secrets.outPath;
        };
        colmenaHive = import ./hive { inherit inputs; };
      };
    });
}
