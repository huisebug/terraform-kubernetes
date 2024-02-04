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

variable "KUBE_APISERVER" {
  description = "#用于kubeconfig生成脚本中的kube-apiserver地址变量"
  type = string
}


variable "ClusterCIDR" {
  description = "#集群中pod的网段"
  type = string
}



variable "KubernetesClusterVersion" {
  description = "kubernetes容器镜像"
  type = string
}

variable "proxy" {
  description = "#kube-proxy"
  type = object({
    mode = string
    ipvsscheduler = string
  })
}