package dns

import (
	rbacv1 "cue.dev/x/k8s.io/api/rbac/v1"
)

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
		kind:     clusterrole.kind
		name:     clusterrole.metadata.name
	}
	subjects: [{
		kind:        "ServiceAccount"
		name:        "coredns"
		"namespace": namespace.metadata.name
	}]
}
