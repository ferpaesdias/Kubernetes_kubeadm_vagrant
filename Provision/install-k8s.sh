#!/bin/env bash

# Instala módulos
function loadModules {

    echo -e "Carregar módulos do Kernel\n" 

# Configuração dos módulos do Node
cat <<-EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

    sudo modprobe overlay
    sudo modprobe br_netfilter

# Configurar parâmetros do sistema
cat <<-EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

    sudo sysctl --system 
} 

function installk8s {
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

    sudo apt-get update > /dev/null 2>&1
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl

    # Adiciona alias e autocomplete do kubectl em todos os usuários
    sudo echo 'source <(kubectl completion bash)' >> /etc/bash.bashrc
    echo 'alias k="kubectl"' >> /etc/bash.bashrc
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

    echo -e "Executando o comando 'kubeadm init'"
    kubeadm init --pod-network-cidr=172.16.0.0/16 --apiserver-advertise-address=192.168.3.201

    echo -e "Configuracoes do kubeadm enviadas para o usuario vagrant\n"
    mkdir -p /home/vagrant/.kube 
    sudo cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
    sudo cp /etc/kubernetes/admin.conf /vagrant/token/kube_config
    sudo chown vagrant:vagrant /home/vagrant/.kube/config
    
    # Arquivo que contém o comando que vincula os Workers ao Control Plane
    kubeadm token create --print-join-command > /vagrant/token/kubeadm_node_token
}

function addWorker {
    kubeadmtoken=$(cat /vagrant/token/kubeadm_node_token)
    sudo $kubeadmtoken
}

function installCNICilium {
    sudo curl -fsSL -o /vagrant/Provision/token/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    sudo chmod 700 /vagrant/Provision/token/get_helm.sh
    sudo bash /vagrant/Provision/token/get_helm.sh

    helm repo add cilium https://helm.cilium.io/
    helm install cilium cilium/cilium --version 1.17.1 --namespace kube-system

}