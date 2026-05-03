package autolab

Resources: "kube-system": #HelmDeployment & {
	#url:     "https://kubernetes-sigs.github.io/metrics-server"
	#chart:   "metrics-server"
	#version: "3.13.0"
	#values: {
		args: [
			"--kubelet-insecure-tls",
		]
		metrics: enabled:        true
		serviceMonitor: enabled: true
	}
}
