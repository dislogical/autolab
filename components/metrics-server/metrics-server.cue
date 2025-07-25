package holos

holos: MetricsServer.BuildPlan

MetricsServer: #Helm & {
	Chart: {
		name:    "metrics-server"
		version: "3.13.0"
		repository: {
			name: "metrics-server"
			url:  "https://kubernetes-sigs.github.io/metrics-server/"
		}
	}
	Values: {
		args: [
			"--kubelet-insecure-tls",
		]
	}
	KustomizeConfig: Kustomization: namespace: "kube-system"
}
