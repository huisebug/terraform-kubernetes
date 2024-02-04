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


variable "ClusterCIDR" {
  description = "#集群中pod的网段"
  type = string
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