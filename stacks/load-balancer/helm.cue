package autolab

import (
	helmrepov1 "github.com/orvis98/cue-schemas/source.toolkit.fluxcd.io/helmrepository/v1"
	helmreleasev2 "github.com/orvis98/cue-schemas/helm.toolkit.fluxcd.io/helmrelease/v2"
)

export: load_balancer: {
	let this = export.load_balancer
	let _interval = "24h"

	helmrepository: helmrepov1.#HelmRepository & {
		metadata: {
			name:      "metallb"
			namespace: this.namespace.metadata.name
		}
		spec: {
			interval: _interval
			url:      "https://metallb.github.io/metallb"
		}
	}

	helmrelease: helmreleasev2.#HelmRelease & {
		metadata: {
			name:      "metallb"
			namespace: this.namespace.metadata.name
			annotations: {
				"tilt.dev/crd": "metallb.io"
			}
		}
		spec: {
			interval: _interval
			dependsOn: [{
				name:      "prometheus-crds"
				namespace: "metrics"
			}]
			chart: spec: {
				chart: "metallb"
				sourceRef: {
					kind: helmrepository.kind
					name: helmrepository.metadata.name
				}
			}
			install: crds: "CreateReplace"
			values: {
				controller: {
					repository: "quay.io/metallb/controller"
					tag:        "v0.14.9"
					pullPolicy: "IfNotPresent"
				}
				speaker: {
					image: {
						repository: "quay.io/metallb/speaker"
						tag:        "v0.15.2@sha256:260c9406f957c0830d4e6cd2e9ac8c05e51ac959dd2462c4c2269ac43076665a"
						pullPolicy: "IfNotPresent"
					}
					frr: enabled: false
				}
				prometheus: {
					serviceAccount: "prometheus-kube-prometheus-prometheus"
					namespace:      "metrics"
					serviceMonitor: enabled: true
				}
			}
		}
	}
}
