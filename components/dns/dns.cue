package holos

holos: Dns.BuildPlan

Dns: {
	Resources: {
		Namespace: dns: {}

		ClusterRole: gateway: {
			rules: [{
				apiGroups: [""]
				resources: [
					"endpoints",
					"services",
					"pods",
					"namespaces",
				]
				verbs: [
					"list",
					"watch",
				]
			}, {
				apiGroups: ["apiextensions.k8s.io"]
				resources: ["customresourcedefinitions"]
				verbs: [
					"get",
					"list",
					"watch",
				]
			}, {
				apiGroups: ["gateway.networking.k8s.io"]
				resources: [
					"gateways",
					"gatewayclasses",
					"httproutes",
					"tlsroutes",
					"grpcroutes",
				]
				verbs: [
					"watch",
					"list",
				]
			}, {
				apiGroups: ["externaldns.k8s.io"]
				resources: ["dnsendpoints"]
				verbs: [
					"watch",
					"list",
				]
			}]
		}

		ClusterRoleBinding: gateway: {
			roleRef: {
				apiGroup: "rbac.authorization.k8s.io"
				kind:     "ClusterRole"
				name:     "gateway"
			}
			subjects: [{
				kind:      "ServiceAccount"
				name:      "coredns"
				namespace: Namespace.dns.metadata.name
			}]
		}
	}
}

Dns: #Helm & {
	Namespace: "dns"

	Chart: {
		name:    "coredns"
		version: "1.45.0"
		repository: {
			name: "coredns"
			url:  "https://coredns.github.io/helm"
		}
	}
	Values: {
		isClusterService: false
		image: {
			repository: "ghcr.io/k8s-gateway/k8s_gateway"
			tag:        "1.5.1"
			pullPolicy: "IfNotPresent"
		}
		serviceAccount: create: true
		serviceType: "LoadBalancer"
		service: loadBalancerIP: "10.0.1.2"

		// Snippets
		let _common_plugins = [{
			name: "cache"
		}, {
			name:        "log"
			parameters:  ". \"{combined}\""
			configBlock: "class denial error"
		}]
		servers: [
			// Site URLs
			for site in [{name: "ballard", upstream: "10.0.1.1"}, {name: "mission", upstream: "10.1.1.1"}] {
				zones: [{
					zone: "\(site.name).\(env.external_url)"
				}]
				port: 53
				plugins: [
					for plugin in _common_plugins {plugin},
					{
						name:       "forward"
						parameters: ". \(site.upstream)"
					},
				]
			},

			// Services
			{
				zones: [{
					zone: env.external_url
				}]
				port: 53
				plugins: [
					for plugin in _common_plugins {plugin},
					{
						name:        "k8s_gateway"
						configBlock: "resources HTTPRoute"
					},
				]
			},

			// Global block
			{
				port: 53
				plugins: [
					for plugin in _common_plugins {plugin},
					{
						name: "any"
					}, {
						name: "errors"
					}, {
						name: "health"
					}, {
						name: "ready"
					}, {
						name:       "prometheus"
						parameters: "0.0.0.0:9153"
					}, {
						name:       "reload"
						parameters: "30s 5s"
					}, {
						name:       "forward"
						parameters: ". tls://1.1.1.1 tls://1.0.0.1"
						configBlock: """
						tls
						tls_servername one.one.one.one
						"""
					},
				]
			},
		]
	}
}
