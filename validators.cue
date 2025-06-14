package holos

#ComponentConfig: Validators: {
	k8svalidate: {
		kind: "Command"
		command: args: [
			"kubeconform",
			"-schema-location", "default",
			"-schema-location", "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json",
			"-schema-location", "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/{{.NormalizedKubernetesVersion}}/{{.ResourceKind}}{{.KindSuffix}}.json",
			"-skip", "CustomResourceDefinition",
			"-summary",
		]
	}
	kube_linter: {
		kind: "Command"
		command: args: [
			"kube-linter",
			"lint",
			"--config", ".kube-linter.yaml",
		]
	}

	config: {
		kind: "Command"
		command: args: [
			"cue", "vet", "-c", "./config",
		]
	}
}
