package holos

holos: Capacitor.BuildPlan

Capacitor: #Kustomize & {
	KustomizeConfig: {
		Resources: {
			"https://github.com/gimlet-io/capacitor/deploy/k8s?ref=capacitor-v0.4.8": _
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
			hostnames: ["flux.\(env.external_url)"]
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
