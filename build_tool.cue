package autolab

import (
	"encoding/yaml"
	"list"
	"tool/cli"
	"tool/exec"
	"tool/file"

	"github.com/dislogical/autolab/stacks/dns"
)

let _yaml = yaml.MarshalStream([for key, value in dns {value}])
_pass_yaml: {
	stdin: _yaml
}
let _files = (file.Glob & {
	glob: "stacks/**/*.cue"
}).files

command: {
	export: task: print: cli.Print & {
		text: _yaml
	}
	lint: task: {
		fmt: exec.Run & {
			cmd: list.Concat([[
				"cue",
				"fmt",
				"--check",
			], _files])
		}
		vet: exec.Run & {
			cmd: [
				"cue",
				"vet",
				"-c",
				"-v",
				"github.com/dislogical/autolab/stacks/dns",
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
