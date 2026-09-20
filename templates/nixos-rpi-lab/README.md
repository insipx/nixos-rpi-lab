# nixos-lab template

## Directory layout

```text
.
├── base/                # Shared system, networking, console, and user config
├── deployments/         # Kubernetes workloads and services
│   └── kubenix/         # Kubernetes resources in Nix
├── hive/                # Colmena NixOS definitions for cluster deployment
└── machine-specific/    # Hardware and filesystem configuration
    └── rpi5/            # Raspberry Pi 5 hardware and kernel settings
```
