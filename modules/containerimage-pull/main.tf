resource "null_resource" "containerimage-pulletcd" {
  count = length(var.etcd)

  connection {
    type        = "ssh"
    host        = var.etcd[count.index].ip
    user        = var.ssh.user
    port        = var.ssh.port
    password    = var.ssh.password
  }

  provisioner "remote-exec" {
    inline = [
      # 假设您希望使用 "ctr" 命令拉取映像
      "sudo ctr -n k8s.io i pull ${var.pause_image}",
      "sudo ctr -n k8s.io i pull ${var.etcdImage}",
    ]
  }
}

resource "null_resource" "containerimage-pullmaster" {
  count = length(var.master)

  connection {
    type        = "ssh"
    host        = var.master[count.index].ip
    user        = var.ssh.user
    port        = var.ssh.port
    password    = var.ssh.password
  }

  provisioner "remote-exec" {
    inline = [
      # 假设您希望使用 "ctr" 命令拉取映像
       "sudo ctr -n k8s.io i pull ${var.pause_image}",
        "sudo ctr -n k8s.io i pull ${var.KubernetesImage}",
          "sudo ctr -n k8s.io i pull ${var.kubevipimage}",
        
    ]
  }
}
