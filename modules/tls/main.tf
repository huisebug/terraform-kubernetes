
locals {
    

    apiServerIP      = [for host in var.certSANs.apiServer : host if can(regex("^[\\d.]+$", host))]
    apiServerDomain  = [for host in var.certSANs.apiServer : host if !can(regex("^[\\d.]+$", host))]

    MasterIP = [for master in var.master : master.hostname if can(regex("^[\\d.]+$", master.hostname))]
    MasterDomain = [for master in var.master : master.hostname if !can(regex("^[\\d.]+$", master.hostname))]


    apiIP = concat(local.apiServerIP,local.MasterIP)
    apiDomain = concat(local.apiServerDomain,local.MasterDomain)

    etcdIP      = [for host in var.certSANs.etcd : host if can(regex("^[\\d.]+$", host))]
    etcdDomain  = [for host in var.certSANs.etcd : host if !can(regex("^[\\d.]+$", host))]

}


locals {
  apiDomainAltNames = [
    for i, host in local.apiDomain : "DNS.${i + 6} = ${host}"
    if length(local.apiDomain) > 0
  ]
  apiIPAltNames = [
    for i, host in local.apiIP : "IP.${i + 3} = ${host}"
    if length(local.apiIP) > 0
  ]
  AllnodeIPAltNames = [
    for i, host in var.Allnode : "IP.${i + 3 + length(local.apiIP)} = ${host.ip}"
  ]  
  VIPAltNames = [
  length(var.master) != 1 ? "IP.${3 + length(var.Allnode) + length(local.apiIP)} = ${var.clusterha.vip}" : ""
  ]
  etcdDomainAltNames = [
    for i, host in local.etcdDomain : "DNS.${i + 2} = ${host}"
    if length(local.etcdDomain) > 0
  ]  
  etcdIPAltNames = [
    for i, host in local.etcdIP : "IP.${i + 2} = ${host}"
    if length(local.etcdIP) > 0
  ]
  etcdnodeNames = [
    for i, host in var.etcd : "IP.${i + 2 + length(local.etcdIP)} = ${host.ip}"
  ]  
}

locals {
  apiDomainAltNamesString = join("\n", local.apiDomainAltNames)
    apiIPAltNamesString = join("\n", local.apiIPAltNames)
      AllnodeIPAltNamesString = join("\n", local.AllnodeIPAltNames)
        VIPAltNamesString = join("\n", local.VIPAltNames)
          etcdDomainAltNamesString = join("\n", local.etcdDomainAltNames)
          etcdIPAltNamesString = join("\n", local.etcdIPAltNames)
          etcdnodeNamesString = join("\n", local.etcdnodeNames)
              
}


