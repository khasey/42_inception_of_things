#!/bin/sh
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

echo "${GREEN}====! $1 !=====${RESET}"

echo "${GREEN}[INFO]  Installing k3s on server node (ip: $1) ===================>>>>>>>>//////${RESET}"

export INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san $(hostname) --node-ip $1 --bind-address=$1 --advertise-address=$1"

echo "${GREEN}[INFO]  ARGUMENT PASSED TO INSTALL_K3S_EXEC: $INSTALL_K3S_EXEC ===================>>>>>>>>//////${RESET}"

apk add curl

curl -sfL https://get.k3s.io | sh -

echo "${GREEN}[INFO]  Doing some sleep to wait for k3s to be ready ===================>>>>>>>>//////${RESET}"

sleep 10

echo "${GREEN}[INFO]  Installing Nginx Ingress Controller ===================>>>>>>>>//////${RESET}"

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

echo "${GREEN}[INFO]  Waiting for Nginx Ingress Controller to be ready ===================>>>>>>>>//////${RESET}"

# Wait until the ingress controller pods are ready
while [[ $(kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
  echo "Waiting for Nginx Ingress Controller to be ready..."
  sleep 5
done

echo "${GREEN}[INFO]  Applying Kubernetes manifests ===================>>>>>>>>//////${RESET}"

sudo k3s kubectl apply -f /vagrant/kubernetes_manifests/app1.yaml
sudo k3s kubectl apply -f /vagrant/kubernetes_manifests/app2.yaml
sudo k3s kubectl apply -f /vagrant/kubernetes_manifests/app3.yaml

echo "${GREEN}[INFO]  Applying Ingress ===================>>>>>>>>//////${RESET}"

sudo k3s kubectl apply -f /vagrant/kubernetes_manifests/ingress.yaml

echo "${GREEN}[INFO]  Successfully installed k3s on server node ===================>>>>>>>>//////${RESET}"

echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh

# Ensure services are running and display their status
sudo k3s kubectl get pods --all-namespaces
sudo k3s kubectl get services --all-namespaces
sudo k3s kubectl get ingress --all-namespaces
