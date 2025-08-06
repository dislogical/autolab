package cuebe

import (
	"encoding/yaml"

	kustomize "sigs.k8s.io/kustomize/api/types"
)

#Taskfile: {
	// Input
	#Envs: [...string]
	#Components: [...]

	version: 3
	silent:  true
	output:  "prefixed"
	run:     "once"

	tasks: {
		// Make shared tasks to pull the helm charts
		for _, component in #Components
		for _, artifact in component.spec.artifacts
		for _, generator in artifact.generators
		if generator.kind == "Helm" {
			(#HelmPull & {#Generator: generator}).tasks
		}

		// Make tasks to render the components
		for _, env in #Envs {
			let envDir = ".cuebe/\(env)"

			for _, component in #Components {
				let taskName = "component:\(env):\(component.name)"
				let _outDir = "\(envDir)/\(component.path)"
				let artifact = component.spec.artifacts[0]

				for index, generator in artifact.generators {
					"\(taskName):generator-\(index)": #Generator & {
						#generator: generator
						#srcDir:    component.path
						#outDir:    _outDir
					}
				}

				for index, transformer in artifact.transformers {
					"\(taskName):transformer-\(index)": #Transformer & {
						#transformer: transformer
						#srcDir:      component.path
						#outDir:      _outDir
					} & {
						deps: [
							for genIndex, _ in artifact.generators {
								"\(taskName):generator-\(genIndex)"
							},
						]
					}
				}

				for index, validator in artifact.validators {
					"\(taskName):validator-\(index)": #Validator & {
						#validator: validator
						#srcDir:    component.path
						#outDir:    _outDir
					} & {
						deps: [
							for transIndex, _ in artifact.transformers {
								"\(taskName):transformer-\(transIndex)"
							},
						]
					}
				}

				// Create <env>:<component> task that depends on all transformers
				"\(taskName)": deps: [
					for index, _ in artifact.transformers {
						"\(taskName):transformer-\(index)"
					},
					for index, _ in artifact.validators {
						"\(taskName):validator-\(index)"
					},
				]
			}

			// Create <env> task that depends on all components
			(env): {
				deps: [
					for _, component in #Components {
						"component:\(env):\(component.name)"
					},
				]
				let kustomization = kustomize.#Kustomization & {
					apiVersion: kustomize.#KustomizationVersion
					kind:       kustomize.#KustomizationKind
					resources: [
						for _, component in #Components
						for _, artifact in component.spec.artifacts {
							artifact.artifact
						},
					]
				}
				cmds: [
					"echo Kustomizing...",
					"echo '\(yaml.Marshal(kustomization))' > \(envDir)/kustomization.yaml",
					"kustomize build \(envDir) > \(envDir)/kustomized.yaml",
				]
			}
		}

		default: {
			deps: [for _, env in #Envs {env}]
			cmd: "echo Done!"
		}
	}
}
