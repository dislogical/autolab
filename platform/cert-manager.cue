@experiment(explicitopen)
package autolab

let certManagerVersion = "v1.20.2"

Manifests: "cert-manager": "https://github.com/cert-manager/cert-manager/releases/download/\(certManagerVersion)/cert-manager.crds.yaml"

Resources: CertManager: {
	HelmRepository: "cert-manager": spec: {
		url: "https://charts.jetstack.io"
	}
	HelmRelease: "cert-manager": spec: {
		#DisableHelmCrds...
		chart: spec: {
			chart:   "cert-manager"
			version: certManagerVersion
			sourceRef: #ReferenceOf & {#Resource: HelmRepository["cert-manager"]}
		}
		values: {
			crds: enabled: false
			global: leaderElection: namespace: Resources.CertManager.Namespace.CertManager.metadata.name

			config: featureGates: ServerSideApply: true

			prometheus: servicemonitor: enabled: true
		}
	}

	Issuer: {
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
