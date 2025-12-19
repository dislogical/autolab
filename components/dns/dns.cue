package holos

holos: Dns.BuildPlan

Dns: #Helm & {
	Resources: Namespace: dns: _
	Namespace: Resources.Namespace.dns.metadata.name
	KustomizeConfig: Kustomization: namespace: Namespace

	Chart: {
		name:    "k8s-gateway"
		version: "3.2.8"
		repository: {
			name: "k8s-gateway"
			url:  "https://k8s-gateway.github.io/k8s_gateway/"
		}
	}
	Values: {
		domain: env.external_url
		watchedResources: [
			"HTTPRoute",
		]

		service: loadBalancerIP: "10.0.1.2"

		extraZonePlugins: [
			// Site URLs
			for site in [{name: "ballard", upstream: "10.0.1.1"}, {name: "mission", upstream: "10.1.1.1"}] {
				name:       "forward"
				parameters: "\(site.name).\(env.external_url) \(site.upstream)"
			},
		]
	}
}
