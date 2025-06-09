package autolab

import (
	helmrepov1 "github.com/orvis98/cue-schemas/source.toolkit.fluxcd.io/helmrepository/v1"
	helmreleasev2 "github.com/orvis98/cue-schemas/helm.toolkit.fluxcd.io/helmrelease/v2"
)

let _interval = "24h"

export: kubernetes_dashboard: {
	let this = export.kubernetes_dashboard

	helmrepository: helmrepov1.#HelmRepository & {
		metadata: {
			name:      "kubernetes-dashboard"
			namespace: this.namespace.metadata.name
		}
		spec: {
			interval: _interval
			url:      "https://kubernetes.github.io/dashboard/"
		}
	}

	helmrelease: helmreleasev2.#HelmRelease & {
		metadata: {
			name:      "kubernetes-dashboard"
			namespace: this.namespace.metadata.name
		}
		spec: {
			interval: _interval
			chart: spec: {
				chart: "kubernetes-dashboard"
				sourceRef: {
					kind: helmrepository.kind
					name: helmrepository.metadata.name
				}
			}
			values: {
				kong: enabled: false
			}
		}
	}
}
