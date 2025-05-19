# Install flux but without the repo syncing
k8s_yaml('stacks/flux-system/gotk-components.yaml')

# Install this repo's stacks
k8s_yaml(kustomize('.'))
