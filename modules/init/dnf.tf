
resource "null_resource" "dnf-install" {
    depends_on = [
    null_resource.init
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
    # 删除和创建 yum 目录，下载 steam 默认 yum 源，清理 dnf 缓存
      "rm -rf /etc/yum.repos.d",
      "mkdir /etc/yum.repos.d",
      "curl -o /etc/yum.repos.d/CentOS-Stream-Default.repo https://vs-pkgs.oss-cn-beijing.aliyuncs.com/installserver/CentOS-Stream-Default.repo",
      "dnf clean all",
    # 添加 epel-release 仓库
    # "dnf install -y epel-release",
    # 安装基础软件包    
    # "dnf install -y vim tree conntrack-tools nfs-utils jq socat bash-completion ipset perl ipvsadm conntrack libseccomp net-tools crontabs unzip bind-utils tcpdump telnet lsof wget psmisc chrony"

    ]
  }
}



