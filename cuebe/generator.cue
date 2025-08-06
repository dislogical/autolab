package cuebe

import (
	"strings"
	"encoding/yaml"
)

#Generator: {
	// Inputs
	generator: {
		kind:   "Resources" | "Helm"
		output: string
		...
	}
	srcDir: string
	outDir: string

	// Outputs
	task: {
		sources: [
			srcDir + "/*.cue",
		]
		...
	}
} & ({
	generator: kind: "Resources"
	outDir: string

	let outPath = "\(outDir)/\(generator.output)"

	task: {
		cmds: [
			"echo Exporting Resources",
			"mkdir -p \(outDir)",
			"echo '\(yaml.MarshalStream([
				for _, type in generator.resources
				for _, resource in type {
					resource
				},
			]))' > \(outPath)",
		]
		generates: [
			outPath,
		]
	}
} | {
	generator: {
		kind: "Helm"
		helm: {
			namespace: string | *""
			apiVersions: [...string]
			enableHooks: bool
			...
		}
	}
	outDir: string

	task: {
		deps: [
			"helm-pull:\(generator.helm.chart.repository.name):\(generator.helm.chart.name):\(generator.helm.chart.version)",
		]
		cmds: [
			"echo Rendering Chart...",
			"mkdir -p \(outDir)",
			"echo '\(yaml.Marshal(generator.helm.values))' > \(outDir)/helm.\(generator.helm.chart.release).values.yaml",
			"""
			helm template \(generator.helm.chart.release) \\
				./.cuebe/helm-cache/\(generator.helm.chart.repository.name)/\(generator.helm.chart.name)/\(generator.helm.chart.version)/\(generator.helm.chart.name) \\
				--values \(outDir)/helm.\(generator.helm.chart.release).values.yaml \\
				{{if "\(generator.helm.namespace)"}}--namespace \(generator.helm.namespace){{end}} \\
				--api-versions '\(strings.Join(generator.helm.apiVersions, ","))' \\
				--atomic \\
				{{if not \(generator.helm.enableHooks)}}--no-hooks{{end}} \\
				> \(outDir)/\(generator.output)
			""",
		]
	}
})