resource "null_resource" "tls" {


  # 创建相关目录
  provisioner "local-exec" {
    command = <<-EOT
      sudo mkdir -p /etc/kubernetes/pki
      sudo mkdir -p /etc/kubernetes/pki/etcd
    EOT
  }

  connection {
    type        = "ssh"
    host        = "localhost"
    password = var.ssh.password
  }
  # 分发openssl配置文件
  provisioner "file" {
        content = templatefile("modules/tls/templates/openssl.cnf",{
          KubernetesClusterSVCIP = var.KubernetesClusterSVCIP
          apiDomainAltNamesString = local.apiDomainAltNamesString
          apiIPAltNamesString = local.apiIPAltNamesString
          AllnodeIPAltNamesString = local.AllnodeIPAltNamesString
          VIPAltNamesString = local.VIPAltNamesString
          etcdDomainAltNamesString = local.etcdDomainAltNamesString
          etcdIPAltNamesString = local.etcdIPAltNamesString
          etcdnodeNamesString = local.etcdnodeNamesString
    })
        destination = "/etc/kubernetes/pki/openssl.cnf"
    }


  # 生成相关证书tls
  provisioner "local-exec" {
    command = <<-EOT
      cd /etc/kubernetes/pki/
      # kubernetes-ca
      openssl genrsa -out ca.key 2048
      openssl req -x509 -new -nodes -key ca.key -config openssl.cnf -subj "/CN=kubernetes-ca" -extensions v3_ca -out ca.crt -days 10000

      # etcd-ca
      openssl genrsa -out etcd/ca.key 2048
      openssl req -x509 -new -nodes -key etcd/ca.key -config openssl.cnf -subj "/CN=etcd-ca" -extensions v3_ca -out etcd/ca.crt -days 10000

      # front-proxy-ca
      openssl genrsa -out front-proxy-ca.key 2048
      openssl req -x509 -new -nodes -key front-proxy-ca.key -config openssl.cnf -subj "/CN=kubernetes-ca" -extensions v3_ca -out front-proxy-ca.crt -days 10000

      # apiserver-etcd-client 
      openssl genrsa -out apiserver-etcd-client.key 2048
      openssl req -new -key apiserver-etcd-client.key -subj "/CN=apiserver-etcd-client/O=system:masters" -out apiserver-etcd-client.csr
      openssl x509 -in apiserver-etcd-client.csr -req -CA etcd/ca.crt -CAkey etcd/ca.key -CAcreateserial -extensions v3_req_etcd -extfile openssl.cnf -out apiserver-etcd-client.crt -days 10000

      # kube-etcd
      openssl genrsa -out etcd/server.key 2048
      openssl req -new -key etcd/server.key -subj "/CN=etcd-server" -out etcd/server.csr
      openssl x509 -in etcd/server.csr -req -CA etcd/ca.crt -CAkey etcd/ca.key -CAcreateserial -extensions v3_req_etcd -extfile openssl.cnf -out etcd/server.crt -days 10000

      # kube-etcd-peer
      openssl genrsa -out etcd/peer.key 2048
      openssl req -new -key etcd/peer.key -subj "/CN=etcd-peer" -out etcd/peer.csr
      openssl x509 -in etcd/peer.csr -req -CA etcd/ca.crt -CAkey etcd/ca.key -CAcreateserial -extensions v3_req_etcd -extfile openssl.cnf -out etcd/peer.crt -days 10000

      # kube-etcd-healthcheck-client
      openssl genrsa -out etcd/healthcheck-client.key 2048
      openssl req -new -key etcd/healthcheck-client.key -subj "/CN=etcd-client" -out etcd/healthcheck-client.csr
      openssl x509 -in etcd/healthcheck-client.csr -req -CA etcd/ca.crt -CAkey etcd/ca.key -CAcreateserial -extensions v3_req_etcd -extfile openssl.cnf -out etcd/healthcheck-client.crt -days 10000

      # kube-apiserver
      openssl genrsa -out apiserver.key 2048
      openssl req -new -key apiserver.key -subj "/CN=kube-apiserver" -config openssl.cnf -out apiserver.csr
      openssl x509 -req -in apiserver.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 10000 -extensions v3_req_apiserver -extfile openssl.cnf -out apiserver.crt

      # apiserver-kubelet-client
      openssl genrsa -out  apiserver-kubelet-client.key 2048
      openssl req -new -key apiserver-kubelet-client.key -subj "/CN=apiserver-kubelet-client/O=system:masters" -out apiserver-kubelet-client.csr
      openssl x509 -req -in apiserver-kubelet-client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 10000 -extensions v3_req_client -extfile openssl.cnf -out apiserver-kubelet-client.crt

      # front-proxy-client
      openssl genrsa -out  front-proxy-client.key 2048
      openssl req -new -key front-proxy-client.key -subj "/CN=front-proxy-client" -out front-proxy-client.csr
      openssl x509 -req -in front-proxy-client.csr -CA front-proxy-ca.crt -CAkey front-proxy-ca.key -CAcreateserial -days 10000 -extensions v3_req_client -extfile openssl.cnf -out front-proxy-client.crt

      # kube-scheduler
      openssl genrsa -out  kube-scheduler.key 2048
      openssl req -new -key kube-scheduler.key -subj "/CN=system:kube-scheduler" -out kube-scheduler.csr
      openssl x509 -req -in kube-scheduler.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 10000 -extensions v3_req_client -extfile openssl.cnf -out kube-scheduler.crt

      # sa.pub sa.key
      openssl genrsa -out  sa.key 2048
      openssl ecparam -name secp521r1 -genkey -noout -out sa.key
      openssl ec -in sa.key -outform PEM -pubout -out sa.pub
      openssl req -new -sha256 -key sa.key -subj "/CN=system:kube-controller-manager" -out sa.csr
      openssl x509 -req -in sa.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 10000 -extensions v3_req_client -extfile openssl.cnf -out sa.crt

      # admin
      openssl genrsa -out  admin.key 2048
      openssl req -new -key admin.key -subj "/CN=kubernetes-admin/O=system:masters" -out admin.csr
      openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 10000 -extensions v3_req_client -extfile openssl.cnf -out admin.crt

      # 清理 csr srl
      find . -name "*.csr" -o -name "*.srl" -exec  rm -f {} \;

    EOT
  }
}