{ pkgs, ... }:
{
  imports = [
    ./console.nix
    ./network.nix
    ./user.nix
  ];
  time.timeZone = "America/New_York";
  environment.systemPackages = with pkgs; [
    tree
    neovim
    htop
    ghostty.terminfo
    powertop
    sops
    efibootmgr
    cowsay
    lshw
    ntp
    cryptsetup
    lvm2
    nfs-utils
    libnfs
    lnav
    traceroute
  ];
  # NTP somewhere is important f
  services.chrony = {
    enable = true;
    enableNTS = false; # not enabled in opnsense
    servers = [
      "time.cloudflare.com"
    ];
    extraConfig = ''
      makestep 1.0 -1
    '';
  };
  environment.enableAllTerminfo = false;
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };
  rpiHomeLab = {
    k3s.leaderAddress = "https://leader.lab.lan:6443";
  };
  lab-secrets.enable = true;
}
