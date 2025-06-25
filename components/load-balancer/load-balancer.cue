package holos

holos: LoadBalancer.BuildPlan

LoadBalancer: #Helm & {
	Namespace: "load-balancer"
	KustomizeConfig: Kustomization: namespace: LoadBalancer.Resources.Namespace.load_balancer.metadata.name

	Chart: {
		name:    "metallb"
		release: "metallb"
		version: "0.15.2"
		repository: {
			name: "metallb"
			url:  "https://metallb.github.io/metallb"
		}
	}
	Values: {
		controller: {
			repository: "quay.io/metallb/controller"
			tag:        "v0.15.2"
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
		spec: {
			avoidBuggyIPs: true
			addresses: ["10.0.1.0/29"]
		}
	}
	L2Advertisement: default: {
		apiVersion: "metallb.io/v1beta1"
		metadata: namespace: "load-balancer"
		spec: ipAddressPools: ["default-pool"]
	}
}
