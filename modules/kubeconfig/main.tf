resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = <<-EOT
      kubectl config set-cluster ${var.CLUSTER_NAME} \
        --certificate-authority=/etc/kubernetes/pki/ca.crt \
        --embed-certs=true \
        --server=${var.KUBE_APISERVER} \
        --kubeconfig=/etc/kubernetes/${each.value.KUBE_CONFIG} && \
       kubectl config set-credentials ${each.value.KUBE_USER} \
        --client-certificate=/etc/kubernetes/pki/${each.value.KUBE_CERT}.crt \
        --client-key=/etc/kubernetes/pki/${each.value.KUBE_CERT}.key \
        --embed-certs=true \
        --kubeconfig=/etc/kubernetes/${each.value.KUBE_CONFIG} && \
       kubectl config set-context ${each.value.KUBE_USER}@${var.CLUSTER_NAME} \
        --cluster=${var.CLUSTER_NAME} \
        --user=${each.value.KUBE_USER} \
        --kubeconfig=/etc/kubernetes/${each.value.KUBE_CONFIG} && \
       kubectl config use-context ${each.value.KUBE_USER}@${var.CLUSTER_NAME} --kubeconfig=/etc/kubernetes/${each.value.KUBE_CONFIG}
    EOT

    interpreter = ["bash", "-c"]
  }

  for_each = {
    controller_manager = {
      KUBE_USER   = "system:kube-controller-manager",
      KUBE_CERT   = "sa",
      KUBE_CONFIG = "controller-manager.kubeconfig",
    },
    kube_scheduler    = {
      KUBE_USER   = "system:kube-scheduler",
      KUBE_CERT   = "kube-scheduler",
      KUBE_CONFIG = "scheduler.kubeconfig",
    },
    admin             = {
      KUBE_USER   = "kubernetes-admin",
      KUBE_CERT   = "admin",
      KUBE_CONFIG = "admin.kubeconfig",
    },
  }
}
