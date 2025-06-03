package gateway

import (
	corev1 "cue.dev/x/k8s.io/api/core/v1"
)

namespace: corev1.#Namespace & {
	metadata: name: "gateway"
}
