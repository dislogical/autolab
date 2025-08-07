package cuebe

import (
	"strings"
	"encoding/yaml"

	"github.com/holos-run/holos/api/core/v1alpha5:core"
)

#Generator: {
	// Inputs
	#generator: core.#Generator
	#srcDir:    string
	#outDir:    string

	sources: [
		#srcDir + "/*.cue",
	]
	generates: [
		"\(#outDir)/\(#generator.output)",
	]

	...
} & ({
	#generator: kind: "Resources"
	#outDir: string

	let outPath = "\(#outDir)/\(#generator.output)"

	cmds: [
		"echo Exporting Resources",
		"mkdir -p \(#outDir)",
		"""
		cat << EOF > \(outPath)
		\(yaml.MarshalStream([
			for _, type in #generator.resources
			for _, resource in type {
				resource
			},
		]))
		EOF
		""",
	]
} | {
	#generator: kind: "Helm"
	#outDir: string

	let namespaceArg = [
		if #generator.helm.namespace != _|_ {
			"--namespace \(#generator.helm.namespace)"
		},
		"",
	][0]
	let apiVersionArg = [
		if #generator.helm.apiVersions != _|_ {
			"--api-versions '\(strings.Join(#generator.helm.apiVersions, ","))'"
		},
		"",
	][0]

	deps: [
		"helm-pull:\(#generator.helm.chart.repository.name):\(#generator.helm.chart.name):\(#generator.helm.chart.version)",
	]
	cmds: [
		"echo Rendering Chart...",
		"mkdir -p \(#outDir)",
		"""
		cat << EOF > \(#outDir)/helm.\(#generator.helm.chart.release).values.yaml
		\(yaml.Marshal(#generator.helm.values))
		EOF
		""",
		"""
		helm template \(#generator.helm.chart.release) \\
			./.cuebe/helm-cache/\(#generator.helm.chart.repository.name)/\(#generator.helm.chart.name)/\(#generator.helm.chart.version)/\(#generator.helm.chart.name) \\
			--values \(#outDir)/helm.\(#generator.helm.chart.release).values.yaml \\
			--include-crds \\
			\(namespaceArg) \\
			\(apiVersionArg) \\
			--atomic \\
			{{if not \(#generator.helm.enableHooks)}}--no-hooks{{end}} \\
			> \(#outDir)/\(#generator.output)
		""",
	]
})
