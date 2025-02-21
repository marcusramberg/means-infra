{
  pkgs,
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
    bitwarden-cli
    helmWrap
    helmfileWrap
    inputs.helmfile-nix.packages.${pkgs.stdenv.system}.default
    k9s
    opentofu
    stern
  ];

  processes = {
    bw.exec = "${pkgs.bitwarden-cli}/bin/bw serve";
  };

  scripts.kubectl.exec = ''
    k3s kubectl $@
  '';
}
