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
  Target namespace — set in env overlay (e.g. ae-prod-values.yaml).
*/}}
{{- define "ruby-test-apps.namespace" -}}
{{- default .Release.Namespace .Values.namespace -}}
{{- end }}

{{/*
  ESO opt-in: enabled only when env values file sets eso.enabled: true.
*/}}
{{- define "ruby-test-apps.esoEnabled" -}}
{{- $eso := .Values.eso -}}
{{- if and $eso $eso.enabled -}}true{{- end -}}
{{- end -}}

{{- define "ruby-test-apps.esoWaitForSecret" -}}
{{- if and (include "ruby-test-apps.esoEnabled" .) .Values.eso.waitForSecret -}}true{{- end -}}
{{- end -}}

{{/*
  AWS Secrets Manager path. Default: <namespace>/<project.repoName>. Override: eso.remotePathPrefix.
*/}}
{{- define "ruby-test-apps.esoRemotePath" -}}
{{- $ns := include "ruby-test-apps.namespace" . -}}
{{- $repo := .Values.project.repoName | default .Chart.Name -}}
{{- default (printf "%s/%s" $ns $repo) .Values.eso.remotePathPrefix -}}
{{- end }}

{{/*
  K8s Secret synced from ESO (ExternalSecret spec.target.name).
*/}}
{{- define "ruby-test-apps.esoTargetSecretName" -}}
{{- if .Values.eso.targetSecretName -}}
{{- .Values.eso.targetSecretName -}}
{{- else -}}
{{- include "ruby-test-apps.fullname" . -}}
{{- end -}}
{{- end }}

