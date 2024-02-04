
variable "ssh" {
  description = "ssh信息"
  type = object({
    user = string
    port    = number
    password     = string
  })
}

variable "console" {
  description = "作为terraform管理的节点"
  type = string
}


variable "master" {
  description = "作为master的节点"
  type = list(object({
    ip    = string
    hostname     = string
  }))
   default = []
}

variable "node" {
  description = "作为node的节点"
  type = list(object({
    ip    = string
    hostname     = string
  }))
  default = []
}




variable "etcd" {
  description = "作为etcd的节点"
  type = list(object({
    ip    = string
    clusterName     = string
  }))
}




variable "etcdImage" {
  description = "etcd容器镜像"
  type = string
}



variable "pause_image" {
  description = "集群pause容器镜像"
  type = string
}



variable "KubernetesImage" {
  description = "kubernetes容器镜像"
  type = string
}


variable "KubernetesClusterVersion" {
  description = "kubernetes容器镜像"
  type = string
}

variable "kubevipimage" {
  description = "kube-vip容器镜像"
  type = string
}


variable "clusterha" {
  description = "#集群中使用的HA方案"
  type = object({
    vip    = string
    vipSubnet     = string
  })
}

variable "INTERFACE_NAME" {
  description = "#将会用于HA和k8s集群网络"
 type = string
}

variable "CLUSTER_NAME" {
  description = "集群名称"
 type = string
}

variable "ClusterCIDR" {
  description = "#集群中pod的网段"
  type = string
}

variable "ServiceClusterIPRange" {
  description = "#集群中svc的网段"
  type = string
}


variable "KubernetesClusterSVCIP" {
  description = "集群中kubernetes的svc-IP"
  type = string
}




variable "container" {
  description = "container配置"
  type = object({
    container    = string
      #cgroup驱动，默认是cgroupfs,可以设置为systemd
    cgroupdriver     = string
  })
}

variable "kubelet" {
  description = "kubelet配置"
  type = object({
    rootdir    = string
    logLevel     = number
    staticPodPath = string
    #开启禁用swap交换分区
    failSwapOn = bool
  })
 
}

variable "ClusterDns" {
  description = "#集群中DNS的svc-IP，可随意配置，一般是ServiceClusterIPRange的第二个ip"
  type = string
}
variable "ClusterDomain" {
  description = "#集群中DNS的svc-IP，可随意配置，一般是ServiceClusterIPRange的第二个ip"
  type = string
}

variable "certSANs" {
  description = "tls配置"
  type = object({
    apiServer = list(string)
    etcd = list(string)
  })
}



variable "k8scni" {
  description = "#集群网络组件部署方案"
  type = string
}

variable "flannel" {
  description = "#flannel"
  type = object({
    Backendtype = string
  })
}
variable "calico" {
  description = "#calico"
  type = object({
  })
}

variable "proxy" {
  description = "#kube-proxy"
  type = object({
    mode = string
    ipvsscheduler = string
  })
}

