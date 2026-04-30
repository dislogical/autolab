@experiment(explicitopen)
package autolab

Manifests: Gateway: "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.0/standard-install.yaml"

Resources: Gateway: {
	HelmRepository: traefik: spec: {
		url: "https://traefik.github.io/charts"
	}
	HelmRelease: traefik: spec: {
		#DisableHelmCrds...
		chart: spec: {
			chart:   "traefik"
			version: "38.0.2"
			sourceRef: #ReferenceOf & {#Resource: HelmRepository.traefik}
		}
		values: {
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
					namespacePolicy: from: "All"
				}
				websecure: {
					port:     8443
					protocol: "HTTPS"
					namespacePolicy: from: "All"
					certificateRefs: [{
						name: Gateway.Certificate.default.spec.secretName
					}]
				}
			}
			metrics: prometheus: serviceMonitor: enabled: true
		}
	}

	HTTPRoute: traefik: {
		spec: {
			parentRefs: [{
				kind: "Gateway"
				name: "traefik-gateway"
			}]
			hostnames: [
				"traefik.services.\(env.external_url)",
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
		spec: {
			secretName: "gw-tls-\(env.cert_issuer)" //pragma: allowlist secret
			dnsNames: [
				env.external_url,
				"*.\(env.external_url)",
				"*.services.\(env.external_url)",
			]
			issuerRef: {
				name: env.cert_issuer
				kind: "ClusterIssuer"
			}
		}
	}
}
