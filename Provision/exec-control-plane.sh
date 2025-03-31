#!/bin/env bash

source /vagrant/Provision/users-appsbasicos.sh
source /vagrant/Provision/install-k8s.sh
     
echo -e "Configurando usuarios\n"
addUser 

echo -e "Instalando aplicativos iniciais\n"
installApp

echo -e "Carregando Modulos\n"
loadModules 

echo -e "\nInstalando o kubeadm, kubelet e kubectl\n"
installk8s 

echo -e "\nInstalando o Containerd\n"
installContainerd

echo -e "\nIniciando o kubeadm\n"
startCluster

echo -e "\nInstalando o CNI Cilium\n"
installCNICilium