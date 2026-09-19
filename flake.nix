{
  description = "A Collection of Nix Flake Templates & Modules for a Raspberry Pi K3s Cluster";
  outputs =
    { self, ... }:
    {
      nixosModules = {
        homelab =
          { ... }:
          {
            imports = [ ./modules/homelab ];
          };
        default = self.nixosModules.homelab;

      };
      templates = {
        lab = {
          path = ./templates/nixos-rpi-lab;
          description = "A k3s nixos lab";
        };

        secrets = {
          path = ./templates/nixos-rpi-lab-secrets;
          description = "Secrets for the lab";
        };
        defaultTemplate = self.templates.rpi-lab;

      };
    };
}
