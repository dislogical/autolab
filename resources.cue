package holos

import (
	corev1 "cue.dev/x/k8s.io/api/core/v1"
	appsv1 "cue.dev/x/k8s.io/api/apps/v1"
	rbacv1 "cue.dev/x/k8s.io/api/rbac/v1"
	batchv1 "cue.dev/x/k8s.io/api/batch/v1"

	ci "cert-manager.io/clusterissuer/v1"
	rgv1 "github.com/orvis98/cue-schemas/gateway.networking.k8s.io/gateway.networking.k8s.io/referencegrant/v1beta1"
	certv1 "cert-manager.io/certificate/v1"
	issuerv1 "cert-manager.io/issuer/v1"
	hrv1 "github.com/orvis98/cue-schemas/gateway.networking.k8s.io/gateway.networking.k8s.io/httproute/v1"
	es "external-secrets.io/externalsecret/v1beta1"
	ss "external-secrets.io/secretstore/v1beta1"
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

	Certificate?: [_]:        certv1.#Certificate
	ClusterIssuer?: [_]:      ci.#ClusterIssuer
	ClusterRole?: [_]:        rbacv1.#ClusterRole
	ClusterRoleBinding?: [_]: rbacv1.#ClusterRoleBinding
	ConfigMap?: [_]:          corev1.#ConfigMap
	CronJob?: [_]:            batchv1.#CronJob
	Deployment?: [_]:         appsv1.#Deployment
	ExternalSecret?: [_]:     es.#ExternalSecret
	HTTPRoute?: [_]:          hrv1.#HTTPRoute
	Issuer?: [_]:             issuerv1.#Issuer
	Job?: [_]:                batchv1.#Job
	Namespace?: [_]:          corev1.#Namespace
	ReferenceGrant?: [_]:     rgv1.#ReferenceGrant
	Role?: [_]:               rbacv1.#Role
	RoleBinding?: [_]:        rbacv1.#RoleBinding
	Secret?: [_]:             corev1.#Secret
	SecretStore?: [_]:        ss.#SecretStore
	Service?: [_]:            corev1.#Service
	ServiceAccount?: [_]:     corev1.#ServiceAccount
	StatefulSet?: [_]:        appsv1.#StatefulSet
}
