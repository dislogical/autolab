package holos

holos: LoadBalancer.BuildPlan

LoadBalancer: #Helm & {
	Namespace: LoadBalancer.Resources.Namespace.metrics.metadata.name

	Chart: {
		name:    "kube-prometheus-stack"
		version: "73.2.0"
		repository: {
			name: "kube-prometheus-stack"
			url:  "https://prometheus-community.github.io/helm-charts"
		}
	}
	Values: {
		prometheus: {
			prometheusSpec: {
				maximumStartupDurationSeconds:           null
				ruleSelectorNilUsesHelmValues:           false
				serviceMonitorSelectorNilUsesHelmValues: false
				podMonitorSelectorNilUsesHelmValues:     false
				probeSelectorNilUsesHelmValues:          false
				scrapeConfigSelectorNilUsesHelmValues:   false
			}
			route: main: {
				enabled: true
				hostnames: ["prometheus.\(env.external_url)"]
				parentRefs: [{
					kind:      "Gateway"
					name:      "traefik-gateway"
					namespace: "gateway"
				}]
			}
		}
		prometheusOperator: tls: enabled: false
		grafana: route: main: {
			enabled: true
			hostnames: ["grafana.\(env.external_url)"]
			parentRefs: [{
				kind:      "Gateway"
				name:      "traefik-gateway"
				namespace: "gateway"
			}]
		}
	}
}

LoadBalancer: Resources: {
	Namespace: metrics: _
}
