load('./stacks/flux-system/Tiltfile', 'flux')
load('./stacks/capacitor/Tiltfile', 'capacitor')
load('./stacks/gateway/Tiltfile', 'gateway')
load('./stacks/load-balancer/Tiltfile', 'load_balancer')
load('./stacks/dns/Tiltfile', 'dns')
load('./stacks/kubernetes-dashboard/Tiltfile', 'kubernetes_dashboard')
load('./stacks/metrics/Tiltfile', 'metrics')

load('ext://helm_resource', 'helm_repo', 'helm_resource')

ctx = k8s_context()
if ctx.startswith('admin@talos-'):
    allow_k8s_contexts(ctx)

update_settings(k8s_upsert_timeout_secs=180)

def _get_object_name(object, metadata=None, name = None, kind = None, namespace = None):
    metadata = metadata or object.get('metadata', {})
    name = name or metadata['name'].lower()
    kind = kind or object['kind'].lower()
    namespace = namespace or metadata.get('namespace', None)

    if namespace:
        return '{}:{}:{}'.format(name, kind, namespace.lower())
    else:
        return '{}:{}'.format(name, kind)

config.define_bool('flux-mode', usage='Use flux for helm instead of tilt')
options = config.parse()
flux_mode = options.get('flux-mode', False)

def process_stack(path):
    label = os.path.basename(path)
    kustomized = kustomize(path)

    helm_repos, rest = filter_yaml(kustomized, api_version='source.toolkit.fluxcd.io', kind='HelmRepository')
    helm_releases, rest = filter_yaml(rest, api_version='helm.toolkit.fluxcd.io', kind='HelmRelease')

    for repo in decode_yaml_stream(helm_repos):
        metadata = repo.get('metadata', {})
        spec = repo['spec']
        helm_repo(
            metadata['name'],
            spec['url'],
            resource_name=_get_object_name(repo),
            labels=[label],
        )

    for release in decode_yaml_stream(helm_releases):
        metadata = release.get('metadata', {})
        spec = release['spec']
        chart = spec['chart']['spec']
        values_files = [os.path.join(path, entry['valuesKey']) for entry in spec.get('valuesFrom') if entry['kind'] == 'ConfigMap']
        source_ref = chart['sourceRef']

        flags = []
        if spec.get('install', {}).get('crds', None) == 'Skip':
            flags.append('--skip-crds')

        pod_readiness='wait'
        if metadata['name'].endswith('-crds'):
            pod_readiness='ignore'

        dependencies = [_get_object_name(source_ref, metadata=source_ref, namespace=source_ref.get('namespace', metadata.get('namespace')))]
        for dep in spec.get('dependsOn', []):
            dependencies.append(_get_object_name(
                dep,
                metadata=dep,
                kind='helmrelease',
                namespace=dep.get('namespace', metadata.get('namespace'))
            ))

        helm_resource(
            _get_object_name(release),
            source_ref['name'] + '/' + chart['chart'],
            release_name=metadata['name'],
            namespace=metadata['namespace'],
            flags=flags + ['--values=' + file for file in values_files],
            deps=values_files,
            resource_deps=dependencies,
            pod_readiness=pod_readiness,
            labels=[label],
        )

    k8s_yaml(rest)
    for object in decode_yaml_stream(rest):
        metadata = object['metadata']
        name = _get_object_name(object)
        k8s_resource(
            new_name=name,
            objects=[name],
            labels=[label],
            )

        # Depend on namespace creation
        namespace = metadata.get('namespace')
        if namespace:
            k8s_resource(
                workload=name,
                resource_deps=['{}:namespace'.format(namespace)]
            )

    gateway_resources, _ = filter_yaml(kustomized, api_version='gateway.networking.k8s.io')
    for resource in decode_yaml_stream(gateway_resources):
        k8s_resource(
            workload=_get_object_name(resource),
            links=[link(hostname + ':8080', resource['metadata']['name']) for hostname in resource['spec']['hostnames']],
            resource_deps=['traefik-crds:helmrelease:gateway'], # HACK
            )

    lb_resources, _ = filter_yaml(kustomized, api_version='metallb.io')
    for resource in decode_yaml_stream(lb_resources):
        k8s_resource(
            workload=_get_object_name(resource),
            resource_deps=['metallb:helmrelease:load-balancer'],
        )

k8s_yaml('stacks/flux-system/gotk-components.yaml')
process_stack('stacks/capacitor')
process_stack('stacks/gateway')
process_stack('stacks/load-balancer')
process_stack('stacks/dns')
process_stack('stacks/kubernetes-dashboard')
process_stack('stacks/metrics')
