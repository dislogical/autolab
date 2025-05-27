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
            resource_name='{}:{}:{}'.format(metadata['name'], repo['kind'], metadata['namespace']),
            labels=[label],
        )

    for release in decode_yaml_stream(helm_releases):
        metadata = release.get('metadata', {})
        spec = release['spec']
        chart = spec['chart']['spec']
        values_files = [os.path.join(path, entry['valuesKey']) for entry in spec.get('valuesFrom') if entry['kind'] == 'ConfigMap']

        flags = []
        if spec.get('install', {}).get('crds', None) == 'Skip':
            flags.append('--skip-crds')

        helm_resource(
            '{}:{}:{}'.format(metadata['name'], release['kind'], metadata['namespace']),
            chart['sourceRef']['name'] + '/' + chart['chart'],
            release_name=metadata['name'],
            namespace=metadata['namespace'],
            flags=flags + ['--values=' + file for file in values_files],
            deps=values_files,
            labels=[label],
            resource_deps=['{}:{}:{}'.format(chart['sourceRef']['name'], chart['sourceRef']['kind'], chart['sourceRef'].get('namespace', metadata['namespace']))],
        )

    for object in decode_yaml_stream(rest):
        apiVersion = object['apiVersion']
        kind = object['kind']
        metadata = object.get('metadata', {})
        spec = object.get('spec', {})

        if not flux_mode:
            if kind == 'ConfigMap' and len(object['data']) == 1:
                values_path = os.path.join(path, object['data'].keys()[0])
                if os.path.exists(values_path):
                    continue

        k8s_yaml(encode_yaml(object))

        if apiVersion.startswith('gateway.networking.k8s.io') and kind.endswith('Route'):
            k8s_resource(
                new_name='route-' + metadata['name'],
                objects=['{}:{}:{}'.format(metadata['name'], kind, metadata['namespace'])],
                labels=[label],
                links=[link(hostname + ':8080', metadata['name']) for hostname in spec['hostnames']],
                resource_deps=['traefik-crds:HelmRelease:gateway'], # HACK
                )

k8s_yaml('stacks/flux-system/gotk-components.yaml')
process_stack('stacks/gateway')
process_stack('stacks/load-balancer')
process_stack('stacks/dns')
process_stack('stacks/kubernetes-dashboard')
process_stack('stacks/metrics')

# flux()
# capacitor()
# gateway()
# load_balancer()
# dns()
# kubernetes_dashboard()
# metrics()
