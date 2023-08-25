#!/bin/bash
releaseStatus=$(sudo helm status traefik --namespace traefik > /dev/null 2>&1; echo $?)
if [ $releaseStatus -eq 0 ]; then
    sudo helm uninstall traefik --namespace traefik
fi

sudo helm repo add traefik https://helm.traefik.io/traefik
sudo helm repo update
sudo helm install traefik traefik/traefik --namespace traefik
echo "Waiting for 20 seconds..."
sleep 10
LB_DNS=$(sudo kubectl get svc traefik -n traefik -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' | tr -d '\n')
echo "LoadBalancer DNS: $LB_DNS"
sudo helm upgrade --install ingress ./ingress/helm-chart -f ./ingress/values.yaml --set ingressHost=$LB_DNS 
