load('ext://namespace', 'namespace_create')
load('ext://helm_resource', 'helm_repo', 'helm_resource')

ctx = k8s_context()
if ctx.startswith('admin@talos-'):
    allow_k8s_contexts(ctx)

update_settings(k8s_upsert_timeout_secs=180)

def _get_object_name(object, name = None, kind = None, namespace = None, metadata=None):
    metadata = metadata or object.get('metadata', {}) or object
    name = name or metadata['name'].lower()
    kind = kind or object['kind'].lower()
    namespace = namespace or metadata.get('namespace', None)

    if namespace:
        return '{}:{}:{}'.format(name, kind, namespace.lower())
    else:
        return '{}:{}'.format(name, kind)

def _get_object_labels(object):
    label = object.get('metadata', {}).get('annotations', {}).get('tilt.dev/label')
    if not label:
        label = object.get('metadata', {}).get('namespace')
    return [label] if label else []

config.define_bool('flux-mode', usage='Use flux for helm instead of tilt')
options = config.parse()
flux_mode = options.get('flux-mode', False)

def process_stack(path):
    kustomized = kustomize(path)

    config_maps, rest = filter_yaml(kustomized, kind='ConfigMap')
    helm_repos, rest = filter_yaml(kustomized, api_version='source.toolkit.fluxcd.io', kind='HelmRepository')
    helm_releases, rest = filter_yaml(rest, api_version='helm.toolkit.fluxcd.io', kind='HelmRelease')

    values_objects = {}
    for config_map in decode_yaml_stream(config_maps):
        metadata = config_map['metadata']
        name = metadata['name']
        namespace = metadata.get('namespace', None)
        data = config_map['data']

        contents = values_objects.setdefault(namespace, {}).setdefault(name, {})
        # TODO: When helm 3.19 comes out, we can replace this hack with just the object
        for key, value in data.items():
            contents_object = contents.setdefault(key, {})
            object = decode_yaml(value)
            for key, value in object.items():
                contents_object[key] = value

    for repo in decode_yaml_stream(helm_repos):
        metadata = repo['metadata']
        spec = repo['spec']
        helm_repo(
            metadata['name'],
            spec['url'],
            resource_name=_get_object_name(repo),
            labels=_get_object_labels(repo),
        )

    for release in decode_yaml_stream(helm_releases):
        metadata = release.get('metadata', {})
        namespace = metadata.get('namespace')
        spec = release['spec']
        chart = spec['chart']['spec']
        source_ref = chart['sourceRef']

        # Parse values
        values = {}
        for value_source in spec.get('valuesFrom', []):
            namespace = value_source.get('namespace',  namespace)
            name = value_source['name']
            key = value_source['valuesKey']

            # TODO: When helm 3.19 comes out, we can replace this hack with just the object
            object = values_objects.get(namespace, {}).get(name, {}).get(key, {})
            for key, value in object.items():
                values[key] = encode_json(value).replace('\n', '')

        flags = []
        if spec.get('install', {}).get('crds', None) == 'Skip':
            flags.append('--skip-crds')

        pod_readiness='wait'
        if metadata['name'].endswith('-crds'):
            pod_readiness='ignore'

        dependencies = [_get_object_name(source_ref, namespace=source_ref.get('namespace', namespace))]
        for dep in spec.get('dependsOn', []):
            dependencies.append(_get_object_name(
                dep,
                metadata=dep,
                kind='helmrelease',
                namespace=dep.get('namespace', namespace)
            ))
        if namespace:
            dependencies.append('{}:namespace'.format(namespace))

        helm_resource(
            _get_object_name(release),
            source_ref['name'] + '/' + chart['chart'],
            release_name=metadata['name'],
            namespace=metadata['namespace'],
            flags=flags + ['--set-json=' + '{}={}'.format(key, value) for key, value in values.items()],
            resource_deps=dependencies,
            pod_readiness=pod_readiness,
            labels=_get_object_labels(release),
        )

    k8s_yaml(rest)

    for object in decode_yaml_stream(rest):
        name = _get_object_name(object)
        k8s_resource(
            new_name=name,
            objects=[name],
            labels=_get_object_labels(object),
            )

    namespaces, rest = filter_yaml(rest, kind='namespace')
    for object in decode_yaml_stream(namespaces):
        k8s_resource(
            workload=_get_object_name(object),
            labels=[object['metadata']['name'],]
        )

    for object in decode_yaml_stream(rest):
        # Depend on namespace creation
        namespace = object['metadata'].get('namespace')
        if namespace:
            k8s_resource(
                workload=_get_object_name(object),
                resource_deps=['{}:namespace'.format(namespace)]
            )

    gateway_resources, rest = filter_yaml(rest, api_version='gateway.networking.k8s.io')
    for resource in decode_yaml_stream(gateway_resources):
        k8s_resource(
            workload=_get_object_name(resource),
            links=[link(hostname + ':8080', resource['metadata']['name']) for hostname in resource['spec']['hostnames']],
            resource_deps=['traefik-crds:helmrelease:gateway'], # HACK
            )

    lb_resources, rest = filter_yaml(rest, api_version='metallb.io')
    for resource in decode_yaml_stream(lb_resources):
        k8s_resource(
            workload=_get_object_name(resource),
            resource_deps=['metallb:helmrelease:load-balancer'],
        )

