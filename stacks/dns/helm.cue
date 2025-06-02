package dns

import (
	helmrepov1 "github.com/orvis98/cue-schemas/source.toolkit.fluxcd.io/helmrepository/v1"
	helmreleasev2 "github.com/orvis98/cue-schemas/helm.toolkit.fluxcd.io/helmrelease/v2"
)

let _metadata = {
	name:        "coredns"
	"namespace": namespace.metadata.name
	labels: "app.kubernetes.io/component": "coredns"
}
let _interval = "24h"

helmrepository: helmrepov1.#HelmRepository & {
	metadata: _metadata
	spec: {
		interval: _interval
		url:      "https://coredns.github.io/helm"
	}
}
helmrelease: helmreleasev2.#HelmRelease & {
	metadata: _metadata
	spec: {
		interval: _interval
		chart: spec: {
			chart:             "coredns"
			reconcileStrategy: "ChartVersion"
			sourceRef: {
				kind: helmrepository.kind
				name: helmrepository.metadata.name
			}
		}
		valuesFrom: [{
			kind:      "ConfigMap"
			name:      "helm-values"
			valuesKey: "values-coredns.yaml"
		}]
	}
}
