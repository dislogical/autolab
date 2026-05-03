package autolab

Resources: "rook-ceph": #HelmDeployment & {
	#url:     "https://charts.rook.io/release"
	#chart:   "rook-ceph"
	#version: "v1.19.5"

	#releaseName: "rook-ceph-operator"
	#values: {
		monitoring: enabled:     true
		serviceMonitor: enabled: true
	}
}
