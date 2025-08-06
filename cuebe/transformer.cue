package cuebe

import (
	"path"
	"encoding/yaml"

	kustomize "sigs.k8s.io/kustomize/api/types"
)

#Transformer: {
	transformer: {
		kind:   "Kustomize"
		output: string
		inputs: [...string]
		...
	}
	srcDir: string
	outDir: string

	task: {
		sources: [
			"\(srcDir)/*.cue",
			for _, input in transformer.inputs {
				"\(outDir)/\(input)"
			},
		]
		...
	}
} & ({
	transformer: {
		kind:          "Kustomize"
		kustomization: kustomize.#Kustomization
	}
	outDir: string

	// Transformer output includes the componentPath
	let outputFile = path.Base(transformer.output)

	task: {
		cmds: [
			"echo Kustomizing...",
			"echo '\(yaml.Marshal(transformer.kustomize.kustomization))' > \(outDir)/kustomization.yaml",
			"kustomize build \(outDir) > \(outDir)/\(outputFile)",
		]

		generates: [
			"\(outDir)/kustomization.yaml",
			"\(outDir)/\(outputFile)",
		]
	}
})
