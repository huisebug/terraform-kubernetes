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