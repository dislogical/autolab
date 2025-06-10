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
		kubernetes_dashboard: _
		load_balancer:        _
	}
}

// Render a Platform resource for holos to process
holos: Platform.Resource
