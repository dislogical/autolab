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
		version: "1.42.2"
		repository: {
			name: "coredns"
			url:  "https://coredns.github.io/helm"
		}
	}
	Values: {
		isClusterService: false
		image: {
			repository: "ghcr.io/k8s-gateway/k8s_gateway"
			tag:        "1.2.1@sha256:7830e736192ec17039a0c6f5302d025e93cc323b15b8e74c69fcdeb895062a5b"
			pullPolicy: "IfNotPresent"
		}
		serviceAccount: create: true
		serviceType: "LoadBalancer"
		service: loadBalancerIP: "10.42.42.2"
		servers: [{
			zones: [{
				zone:    "."
				scheme:  "dns://"
				use_tcp: true
			}]
			port: 53
			plugins: [{
				name: "any"
			}, {
				name: "debug"
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
				name: "loadbalance"
			}, {
				name:        "k8s_gateway"
				parameters:  "\(env.external_url)"
				configBlock: "resources HTTPRoute"
			}, {
				name:       "cache"
				parameters: "30 \(env.external_url)"
			}, {
				name:       "forward"
				parameters: "ballard.coldencullen.com 10.0.1.1"
			}, {
				name:       "forward"
				parameters: "mission.coldencullen.com 10.1.1.1"
			}, {
				name:       "forward"
				parameters: ". tls://1.1.1.1 tls://1.0.0.1"
				configBlock: """
					tls
					tls_servername one.one.one.one
					"""
			}]
		}]
	}
}
