package autolab

Resources: Postgres: {
	HelmRepository: "cloudnative-pg": spec: {
		url: "https://cloudnative-pg.github.io/charts"
	}

	HelmRelease: "cloudnative-pg": spec: {
		chart: spec: {
			chart:   "cloudnative-pg"
			version: "0.28.0"
			sourceRef: #ReferenceOf & {#Resource: HelmRepository["cloudnative-pg"]}
		}
		values: {
			cluster: {
				instances: 2
				monitoring: enabled: true
			}
		}
	}
}
