package autolab

import (
	httproutev1 "github.com/orvis98/cue-schemas/gateway.networking.k8s.io/gateway.networking.k8s.io/httproute/v1"
)

export: kubernetes_dashboard: {
	let this = export.kubernetes_dashboard
	httproute: httproutev1.#HTTPRoute & {
		metadata: {
			name:      "kubernetes-dashboard-route"
			namespace: this.namespace.metadata.name
		}
		spec: {
			parentRefs: [{
				name:      "traefik-gateway"
				namespace: "gateway"
			}]
			hostnames: ["kubernetes.localhost"]
			rules: [{
				backendRefs: [{
					kind: "Service"
					name: "kubernetes-dashboard-web"
					port: 8000
				}]
			}]
		}
	}
}
