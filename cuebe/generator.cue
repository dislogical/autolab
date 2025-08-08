package cuebe

#GeneratorTasks: {
	_Common: {
		requires: vars: [
			"GENERATOR",
			"SRC_DIR",
			"OUT_DIR",
		]
		sources: [
			"{{.SRC_DIR}}/*",
		]
		generates: [
			"{{.OUT_FILE}}/{{.GENERATOR.output}}",
		]
	}

	"generator:resources": _Common & {
		cmds: [
			"echo Exporting Resources from {{.SRC_DIR}}...",
			"mkdir -p {{.OUT_DIR}}",
			// """
			// cue export ./{{.SRC_DIR}} -o text:{{.OUT_FILE}}/{{.GENERATOR.output}} -e 'yaml.MarshalStream([
			// 		for artifact in holos.spec.artifacts
			// 		for generator in artifact.generators
			// 		if generator.kind == "Resources"
			// 		for _, resources in generator.resources
			// 		for _, resource in resources {
			// 			resource
			// 		}
			// 	])'
			// """,
			"""
				cat << EOF > {{.OUT_DIR}}/{{.GENERATOR.output}}
				{{- range $_, $kind := .GENERATOR.resources}}
				{{- range $_, $resource := $kind}}
				---
				{{toYaml $resource}}
				{{- end}}
				{{- end}}
				EOF
				""",
		]
	}

	"generator:helm": _Common & {
		cmds: [
			"echo Rendering Chart {{.GENERATOR.helm.chart.release}} from {{.SRC_DIR}}...",
			"mkdir -p {{.OUT_DIR}}",
			"""
				cat << EOF > {{.OUT_DIR}}/helm.{{.GENERATOR.helm.chart.release}}.values.yaml

				{{toYaml .GENERATOR.helm.values}}

				EOF
				""",
			"""
				helm template {{.GENERATOR.helm.chart.release}} \\
					./.cuebe/helm-cache/{{.GENERATOR.helm.chart.repository.name}}/{{.GENERATOR.helm.chart.name}}/{{.GENERATOR.helm.chart.version}}/{{.GENERATOR.helm.chart.name}} \\
					--values {{.OUT_DIR}}/helm.{{.GENERATOR.helm.chart.release}}.values.yaml \\
					--include-crds \\
					{{if .GENERATOR.helm.namespace}}--namespace {{.GENERATOR.helm.namespace}}{{end}} \\
					{{if .GENERATOR.helm.apiVersions}}--api-versions '{{.GENERATOR.helm.apiVersions | join ","}}'{{end}} \\
					--atomic \\
					{{if not .GENERATOR.helm.enableHooks}}--no-hooks{{end}} \\
					> {{.OUT_DIR}}/{{.GENERATOR.output}}
				""",
		]
	}
}
