{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/packages/
  packages = with pkgs; [
    # Build Tools
    go-task
    cue
    holos
    kustomize
    kubernetes-helm
    kubeconform
    yq

    # Deployment
    fluxcd

    # Test Environment
    ctlptl
    kind
    tilt
  ];

  languages.python = {
    enable = true;
    package = pkgs.python3.withPackages(p: with p; [
      pyyaml
    ]);
  };
}
