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
    cowsay
    lshw
    cryptsetup
    lvm2
    nfs-utils
    libnfs
    lnav
    traceroute
  ];
  # NTP somewhere is important
  services.chrony = {
    enable = true;
    enableNTS = true;
    servers = [
      "time.cloudflare.com"
    ];
    extraConfig = ''
      makestep 1.0 -1
    '';
  };
  environment.enableAllTerminfo = false;
  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      min-free = "${toString (100 * 1024 * 1024)}";
      max-free = "${toString (1024 * 1024 * 1024)}";
    };
  };
  rpiHomeLab = {
    k3s.leaderAddress = "https://leader.lab.lan:6443";
  };
  lab-secrets.enable = true;
}
