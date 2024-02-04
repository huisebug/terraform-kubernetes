variable "ssh" {
  description = "ssh信息"
  type = object({
    user = string
    port    = number
    password     = string
  })
}


variable "etcd" {
  description = "作为etcd的节点"
  type = list(object({
    ip    = string
    clusterName     = string
  }))
}

variable "master" {
  description = "作为master的节点"
  type = list(object({
    ip    = string
    hostname     = string
  }))
   default = []
}

variable "pause_image" {
  description = "集群pause容器镜像"
  type = string
}

variable "KubernetesImage" {
  description = "kubernetes容器镜像"
  type = string
}

variable "etcdImage" {
  description = "etcd容器镜像"
  type = string
}

variable "kubevipimage" {
  description = "kube-vip容器镜像"
  type = string
}
