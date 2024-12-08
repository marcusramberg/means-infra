{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  helmWrap =
    with pkgs;
    wrapHelm kubernetes-helm {
      plugins = with kubernetes-helmPlugins; [
        helm-diff
        helm-git
      ];
    };
  helmfileWrap = pkgs.helmfile-wrapped.override { inherit (helmWrap) pluginsDir; };
in
{
  env = {
    KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
  };
  packages = with pkgs; [
    argocd
    helmWrap
    helmfileWrap
    inputs.helmfile-nix.packages.${pkgs.stdenv.system}.default
    opentofu
    stern
  ];

  scripts.kubectl.exec = ''
    k3s kubectl $@
  '';
}
