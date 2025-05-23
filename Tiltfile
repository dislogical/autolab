load('ext://helm_resource', 'helm_repo', 'helm_resource')

load('./stacks/flux-system/Tiltfile', 'flux')
load('./stacks/capacitor/Tiltfile', 'capacitor')
load('./stacks/gateway/Tiltfile', 'gateway')
load('./stacks/load-balancer/Tiltfile', 'load_balancer')
load('./stacks/dns/Tiltfile', 'dns')
load('./stacks/kubernetes-dashboard/Tiltfile', 'kubernetes_dashboard')
load('./stacks/metrics/Tiltfile', 'metrics')

ctx = k8s_context()
if ctx.startswith('admin@talos-'):
    allow_k8s_contexts(ctx)

update_settings(k8s_upsert_timeout_secs=180)

# flux()
# capacitor()
gateway()
load_balancer()
dns()
kubernetes_dashboard()
metrics()
