resource "null_resource" "etcd" {
  count = length(var.etcd)
  connection {
    type        = "ssh"
    host        = var.etcd[count.index].ip
    user        = var.ssh.user
    port        = var.ssh.port
    password = var.ssh.password
  }
  # 创建etcd相关目录
  provisioner "remote-exec" {
    inline = [
      
      "sudo mkdir -p /etc/kubernetes/pki/etcd",
      "sudo mkdir -p /etc/etcd"
    ]
  }


  provisioner "file" {
    source      = "/etc/kubernetes/pki/etcd/"
    destination = "/etc/kubernetes/pki/etcd/"
  }


  provisioner "file" {
    content = templatefile("modules/etcd/templates/etcd.config.yml", {
      ip = var.etcd[count.index].ip
      clusterName = var.etcd[count.index].clusterName
      initial-cluster = join(",", [for host in var.etcd : "${host.clusterName}=https://${host.ip}:2380"])
    })
    destination = "/etc/etcd/etcd.config.yml"
  }
# 分发etcd部署yaml到kubelet静态pod目录下
  provisioner "file" {
    content = templatefile("modules/etcd/templates/etcd.yaml", {
      etcdImage = var.etcdImage
    })
    destination = "/etc/kubernetes/manifests/etcd.yaml"
  }



}