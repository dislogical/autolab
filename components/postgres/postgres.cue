package holos

import (
	"strings"

	"github.com/holos-run/holos/api/core/v1alpha5:core"
	"github.com/holos-run/holos/api/author/v1alpha5:author"
)

let _namespace = "postgres"
let _cluster_name = "cluster"

holos: core.#BuildPlan & Postgres.BuildPlan

Postgres: #ComponentConfig & {
	Resources: {
		Namespace: postgres: _

		NetworkPolicy: allow_webhooks: {
			apiVersion: "networking.k8s.io/v1"
			metadata: {
				name:      "allow-webhooks"
				namespace: _namespace
			}
			spec: {
				namespaceSelector: matchLabels: "kubernetes.io/metadata.name": _namespace
				podSelector: matchLabels: "app.kubernetes.io/name":            "cloudnative-pg" // Matches the Operator pod
				policyTypes: [
					"Ingress"
				]
				ingress: [{
					ports: [{
						port: 9443
					}]
				}]
			}
		}
	}

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
					enableHooks: true
				}
			},
			{
				kind:   "Helm"
				output: "helm.cluster.gen.yaml"
				helm: core.#Helm & {
					namespace: _namespace
					chart: {
						name:    _cluster_name
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
								"tilt.dev/depends-on": strings.Join([
									"postgres-cloudnative-pg:Deployment:\(_namespace)",
									"cnpg-mutating-webhook-configuration:MutatingWebhookConfiguration:default",
									"allow-webhooks:NetworkPolicy:\(_namespace)"
									], ",")
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
