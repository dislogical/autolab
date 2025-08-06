package holos

import (
	"encoding/yaml"

	"tool/file"
	"tool/exec"

	"github.com/dislogical/autolab/cuebe"
)

let Envs = ["dev", "prod"]

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

	let Taskfile = cuebe.#Taskfile & {
		#Envs: Envs
		#Components: [
			for _, component in components {
				component & yaml.Unmarshal(describe[component.name].stdout)
			},
		]
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

			// There's an issue where task run through cue doesn't work in parallel
			"-C1",
		]

		env: {
			TASK_TEMP_DIR: ".cuebe/task"
		}

		stdin: yaml.Marshal(Taskfile)
	}

	write: file.Create & {
		$after: [
			for _, component in components {
				describe[component.name]
			},
		]

		filename: "Taskfile.yaml"
		contents: yaml.Marshal(Taskfile)
	}
}
