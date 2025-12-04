package holos

holos: LoadBalancer.BuildPlan

LoadBalancer: #Helm & {
	Namespace: "load-balancer"
	KustomizeConfig: Kustomization: namespace: LoadBalancer.Resources.Namespace.load_balancer.metadata.name

	Chart: {
		name:    "metallb"
		release: "metallb"
		version: "0.15.3"
		repository: {
			name: "metallb"
			url:  "https://metallb.github.io/metallb"
		}
	}
	Values: {
		speaker: {
			frr: enabled: false
		}
		// prometheus: {
		// 	serviceAccount: "prometheus-kube-prometheus-prometheus"
		// 	namespace:      "metrics"
		// 	serviceMonitor: enabled: true
		// }
	}
}

LoadBalancer: Resources: {
	Namespace: load_balancer: {
		metadata: {
			name: "load-balancer"
			labels: {
				"pod-security.kubernetes.io/enforce": "privileged"
				"pod-security.kubernetes.io/audit":   "privileged"
				"pod-security.kubernetes.io/warn":    "privileged"
			}
		}
	}

	IPAddressPool: default: {
		apiVersion: "metallb.io/v1beta1"
		metadata: namespace: "load-balancer"
		spec: {
			avoidBuggyIPs: true
			addresses: ["10.0.1.0/29"]
		}
	}
	L2Advertisement: default: {
		apiVersion: "metallb.io/v1beta1"
		metadata: namespace: "load-balancer"
		spec: ipAddressPools: [IPAddressPool.default.metadata.name]
	}
}
