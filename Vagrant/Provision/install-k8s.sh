#!/bin/env bash

# Desabilita Swap
function loadModules {

    echo -e "Carregar módulos do Kernel\n" 

    sudo touch /etc/modules-load.d/k8s.conf
    sudo chmod 666 /etc/modules-load.d/k8s.conf
    sudo echo overlay >> /etc/modules-load.d/k8s.conf
    sudo echo br_netfilter >> /etc/modules-load.d/k8s.conf
    sudo chmod 644 /etc/modules-load.d/k8s.conf

    sudo modprobe overlay
    sudo modprobe br_netfilter

    sudo touch /etc/sysctl.d/k8s.conf
    sudo chmod 666 /etc/sysctl.d/k8s.conf
    sudo echo "net.bridge.bridge-nf-call-iptables  = 1" >> /etc/sysctl.d/k8s.conf
    sudo echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.d/k8s.conf
    sudo echo "net.ipv4.ip_forward                 = 1" >> /etc/sysctl.d/k8s.conf
    sudo chmod 644 /etc/sysctl.d/k8s.conf

    sudo sysctl --system 
} 

function installk8s {
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

    sudo apt-get update > /dev/null 2>&1
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl

    # Adiciona alias no bash do usuario vagrant
    echo 'alias k="kubectl"' >> /home/vagrant/.bashrc
}

function installContainerd {
    sudo install -m 0755 -d /etc/apt/keyrings

    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update > /dev/null 2>&1 && sudo apt-get install -y containerd.io

    # Configurar o containerd, alterar a opção SystemdCgroup para true
    sudo containerd config default | sudo tee /etc/containerd/config.toml
    sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

    sudo systemctl restart containerd

    # Habilitar o serviço do kubelet
    sudo systemctl enable --now kubelet
}

function startCluster {
    sudo kubeadm init --pod-network-cidr=10.10.0.0/16 --apiserver-advertise-address=192.168.3.201

    echo -e "Configuracoes do kubeadm enviadas para o usuario vagrant\n"

    mkdir -p /home/vagrant/.kube
    sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
    sudo chown vagrant:vagrant /home/vagrant/.kube/config

    kubeadm token create --print-join-command > /vagrant/Provision/kubeadm_node_token

    echo -e "comando kubectl\n"
    
    a=0
    while [ $a -eq 0 ]
    do
        kubectl get nodes > /dev/null 2>&1

        if [ $? -eq 0 ]
        then
            echo -e "comando executado com sucesso\n"
            a=5
        else
            echo -e "comando executado com erro\n"
        fi
    done  

    kubectl get nodes -o wide
}

function addNode {
    kubeadmtoken=$(cat /vagrant/Provision/kubeadm_node_token)
    sudo $kubeadmtoken
}

function installCNICilium {
    # sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    # sudo chmod 700 get_helm.sh
    # sudo ./get_helm.sh

    # helm repo add cilium https://helm.cilium.io/
    # helm install cilium cilium/cilium --version 1.17.1 --namespace kube-system

    echo -e "\nInstalando o CNI Cilium 2\n"

}