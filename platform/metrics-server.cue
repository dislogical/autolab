package autolab

Resources: "kube-system": {
	HelmRepository: "metrics-server": spec: {
		url: "https://kubernetes-sigs.github.io/metrics-server/"
	}
	HelmRelease: "metrics-server": spec: {
		chart: spec: {
			chart:   "metrics-server"
			version: "3.13.0"
			sourceRef: #ReferenceOf & {#Resource: HelmRepository["metrics-server"]}
		}
		values: {
			args: [
				"--kubelet-insecure-tls",
			]
			metrics: enabled: true
			serviceMonitor: enabled: true
		}
	}
}
