package holos

import (
	"github.com/holos-run/holos/api/core/v1alpha5:core"
	"github.com/holos-run/holos/api/author/v1alpha5:author"
)

let _namespace = "postgres"

holos: core.#BuildPlan & Postgres.BuildPlan

Postgres: #ComponentConfig & {
	Resources: Namespace: postgres: _

	KustomizeConfig: author.#KustomizeConfig

	Artifacts: HolosComponent: {
		artifact: _
		generators: [
			{
				kind:   "Helm"
				output: "helm.postgres.gen.yaml"
				helm: core.#Helm & {
					namespace: _namespace
					chart: {
						name:    "cloudnative-pg"
						release: "postgres"
						version: "0.24.0"
						repository: {
							name: "cloudnative-pg"
							url:  "https://cloudnative-pg.github.io/charts"
						}
					}
					values: {
						cluster: {
							instances: 2
							monitoring: enabled: true
						}
					}
					enableHooks: true
				}
			},
			{
				kind:   "Helm"
				output: "helm.cluseter.gen.yaml"
				helm: core.#Helm & {
					namespace: _namespace
					chart: {
						name:    "cluster"
						release: "cluster"
						version: "0.3.1"
						repository: {
							name: "cloudnative-pg"
							url:  "https://cloudnative-pg.github.io/charts"
						}
					}
					values: {
						cluster: {
							instances: 2
							postgresql: parameters: {
								max_connections: "200"
								shared_buffers:  "2GB"
							}
							initdb: owner: "system"

							annotations: {
								"tilt.dev/depends-on": "postgres-cloudnative-pg:Deployment:\(_namespace)"
							}
						}

						monitoring: enabled: true
					}
					enableHooks: true
				}
			},
			{
				kind:      "Resources"
				output:    "resources.gen.yaml"
				resources: Resources
			},
		]
		transformers: [
			core.#Transformer & {
				kind: "Kustomize"
				inputs: [for x in generators {x.output}]
				output: artifact
				kustomize: kustomization: KustomizeConfig.Kustomization & {
					resources: [
						for x in generators {x.output},
						for x in KustomizeConfig.Files {x.Source},
						for x in KustomizeConfig.Resources {x.Source},
					]
				}
			},
		]
	}
}
