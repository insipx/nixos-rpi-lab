#### A Collection of Nix Flake Templates & Modules for a Raspberry Pi K3s Cluster

Much of this configuration/how to is also on nvmd/nixos-raspberrypi:
https://github.com/nvmd/nixos-raspberrypi

# Repository layout

```text
.
├── modules/                     # Reusable NixOS modules
│   └── homelab/                 # Raspberry Pi homelab configuration options
└── templates/                   # Flake templates for new deployments
    ├── nixos-rpi-lab/           # Cluster configuration and Kubernetes deployments
    └── nixos-rpi-lab-secrets/   # Separate secrets repository using age and sops
```

See the [lab template README](templates/nixos-rpi-lab/README.md) for its directory layout.

# The template for the lab

```nix
nix flake init -t github:insipx/nixos-rpi-lab#lab
```

# The template for the secrets repository

```nix
nix flake init -t github:insipx/nixos-rpi-lab#secrets
```

# Using the nixosModule

```nix
{
    inputs.homelab.url = "github:insipx/nixos-lab";
    outputs = {
        nixosConfigurations.rpi5Install = inputs.nixos-raspberrypi.lib.nixosSystemFull {
            modules = [
                inputs.homelab.nixosModules.default
                {
                    rpiHomeLab = {
                        networking = {
                            hostId = "55555555"; # this should be unique per-machine
                            hostName = "my-new-host"; # change before installing
                            address = "10.10.10.123/22"; # change before installing
                            interface = "end0"; # ensure this is the correct interface
                        };
                        k3s.enable = false; # install w/o k3s enabled at first
                    };
                    imports = [
                        ./base
                        ./machine-specific/rpi5
                    ];
                }
            ];
            specialArgs = inputs;
        };
    };
}
```
