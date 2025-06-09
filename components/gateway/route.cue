package autolab

import (
	httproutev1 "github.com/orvis98/cue-schemas/gateway.networking.k8s.io/gateway.networking.k8s.io/httproute/v1"
)

export: gateway: {
	let this = export.gateway
	dashboardRoute: httproutev1.#HTTPRoute & {
		metadata: {
			name:        "traefik-dashboard"
			"namespace": this.namespace.metadata.name
		}
		spec: {
			parentRefs: [{
				kind: "Gateway"
				name: "traefik-gateway"
			}]
			hostnames: [
				"traefik.localhost",
			]
			rules: [{
				backendRefs: [{
					kind: "TraefikService"
					name: "api@internal"
				}]
			}]
		}
	}
}
