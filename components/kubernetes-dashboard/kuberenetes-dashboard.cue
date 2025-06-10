package holos

holos: KubernetesDashboard.BuildPlan

KubernetesDashboard: #Helm & {
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
		kong: enabled: false
	}
}

KubernetesDashboard: Resources: {
	Namespace: kubernetes_dashboard: {
		metadata: name: "kubernetes-dashboard"
	}

	HTTPRoute: kubernetes_dashboard: {
		metadata: namespace: "kubernetes-dashboard"
		spec: {
			parentRefs: [{
				name:      "traefik-gateway"
				namespace: "gateway"
			}]
			hostnames: ["kubernetes.localhost"]
			rules: [{
				backendRefs: [{
					kind: "Service"
					name: "kubernetes-dashboard-web"
					port: 8000
				}]
			}]
		}
	}
}
