module "ping" {
  source            = "./modules/ping"
  ssh = var.ssh
  Allnode = concat(var.master, var.node)
}


module "init" {
  source            = "./modules/init"
  ssh = var.ssh
  console = var.console
  Allnode = concat(var.master, var.node)
}

module "container" {
  source            = "./modules/container"
  ssh = var.ssh
  Allnode = concat(var.master, var.node)
  pause_image = var.pause_image
  container = var.container
}


module "containerimage-pull" {
  source            = "./modules/containerimage-pull"
  ssh = var.ssh
  etcd = var.etcd
  master = var.master
  etcdImage = var.etcdImage
  pause_image = var.pause_image
  KubernetesImage = var.KubernetesImage
  kubevipimage = var.kubevipimage

}


module "tls" {
  source            = "./modules/tls"
  ssh = var.ssh
  KubernetesClusterSVCIP = var.KubernetesClusterSVCIP
  etcd = var.etcd
  master = var.master
  Allnode = concat(var.master, var.node)
  certSANs = var.certSANs
  clusterha = var.clusterha

}

module "kubelet-bootstrap" {
  source            = "./modules/kubelet-bootstrap"
  CLUSTER_NAME = var.CLUSTER_NAME
  KUBE_APISERVER= length(var.master) == 1 ? "https://${var.master[0].ip}:6443" : "https://${var.clusterha.vip}:6443"

}

module "kubelet" {
  source            = "./modules/kubelet"
  ssh = var.ssh
  Allnode = concat(var.master, var.node)

  container = var.container
  kubelet = var.kubelet
  ClusterDns = var.ClusterDns
  ClusterDomain = var.ClusterDomain

}

module "etcd" {
  source            = "./modules/etcd"
  ssh = var.ssh
  etcd = var.etcd
  etcdImage = var.etcdImage
}

module "kubeconfig" {
  source            = "./modules/kubeconfig"
  CLUSTER_NAME = var.CLUSTER_NAME
  KUBE_APISERVER= length(var.master) == 1 ? "https://${var.master[0].ip}:6443" : "https://${var.clusterha.vip}:6443"
}

module "k8s-master" {
  source            = "./modules/k8s-master"
  ssh = var.ssh
  master = var.master
  ClusterCIDR = var.ClusterCIDR
  ServiceClusterIPRange = var.ServiceClusterIPRange
  etcd = var.etcd
  KubernetesImage = var.KubernetesImage
}

module "kube-vip" {
  source            = "./modules/kube-vip"
  ssh = var.ssh
  master = var.master
  kubevipimage = var.kubevipimage
  clusterha = var.clusterha
  INTERFACE_NAME = var.INTERFACE_NAME
}

module "kubelet-bootstrap-csr" {
  source            = "./modules/kubelet-bootstrap-csr"
}


module "k8s-cni" {
  source            = "./modules/k8s-cni"
  ssh = var.ssh
  master = var.master
  ClusterCIDR = var.ClusterCIDR
  k8scni = var.k8scni
  flannel = var.flannel
  calico = var.calico

}


module "kube-proxy" {
  source            = "./modules/kube-proxy"
  ssh = var.ssh
  master = var.master
  KUBE_APISERVER= length(var.master) == 1 ? "https://${var.master[0].ip}:6443" : "https://${var.clusterha.vip}:6443"
  ClusterCIDR = var.ClusterCIDR
  proxy = var.proxy
  KubernetesClusterVersion = var.KubernetesClusterVersion

}

module "coredns" {
  source            = "./modules/coredns"
  ssh = var.ssh
  master = var.master
  ClusterDns = var.ClusterDns
  ClusterDomain = var.ClusterDomain

}