#!/bin/env bash

source /vagrant/Provision/users-appsbasicos.sh
source /vagrant/Provision/install-k8s.sh
     
echo -e "Configurando usuarios\n"
addUser > /dev/null 2>&1

echo -e "Instalando aplicativos iniciais\n"
installApp > /dev/null 2>&1

echo -e "Carregando Modulos\n"
loadModules #> /dev/null 2>&1

echo -e "\nInstalando o kubeadm, kubelet e kubectl\n"
installk8s #> /dev/null 2>&1

echo -e "\nInstalando o Containerd\n"
installContainerd

echo -e "\nIniciando o kubeadm\n"
startCluster