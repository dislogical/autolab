package holos

holos: Capacitor.BuildPlan

Capacitor: #Kustomize & {
	KustomizeConfig: {
		Resources: {
			"https://raw.githubusercontent.com/gimlet-io/capacitor/main/deploy/k8s/rbac.yaml":     _
			"https://raw.githubusercontent.com/gimlet-io/capacitor/main/deploy/k8s/manifest.yaml": _
		}
	}
	Resources: HTTPRoute: capacitor: {
		metadata: namespace: "flux-system"
		spec: {
			parentRefs: [{
				kind:      "Gateway"
				name:      "traefik-gateway"
				namespace: "gateway"
			}]
			hostnames: ["flux.localhost"]
			rules: [{
				backendRefs: [{
					kind: "Service"
					name: "capacitor"
					port: 9000
				}]
			}]
		}
	}
}
