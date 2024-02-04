resource "null_resource" "containerd-dnf" {
  depends_on = [
    null_resource.containerd-precondition 
  ]
 
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
    # 添加docker-ce的repo文件,使用docker-ce的repo来仅安装containerd
    "curl -o /etc/yum.repos.d/docker-ce.repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo",
    # 安装containerd服务
    "dnf -y install containerd",
    # 启动containerd,并开机自启
    "systemctl start containerd && systemctl enable containerd"
    ]
  }
  

}





