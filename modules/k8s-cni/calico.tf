


resource "null_resource" "calico" {

  count = var.k8scni == "calico" ? length(var.master) : 0
 
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
        content = templatefile("modules/k8s-cni/templates/calico.yaml",{

    })
        destination = "/etc/kubernetes/${var.k8scni}/calico.yaml"
        
    }

}

