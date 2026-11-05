load('ext://namespace', 'namespace_create')

allow_k8s_contexts('admin@talos-docker-autolab')

namespace_create('cert-manager')
namespace_create('cnpg-system')
namespace_create('headlamp')

watch_file('helmfile.yaml')
k8s_yaml(local('helmfile template'))

k8s_resource(
  workload='headlamp',
  port_forwards=[
    port_forward(8080, name='headlamp'),
  ],
)
