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
    kind
    tilt

    # Dev tools
    commitizen
  ];

  languages.python = {
    enable = true;
    package = pkgs.python3.withPackages(p: with p; [
      pyyaml
    ]);
  };

  tasks = {
    "devenv:enterTest".exec = "tilt ci";
  };

  scripts = {
    publish-manifest.exec = ''
      OCI_REPO=oci://ghcr.io/dislogical/autolab/manifest
      IMAGE=$OCI_REPO:$(git rev-parse --short HEAD)

      # Render the manifests
      task render:prod

      # Push the manifest to the repo
      flux push artifact $IMAGE -f deploy/prod/kustomized.yaml \
        --reproducible \
        --source=$(git config --get remote.origin.url) \
        --revision=$(git branch --show-current)@sha1:$(git rev-parse HEAD) \
        --annotations='org.opencontainers.image.licenses=MIT' \
        --annotations='org.opencontainers.image.source=https://github.com/dislogical/autolab'

      # Tag the manifest as latest
      flux tag artifact $IMAGE --tag latest
    '';
  };
}
