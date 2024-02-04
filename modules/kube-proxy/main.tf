
resource "null_resource" "k8s-proxy" {
  connection {
    type        = "ssh"
    host        = var.master[0].ip
    user        = var.ssh.user
    port        = var.ssh.port
    password = var.ssh.password
  }

    # 创建相关目录
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/kubernetes/kube-proxy/",
    ]
  }


    # 分发部署
  provisioner "file" {
        content = templatefile("modules/kube-proxy/templates/kube-proxy.yaml",{
          ClusterCIDR = var.ClusterCIDR
          KUBE_APISERVER = var.KUBE_APISERVER
          KubernetesClusterVersion = var.KubernetesClusterVersion
          proxy = var.proxy
    })
        destination = "/etc/kubernetes/kube-proxy/kube-proxy.yaml"
      
    }

  provisioner "remote-exec" {
    inline = [
      "sudo /usr/local/bin/kubectl apply -f /etc/kubernetes/kube-proxy/kube-proxy.yaml",
    ]
  }

}