
项目介绍
========

```shell
├── down.sh                            #使用containerd下载kubernetes的客户端，如kubectl、kubelet
├── main.tf                            #terraform 入口tf                            
├── modules                            #terraform modules
│   ├── container                      #container，主要是安装containerd服务
│   │   ├── dnf.tf
│   │   ├── main.tf
│   │   ├── templates
│   │   │   └── config.toml
│   │   └── variables.tf
│   ├── containerimage-pull            #使用把后续所需的容器镜像提前pull
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── coredns                        
│   │   ├── main.tf
│   │   ├── templates
│   │   │   ├── coredns-configmap.yaml
│   │   │   └── coredns.yaml
│   │   └── variables.tf
│   ├── etcd
│   │   ├── main.tf
│   │   ├── templates
│   │   │   ├── etcd.config.yml
│   │   │   └── etcd.yaml
│   │   └── variables.tf
│   ├── init                           #对centos 8 系统进行系统初始化配置
│   │   ├── dnf.tf
│   │   ├── files
│   │   │   ├── containerd.conf
│   │   │   ├── ipvs.conf
│   │   │   ├── istio.conf
│   │   │   ├── k8s-sysctl.conf
│   │   │   └── limit.conf
│   │   ├── main.tf
│   │   ├── templates
│   │   │   └── chrony.conf
│   │   └── variables.tf
│   ├── k8s-cni                        #使用kubernetes cni服务，支持calico和flannel
│   │   ├── calico.tf
│   │   ├── kube-flannel.tf
│   │   ├── main.tf
│   │   ├── templates
│   │   │   ├── calico.yaml
│   │   │   └── kube-flannel.yaml
│   │   └── variables.tf
│   ├── k8s-master
│   │   ├── main.tf
│   │   ├── templates
│   │   │   ├── kube-apiserver.yaml
│   │   │   ├── kube-controller-manager.yaml
│   │   │   └── kube-scheduler.yaml
│   │   └── variables.tf
│   ├── kubeconfig
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── kubelet
│   │   ├── main.tf
│   │   ├── templates
│   │   │   ├── kubelet-conf.yml
│   │   │   └── kubelet.service
│   │   └── variables.tf
│   ├── kubelet-bootstrap
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── kubelet-bootstrap-csr
│   │   ├── files
│   │   │   └── kubelet-bootstrap-csr.yaml
│   │   └── main.tf
│   ├── kube-proxy
│   │   ├── main.tf
│   │   ├── templates
│   │   │   └── kube-proxy.yaml
│   │   └── variables.tf
│   ├── kube-vip                        #kube-apiserver的负载均衡
│   │   ├── main.tf
│   │   ├── templates
│   │   │   └── kube-vip.yaml
│   │   └── variables.tf
│   ├── ping                            #测试机器连通性
│   │   ├── main.tf
│   │   └── variables.tf
│   └── tls
│       ├── main.tf
│       ├── templates
│       │   └── openssl.cnf
│       └── variables.tf
├── terraform.tfvars                    #tf配置，需要修改相关信息
├── tf.sh                               #执行shell脚本，无需执行其他命令，在这里进行交互执行即可
└── variables.tf                        #tf变量
```

配置修改介绍terraform.tfvars 
========

主要修改下面的地方
-   如果你有3台服务器,希望3台都是master节点(默认会安装node节点),那就按照如下格式进行填写，node变量留空
-   当master超过2台时,说明集群需要负载均衡,这时候就需要在clusterha处填写预留的vip信息
-   console是为了方便对机器系统初始化后进行重启生效,terraform不允许机器重启,后面会特别说明
```shell
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
```

执行安装
========
1)执行脚本，脚本会安装terraform，并且进行terraform init
```shell
bash tf.sh
```


2)查看tf.sh效果
```shell
bash tf.sh
```


依照上述的module会对应序列号，只需要按照序列号传递即可
例如 1 ,然后回车


3)初始化所有机器
```shell
bash tf.sh    #输入2
```

最终会提示机器ssh断开,这是正常的,terraform不允许机器重启,此时已经重启了除开terraform console的所有机器


4)重启当前机器
这时候terraform console机器(也就是本机)需要手动重启reboot 或 init 6

5)部署containerd服务
```shell
bash tf.sh    #输入3
```

完成后会执行down.sh下载相关的kubernetes二进制包


6)直接执行安装剩余的过程：install  
```shell
bash tf.sh     #输入install  
```


7)查看节点状态和pod信息
```shell
kubectl get node  
kubectl get pod -A 
```

注意：我这里是2master 1node的集群


如果想查看完整的文档介绍请跳转https://huisebug.github.io/2024/02/04/terraform-kubernetes/