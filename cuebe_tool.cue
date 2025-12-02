package holos

import (
	"encoding/yaml"

	"tool/exec"

	"github.com/dislogical/autolab/cuebe"
)

let Envs = ["dev", "prod"]

command: build: {
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
		for _, env in Envs
		for _, component in components {
			(env): (component.name): exec.Run & {
				$after: project

				cmd: [
					"cue", "export", "./\(component.path)",
					"--out=yaml",
					"-t", "holos_component_name=" + component.name,
					"-t", "holos_component_path=" + component.path,
					"-t", "env=" + env,
					"-e", "holos",
				]

				stdout:     string
				descriptor: yaml.Unmarshal(stdout)
			}
		}
	}

	let Taskfile = cuebe.#Taskfile & {
		for _, env in Envs {
			#Envs: (env): [
				for _, component in components {
					component & describe[env][component.name].descriptor
				},
			]
		}
	}

	task: exec.Run & {
		cmd: [
			"task",
			"-t", "-",
		]

		stdin: yaml.Marshal(Taskfile)
	}
}
