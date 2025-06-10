package holos

import "github.com/holos-run/holos/api/author/v1alpha5:author"

Platform: author.#Platform & {
	Name: "default"

	Components: {
		[NAME=string]: {
			name: string | *NAME
			path: string | *"components/\(NAME)"
		}
	}

	Components: {
		dns:     _
		gateway: _
	}
}

// Render a Platform resource for holos to process
holos: Platform.Resource
