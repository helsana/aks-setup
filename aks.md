# AKS 
https://ichi.pro/de/traefik-ingress-im-azure-kubernetes-dienst-275193782592692


# Define variables
```bash
export PIP_RESOURCE_GROUP=aks-public-ip
export AKS_RESOURCE_GROUP=AKS
export AKS_CLUSTER_NAME=aks-c3smonkey
export LOCATION=eastus2
export NODE_COUNT=2
export NODE_SIZE=Standard_D1_V2
export CONTAINER_REGISTRY=myhelsana
```

# Login to Azure
```bash
az login
```

# Create Azure resource group
```bash
az group create --name $AKS_RESOURCE_GROUP --location $LOCATION
```

# Create AKS Cluster
```bash
az aks create --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --node-count $NODE_COUNT --node-vm-size $NODE_SIZE --enable-addons monitoring --generate-ssh-keys
```
# Get Credentials
```bash
az aks get-credentials --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME
```

# Public IP
```bash
az network public-ip create \
    --resource-group $AKS_RESOURCE_GROUP \
    --name $PIP_RESOURCE_GROUP \
    --sku Standard \
    --allocation-method static

# Do not change anything below this line
CLIENT_ID=$(az aks show --name $AKS_CLUSTER_NAME --resource-group $AKS_RESOURCE_GROUP | jq -r .identity.principalId)
SUB_ID=$(az account show --query "id" --output tsv)

az role assignment create --role "Virtual Machine Contributor" --assignee $CLIENT_ID --scope /subscriptions/$SUB_ID/resourceGroups/$AKS_RESOURCE_GROUP
```
## GET IP 
```bash
az network public-ip show -g $AKS_RESOURCE_GROUP -n $PIP_RESOURCE_GROUP | jq .ipAddress -r
```

# Traefik
```bash
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik traefik/traefik -f traefik/helm/traefik-values.yaml
```
## Check Installation
```bash
kubectl get pods | grep traefik
```

## Expose Dashboard
```bash
kubectl port-forward $(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name) 9000:9000
```
http://127.0.0.1:9000/dashboard/


## Install Sample Services
```bash
kubectl apply -f traefik/service1.yaml
kubectl apply -f traefik/service2.yaml
```

## Check :
http <Public IP>/service1
http <Public IP>/service2


# Create Container Registry
```bash
az acr create --resource-group $AKS_RESOURCE_GROUP --name $CONTAINER_REGISTRY --sku Standard
az aks update -n $AKS_CLUSTER_NAME -g $AKS_RESOURCE_GROUP --attach-acr $CONTAINER_REGISTRY
```

## Login to Container Registry
```bash
az acr login --name myhelsana.azurecr.io
```

# Scale Nodes
```bash
NODEPOOL_NAME=$(az aks show --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --query agentPoolProfiles | jq -r '.[].name')
az aks scale --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --node-count 2 --nodepool-name $NODEPOOL_NAME
k get nodes
```

## Stop Cluster
```bash
az aks stop -g $AKS_RESOURCE_GROUP -n $AKS_CLUSTER_NAME
```
## Start Cluster
```bash
az aks start -g $AKS_RESOURCE_GROUP -n $AKS_CLUSTER_NAME
```

