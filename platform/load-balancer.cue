package autolab

let metalLbVersion = "v0.15.3"

Manifests: metallb: "https://github.com/metallb/metallb//config/crd?ref=\(metalLbVersion)"

Resources: LoadBalancer: {
	Namespace: LoadBalancer: metadata: labels: {
		"pod-security.kubernetes.io/enforce": "privileged"
		"pod-security.kubernetes.io/audit":   "privileged"
		"pod-security.kubernetes.io/warn":    "privileged"
	}

	HelmRepository: metallb: spec: {
		url: "https://metallb.github.io/metallb"
	}
	HelmRelease: metallb: spec: {
		chart: spec: {
			chart:   "metallb"
			version: metalLbVersion
			sourceRef: #ReferenceOf & {#Resource: HelmRepository.metallb}
		}
		values: {
			speaker: {
				frr: enabled: false
			}
			prometheus: {
				serviceAccount: "prometheus-kube-prometheus-prometheus"
				namespace:      Resources.Metrics.Namespace.Metrics.metadata.name
				serviceMonitor: enabled: true
			}
		}
	}

	IPAddressPool: default: {
		apiVersion: "metallb.io/v1beta1"
		spec: {
			avoidBuggyIPs: true
			addresses: ["10.0.1.0/29"]
		}
	}
	L2Advertisement: default: {
		apiVersion: "metallb.io/v1beta1"
		spec: ipAddressPools: [IPAddressPool.default.metadata.name]
	}
}
