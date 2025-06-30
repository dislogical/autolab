package holos

holos: CertManager.BuildPlan

CertManager: #Helm & {
	Namespace: "gateway"

	Chart: {
		name:    "cert-manager"
		version: "v1.18.1"
		repository: {
			name: "cert-manager"
			url:  "https://charts.jetstack.io"
		}
	}
	Values: {
		crds: enabled: true
		global: leaderElection: namespace: Namespace
		image: {
			registry:   "quay.io"
			repository: "jetstack/cert-manager-controller"
			tag:        "v1.17.2"
		}
		webhook: image: {
			registry:   "quay.io"
			repository: "jetstack/cert-manager-webhook"
			tag:        "v1.17.2"
		}
		acmesolver: image: {
			registry:   "quay.io"
			repository: "jetstack/cert-manager-acmesolver"
			tag:        "v1.17.2"
		}
		prometheus: {
			servicemonitor: enabled: true
			podmonitor: enabled:     false
		}
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
