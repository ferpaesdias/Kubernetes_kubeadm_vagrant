function installCNICilium {
    # sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    # sudo chmod 700 get_helm.sh
    # sudo ./get_helm.sh

    # helm repo add cilium https://helm.cilium.io/
    # helm install cilium cilium/cilium --version 1.17.1 --namespace kube-system

    echo -e "\nInstalando o CNI Cilium 2\n"

    kubectl get nodes

}