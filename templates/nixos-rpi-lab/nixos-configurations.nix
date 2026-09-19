{ inputs, ... }:
{
  flake.nixosConfigurations.initialInstall = inputs.nixos-raspberrypi.lib.nixosSystemFull {
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
}
