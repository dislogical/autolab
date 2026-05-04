package autolab

Resources: "cnpg-system": #HelmDeployment & {
	#url:     "https://cloudnative-pg.github.io/charts"
	#chart:   "cloudnative-pg"
	#version: "0.28.0"
	#values: {
		cluster: {
			instances: 2
			monitoring: enabled: true
		}
	}
}
