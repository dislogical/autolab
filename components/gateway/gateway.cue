package holos

holos: Gateway.BuildPlan

Gateway: {
	Resources: {
		Namespace: gateway: _

		HTTPRoute: traefik: {
			metadata: {
				namespace: Namespace.gateway.metadata.name
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
}

Gateway: #Helm & {
	Namespace: Gateway.Resources.Namespace.gateway.metadata.name

	Chart: {
		name:    "traefik"
		version: "36.0.0"
		repository: {
			name: "traefik"
			url:  "https://traefik.github.io/charts"
		}
	}
	Values: {
		image: {
			registry:   "docker.io"
			repository: "traefik"
			tag:        "v3.4.1@sha256:cd40ab7bc1f047731d5b22595203812343efcb6538014c4e93221cfc3a77217a"
		}

		providers: {
			kubernetesIngress: enabled: false
			kubernetesCRD: enabled:     false
			kubernetesGateway: {
				enabled: true
				statusAddress: service: enabled: true
			}
		}

		service: annotations: {
			"metallb.io/loadBalancerIPs": "10.42.42.1"
			"tilt.dev/port-forward":      "8000:8080"
		}
		gateway: listeners: web: namespacePolicy: "All"
		// metrics: prometheus: serviceMonitor: enabled: true
	}
}
