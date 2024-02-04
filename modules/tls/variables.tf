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
  
}

variable "Allnode" {
  description = "合并所有变量的节点"
  type        = list(object({
    ip       = string
    hostname = string
  }))

}

variable "certSANs" {
  description = "tls配置"
  type = object({
    apiServer = list(string)
    etcd = list(string)
  })
}

variable "clusterha" {
  description = "#集群中使用的HA方案"
  type = object({
    vip    = string
    vipSubnet     = string
  })
}

variable "KubernetesClusterSVCIP" {
  description = "集群中kubernetes的svc-IP"
  type = string
}