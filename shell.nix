{ pkgs ? import <nixpkgs> {} }:
let
  pythonEnv = pkgs.python3.withPackages(p: with p; [
    pyyaml
  ]);
in
  pkgs.mkShell {
    packages = with pkgs; [
      pythonEnv

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
