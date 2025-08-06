package cuebe

import (
	"list"
	"path"
	"strings"

	"github.com/holos-run/holos/api/core/v1alpha5:core"
)

#Validator: {
	#validator: core.#Validator
	#srcDir:    string
	#outDir:    string

	sources: [
		"\(#srcDir)/*.cue",
		for _, input in #validator.inputs {
			"\(#outDir)/\(path.Base(input))"
		},
	]

	...
} & ({
	#validator: kind: "Command"
	#outDir: string

	cmds: [
		"echo Validating with \(#validator.command.args[0])...",
		for input in #validator.inputs {
			// Need to wrap this in {{ `` }} so the Task templating doesn't pick anything up
			"""
			{{ `\(strings.Join(list.Concat([#validator.command.args, ["\(#outDir)/\(path.Base(input))"]]), " "))` }}
			"""
		},
	]
})
