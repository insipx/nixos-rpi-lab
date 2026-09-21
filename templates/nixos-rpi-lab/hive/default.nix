{ inputs }:
let
  commonImports = [
    inputs.disko.nixosModules.disko
    inputs.lab-secrets.nixosModules.default
    inputs.homelab.nixosModules.default
    ./../base
  ];
in
inputs.colmena.lib.makeHive {
  meta =
    let
      pkgConfig = {
        system = "x86_64-linux";
        overlays = [
        ];
        config.allowUnfree = true;
      };
    in
    {
      nixpkgs = import inputs.nixos-raspberrypi.inputs.nixpkgs pkgConfig;
      # if you have remote builders
      machinesFile = /etc/nix/machines;
      specialArgs = {
        inherit inputs;
        inherit (inputs) nixos-raspberrypi;
      };
    };

  node1 = _: {
    imports = [
      ./../machine-specific/rpi5
    ]
    ++ commonImports;
    deployment = {
      targetHost = "node1.lab.lan";
      targetUser = "user";
      tags = [
        "homelab"
        "control"
      ];
    };
    rpiHomeLab = {
      networking = {
        hostId = "00000000";
        hostName = "node1";
        address = "10.10.10.10/22";
        interface = "end0";
      };
    };
    rpiHomeLab.k3s.leader = true;
    rpiHomeLab.k3s.enable = true;
    rpiHomeLab.k3s.longhorn = true;
    rpiHomeLab.k3s.longhornDiskSize = "25G";
    lab-secrets.settings.k3s = true;
    services.k3s.extraFlags = [
      "--tls-san node1.lab.lan"
      "--tls-san node1"
      "--tls-san 10.10.10.10"
    ];
  };

  node2 = _: {
    imports = [
      ./../machine-specific/rpi5
    ]
    ++ commonImports;
    deployment = {
      targetHost = "node2.lab.lan";
      targetUser = "user";
      tags = [
        "homelab"
        "control"
      ];
    };
    rpiHomeLab = {
      networking = {
        hostName = "node2";
        hostId = "11111111";
        address = "10.10.10.2/22";
        interface = "end0";
      };
      k3s.longhorn = true;
      k3s.longhornDiskSize = "25G";

      k3s.enable = true;
    };
    lab-secrets.settings.k3s = true;

  };

  node3 = _: {
    imports = [
      ./../machine-specific/rpi5
    ]
    ++ commonImports;

    deployment = {
      tags = [
        "homelab"
        "control"
      ];
      targetHost = "node3.lab.lan";
      targetUser = "user";
    };
    rpiHomeLab = {
      networking = {
        hostId = "22222222";
        hostName = "node3";
        address = "10.10.10.3/22";
        interface = "end0";
      };
      k3s.enable = true;
      k3s.longhorn = true;
      rpiHomeLab.k3s.longhornDiskSize = "25G";

    };
    lab-secrets.settings.k3s = true;
  };
}
