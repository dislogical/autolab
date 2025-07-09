{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  packages = with pkgs; [
    # Build Tools
    go-task
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
}
