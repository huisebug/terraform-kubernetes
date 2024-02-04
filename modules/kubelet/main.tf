locals {
  container_socket = {

    containerd = "unix:///run/containerd/containerd.sock"
  }
}


resource "null_resource" "kubelet" {
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
      # 创建相关目录
    "sudo mkdir -p  /etc/kubernetes/pki",
    "sudo mkdir -p  /etc/kubernetes/manifests",
    "sudo mkdir -p  /var/lib/kubelet",
    "sudo mkdir -p  /opt/cni/bin",

      # 删除老旧的kubelet认证文件
      "sudo rm -rf /etc/kubernetes/pki/kubelet-client-*"
    ]
  }

    # 分发k8s-cni二进制文件目录
      provisioner "file" {
        source      = "/opt/cni/bin/"
        destination = "/opt/cni/bin/"
      }

    # 分发Kubelet二进制文件
      provisioner "file" {
        source      = "/usr/local/bin/kubelet"
        destination = "/usr/local/bin/kubelet"
      }

      # 分发Kubelet配置文件
    provisioner "file" {
        content = templatefile("modules/kubelet/templates/kubelet-conf.yml",{
          bind = var.Allnode[count.index].ip
          container = var.container
          kubelet = var.kubelet
          ClusterDns = var.ClusterDns
          ClusterDomain = var.ClusterDomain
          healthzBindAddress = var.Allnode[count.index].ip
    })
        destination = "/etc/kubernetes/kubelet-conf.yml"
    }

    provisioner "file" {
        content = templatefile("modules/kubelet/templates/kubelet.service",{
          bind = var.Allnode[count.index].ip
          container = var.container
          kubelet = var.kubelet
          hostname = var.Allnode[count.index].hostname
          healthzBindAddress = var.Allnode[count.index].ip
          runtime = local.container_socket[var.container.container]
    })
        destination = "/usr/lib/systemd/system/kubelet.service"
    }
     # 分发kubelet相关证书
    provisioner "file" {
      source      = "/etc/kubernetes/pki/ca.crt"
      destination = "/etc/kubernetes/pki/ca.crt"
    }
      provisioner "file" {
      source      = "/etc/kubernetes/bootstrap.kubeconfig"
      destination = "/etc/kubernetes/bootstrap.kubeconfig"
    }
    # 开机并启动kubelet
    provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /usr/local/bin/kubelet",
      "sudo chmod +x /opt/cni/bin/*",
      "sudo systemctl enable kubelet",
      "sudo systemctl start kubelet",
    ]
     }
}

