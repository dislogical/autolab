package holos

holos: LoadBalancer.BuildPlan

LoadBalancer: #Helm & {
	Namespace: "kubernetes-dashboard"

	Chart: {
		name:    "kubernetes-dashboard"
		version: "7.13.0"
		repository: {
			name: "kubernetes-dashboard"
			url:  "https://kubernetes.github.io/dashboard"
		}
	}
	Values: {
		controller: {
			repository: "quay.io/metallb/controller"
			tag:        "v0.14.9"
		}
		speaker: {
			image: {
				repository: "quay.io/metallb/speaker"
				tag:        "v0.15.2@sha256:260c9406f957c0830d4e6cd2e9ac8c05e51ac959dd2462c4c2269ac43076665a"
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

LoadBalancer: Resources: {
	Namespace: load_balancer: {
		metadata: name: "load-balancer"
	}

	IPAddressPool: default: {
		apiVersion: "metallb.io/v1beta1"
		metadata: namespace: "load-balancer"
		spec: addresses: ["10.42.42.0/24"]
	}
	L2Advertisement: default: {
		apiVersion: "metallb.io/v1beta1"
		metadata: namespace: "load-balancer"
		spec: ipAddressPools: ["default-pool"]
	}
}
