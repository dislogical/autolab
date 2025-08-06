package cuebe

import (
	"path"
	"encoding/yaml"

	"github.com/holos-run/holos/api/core/v1alpha5:core"
)

#Transformer: {
	#transformer: core.#Transformer
	#srcDir:      string
	#outDir:      string

	sources: [
		"\(#srcDir)/*.cue",
		for _, input in #transformer.inputs {
			"\(#outDir)/\(input)"
		},
	]

	...
} & ({
	#transformer: kind: "Kustomize"
	#outDir: string

	// Transformer output includes the componentPath
	let outputFile = path.Base(#transformer.output)

	cmds: [
		"echo Kustomizing...",
		"echo '\(yaml.Marshal(#transformer.kustomize.kustomization))' > \(#outDir)/kustomization.yaml",
		"kustomize build \(#outDir) > \(#outDir)/\(outputFile)",
	]

	generates: [
		"\(#outDir)/kustomization.yaml",
		"\(#outDir)/\(outputFile)",
	]
})
