{ kubenix, ... }:

{
  imports = with kubenix.modules; [
    k8s
    helm
    submodules
    ./traefik
    ./metal-lb
    ./longhorn
  ];

  submodules.imports = [
    ./lib/namespaced.nix
  ];
}
