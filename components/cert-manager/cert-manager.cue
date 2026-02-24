package holos

holos: CertManager.BuildPlan

CertManager: #Helm & {
	Namespace: "gateway"

	Chart: {
		name:    "cert-manager"
		version: "v1.19.4"
		repository: {
			name: "cert-manager"
			url:  "https://charts.jetstack.io"
		}
	}
	Values: {
		crds: enabled: true
		global: leaderElection: namespace: Namespace

		config: featureGates: ServerSideApply: true

		prometheus: servicemonitor: enabled: true
	}
}

CertManager: {
	Resources: Issuer: {
		"self-signed": {
			metadata: namespace: CertManager.Namespace
			spec: selfSigned: {}
		}
		"acme-staging": {
			metadata: namespace: CertManager.Namespace
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
			metadata: namespace: CertManager.Namespace
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
