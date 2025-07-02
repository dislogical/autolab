package holos

import (
	"strings"

	"github.com/holos-run/holos/api/author/v1alpha5:author"
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
		dns:                  _
		gateway:              _
		cert_manager:         _
		kubernetes_dashboard: _
		load_balancer:        _
		metrics:              _
		postgres:             _
		capacitor:            _
		headlamp:             _
	}
}

// Render a Platform resource for holos to process
holos: Platform.Resource

// Used to emit a kustomization file
kustomization: {
	apiVersion: "kustomize.config.k8s.io/v1beta1"
	kind:       "Kustomization"
	resources: [
		for component in Platform.Components {"./components/\(component.name)/\(component.name).gen.yaml"},
	]
}
