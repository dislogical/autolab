package autolab

import (
	helmrepov1 "github.com/orvis98/cue-schemas/source.toolkit.fluxcd.io/helmrepository/v1"
	helmreleasev2 "github.com/orvis98/cue-schemas/helm.toolkit.fluxcd.io/helmrelease/v2"
)

export: postgres: {
	let this = export.postgres
	let _interval = "24h"

	helmrepository: helmrepov1.#HelmRepository & {
		metadata: {
			name:      "cloudnative-pg"
			namespace: this.namespace.metadata.name
		}
		spec: {
			interval: _interval
			url:      "https://cloudnative-pg.github.io/charts"
		}
	}

	operator: helmreleasev2.#HelmRelease & {
		metadata: {
			name:      "operator"
			namespace: this.namespace.metadata.name
		}
		spec: {
			interval: _interval
			chart: spec: {
				chart: "cloudnative-pg"
				sourceRef: {
					kind: helmrepository.kind
					name: helmrepository.metadata.name
				}
			}
			install: crds: "CreateReplace"
			values: {
				image: {
					repository: "ghcr.io/cloudnative-pg/cloudnative-pg"
					tag:        "1.26.0@sha256:927d7a8a1f32fe4c1e19665dc36d988f26207d7b7fce81b5e5af2ee0cd18aeef"
					pullPolicy: "IfNotPresent"
				}
			}
		}
	}

	cluster: helmreleasev2.#HelmRelease & {
		metadata: {
			name:      "cluster"
			namespace: this.namespace.metadata.name
		}
		spec: {
			interval: _interval
			dependsOn: [{name: operator.metadata.name}]
			chart: spec: {
				chart: "cluster"
				sourceRef: {
					kind: helmrepository.kind
					name: helmrepository.metadata.name
				}
			}
			install: crds: "CreateReplace"
			values: {
				cluster: {
					instances: 2
					monitoring: enabled: true
				}
			}
		}
	}
}
