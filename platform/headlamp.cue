package autolab

import "encoding/yaml"

Resources: Headlamp: {
	HelmRepository: headlamp: spec: {
		url: "https://kubernetes-sigs.github.io/headlamp"
	}
	HelmRelease: headlamp: spec: {
		chart: spec: {
			chart:   "headlamp"
			version: "0.41.0"
			sourceRef: #ReferenceOf & {#Resource: HelmRepository.headlamp}
		}
		values: {
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
						version: "0.6.0"
					}, {
						name:    "cert-manager"
						source:  "https://artifacthub.io/packages/headlamp/headlamp-plugins/headlamp_cert-manager"
						version: "0.1.0"
					}, {
						name:    "kompose"
						source:  "https://artifacthub.io/packages/headlamp/headlamp-plugins/headlamp_kompose"
						version: "0.1.1-beta-1"
					}]
				})
			}
		}
	}

	HTTPRoute: headlamp: {
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
