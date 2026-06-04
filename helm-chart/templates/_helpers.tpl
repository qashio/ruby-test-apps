{{- define "ruby-test-apps.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "ruby-test-apps.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "ruby-test-apps.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "ruby-test-apps.labels" -}}
helm.sh/chart: {{ include "ruby-test-apps.chart" . }}
{{ include "ruby-test-apps.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "ruby-test-apps.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ruby-test-apps.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "ruby-test-apps.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ruby-test-apps.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
  ESO only when the env values file defines an `eso` block with enabled: true and remotePath.
  If `eso` is omitted entirely, no ExternalSecret is rendered (deployment is not blocked).
*/}}
{{- define "ruby-test-apps.esoEnabled" -}}
{{- $eso := .Values.eso -}}
{{- if and $eso $eso.enabled $eso.remotePath -}}true{{- end -}}
{{- end -}}

{{- define "ruby-test-apps.useInlineSecret" -}}
{{- if and (not (include "ruby-test-apps.esoEnabled" .)) .Values.secretKeyBase -}}true{{- end -}}
{{- end -}}
