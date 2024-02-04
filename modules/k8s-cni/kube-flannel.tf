


resource "null_resource" "kube-flannel" {

  count = var.k8scni == "kube-flannel" ? length(var.master) : 0
 
  connection {
    type        = "ssh"
    host        = var.master[count.index].ip
    user        = var.ssh.user
    port        = var.ssh.port
    password = var.ssh.password
  }


  # 创建相关目录
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/kubernetes/${var.k8scni}/",
    ]
  }



    # 分发部署
  provisioner "file" {
        content = templatefile("modules/k8s-cni/templates/kube-flannel.yaml",{
          ClusterCIDR = var.ClusterCIDR
          flannel = var.flannel
    })
        destination = "/etc/kubernetes/${var.k8scni}/kube-flannel.yaml"
      
    }
}
