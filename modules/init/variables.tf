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

variable "Allnode" {
  description = "合并所有变量的节点"
  type        = list(object({
    ip       = string
    hostname = string
  }))

}


variable TimeZone {
  description = "系统时区"
  type = string
  default = "Asia/Shanghai"
}

variable ntp_domain1 {
  description = "ntp服务配置1"
  type = string
  default = "time2.aliyun.com"
}

variable ntp_domain2 {
  description = "ntp服务配置2"
  type = string
  default = "s1b.time.edu.cn"
}