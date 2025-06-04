package autolab

import (
	corev1 "cue.dev/x/k8s.io/api/core/v1"
)

export: kubernetes_dashboard: namespace: corev1.#Namespace & {
	metadata: name: "kubernetes-dashboard"
}
