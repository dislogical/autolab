@experiment(aliasv2)
package autolab

import (
	"strings"
	"net"

	corev1 "cue.dev/x/k8s.io/api/core/v1"
	appsv1 "cue.dev/x/k8s.io/api/apps/v1"
	rbacv1 "cue.dev/x/k8s.io/api/rbac/v1"
	batchv1 "cue.dev/x/k8s.io/api/batch/v1"

	gwv1 "cue.dev/x/crd/k8s.io/networking/gateway/v1"

	cmv1 "cue.dev/x/crd/cert-manager.io/v1"

	fsv1 "cue.dev/x/crd/fluxcd.io/source/v1"
	fkv1 "cue.dev/x/crd/fluxcd.io/kustomize/v1"
	fhv2 "cue.dev/x/crd/fluxcd.io/helm/v2"
)

Manifests: {
	[string]: net.URL
}

Resources: {
	[string]~(Namespace,_): {

		"Namespace": "\(Namespace)": corev1.#Namespace & {
			metadata: {
				namespace: "default"
				name: strings.ToLower(Namespace)
			}
		}

		[string]~(Kind,_): [string]~(Name,_): {
			kind: string | *Kind
			metadata: {
				// Namespaces don't get a namespace
				if strings.ToLower(Kind) != "namespace" {
					namespace: string | *Resources[Namespace].Namespace[Namespace].metadata.name
				}
				name:      string | *Name
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
		HTTPRoute?: [_]:          gwv1.#HTTPRoute
		Issuer?: [_]:             cmv1.#Issuer
		Job?: [_]:                batchv1.#Job
		ReferenceGrant?: [_]:     gwv1.#ReferenceGrant
		Role?: [_]:               rbacv1.#Role
		RoleBinding?: [_]:        rbacv1.#RoleBinding
		Secret?: [_]:             corev1.#Secret
		Service?: [_]:            corev1.#Service
		ServiceAccount?: [_]:     corev1.#ServiceAccount
		StatefulSet?: [_]:        appsv1.#StatefulSet

		GitRepository?: [_]: fsv1.#GitRepository & {
			spec: interval: "1h"
		}

		HelmRepository?: [_]: fsv1.#HelmRepository & {
			spec: interval: "1h"
		}
		HelmRelease?: [_]: fhv2.#HelmRelease & {
			spec: {
				interval: "1h"
				driftDetection: mode: "enabled"
				install: crds:        "Skip" | "Create" | *"CreateReplace"
				upgrade: crds:        "Skip" | "Create" | *"CreateReplace"
			}
		}

		Kustomization?: [_]: fkv1.#Kustomization & {
			spec: {
				interval: "1h"
				prune:    true
			}
		}
	}
}

#DisableHelmCrds: {
	install: crds: "Skip"
	upgrade: crds: "Skip"
}

#ReferenceOf: {
	#Resource: _

	if true {
		apiVersion: #Resource.apiVersion
		kind:       #Resource.kind
		name:       #Resource.metadata.name
		namespace:  #Resource.metadata.namespace
	}
}
