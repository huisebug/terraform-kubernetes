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

variable "ClusterDns" {
  description = "#集群中DNS的svc-IP，可随意配置，一般是ServiceClusterIPRange的第二个ip"
  type = string
}

variable "ClusterDomain" {
  description = "#集群中DNS的svc-IP，可随意配置，一般是ServiceClusterIPRange的第二个ip"
  type = string
}