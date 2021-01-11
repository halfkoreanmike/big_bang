{{/* this template is deprecated. All application packages must switch to "privateRegistries" */}}
{{- define "imagePullSecret" }}
{{- with .Values.registryCredentials }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}}" .registry .username .password .email (printf "%s:%s" .username .password | b64enc) | b64enc }}
{{- end }}
{{- end }}

{{- define "privateRegistries" -}}
{{ include "privateRegistriesTemplate" . | b64enc }}
{{- end }}

{{- define "privateRegistriesTemplate" -}}
{
  "auths": {
    {{- if .Values.privateRegistries }}
    {{- $length := len .Values.privateRegistries }}
    {{- range $index, $entry := .Values.privateRegistries }}
    "{{- $entry.registry }}": {
      "username{{ $index }}":"{{- $entry.username }}",
      "password":"{{- $entry.password }}",
      "email":"{{- $entry.email }}",
      "auth":"{{- (printf "%s:%s" $entry.username $entry.password | b64enc) }}"
    }{{- if ne $length (add $index 1) }},{{- end }}
    {{- end }}
    {{- end }}
  }
}
{{- end -}}

{{/*
Build the appropriate spec.ref.{} given git branch, commit values
*/}}
{{- define "validRef" -}}
{{- if .commit -}}
{{- if not .branch -}}
{{- fail "A valid branch is required when a commit is specified!" -}}
{{- end -}}
branch: {{ .branch | quote }}
commit: {{ .commit }}
{{- else if .semver -}}
semver: {{ .semver | quote }}
{{- else if .tag -}}
tag: {{ .tag }}
{{- else -}}
branch: {{ .branch | quote }}
{{- end -}}
{{- end -}}

{{/*
Build the appropriate git credentials secret for private git repositories
*/}}
{{- define "gitCreds" -}}
{{- if .existingSecret -}}
secretRef:
  name: {{ .existingSecret }}
{{- else if coalesce .credentials.username .credentials.password .credentials.privateKey .credentials.publicKey .credentials.knownHosts "" -}}
{{- /* Input validation happens in git-credentials.yaml template */ -}}
secretRef:
  name: git-credentials
{{- end -}}
{{- end -}}

{{/*
Build common set of file extensions to include/exclude
*/}}
{{- define "gitIgnore" -}}
  ignore: |
    # exclude file extensions
    /**/*.md
    /**/*.txt
    /**/*.sh
{{- end -}}