{ kubenix, flake, ... }:
let
  ns = "kube-system";
in
{
  imports = with kubenix.modules; [
    k8s
    submodules
  ];
  submodules.imports = [ ../lib/namespaced.nix ];
  submodules.instances.kube-system = {
    submodule = "namespaced";
    args.kubernetes = {
      helm.releases.traefik = {
        chart = kubenix.lib.helm.fetch {
          repo = "https://helm.traefik.io/traefik";
          chart = "traefik";
          version = "40.3.0";
          sha256 = "sha256-V8l23cMxhtIg1bPtRLXJvvzlzzcIl/uGWFYATzCKtPI=";
        };
        includeCRDs = true;
        noHooks = true;
        namespace = ns;
        values = {
          logs.general.level = "DEBUG";

          metrics.prometheus = {
            entrypoint = "metrics";
            addRoutersLabels = true;
            addServicesLabels = true;
            serviceMonitor = {
              enabled = true;
            };
          };
          persistence = {
            enabled = false;
            storageClass = "longhorn-static";
          };
          # enable metal lb
          service.type = "LoadBalancer";
          ports = {
            metrics = {
              port = 9100;
              protocol = "TCP";
              targetPort = "metrics";
            };
          };
        };
      };
      resources = {
        middleware.traefik-https-redirect = {
          metadata = {
            name = "traefik-https-redirect";
            namespace = ns;
          };
          spec = {
            redirectScheme = {
              scheme = "https";
              permanent = true;
            };
          };
        };
        ingressroute.https-redirect = {
          metadata = {
            name = "https-redirect";
            namespace = ns;
          };
          spec = {
            entryPoints = [
              "web"
              "web-public"
            ];
            routes = [
              {
                match = "HostRegexp(`.+`)";
                kind = "Rule";
                priority = 1;
                middlewares = [
                  {
                    name = "traefik-https-redirect";
                    namespace = ns;
                  }
                ];
                # dummy service
                services = [
                  {
                    name = "noop@internal";
                    kind = "TraefikService";
                  }
                ];
              }
            ];
          };
        };
        ingressroute.traefik-dashboard = {
          metadata = {
            name = "traefik-dashboard";
            namespace = ns;
          };
          spec = {
            entryPoints = [ "websecure" ];
            routes = [
              {
                match = "Host(`traefik.${flake.lib.hostname}`)";

                kind = "Rule";
                services = [
                  {
                    name = "api@internal";
                    kind = "TraefikService";
                  }
                ];
              }
            ];
            tls = { };
          };
        };
      };
      customTypes = {
        ingressroute = {
          attrName = "ingressroute";
          group = "traefik.io";
          version = "v1alpha1";
          kind = "IngressRoute";
        };
        middleware = {
          attrName = "middleware";
          group = "traefik.io";
          version = "v1alpha1";
          kind = "Middleware";
        };
        tlsoption = {
          attrName = "tlsoption";
          group = "traefik.io";
          version = "v1alpha1";
          kind = "TLSOption";
        };
        servicemonitors = {
          attrName = "servicemonitors";
          group = "monitoring.coreos.com";
          version = "v1";
          kind = "ServiceMonitor";
        };
      };
    };
  };
}
