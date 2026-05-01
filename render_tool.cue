package autolab

import (
	"encoding/yaml"

	"tool/file"

	kustomize "sigs.k8s.io/kustomize/api/types"
)

command: render: {
	let outDir = "./render/\(env.name)"

	mkdir: file.Mkdir & {
		path:          outDir
		createParents: true
	}
	writeNamespaces: {
		for namespace, resources in Resources {
			(namespace): file.Create & {
				$after: [mkdir]

				filename: "\(outDir)/\(namespace).yaml"
				contents: yaml.MarshalStream([
					for _, type in resources
					for _, resource in type {
						resource
					},
				])
			}
		}
	}
	writeKustomize: file.Create & {
		$after: [mkdir]

		filename: "\(outDir)/kustomization.yaml"
		contents: yaml.Marshal(kustomize.#Kustomization & {
			resources: [
				for _, url in Manifests {url},
				for namespace, _ in Resources {"\(namespace).yaml"},
			]
		})
	}
}
