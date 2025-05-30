terraform {
  required_version = "1.9.1"
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.9.0"
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

resource "kind_cluster" "test" {
  name = "test"
  kind_config {
    api_version = "kind.x-k8s.io/v1alpha4"
    kind        = "Cluster"

    node {
      role = "control-plane"
    }
    node {
      role = "worker"
    }
    node {
      role = "worker"
    }
  }
}

provider "kubernetes" {
  # Configuration options
  host = kind_cluster.test.endpoint

  client_certificate     = kind_cluster.test.client_certificate
  client_key             = kind_cluster.test.client_key
  cluster_ca_certificate = kind_cluster.test.cluster_ca_certificate
}

provider "helm" {
  kubernetes = {
    # Configuration options
    host                   = kind_cluster.test.endpoint
    client_certificate     = kind_cluster.test.client_certificate
    client_key             = kind_cluster.test.client_key
    cluster_ca_certificate = kind_cluster.test.cluster_ca_certificate
  }
}

module "dns" {
  source = "./stacks/dns"
}
