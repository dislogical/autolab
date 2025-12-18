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
		metrics_server: _
		dns:            _
		gateway:        _
		cert_manager:   _
		load_balancer:  _
		postgres:       _
		headlamp:       _
		prometheus:     _
	}
}

// Render a Platform resource for holos to process
holos: Platform.Resource
