allow_k8s_contexts('admin@talos-docker-autolab')

k8s_yaml(local('helmfile template'))

k8s_resource(
  workload='headlamp',
  port_forwards=[
    port_forward(8080, name='headlamp'),
  ],
)
