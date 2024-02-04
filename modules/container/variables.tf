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

variable "pause_image" {
  description = "集群pause容器镜像"
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