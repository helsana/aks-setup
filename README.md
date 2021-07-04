# Create Namespace
```bash
 k create ns myhelsana
```

# Switch to Namespace
```bash
kns myhelsana
```

# Install Infrastructure Resources
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```
## MongoDB
```bash
helm install mongodb --set architecture=replicaset bitnami/mongodb
```
## Redis
```bash
helm install redis bitnami/redis
```
## Prometheus
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false  prometheus-community/kube-prometheus-stack
```

## Install Secrets
```bash
kubesec decrypt secret/secret.enc.yaml | kubectl apply -n myhelsana -f -
kubesec decrypt secret/myhelsana-keystore-secret.enc.yaml | kubectl apply -n myhelsana -f -
kubesec decrypt secret/myhelsana-truststore-secret.enc.yaml | kubectl apply -n myhelsana -f -
```

## Install RBAC for ConfigMaps/Secrets
```bash
k apply -f rbac/roles.yaml
```

## Install Spring Cloud Contracts
```bash
./scripts/install-contracts.sh
```


# Ingress Registrierung
```bash
k apply -f ingress/ingress-registrierung.yaml
```

