package autolab

import (
	corev1 "cue.dev/x/k8s.io/api/core/v1"
)

export: gateway: namespace: corev1.#Namespace & {
	metadata: name: "gateway"
}
