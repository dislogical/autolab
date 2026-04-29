package autolab

Resources: Metrics: {
	GitRepository: "kube-prometheus": spec: {
		url: "https://github.com/prometheus-operator/kube-prometheus"
		ref: tag: "v0.17.0"
	}
	Kustomization: "kube-prometheus-crds": spec: {
		sourceRef: #ReferenceOf & {#Resource: GitRepository["kube-prometheus"]}
		path: "manifests/setup"
	}
	Kustomization: "kube-prometheus": spec: {
		sourceRef: #ReferenceOf & {#Resource: GitRepository["kube-prometheus"]}
		path: "manifests"
		dependsOn: [{
			name: "kube-prometheus-crds"
		}]
	}
}
