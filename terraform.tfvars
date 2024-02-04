ssh = {
  user = "root",
  port = 22
  password = "pwd@123"
}

# 作为terraform管理的节点
console = "192.168.137.100"

#作为master的节点
master = [
  {
  ip    = "192.168.137.100"
  hostname     = "k8s-m1"
  },
  {
  ip    = "192.168.137.101"
  hostname     = "k8s-m2"
  },
]


#作为node的节点
node = [
  {
  ip    = "192.168.137.102"
  hostname     = "k8s-n1"
  },    
]

#作为etcd的节点
etcd = [
  {
  ip    = "192.168.137.100"
  clusterName     = "k8s-m1"
  },
  {
  ip    = "192.168.137.101"
  clusterName     = "k8s-m2"
  },
  {
  ip    = "192.168.137.102"
  clusterName     = "k8s-m3"
  },    
]

clusterha = {
  #k8s集群HA vip IP地址
  vip = "192.168.137.99"
  #k8s集群HA vip IP地址子网掩码，一般是32
  vipSubnet = "24"
}

container = {
  container = "containerd"
  cgroupdriver = "systemd"
}

#k8s集群的版本
KubernetesClusterVersion = "v1.26.12"

# kubernetes容器镜像
etcdImage = "quay.io/coreos/etcd:v3.5.11"


#集群中DNS的svc-IP，可随意配置，一般是ServiceClusterIPRange的第二个ip
ClusterDns = "10.254.0.2"
#集群域名
ClusterDomain = "cluster.local"
#集群中kubernetes的svc-IP，固定是ServiceClusterIPRange的第一个ip,用于tls证书里SAN值
KubernetesClusterSVCIP = "10.254.0.1"
#集群pause镜像
pause_image = "registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.9"
#k8s集群名
CLUSTER_NAME = "kubernetes"
#集群中pod的网段
ClusterCIDR = "10.10.0.0/16"
#集群中svc的网段
ServiceClusterIPRange = "10.254.0.0/16"
# kubernetes容器镜像
KubernetesImage = "registry.cn-hangzhou.aliyuncs.com/huisebug/kubernetes:v1.26.12"
# apiserver 负载均衡服务kube-vip镜像
kubevipimage = "registry.cn-hangzhou.aliyuncs.com/huisebug/source:kube-vip-v0.5.11"



kubelet = {
  rootdir = "/var/lib/kubelet"
  logLevel = 2
  staticPodPath = "/etc/kubernetes/manifests"
  failSwapOn = true
}

#将会用于HA和k8s集群网络
INTERFACE_NAME = "ens160"

#tls配置
certSANs = {
  apiServer = [
    "apiserver.k8s.local",
    "apiserver001.k8s.local",
    "apiserver002.k8s.local",
    "apiserver003.k8s.local",
  ]
  etcd = [
    "etcd001.k8s.local",
    "etcd001.k8s.local",
    "etcd001.k8s.local",
  ]
}



#网络组件部署方案, kube-flannel 或者 calico; VMware-vsphere虚拟化下网卡受限，不允许calico的BGP协议。只能使用flanneld
k8scni = "kube-flannel"

#flannel部署
flannel = {
  # 后端模式 vxlan 或者 host-gw
  Backendtype = "vxlan"
}
#calico部署
calico = {}


#kube-proxy部署
proxy = {
  # 代理模式
  mode = "ipvs" 
  #ipvs模式下使用的调度算法，rr，lc，sh，dh
  ipvsscheduler = "rr"
}

