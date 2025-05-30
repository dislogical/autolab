terraform {
  required_version = "1.9.1"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.0-pre2"
    }
  }
}

resource "kubernetes_namespace" "dns" {
  metadata {
    name = "dns"
  }
}

data "local_file" "coredns_values" {
  filename = "${path.module}/values-coredns.yaml"
}

resource "helm_release" "coredns" {
  name       = "coredns"
  chart      = "coredns"
  repository = "https://coredns.github.io/helm"
  namespace  = kubernetes_namespace.dns.metadata[0].name
  wait       = false
  values = [
    data.local_file.coredns_values.content
  ]
}
