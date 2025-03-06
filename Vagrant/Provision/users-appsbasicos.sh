#!/bin/env bash

### Variáveis ### 
PASS='control123'

# Usuários  
function addUser {

    # Alterar a senha do usuário "vagrant" 
    sudo usermod -p $(openssl passwd -1 ${PASS}) vagrant

    # Alterar a senha do usuário "root" 
    sudo usermod -p $(openssl passwd -1 ${PASS}) root 
}

# Instalar aplicativos iniciais
function installApp {
    
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y vim curl wget apt-transport-https ca-certificates curl gpg gnupg lsb-release 
}