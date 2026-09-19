{ kubenix, ... }:

{
  imports = with kubenix.modules; [
    k8s
    helm
    submodules
    ./traefik/default.nix
    ./metal-lb/default.nix
    ./certs/default.nix
  ];

  submodules.imports = [
    ./lib/namespaced.nix
  ];
}
