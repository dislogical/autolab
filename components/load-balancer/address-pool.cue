package autolab

export: load_balancer: {
	ipaddresspool: {
		apiVersion: "metallb.io/v1beta1"
		kind:       "IPAddressPool"
		metadata: {
			name:      "default-pool"
			namespace: "load-balancer"
		}
		spec: addresses: ["10.42.42.0/24"]
	}
	l2advertisement: {
		apiVersion: "metallb.io/v1beta1"
		kind:       "L2Advertisement"
		metadata: {
			name:      "default-advertisement"
			namespace: "load-balancer"
		}
		spec: ipAddressPools: ["default-pool"]
	}
}
