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

variable "etcdImage" {
  description = "etcd容器镜像"
  type = string
}