{{ $issuerDomain := .Values.domain }}
issuer: https://{{ $issuerDomain }}
storage:
  type: kubernetes
  config:
    inCluster: true
logger:
  level: debug
{{- range .Values.ports }}
{{- if eq .name "http" }}
web:
  http: 0.0.0.0:{{ .internalPort }}
{{- end }}
{{- if eq .name "grpc" }}
grpc:
  addr: 0.0.0.0:{{ .internalPort }}
  tlsCert: /etc/dex/tls/grpc/server/tls.crt
  tlsKey: /etc/dex/tls/grpc/server/tls.key
  tlsClientCA: /etc/dex/tls/grpc/ca/tls.crt
{{- end }}
{{- end }}
connectors:
{{- range $id, $connector := .Values.connectors }}
{{- $type := $connector.config.type | default "github" }}
{{- $id = $id | default "github" }}
{{- $name := $connector.config.name | default "GitHub" }}
- type: {{ $type }}
  id: {{ $id }}
  name: {{ $name }}
  config:
    clientID: {{ $connector.config.clientID }}
    clientSecret: {{ $connector.config.clientSecret }}
    redirectURI: https://{{ $issuerDomain }}/callback
{{- if hasKey $connector.config.orgs }}
    orgs:
{{- range $connector.config.orgs }}
      - name: {{ . }}
{{- end }}
{{- end }}
{{- if eq $type "github" }}
    useLoginAsID: true
{{- end }}
{{- end }}
oauth2:
  skipApprovalScreen: true

enablePasswordDB: false

frontend:
  theme: cloudbees
