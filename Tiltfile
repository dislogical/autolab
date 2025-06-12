load('ext://helm_resource', 'helm_repo', 'helm_resource')
load('ext://namespace', 'namespace_create')

ctx = k8s_context()
if ctx.startswith('admin@talos-'):
    allow_k8s_contexts(ctx)

update_settings(k8s_upsert_timeout_secs=180)

def resource_name(id):
    return _get_object_name(name=id.name, kind=id.kind, namespace=id.namespace)
workload_to_resource_function(resource_name)

def _get_object_name(object = {}, name = None, kind = None, namespace = None, metadata=None):
    metadata = metadata or object.get('metadata', {}) or object
    name = name or metadata['name']
    kind = kind or object['kind']

    name = name.replace(':', '\\:')

    return '{}:{}:{}'.format(name, kind, namespace or metadata.get('namespace', 'default'))

def _get_object_labels(object):
    if object['kind'].lower() == 'namespace':
        return [object['metadata']['name']]

    if object['kind'].lower() == 'customresourcedefinition':
        return ['CRDs']

    label = object.get('metadata', {}).get('annotations', {}).get('tilt.dev/label')
    if not label:
        label = object.get('metadata', {}).get('namespace')
    return [label] if label else []

def _get_object_field(object, fields, default = None):
    current = object
    for field in fields.split('.'):
        current = current.get(field) if current else None
    return current or default

watch_file('flux-system/gotk-components.yaml')
flux = read_file('flux-system/gotk-components.yaml')

watch_file('components')
watch_file('platform')
built = local('holos render platform && holos cue export --out yaml ./platform -e kustomization > deploy/kustomization.yaml && kustomize build deploy', quiet=True)

# Make services get workloads
k8s_kind('^Service$')

crds = {}

for kustomized in [flux, built]:

    k8s_yaml(kustomized)

    crd_yamls, _ = filter_yaml(kustomized, kind='CustomResourceDefinition', api_version='apiextensions.k8s.io')

    for crd in decode_yaml_stream(crd_yamls):
        group = _get_object_field(crd, 'spec.group')
        kind = _get_object_field(crd, 'spec.names.kind').lower()
        crds.setdefault(group, {})[kind] = _get_object_name(crd)

    for resource in decode_yaml_stream(kustomized):
        name = _get_object_name(resource)
        kind = resource['kind'].lower()

        if kind not in ['service', 'deployment', 'job', 'daemonset']:
            k8s_resource(
                new_name=name,
                objects=[name],
            )

        # Services don't get pod readiness notifications
        if kind == 'service':
            k8s_resource(
                workload=name,
                pod_readiness='ignore',
            )

        k8s_resource(
            workload=name,
            labels=_get_object_labels(resource)
        )

        # Make sure custom resources get dependencies on their CRDs
        api_version = resource.get('apiVersion', '').split('/')
        if len(api_version) == 2 and api_version[0] != 'apps' and not api_version[0].endswith('k8s.io'):
            crd = crds.get(api_version[0], {}).get(kind)
            if crd:
                k8s_resource(
                    workload=name,
                    resource_deps=[crd]
                )
            else:
                print('couldnt find crd', api_version, kind)

        # Make sure objects depend on their namespace
        namespace = _get_object_field(resource, 'metadata.namespace', 'default')
        if namespace not in ['default', 'kube-system']:
            k8s_resource(
                workload=name,
                resource_deps=[_get_object_name(name=namespace, kind='Namespace')]
            )

        # Make sure deployments depend on their service accounts
        if kind == 'deployment':
            service_account = _get_object_field(resource, 'spec.template.spec.serviceAccountName')
            if service_account:
                k8s_resource(
                    workload=name,
                    resource_deps=[_get_object_name(name=service_account, kind='ServiceAccount', namespace=namespace)]
                )

        # Enable port-forwards via annotation
        port_forward = _get_object_field(resource, 'metadata.annotations', {}).get('tilt.dev/port-forward')
        if port_forward:
            k8s_resource(
                workload=name,
                port_forwards=[port_forward],
            )
