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

variable "clusterha" {
  description = "#集群中使用的HA方案"
  type = object({
    vip    = string
    vipSubnet     = string
  })
}

variable "kubevipimage" {
  description = "kube-vip容器镜像"
  type = string
}

variable "INTERFACE_NAME" {
  description = "#将会用于HA和k8s集群网络"
 type = string
}

