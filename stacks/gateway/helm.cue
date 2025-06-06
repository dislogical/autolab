package autolab

import (
	helmrepov1 "github.com/orvis98/cue-schemas/source.toolkit.fluxcd.io/helmrepository/v1"
	helmreleasev2 "github.com/orvis98/cue-schemas/helm.toolkit.fluxcd.io/helmrelease/v2"
)

let _interval = "24h"

export: gateway: {
	let this = export.gateway

	helmrepository: helmrepov1.#HelmRepository & {
		apiVersion: "source.toolkit.fluxcd.io/v1"
		kind:       "HelmRepository"
		metadata: {
			name:      "traefik"
			namespace: this.namespace.metadata.name
		}
		spec: {
			interval: _interval
			url:      "https://helm.traefik.io/traefik"
		}
	}

	crdsrelease: helmreleasev2.#HelmRelease & {
		metadata: {
			name:      "traefik-crds"
			namespace: this.namespace.metadata.name
			annotations: {
				"tilt.dev/crd": "gateway.networking.k8s.io"
			}
		}
		spec: {
			interval: _interval
			chart: spec: {
				chart:             "traefik-crds"
				reconcileStrategy: "ChartVersion"
				sourceRef: {
					kind: helmrepository.kind
					name: helmrepository.metadata.name
				}
			}
			install: crds: "CreateReplace"
			values: {
				traefik:    false
				gatewayAPI: true
			}
		}
	}

	traefikrelease: helmreleasev2.#HelmRelease & {
		apiVersion: "helm.toolkit.fluxcd.io/v2"
		kind:       "HelmRelease"
		metadata: {
			name:      "traefik"
			namespace: this.namespace.metadata.name
			annotations: {
				"tilt.dev/port-forward": "8000:8080"
			}
		}
		spec: {
			interval: _interval
			dependsOn: [{
				name: crdsrelease.metadata.name
			}, {
				name:      "prometheus-crds"
				namespace: "metrics"
			}]
			chart: spec: {
				chart: "traefik"
				sourceRef: {
					kind: helmrepository.kind
					name: helmrepository.metadata.name
				}
			}
			install: crds: "Skip"
			values: {
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

				service: annotations: "metallb.io/loadBalancerIPs": "10.42.42.1"
				gateway: listeners: web: namespacePolicy:     "All"
				metrics: prometheus: serviceMonitor: enabled: true
			}
		}
	}
}
