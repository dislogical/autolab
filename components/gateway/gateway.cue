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
					"traefik.\(env.external_url)",
				]
				rules: [{
					backendRefs: [{
						kind: "TraefikService"
						name: "api@internal"
					}]
				}]
			}
		}

		Certificate: default: {
			metadata: namespace: Namespace.gateway.metadata.name
			spec: {
				secretName: "gw-tls-\(env.cert_issuer)" //pragma: allowlist secret
				dnsNames: [
					env.external_url,
					"*.\(env.external_url)",
					"*.services.\(env.external_url)",
				]
				issuerRef: {
					name: env.cert_issuer
					kind: "Issuer"
				}
			}
		}
	}
}

Gateway: #Helm & {
	Namespace: Gateway.Resources.Namespace.gateway.metadata.name

	Chart: {
		name:    "traefik"
		version: "37.0.0"
		repository: {
			name: "traefik"
			url:  "https://traefik.github.io/charts"
		}
	}
	Values: {
		providers: {
			kubernetesIngress: enabled: false
			kubernetesCRD: enabled:     false
			kubernetesGateway: {
				enabled: true
				statusAddress: service: enabled: true
			}
		}

		service: annotations: {
			"metallb.io/loadBalancerIPs": "10.0.1.3"
			"tilt.dev/port-forward":      "8080:80"
		}

		ports: {
			web: redirections: entryPoint: {
				to:     "websecure"
				scheme: "https"
			}
			websecure: asDefault: true
		}

		gateway: listeners: {
			web: {
				namespacePolicy: "All"
			}
			websecure: {
				port:            8443
				protocol:        "HTTPS"
				namespacePolicy: "All"
				certificateRefs: [{
					name: Gateway.Resources.Certificate.default.spec.secretName
				}]
			}
		}
		metrics: prometheus: serviceMonitor: enabled: true
	}
	APIVersions: [
		"monitoring.coreos.com/v1",
	]
}
