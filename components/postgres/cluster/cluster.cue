package holos

holos: Postgres.BuildPlan

Postgres: #Helm & {
	Namespace: "postgres"

	Chart: {
		name:    "cluster"
		version: "0.3.1"
		repository: {
			name: "cloudnative-pg"
			url:  "https://cloudnative-pg.github.io/charts"
		}
	}
	Values: {
		image: {
			repository: "ghcr.io/cloudnative-pg/cloudnative-pg"
			tag:        "1.26.0@sha256:927d7a8a1f32fe4c1e19665dc36d988f26207d7b7fce81b5e5af2ee0cd18aeef"
		}
	}
}
