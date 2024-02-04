
locals {
  SystemdCgroup = var.container.cgroupdriver == "systemd" ? "true" : "false"
}

resource "null_resource" "containerd-precondition" {
  count = length(var.Allnode)
  connection {
    type        = "ssh"
    host        = var.Allnode[count.index].ip
    user        = var.ssh.user
    port        = var.ssh.port
    password = var.ssh.password
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/containerd/",
    ]
  }

  provisioner "file" {
    content = templatefile("modules/container/templates/config.toml", {  
      sandbox_image = var.pause_image
      SystemdCgroup = local.SystemdCgroup
    })
    destination = "/etc/containerd/config.toml"
  } 



}





