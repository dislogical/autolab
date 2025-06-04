package autolab

import (
	httproutev1 "github.com/orvis98/cue-schemas/gateway.networking.k8s.io/gateway.networking.k8s.io/httproute/v1"
)

export: capacitor: {
	httproute: httproutev1.#HTTPRoute & {
		metadata: {
			name:      "capacitor"
			namespace: "flux-system"
		}
		spec: {
			parentRefs: [{
				kind:      "Gateway"
				name:      "traefik-gateway"
				namespace: "gateway"
			}]
			hostnames: ["flux.localhost"]
			rules: [{
				backendRefs: [{
					kind: "Service"
					name: "capacitor"
					port: 9000
				}]
			}]
		}
	}
}
