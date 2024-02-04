
resource "null_resource" "init" {
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
    # 设置主机名
    "sudo hostnamectl set-hostname ${var.Allnode[count.index].hostname}",
    # 设置系统时区
    "sudo timedatectl set-timezone ${var.TimeZone}",
    # 关闭ssh DNS反向解析和初次访问提示询问
    "sudo sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config",
    "sudo sed -i 's/^.*StrictHostKeyChecking.*$/StrictHostKeyChecking no/' /etc/ssh/ssh_config",
    # 关闭 firewalld
    "sudo systemctl stop firewalld && systemctl disable firewalld",
    # 永久关闭 SELinux
    "sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config",
    # 增加 kubectl 所需的全局环境变量
    "sudo echo 'export PATH=\"$PATH:/usr/local/bin\"' >> ~/.bash_profile"

    ]
  }

# 分发modules-load和系统用户资源配置文件limit和sysctl文件
  provisioner "file" {
    source      = "modules/init/files/ipvs.conf"
    destination = "/etc/modules-load.d/ipvs.conf"
  }
  provisioner "file" {
    source      = "modules/init/files/containerd.conf"
    destination = "/etc/modules-load.d/containerd.conf"
  }
  provisioner "file" {
    source      = "modules/init/files/istio.conf"
    destination = "/etc/modules-load.d/istio.conf"
  }  
  provisioner "file" {
    source      = "modules/init/files/limit.conf"
    destination = "/etc/security/limits.d/limit.conf"
  }
  provisioner "file" {
    source      = "modules/init/files/k8s-sysctl.conf"
    destination = "/etc/sysctl.d/k8s-sysctl.conf"
  }  

  provisioner "remote-exec" {
    inline = [

      # 解决ipmi驱动问题
      "sudo modprobe ipmi_devintf",
      "sudo modprobe ipmi_msghandler",
      "sudo modprobe ipmi_si type=kcs ports=0xca2 regspacings=1 || true",

      # 解决ipmi驱动问题而启动systemd-modules-load
      "sudo systemctl start systemd-modules-load || true",
      "sudo systemctl enable systemd-modules-load || true",
    ]
  }

      # 分发chrony配置文件
    provisioner "file" {
        content = templatefile("modules/init/templates/chrony.conf",{
      ntp_domain1 = var.ntp_domain1
      ntp_domain2 = var.ntp_domain2
    })
        destination = "/etc/chrony.conf"
    }

    provisioner "remote-exec" {
    inline = [
        # 设置chronyd开机自启并重新启动服务
      "sudo systemctl enable chronyd",
      "sudo systemctl restart chronyd",
      # 执行chrony配置，同步时间
      "sudo chronyc sources",
    ]
     }

      # 修改fstab文件关闭swap
    provisioner "remote-exec" {
    inline = [
         "sudo sed -i '/^\\s*[^#].*swap/s/^/#/' /etc/fstab",
    ]
     }
}

locals {
 filtered_nodes = [for node in var.Allnode : node if node.ip != var.console]
}

resource "null_resource" "reboot-filtered_nodes" {
  depends_on = [
    null_resource.dnf-install
  ]

  count = length(local.filtered_nodes)

  connection {
    type     = "ssh"
    host     = local.filtered_nodes[count.index].ip
    user     = var.ssh.user
    port     = var.ssh.port
    password = var.ssh.password
  }

  # 除了console节点重启
  provisioner "remote-exec" {
    inline = [
      "sudo shutdown -r now",
    ]
  }
}
