#!/bin/bash

GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

export NAME="kthierrySW"
echo "${GREEN}[INFO]  Installing k3s on server worker node (ip: $2) ===================>>>>>>>>//////${RESET}"

export TOKEN_FILE="/vagrant/scripts/node-token"

echo "${GREEN}[INFO]  Token: $(cat $TOKEN_FILE) ===================>>>>>>>>//////${RESET}"

export INSTALL_K3S_EXEC="agent --server https://$1:6443 --token-file $TOKEN_FILE --node-ip=$2"

echo "${GREEN}[INFO]  ARGUMENT PASSED TO INSTALL_K3S_EXEC: $INSTALL_K3S_EXEC ===================>>>>>>>>//////${RESET}"

apk add curl

curl -sfL https://get.k3s.io | sh -

echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh 