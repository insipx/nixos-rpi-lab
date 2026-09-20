localFlake:

{ lib, config, ... }:
{
  imports = [
    localFlake.sops-nix.nixosModules.default
  ];
  options = {
    lab-secrets = {
      enable = lib.mkOption {
        defaultText = lib.literalMD "enable lab secrets";
        type = lib.types.bool;
        default = false;
      };
      generateKey = lib.mkOption {
        defaultText = lib.literalMD "generate sshkeypaths and generate key";
        type = lib.types.bool;
        default = true;
      };
      settings = {
        k3s = lib.mkOption {
          defaultText = lib.literalMD "enable k3s secret";
          type = lib.types.bool;
          default = false;
        };
      };
    };
  };
  config.sops = lib.mkIf config.lab-secrets.enable {
    age = lib.mkIf config.lab-secrets.generateKey {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      generateKey = false;
    };
    secrets.k3s_token = lib.mkIf config.lab-secrets.settings.k3s {
      sopsFile = ./secrets/homelab.yaml;
    };
  };
}
