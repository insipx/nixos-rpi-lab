#### A Collection of Nix Flake Templates & Modules for a Raspberry Pi K3s Cluster

Much of this configuration/how to is also on nvmd/nixos-raspberrypi:
https://github.com/nvmd/nixos-raspberrypi

A guide for initial setup is available https://insipx.xyz/blog/raspberry-pi-homelab/


# Repository layout

```text
.
├── modules/                     # Reusable NixOS modules
│   └── homelab/                 # Raspberry Pi homelab configuration options
└── templates/                   # Flake templates for new deployments
    ├── nixos-rpi-lab/           # Cluster configuration and Kubernetes deployments
    └── nixos-rpi-lab-secrets/   # Separate secrets repository using age and sops
```

See the [lab template README](templates/nixos-rpi-lab/README.md) for its
directory layout.

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

# NixOS Homelab Module Configuration

## Configuration

All options are under `rpiHomeLab`.

### Networking

| Option                 | Type           | Default      | Description                                                                                   |
| ---------------------- | -------------- | ------------ | --------------------------------------------------------------------------------------------- |
| `networking.interface` | string or null | No default   | static interface `"end0"`.                                                                    |
| `networking.hostId`    | string or null | No default   | Unique ID for the ZFS Host.                                                                   |
| `networking.hostName`  | string or null | `null`       | Hostname                                                                                      |
| `networking.address`   | string or null | `null`       | static address + subnet prefix `"10.10.69.20/22"`. `null` skips static network configuration. |
| `networking.gateway`   | string or null | `10.10.69.1` | gateway address of the router/firewall                                                        |
| `networking.dns`       | string or null | `1.1.1.1`    | dns server to use                                                                             |

### Kubernetes and storage

| Option                 | Type           | Default | Description                                                                                             |
| ---------------------- | -------------- | ------- | ------------------------------------------------------------------------------------------------------- |
| `k3s.enable`           | boolean        | `false` | Enable k3s                                                                                              |
| `k3s.leader`           | boolean        | `false` | Indiciate this node as the leader. there may be only a single leader.                                   |
| `k3s.agent`            | boolean        | `false` | Make this node a worker only.                                                                           |
| `k3s.leaderAddress`    | string or null | `null`  | address of the leader.                                                                                  |
| `k3s.longhorn`         | boolean        | `false` | Enable longhorn as well as NixOS specific options to make it work with ZFS.                             |
| `k3s.longhornDiskSize` | string or null | `null`  | Size of the ZFS volume backing Longhorn’s ext4 overlay, `"900G"` would make a 900GB ext4 overlay on ZFS |

#### Node roles

Set `k3s.enable = true` for each participating node.

| Role           | `k3s.leader` | `k3s.agent` | `k3s.leaderAddress` |
| -------------- | ------------ | ----------- | ------------------- |
| Initial server | `true`       | `false`     | Not used            |
| Joining server | `false`      | `false`     | Existing server URL |
| Worker         | `false`      | `true`      | Existing server URL |

Conflicting role settings are not validated.

#### K3s behavior

- Requires the SOPS secret `k3s_token`
- Disables bundled Traefik and ServiceLB on server nodes. This is to allow for
  metallb.
- Enables the `--debug` flag.
- Opens TCP ports `6443`, `2379`, `2380`, `9100`, and `10250`.
- Opens UDP ports `5353`, `8472`, and `123`.

#### Longhorn storage

`k3s.longhorn = true` enables iSCSI, rpcbind, NFS support, and an iSCSI service
adjustment for NixOS. When K3s is enabled, it also adds the node label
`longhorn-storage=enabled`.

The host prerequisites and Disko size assignment apply independently of
`k3s.enable`.

`k3s.longhornDiskSize` sets:

```nix
disko.devices.zpool.rpool.datasets."longhorn-ext4".size
```

this is meant to be used with the filesystem.nix disko configuration in the
template.

### Example: worker with Longhorn storage

```nix
rpiHomeLab = {
  networking = {
    interface = "end0";
    hostId = "a1b2c3d4"; # Use a unique value for each node.
    hostName = "worker-01";
    address = "10.10.69.20/22";
  };

  k3s = {
    enable = true;
    leader = false;
    agent = true;
    leaderAddress = "https://10.10.69.10:6443";
    longhorn = true;
    longhornDiskSize = "900G"; # Adjust for this node's available storage.
  };
};
```
