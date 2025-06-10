package holos

holos: Postgres.BuildPlan

Postgres: #Helm & {
	Namespace: "postgres"

	Chart: {
		name:    "cloudnative-pg"
		version: "0.24.0"
		repository: {
			name: "cloudnative-pg"
			url:  "https://cloudnative-pg.github.io/charts"
		}
	}
	Values: {
		cluster: {
			instances: 2
			monitoring: enabled: true
		}
	}
}
