package autolab

Resources: "rook-ceph": {
	HelmRepository: "rook-ceph": spec: {
		url: "https://charts.rook.io/release"
	}

	HelmRelease: "rook-ceph-operator": spec: {
		chart: spec: {
			chart:   "rook-ceph"
			version: "v1.19.5"
			sourceRef: #ReferenceOf & {#Resource: HelmRepository["rook-ceph"]}
		}
		values: {
			monitoring: enabled: true
			serviceMonitor: enabled: true
		}
	}
}
