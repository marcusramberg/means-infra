_: [
  {
    environments.dev = { };
  }
  {
    repositories = [
      {
        name = "tailscale";
        url = "https://pkgs.tailscale.com/helmcharts";
      }
      {
        name = "argocd";
        url = "https://argoproj.github.io/argo-helm";
      }
      {
        name = "prometheus-community";
        url = "https://prometheus-community.github.io/helm-charts";
      }
      {
        name = "arc";
        url = "ghcr.io/actions/actions-runner-controller-charts";
        oci = true;
      }
      {
        name = "synology-csi-chart";
        url = "https://christian-schlichtherle.github.io/synology-csi-chart";
      }
    ];
    releases = [
      {
        name = "tailscale";
        namespace = "tailscale";
        chart = "tailscale/tailscale-operator";
        values = [
          {
            oauth = {
              clientId = "ref+bw://eff8d5ce-178a-4f7b-aca1-4426204dffe2/username";
              clientSecret = "ref+bw://eff8d5ce-178a-4f7b-aca1-4426204dffe2/password";
            };
          }
        ];
      }
      {
        name = "prometheus-stack";
        namespace = "monitoring";
        chart = "prometheus-community/kube-prometheus-stack";
        values = [ "prometheus.yaml" ];
      }
      {
        name = "argocd";
        namespace = "argocd";
        installed = true;
        chart = "argocd/argo-cd";
        values = [ "argo.yaml" ];
      }
      {
        name = "arc-controller";
        chart = "arc/gha-runner-scale-set-controller";
        version = "0.10.1";
        namespace = "arc";
        values = [
          {
            githubConfigSecret = "pre-defined-secret";
            replicas = 3;
            securityContext = {
              capabilities = {
                drop = [ "ALL" ];
              };
              readOnlyRootFilesystem = true;
              runAsNonRoot = true;
              runAsUser = 1000;
            };
            resources = {
              requests = {
                cpu = "100m";
                memory = "128Mi";
              };
            };
            watchSingleNamespace = "runners";
          }
        ];
      }
      {
        name = "infra-scaleset";
        version = "0.10.1";
        namespace = "runners";
        chart = "arc/gha-runner-scale-set";
        values = [
          {
            githubConfigSecret = "pre-defined-secret";
            githubConfigUrl = "https://github.com/marcusramberg/means-infra";
            containerMode = {
              type = "dind";
            };
            controllerServiceAccount = {
              namespace = "arc";
              name = "arc-controller-gha-rs-controller";
            };
          }
        ];
      }
      {
        name = "infra-container-scaleset";
        version = "0.10.1";
        namespace = "runners";
        chart = "arc/gha-runner-scale-set";
        values = [
          {
            githubConfigSecret = "pre-defined-secret";
            containerMode = {
              type = "kubernetes";
              kubernetesModeWorkVolumeClaim = {
                accessModes = [ "ReadWriteOnce" ];
                resources = {
                  requests = {
                    storage = "1Gi";
                  };
                };
              };
            };
            githubConfigUrl = "https://github.com/marcusramberg/means-infra";
            controllerServiceAccount = {
              namespace = "arc";
              name = "arc-controller-gha-rs-controller";
            };
          }
        ];
      }
      {
        name = "mspace-csi";
        version = "0.10.1";
        namespace = "kube-system";
        chart = "synology-csi-chart/synology-csi";
      }
    ];
  }
]
