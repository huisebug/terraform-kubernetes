variable "ssh" {
  description = "ssh信息"
  type = object({
    user = string
    port    = number
    password     = string
  })
}



variable "Allnode" {
  description = "合并所有变量的节点"
  type        = list(object({
    ip       = string
    hostname = string
  }))

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

variable "container" {
  description = "container配置"
  type = object({
    container    = string
      #cgroup驱动，默认是cgroupfs,可以设置为systemd
    cgroupdriver     = string

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