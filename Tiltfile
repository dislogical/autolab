load('ext://helm_resource', 'helm_repo', 'helm_resource')

ctx = k8s_context()
if ctx.startswith('admin@talos-'):
    allow_k8s_contexts(ctx)

update_settings(k8s_upsert_timeout_secs=180)

def _get_object_name(object, name = None, kind = None, namespace = None, metadata=None):
    metadata = metadata or object.get('metadata', {}) or object
    name = name or metadata['name']
    kind = kind or object['kind']

    name = name.replace(':', '\\:')

    if kind == 'namespace':
        return '{}:{}'.format(name, kind)
    else:
        namespace = namespace or metadata.get('namespace', 'default')
        return '{}:{}:{}'.format(name, kind, namespace)

def _get_object_labels(object):
    if object['kind'].lower() == 'namespace':
        return [object['metadata']['name']]

    if object['kind'].lower() == 'customresourcedefinition':
        return ['CRDs']

    label = object.get('metadata', {}).get('annotations', {}).get('tilt.dev/label')
    if not label:
        label = object.get('metadata', {}).get('namespace')
    return [label] if label else []

def resource_name(id):
    name = '{}:{}'.format(id.name, id.kind)
    if id.kind.lower() != 'namespace':
        name = '{}:{}'.format(name, id.namespace)
    return name
workload_to_resource_function(resource_name)

kustomized = local('holos render platform && holos cue export --out yaml ./platform -e kustomization > deploy/kustomization.yaml && kustomize build deploy', quiet=True)

k8s_yaml(kustomized)

for resource in decode_yaml_stream(kustomized):
    name = _get_object_name(resource)
    kind = resource['kind'].lower()

    if kind == 'service':
        continue

    if kind in ['service', 'deployment', 'daemonset', 'job']:
        k8s_resource(
            workload=name,
            labels=_get_object_labels(resource),
        )
    else:
        k8s_resource(
            new_name=name,
            objects=[name],
            labels=_get_object_labels(resource),
            )

    port_forward = resource.get('metadata').get('annotations', {}).get('tilt.dev/port-forward')
    if port_forward:
        k8s_resource(
            workload=_get_object_name(resource),
            port_forwards=[port_forward],
        )

# k8s_yaml('flux-system/gotk-components.yaml')
