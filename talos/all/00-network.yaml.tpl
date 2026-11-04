---
apiVersion: v1alpha1
kind: KubeNodeConfig
# The `nodeIP` field is used to configure `--node-ip` flag for the kubelet.
nodeIP:
    # The `validSubnets` field configures the networks to pick kubelet node IP from.
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
