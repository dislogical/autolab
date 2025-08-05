package holos

import (
	"encoding/yaml"

	// "tool/cli"
	"tool/exec"
)

let Envs = ["dev", "prod"]

let Generator = {
	// Inputs
	generator: {
		kind:   "Resources" | "Helm"
		output: string
	}
	srcDir: string
	outDir: string

	let outPath = "\(outDir)/\(generator.output)"

	// Outputs
	task: {
		sources: [
			srcDir + "/*.cue"
		]
		generates: [
			outPath,
		]
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
	}
} | {
	generator: kind: "Helm"
	outDir: string

	task: cmds: [
		"echo '\(yaml.Marshal(generator))'",
	]
})

let Taskfile = {
	// Input
	Components: [...]

	version: 3
	silent:  true
	output:  "prefixed"

	tasks: {
		for _, env in Envs {
			let envDir = "deploy/\(env)"

			for _, component in Components {
				let artifact = component.spec.artifacts[0]

				for index, _generator in artifact.generators {
					"\(env):\(component.name):generator-\(index)": (Generator & {
						generator: _generator
						srcDir: component.path
						outDir:    "\(envDir)/\(component.path)"
					}).task
				}

				// Create <env>:<component> task that depends on all generators
				"\(env):\(component.name)": deps: [
					for index, _ in artifact.generators {
						"\(env):\(component.name):generator-\(index)"
					},
				]
			}

			// Create <env> task that depends on all components
			(env): deps: [
				for _, component in Components {
					"\(env):\(component.name)"
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
