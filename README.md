# Kubernetes_kubeadm_vagrant

<br>

Criação de uma infraestrutura local do Kubernetes com 01 Control Plane e 02 Workers.   
Será utilizado o Vagrant e o Kubeadm.    
O Sistema Operacional das VMs será o Debian 12.

<br>

```mermaid
flowchart TB
    A[k8s-control-plane <br> 192.168.3.201] --> B[k8s-worker1 <br> 192.168.3.202]
    A --> C[k8s-worker2 <br> 192.168.3.203]
```