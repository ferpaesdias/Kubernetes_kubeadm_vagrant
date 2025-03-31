#!/bin/env bash

### Variáveis ### 
PASS='control123'

# Usuários  
function add_User {

    # Ajuste fuso horario
    sudo timedatectl set-timezone America/Sao_Paulo

# Adiciona uma entrada do Node1 no Hosts dos Nodes
cat <<-EOF | sudo tee -a /etc/hosts
192.168.3.201 k8s-control-plane
EOF


    # Alterar a senha do usuário "root" 
    sudo usermod -p $(openssl passwd -1 ${PASS}) root 
}

# Instalar aplicativos iniciais
function installApp {

    sudo apt update > /dev/null 2>&1 
    sudo apt install -y vim curl wget apt-transport-https ca-certificates curl gpg gnupg lsb-release git 
}