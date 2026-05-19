machine:
  kubelet:
    nodeIP:
      validSubnets:
        - 10.0.1.0/24
---
apiVersion: v1alpha1
kind: HostnameConfig
auto: off
hostname: "{{ .Node.Host }}"

{{ range .Node.Data.network.links }}
---
apiVersion: v1alpha1
kind: LinkConfig
name: {{ . }} # Name of the link (interface).
up: true
---
apiVersion: v1alpha1
kind: DHCPv4Config
name: {{ . }}
{{ end }}
