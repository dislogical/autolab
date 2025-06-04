package autolab

import (
	"encoding/yaml"
	"tool/cli"
	"tool/exec"
)

export: {}
let _yaml = yaml.MarshalStream([for _, module in export for _, value in module {value}])
let _pass_yaml = {
	stdin: _yaml
}

command: {
	export: task: print: cli.Print & {
		text: _yaml
	}
	lint: task: {
		fmt: exec.Run & {
			cmd: [
				"cue",
				"fmt",
				"--check",
				"./...",
			]
		}
		vet: exec.Run & {
			cmd: [
				"cue",
				"vet",
				"-c",
				"-v",
				"./...",
			]
			after: fmt
		}
		lint: exec.Run & _pass_yaml & {
			cmd: [
				"kube-linter",
				"lint",
				"-",
			]
			after: vet
		}
		kubeconform: exec.Run & _pass_yaml & {
			cmd: [
				"kubeconform",
				"-schema-location", "default",
				"-schema-location", "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json",
				"-summary",
			]
			after: vet
		}
	}
}
