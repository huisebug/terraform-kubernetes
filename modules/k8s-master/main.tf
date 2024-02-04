resource "null_resource" "k8s-master" {
  count = length(var.master)
  connection {
    type        = "ssh"
    host        = var.master[count.index].ip
    user        = var.ssh.user
    port        = var.ssh.port
    password = var.ssh.password
  }

  # 创建k8s-master相关目录
  provisioner "remote-exec" {
    inline = [
      
      "sudo mkdir -p /root/.kube/",
    ]
  }


  # 分发证书
  provisioner "file" {
    source      = "/etc/kubernetes/pki/"
    destination = "/etc/kubernetes/pki/"
  }

  
  # 分发管理组件的kubeconfig
  provisioner "file" {
    source      = "/etc/kubernetes/admin.kubeconfig"
    destination = "/etc/kubernetes/admin.kubeconfig"
  }
  provisioner "file" {
    source      = "/etc/kubernetes/controller-manager.kubeconfig"
    destination = "/etc/kubernetes/controller-manager.kubeconfig"
  }  
  provisioner "file" {
    source      = "/etc/kubernetes/scheduler.kubeconfig"
    destination = "/etc/kubernetes/scheduler.kubeconfig"
  }
  provisioner "file" {
    source      = "/usr/local/bin/kubectl"
    destination = "/usr/local/bin/kubectl"
  }  

  #设置kubectl的kubeconfig
  provisioner "file" {
    source      = "/etc/kubernetes/admin.kubeconfig"
    destination = "/root/.kube/config"
  }  

  # 分发kube-api-server部署yaml到kubelet静态pod目录下
  provisioner "file" {
        content = templatefile("modules/k8s-master/templates/kube-apiserver.yaml",{
          bind = var.master[count.index].ip
          etcd-servers = join(",", [for host in var.etcd : "https://${host.ip}:2379"])
          service-cluster-ip-range = var.ServiceClusterIPRange
          KubernetesImage = var.KubernetesImage
    })
        destination = "/etc/kubernetes/manifests/kube-apiserver.yaml"
    }
  # 分发kube-controller-manager部署yaml到kubelet静态pod目录下
  provisioner "file" {
        content = templatefile("modules/k8s-master/templates/kube-controller-manager.yaml",{
          cluster-cidr = var.ClusterCIDR
          service-cluster-ip-range = var.ServiceClusterIPRange
          KubernetesImage = var.KubernetesImage
    })
        destination = "/etc/kubernetes/manifests/kube-controller-manager.yaml"
    }
  # 分发kube-scheduler部署yaml到kubelet静态pod目录下
  provisioner "file" {
        content = templatefile("modules/k8s-master/templates/kube-scheduler.yaml",{
          KubernetesImage = var.KubernetesImage
    })
        destination = "/etc/kubernetes/manifests/kube-scheduler.yaml"
    }    
  # kubectl命令补全
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /usr/local/bin/kubectl",
      "sudo /usr/local/bin/kubectl completion bash > /etc/bash_completion.d/kubectl"
    ]
  }

  
}