
resource "null_resource" "coredns" {
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
      "sudo mkdir -p /etc/kubernetes/coredns/",
    ]
  }

    # 分发部署
  provisioner "file" {
        content = templatefile("modules/coredns/templates/coredns-configmap.yaml",{
          ClusterDomain = var.ClusterDomain
    
    })
        destination = "/etc/kubernetes/coredns/coredns-configmap.yaml"
      
    }
    # 分发部署
  provisioner "file" {
        content = templatefile("modules/coredns/templates/coredns.yaml",{
          ClusterDns = var.ClusterDns
  
    })
        destination = "/etc/kubernetes/coredns/coredns.yaml"
      
    }

  provisioner "remote-exec" {
    inline = [
      "sudo /usr/local/bin/kubectl apply -f /etc/kubernetes/coredns/coredns-configmap.yaml",
      "sudo /usr/local/bin/kubectl apply -f /etc/kubernetes/coredns/coredns.yaml",
    ]
  }

}