package holos

import (
	"strings"

	"github.com/holos-run/holos/api/author/v1alpha5:author"
	kustomize "sigs.k8s.io/kustomize/api/types"
)

Platform: author.#Platform & {
	Name: "default"

	Components: {
		[NAME=string]: {
			name: string | *strings.Replace(NAME, "_", "-", -1)
			path: string | *"components/\(name)"
		}
	}

	Components: {
		metrics_server: _
		dns:            _
		gateway:        _
		cert_manager:   _
		load_balancer:  _
		metrics:        _
		postgres:       _
		headlamp:       _
	}
}

// Render a Platform resource for holos to process
holos: Platform.Resource

// Used to emit a kustomization file
kustomization: kustomize.#Kustomization & {
	apiVersion: kustomize.#KustomizationVersion
	kind:       kustomize.#KustomizationKind
	resources: [
		for component in Platform.Components {"./components/\(component.name)/\(component.name).gen.yaml"},
	]
}
