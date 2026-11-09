---
apiVersion: v1alpha1
kind: HostnameConfig
auto: off
hostname: "{{ .Node.Host }}"

{{ $gateway := .Data.network.gateway }}
{{ $addr := .Node.IP.AsSlice }}
{{ range $idx, $name := .Node.Data.network.links }}
{{ $last := mustLast $addr | add $idx }}
{{ $link_addr := mustAppend (slice $addr 0 3) $last | join "." }}
---
apiVersion: v1alpha1
kind: LinkConfig
name: {{ $name }} # Name of the link (interface).
up: true
addresses:
  - address: {{ $link_addr }}/24
routes:
  - gateway: {{ $gateway }}
{{ end }}
