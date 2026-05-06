{{/*
Common labels
*/}}
{{- define "platform.labels" -}}
helm.sh/chart: {{ .Chart.Name }}
{{ include "platform.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "platform.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Default Flux settings
*/}}
{{- define "platform.fluxDefaults" -}}
interval: 1h
{{- end }}
{{- define "platform.helmReleaseDefaults" -}}
{{ include "platform.fluxDefaults" . }}
driftDetection:
  mode: enabled
install:
  crds: CreateReplace
upgrade:
  crds: CreateReplace
{{- end }}
