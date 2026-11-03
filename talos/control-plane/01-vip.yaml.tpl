---
apiVersion: v1alpha1
kind: Layer2VIPConfig
name: "{{ .Data.network.vip }}"
link: "{{ index .Node.Data.network.links 0 }}"
