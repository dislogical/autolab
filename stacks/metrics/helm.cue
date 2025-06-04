package autolab

import (
	helmrepov1 "github.com/orvis98/cue-schemas/source.toolkit.fluxcd.io/helmrepository/v1"
	helmreleasev2 "github.com/orvis98/cue-schemas/helm.toolkit.fluxcd.io/helmrelease/v2"
)

export: metrics: {
	let this = export.metrics
	let _interval = "24h"

	helmrepository: helmrepov1.#HelmRepository & {
		metadata: {
			name:      "prometheus"
			namespace: this.namespace.metadata.name
		}
		spec: {
			interval: _interval
			url:      "https://prometheus-community.github.io/helm-charts"
		}
	}
	prometheus_crds: helmreleasev2.#HelmRelease & {
		metadata: {
			name:      "prometheus-crds"
			namespace: this.namespace.metadata.name
		}
		spec: {
			interval: "24h"
			chart: spec: {
				chart: "prometheus-operator-crds"
				sourceRef: {
					kind: helmrepository.kind
					name: helmrepository.metadata.name
				}
			}
			install: crds: "CreateReplace"
		}
	}
	prometheus: helmreleasev2.#HelmRelease & {
		metadata: {
			name:      "prometheus"
			namespace: this.namespace.metadata.name
		}
		spec: {
			interval: _interval
			dependsOn: [{
				name: prometheus_crds.metadata.name
			}, {
				name:      "traefik-crds"
				namespace: "gateway"
			}]
			chart: spec: {
				chart: "kube-prometheus-stack"
				sourceRef: {
					kind: helmrepository.kind
					name: helmrepository.metadata.name
				}
			}
			install: crds: "Skip"
			values: {
				crds: enabled: false
				prometheus: {
					prometheusSpec: {
						maximumStartupDurationSeconds:           null
						ruleSelectorNilUsesHelmValues:           false
						serviceMonitorSelectorNilUsesHelmValues: false
						podMonitorSelectorNilUsesHelmValues:     false
						probeSelectorNilUsesHelmValues:          false
						scrapeConfigSelectorNilUsesHelmValues:   false
					}
					route: main: {
						enabled: true
						hostnames: ["prometheus.localhost"]
						parentRefs: [{
							kind:      "Gateway"
							name:      "traefik-gateway"
							namespace: "gateway"
						}]
					}
				}
				grafana: route: main: {
					enabled: true
					hostnames: ["grafana.localhost"]
					parentRefs: [{
						kind:      "Gateway"
						name:      "traefik-gateway"
						namespace: "gateway"
					}]
				}
			}
		}
	}
}
