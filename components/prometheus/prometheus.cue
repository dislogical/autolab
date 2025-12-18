package holos

holos: Prometheus.BuildPlan

Prometheus: #Helm & {
	Chart: {
		name:    "prometheus-operator-crds"
		version: "25.0.0"
		repository: {
			name: "prometheus-community"
			url:  "https://prometheus-community.github.io/helm-charts"
		}
	}
	KustomizeConfig: Kustomization: namespace: "prometheus"
}
