package holos

import (
	corev1 "cue.dev/x/k8s.io/api/core/v1"
	appsv1 "cue.dev/x/k8s.io/api/apps/v1"
	rbacv1 "cue.dev/x/k8s.io/api/rbac/v1"
	batchv1 "cue.dev/x/k8s.io/api/batch/v1"

	cmv1 "cue.dev/x/crd/cert-manager.io/v1"

	rgv1 "github.com/orvis98/cue-schemas/gateway.networking.k8s.io/gateway.networking.k8s.io/referencegrant/v1beta1"
	hrv1 "github.com/orvis98/cue-schemas/gateway.networking.k8s.io/gateway.networking.k8s.io/httproute/v1"
)

#Resources: {
	[Kind=string]: [InternalLabel=string]: {
		kind: Kind
		metadata: {
			name:       string | *InternalLabel
			namespace?: string
		}

		[_]: _
	}

	Certificate?: [_]:        cmv1.#Certificate
	ClusterIssuer?: [_]:      cmv1.#ClusterIssuer
	ClusterRole?: [_]:        rbacv1.#ClusterRole
	ClusterRoleBinding?: [_]: rbacv1.#ClusterRoleBinding
	ConfigMap?: [_]:          corev1.#ConfigMap
	CronJob?: [_]:            batchv1.#CronJob
	Deployment?: [_]:         appsv1.#Deployment
	HTTPRoute?: [_]:          hrv1.#HTTPRoute
	Issuer?: [_]:             cmv1.#Issuer
	Job?: [_]:                batchv1.#Job
	Namespace?: [_]:          corev1.#Namespace
	ReferenceGrant?: [_]:     rgv1.#ReferenceGrant
	Role?: [_]:               rbacv1.#Role
	RoleBinding?: [_]:        rbacv1.#RoleBinding
	Secret?: [_]:             corev1.#Secret
	Service?: [_]:            corev1.#Service
	ServiceAccount?: [_]:     corev1.#ServiceAccount
	StatefulSet?: [_]:        appsv1.#StatefulSet
}
