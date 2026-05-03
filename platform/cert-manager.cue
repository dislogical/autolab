@experiment(explicitopen)
package autolab

Manifests: "cert-manager": "https://github.com/cert-manager/cert-manager/releases/download/\(Resources["cert-manager"].#version)/cert-manager.crds.yaml"

Resources: "cert-manager": {
	#HelmDeployment & {
		#url:     "https://charts.jetstack.io"
		#chart:   "cert-manager"
		#version: "v1.20.2"
		#crds:    "Skip"
		#values: {
			crds: enabled: false
			global: leaderElection: namespace: "cert-manager"

			config: featureGates: ServerSideApply: true

			prometheus: servicemonitor: enabled: true
		}
	}

	ClusterIssuer: {
		"self-signed": {
			spec: selfSigned: {}
		}
		"acme-staging": {
			spec: acme: {
				server: "https://acme-staging-v02.api.letsencrypt.org/directory"
				privateKeySecretRef: {
					name: "acme-staging-account-key"
				}
				solvers: [{
					dns01: cloudflare: apiTokenSecretRef: {
						name: "cloudflare-api-token"
						key:  "api-token"
					}
				}]
			}
		}
		"acme-prod": {
			spec: acme: {
				server: "https://acme-v02.api.letsencrypt.org/directory"
				privateKeySecretRef: {
					name: "acme-prod-account-key"
				}
				solvers: [{
					dns01: cloudflare: apiTokenSecretRef: {
						name: "cloudflare-api-token"
						key:  "api-token"
					}
				}]
			}
		}
	}
}
