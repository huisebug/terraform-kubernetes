variable "ssh" {
  description = "ssh信息"
  type = object({
    user = string
    port    = number
    password     = string
  })
}


variable "master" {
  description = "作为master的节点"
  type = list(object({
    ip    = string
    hostname     = string
  }))
}

# variable "node" {
#   description = "作为node的节点"
#   type = list(object({
#     ip    = string
#     hostname     = string
#   }))
# }

variable "etcd" {
  description = "作为etcd的节点"
  type = list(object({
    ip    = string
    clusterName     = string
  }))
}

variable "ClusterCIDR" {
  description = "#集群中pod的网段"
  type = string
}

variable "ServiceClusterIPRange" {
  description = "#集群中svc的网段"
  type = string
}

variable "KubernetesImage" {
  description = "kubernetes容器镜像"
  type = string
}