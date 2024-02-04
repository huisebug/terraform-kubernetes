resource "null_resource" "ping" {
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
        "echo pong"
    ]
  }    
  }