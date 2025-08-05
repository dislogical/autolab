package holos

import (
	"path"
	"encoding/yaml"

	// "tool/cli"
	"tool/exec"
)

let Envs = ["dev", "prod"]

#HelmPull: {
	generator: {
		...
	}

	tasks: {
		"helm-pull:\(generator.helm.chart.repository.name):\(generator.helm.chart.name):\(generator.helm.chart.version)": {

			let dest = "deploy/helm-cache/\(generator.helm.chart.repository.name)/\(generator.helm.chart.name)/\(generator.helm.chart.version)"

			// This is here because multiple tasks may be merged by cue, but we need the repo urls to be the same if that's the case.
			_repoUrl: generator.helm.chart.repository.url

			// Don't try to run this task more than once per `task` invocation
			run: "once"
			cmds: [
				"echo Pulling...",
				"mkdir -p \(dest)",
				"""
					echo '#!/usr/bin/env bash
					helm pull \(generator.helm.chart.name) \\
						--repo \(generator.helm.chart.repository.url) \\
						--version \(generator.helm.chart.version) \\
						--destination \(dest) \\
						--untar' > \(dest)/pull.sh
					""",
				"chmod +x \(dest)/pull.sh",
				"\(dest)/pull.sh",
			]

			sources: [
				"\(dest)/pull.sh",
			]
			generates: [
				"\(dest)/\(generator.helm.chart.name)/Chart.yaml",
			]
		}
	}
}

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
	generator: kind: "Helm"
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
				./deploy/helm-cache/\(generator.helm.chart.repository.name)/\(generator.helm.chart.name)/\(generator.helm.chart.version)/\(generator.helm.chart.name) \\
				--values \(outDir)/helm.\(generator.helm.chart.release).values.yaml \\
				--atomic \\
				{{if not \(generator.helm.enableHooks)}}--no-hooks{{end}} \\
				> \(outDir)/\(generator.output)
			""",
		]
	}
})

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
	transformer: kind: "Kustomize"
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

let Taskfile = {
	// Input
	Components: [...]

	version: 3
	silent:  true
	output:  "prefixed"

	tasks: {
		// Make shared tasks to pull the helm charts
		for _, component in Components
		for _, artifact in component.spec.artifacts
		for _, _generator in artifact.generators
		if _generator.kind == "Helm"
		let helmPull = (#HelmPull & {generator: _generator}) {
			helmPull.tasks
		}

		// Make tasks to render the components
		for _, env in Envs {
			let envDir = "deploy/\(env)"

			for _, component in Components {
				let taskName = "component:\(env):\(component.name)"
				let _outDir = "\(envDir)/\(component.path)"
				let artifact = component.spec.artifacts[0]

				for index, _generator in artifact.generators {
					"\(taskName):generator-\(index)": (#Generator & {
						generator: _generator
						srcDir:    component.path
						outDir:    _outDir
					}).task
				}

				for index, _transformer in artifact.transformers {
					"\(taskName):transformer-\(index)": (#Transformer & {
						transformer: _transformer
						srcDir:      component.path
						outDir:      _outDir
					}).task & {
						deps: [
							for index, _ in artifact.generators {
								"\(taskName):generator-\(index)"
							},
						]
					}
				}

				// Create <env>:<component> task that depends on all transformers
				"\(taskName)": deps: [
					for index, _ in artifact.transformers {
						"\(taskName):transformer-\(index)"
					},
				]
			}

			// Create <env> task that depends on all components
			(env): deps: [
				for _, component in Components {
					"component:\(env):\(component.name)"
				},
			]
		}

		default: {
			deps: [for _, env in Envs {env}]
			cmd: "echo Done!"
		}
	}
}

command: task: {
	project: exec.Run & {
		cmd: [
			"cue", "export", "./platform",
			"--out=yaml",
			"-e", "holos",
		]
		stdout: string
	}

	let project_def = yaml.Unmarshal(project.stdout)
	let components = project_def.spec.components

	describe: {
		for _, component in components {
			(component.name): exec.Run & {
				$after: project

				cmd: [
					"cue", "export", "./\(component.path)",
					"--out=yaml",
					"-t", "holos_component_name=" + component.name,
					"-t", "holos_component_path=" + component.path,
					"-e", "holos",
				]
				stdout: string
			}
		}
	}

	task: exec.Run & {
		$after: [
			for _, component in components {
				describe[component.name]
			},
		]

		cmd: [
			"task",
			"-t", "-",

			"-C1",
		]

		stdin: yaml.Marshal(Taskfile & {
			Components: [
				for _, component in components {
					component & yaml.Unmarshal(describe[component.name].stdout)
				},
			]
		})
	}

	// print: cli.Print & {
	// 	$after: [
	// 		for _, component in components {
	// 			describe[component.name]
	// 		},
	// 	]

	// 	text: yaml.Marshal(Taskfile & {
	// 		Components: [
	// 			for _, component in components {
	// 				yaml.Unmarshal(describe[component.name].stdout)
	// 			},
	// 		]
	// 	})
	// }
}
