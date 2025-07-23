package holos

import "encoding/yaml"

holos: Headlamp.BuildPlan

Headlamp: #Helm & {
	Chart: {
		name:    "headlamp"
		version: "0.33.0"
		repository: {
			name: "headlamp"
			url:  "https://kubernetes-sigs.github.io/headlamp"
		}
	}
	Values: {
		config: {
			watchPlugins: true
			extraArgs: [
				"-otlp-endpoint=''",
			]
		}

		pluginsManager: {
			enabled: true
			configContent: yaml.Marshal({
				installOptions: {
					parallel:      true
					maxConcurrent: 2
				}
				plugins: [{
					name:    "flux"
					source:  "https://artifacthub.io/packages/headlamp/headlamp-plugins/headlamp_flux"
					version: "0.3.0"
				}, {
					name:    "cert-manager"
					source:  "https://artifacthub.io/packages/headlamp/headlamp-plugins/headlamp_cert-manager"
					version: "0.1.0"
				}, {
					name:    "kompose"
					source:  "https://artifacthub.io/packages/headlamp/headlamp-plugins/headlamp_kompose"
					version: "0.1.0-beta-1"
				}]
			})
		}
	}
	KustomizeConfig: Kustomization: namespace: Headlamp.Resources.Namespace.headlamp.metadata.name
}

Headlamp: {
	Resources: {
		Namespace: headlamp: _

		HTTPRoute: headlamp: {
			metadata: namespace: Namespace.headlamp.metadata.name
			spec: {
				parentRefs: [{
					kind:      "Gateway"
					name:      "traefik-gateway"
					namespace: "gateway"
				}]
				hostnames: ["services.\(env.external_url)"]
				rules: [{
					backendRefs: [{
						kind: "Service"
						name: "headlamp"
						port: 80
					}]
				}]
			}
		}
	}
}
