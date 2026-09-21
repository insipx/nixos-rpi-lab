localFlake:

{ lib, config, ... }:
{
  imports = [
    localFlake.sops-nix.nixosModules.default
  ];
  options = {
    lab-secrets = {
      enable = lib.mkOption {
        description = lib.literalMD "enable lab secrets";
        defaultText = "false";
        type = lib.types.bool;
        default = false;
      };
      settings = {
        k3s = lib.mkOption {
          description = lib.literalMD "enable k3s secret";
          defaultText = "false";
          type = lib.types.bool;
          default = false;
        };
      };
    };
  };
  config.sops = lib.mkIf config.lab-secrets.enable {
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      generateKey = false;
    };
    secrets.k3s_token = lib.mkIf config.lab-secrets.settings.k3s {
      sopsFile = ./secrets/homelab.yaml;
    };
  };
}
