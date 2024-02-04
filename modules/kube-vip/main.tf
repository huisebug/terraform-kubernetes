resource "null_resource" "kube-vip" {


  count = length(var.master) == 1 ? 0 : length(var.master)
  connection {
    type        = "ssh"
    host        = var.master[count.index].ip
    user        = var.ssh.user
    port        = var.ssh.port
    password = var.ssh.password
  }
  
  provisioner "remote-exec" {
    inline = [
      #  按照kubeadm的规范创建变量文件
        "sudo \\cp -rf /etc/kubernetes/admin.kubeconfig /etc/kubernetes/admin.conf",
       # 添加主机名到 /etc/hosts 文件
      "echo '${join("\n", [for m in var.master : "${m.ip} ${m.hostname}"])}' | sudo tee -a /etc/hosts",
    ]
  }


  provisioner "file" {
    source      = "/etc/kubernetes/pki/etcd/"
    destination = "/etc/kubernetes/pki/etcd/"
  }

  
# 分发etcd部署yaml到kubelet静态pod目录下
  provisioner "file" {
    content = templatefile("modules/kube-vip/templates/kube-vip.yaml", {
      kubevipimage = var.kubevipimage
      INTERFACE_NAME = var.INTERFACE_NAME
      clusterha = var.clusterha
    })
    destination = "/etc/kubernetes/manifests/kube-vip.yaml"
  }



}