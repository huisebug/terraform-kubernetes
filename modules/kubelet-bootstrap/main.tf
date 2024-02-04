resource "null_resource" "kubelet-bootstrap" {
  provisioner "local-exec" {
    command = <<-EOT
      TOKEN_PUB=$(openssl rand -hex 3)
      TOKEN_SECRET=$(openssl rand -hex 8)
      BOOTSTRAP_TOKEN="$TOKEN_PUB.$TOKEN_SECRET"
      cat >/etc/environment<<EOF
      TOKEN_PUB=$TOKEN_PUB
      TOKEN_SECRET=$TOKEN_SECRET
      EOF
      kubectl config set-cluster ${var.CLUSTER_NAME} --certificate-authority=/etc/kubernetes/pki/ca.crt --embed-certs=true --server=${var.KUBE_APISERVER} --kubeconfig=/etc/kubernetes/bootstrap.kubeconfig
      kubectl config set-context kubelet-bootstrap@${var.CLUSTER_NAME} --cluster=${var.CLUSTER_NAME} --user=kubelet-bootstrap --kubeconfig=/etc/kubernetes/bootstrap.kubeconfig
      kubectl config set-credentials kubelet-bootstrap --token=$BOOTSTRAP_TOKEN --kubeconfig=/etc/kubernetes/bootstrap.kubeconfig
      kubectl config use-context kubelet-bootstrap@${var.CLUSTER_NAME} --kubeconfig=/etc/kubernetes/bootstrap.kubeconfig
      kubectl config view --kubeconfig=/etc/kubernetes/bootstrap.kubeconfig
    EOT
  }
}
