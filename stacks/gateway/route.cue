package gateway

import (
	httproutev1 "github.com/orvis98/cue-schemas/gateway.networking.k8s.io/gateway.networking.k8s.io/httproute/v1"
)

dashboardRoute: httproutev1.#HTTPRoute & {
	metadata: {
		name:        "traefik-dashboard"
		"namespace": namespace.metadata.name
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
