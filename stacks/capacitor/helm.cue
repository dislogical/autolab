package autolab

import (
	ocirepository "github.com/orvis98/cue-schemas/source.toolkit.fluxcd.io/ocirepository/v1beta2"
)

export: capacitor: {
	let _interval = "24h"

	repo: ocirepository.#OCIRepository & {
		metadata: {
			name:      "capacitor"
			namespace: "flux-system"
		}
		spec: {
			interval: _interval
			url:      "oci://ghcr.io/gimlet-io/capacitor-manifests"
			ref: semver: ">=0.1.0"
			verify: {
				provider: "cosign"
				matchOIDCIdentity: [{
					issuer:  "https://token.actions.githubusercontent.com"
					subject: "^https://github.com/gimlet-io/capacitor.*$"
				}]
			}
		}
	}
	kustomization: {
		apiVersion: "kustomize.toolkit.fluxcd.io/v1"
		kind:       "Kustomization"
		metadata: {
			name:      "capacitor"
			namespace: "flux-system"
		}
		spec: {
			targetNamespace: "flux-system"
			interval:        _interval
			prune:           true
			path:            "./"
			sourceRef: {
				kind: repo.kind
				name: repo.metadata.name
			}
		}
	}
}
