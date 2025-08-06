package cuebe

import (
	"list"
	"path"
	"strings"
)

#Validator: {
	validator: {
		kind: "Command"
		inputs: [...string]
		...
	}
	srcDir: string
	outDir: string

	task: {
		sources: [
			"\(srcDir)/*.cue",
			for _, input in validator.inputs {
				"\(outDir)/\(path.Base(input))"
			},
		]
		...
	}
} & ({
	validator: {
		kind: "Command"
		command: {
			args: [...string]
		}
	}
	outDir: string

	task: {
		cmds: [
			"echo Validating with \(validator.command.args[0])...",
			for input in validator.inputs {
				// Need to wrap this in {{ `` }} so the Task templating doesn't pick anything up
				"""
				{{ `\(strings.Join(list.Concat([validator.command.args, ["\(outDir)/\(path.Base(input))"]]), " "))` }}
				"""
			},
		]
	}
})
