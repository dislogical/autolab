package autolab

import (
	corev1 "cue.dev/x/k8s.io/api/core/v1"
)

export: dns: namespace: corev1.#Namespace & {
	metadata: name: "dns"
}