def _kubernetes_get_first_metadata(resource, entry):
    for root in ['values', 'sensitive_values']:
        result = resource[root].get(entry)
        if result:
            return result

        metadata = resource[root].get('metadata')
        if type(metadata) == 'list':
            for metadata_inst in metadata:
                result = metadata_inst.get(entry)
                if result:
                    return result
        elif metadata:
            result = metadata.get(entry)
            if result:
                return result

    return None

def _kubernetes_get_all_metadata(resource, entry):
    result = []
    for root in ['values', 'sensitive_values']:
        for metadata in resource[root].get('metadata', []):
            value = metadata.get(entry)
            if value:
                result.append(value)

    return result

def _parse_kubernetes_namespace(resource):
    name = _kubernetes_get_first_metadata(resource, 'name')
    namespace_create(
        name=name,
        annotations=['- {}: {}'.format(key, value) for key, value in _kubernetes_get_all_metadata(resource, 'annotations')],
        labels=['- {}: {}'.format(key, value) for key, value in _kubernetes_get_all_metadata(resource, 'labels')]
    )
    k8s_resource(
        new_name=resource['address'],
        objects=['{}:namespace'.format(name)],
        labels=[name],
    )

def _parse_helm_release(resource):
    namespace = _kubernetes_get_first_metadata(resource, 'namespace')
    repo_resource_name = resource['address'] + '.repo'

    helm_repo(
        name=resource['address'],
        url=resource['values']['repository'],
        resource_name=repo_resource_name,
        labels=[namespace] if namespace else [],
    )

    values = {}
    for value_source in resource['values']['values']:
        values.update(**decode_yaml(value_source))

    if not namespace:
        print('!!!', 'Helm Release without namespace!', '!!!\n', resource)

    depends = resource.get('depends_on')
    print('!!!', 'helm chart depends on:', depends)
    if not depends:
        print(resource)

    helm_resource(
        name=resource['address'],
        chart=resource['address'] + '/' + resource['values']['chart'],
        release_name=resource['values']['name'],
        namespace=namespace,
        flags=['--set-json=' + '{}={}'.format(key, encode_json(value).replace('\n', '')) for key, value in values.items()],
        resource_deps=[repo_resource_name],
    )

matchers = {
    'registry.opentofu.org/hashicorp/kubernetes': {
        'kubernetes_namespace': _parse_kubernetes_namespace,
    },
    'registry.opentofu.org/hashicorp/helm': {
        'helm_release': _parse_helm_release,
    },
}

def process_tf(path):
    plan = decode_json(local('tofu plan -refresh=false -out=.terraform/plan > /dev/null && tofu show  -json .terraform/plan'))
    format_version = plan['format_version']
    terraform_version = plan['terraform_version']

    print('Using terraform', terraform_version, 'format version', format_version)

    def _process_module(module):
        for resource in module.get('resources', []):
            address = resource['address']
            provider = resource['provider_name']
            type = resource['type']

            matcher = matchers.get(provider, {}).get(type)
            if matcher:
                matcher(resource)
                namespace = _kubernetes_get_first_metadata(resource, 'namespace')
                k8s_resource(
                    workload=address,
                    resource_deps=resource.get('depends_on', []),
                    labels=[namespace] if namespace else [],
                )
            else:
                print('no matcher for type', type, 'from', provider)

        for child in module.get('child_modules', []):
            _process_module(child)

    _process_module(plan['planned_values']['root_module'])

k8s_yaml('flux-system/gotk-components.yaml')

process_stack('.')

process_tf('.')

k8s_resource(
    'traefik:helmrelease:gateway',
    port_forwards=[port_forward(8080, 8000)],
    )
