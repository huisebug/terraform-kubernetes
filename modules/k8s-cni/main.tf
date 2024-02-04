
resource "null_resource" "k8s-cni-apply" {
  connection {
    type        = "ssh"
    host        = var.master[0].ip
    user        = var.ssh.user
    port        = var.ssh.port
    password = var.ssh.password
  }
  provisioner "remote-exec" {
    inline = [
      "sudo /usr/local/bin/kubectl apply -f /etc/kubernetes/${var.k8scni}/${var.k8scni}.yaml",
    ]
  }
  depends_on = [
    null_resource.kube-flannel,
    null_resource.calico,
    ]

}