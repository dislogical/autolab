package dns

import (
	"crypto/md5"
	"encoding/hex"
	"encoding/yaml"

	corev1 "cue.dev/x/k8s.io/api/core/v1"

	helmrepov1 "github.com/orvis98/cue-schemas/source.toolkit.fluxcd.io/helmrepository/v1"
	helmreleasev2 "github.com/orvis98/cue-schemas/helm.toolkit.fluxcd.io/helmrelease/v2"
)

let _metadata = {
	name:        "coredns"
	"namespace": namespace.metadata.name
	labels: "app.kubernetes.io/component": "coredns"
}
let _interval = "24h"

values: corev1.#ConfigMap & {
	metadata: {
		name:      "coredns-values-" + hex.Encode(md5.Sum(data.values))
		namespace: _metadata["namespace"]
		labels:    _metadata.labels
	}
	data: values: yaml.Marshal({
		isClusterService: false
		image: {
			repository: "ghcr.io/k8s-gateway/k8s_gateway"
			tag:        "1.2.1@sha256:7830e736192ec17039a0c6f5302d025e93cc323b15b8e74c69fcdeb895062a5b"
			pullPolicy: "IfNotPresent"
		}
		serviceAccount: create: true
		serviceType: "LoadBalancer"
		service: loadBalancerIP: "10.42.42.0"
		servers: [{
			zones: [{
				zone:    "."
				scheme:  "dns://"
				use_tcp: true
			}]
			port: 53
			plugins: [{
				name: "any"
			}, {
				name: "debug"
			}, {
				name: "errors"
			}, {
				name: "health"
			}, {
				name: "ready"
			}, {
				name:       "prometheus"
				parameters: "0.0.0.0:9153"
			}, {
				name: "loadbalance"
			}, {
				name:        "k8s_gateway"
				parameters:  "localhost"
				configBlock: "resources HTTPRoute"
			}, {
				name:       "cache"
				parameters: "30 localhost"
			}, {
				name:       "forward"
				parameters: "ballard.coldencullen.com 10.0.1.1"
			}, {
				name:       "forward"
				parameters: "mission.coldencullen.com 10.1.1.1"
			}, {
				name:       "forward"
				parameters: ". tls://1.1.1.1 tls://1.0.0.1"
				configBlock: """
					tls
					tls_servername one.one.one.one
					"""
			}]
		}]
	})
}

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
			kind:      values.kind
			name:      values.metadata.name
			valuesKey: "values"
		}]
	}
}
