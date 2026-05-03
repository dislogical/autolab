package autolab

Manifests: metallb: "https://github.com/metallb/metallb//config/crd?ref=\(Resources.LoadBalancer.#version)"

Resources: LoadBalancer: {
	Namespace: LoadBalancer: metadata: labels: {
		"pod-security.kubernetes.io/enforce": "privileged"
		"pod-security.kubernetes.io/audit":   "privileged"
		"pod-security.kubernetes.io/warn":    "privileged"
	}

	#HelmDeployment & {
		#url:     "https://metallb.github.io/metallb"
		#chart:   "metallb"
		#version: "v0.15.3"
		#crds:    "Skip"
		#values: {
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
