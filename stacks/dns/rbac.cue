package autolab

import (
	rbacv1 "cue.dev/x/k8s.io/api/rbac/v1"
)

export: dns: {
	let this = export.dns
	let _metadata = {
		name: "dns-gateway"
		labels: {
			"app.kubernetes.io/instance": "coredns"
			"app.kubernetes.io/name":     "coredns"
		}
	}

	clusterrole: rbacv1.#ClusterRole & {
		metadata: _metadata
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

	clusterrolebinding: rbacv1.#ClusterRoleBinding & {
		metadata: _metadata
		roleRef: {
			apiGroup: "rbac.authorization.k8s.io"
			kind:     this.clusterrole.kind
			name:     this.clusterrole.metadata.name
		}
		subjects: [{
			kind:      "ServiceAccount"
			name:      "coredns"
			namespace: this.namespace.metadata.name
		}]
	}
}
