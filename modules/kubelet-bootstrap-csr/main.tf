resource "null_resource" "wait_for_cluster" {
  provisioner "local-exec" {
    command = "kubectl get cs"
    
    environment = {
      # Set any necessary environment variables
    }
  }

  triggers = {
    cluster_check = "${timestamp()}"
  }
}

resource "null_resource" "create_bootstrap_secret" {
  provisioner "local-exec" {
    command = <<EOT
      # 更新系统变量
      source /etc/environment
      kubectl -n kube-system create secret generic bootstrap-token-$TOKEN_PUB \
        --type 'bootstrap.kubernetes.io/token' \
        --from-literal description="cluster bootstrap token" \
        --from-literal token-id=$TOKEN_PUB \
        --from-literal token-secret=$TOKEN_SECRET \
        --from-literal usage-bootstrap-authentication=true \
        --from-literal usage-bootstrap-signing=true
    EOT

    environment = {
      # Set any necessary environment variables
    }
  }

  depends_on = [null_resource.wait_for_cluster]

}

resource "null_resource" "bind_role" {
  provisioner "local-exec" {
    command = "kubectl create clusterrolebinding kubeadm:kubelet-bootstrap --clusterrole system:node-bootstrapper --group system:bootstrappers"
    
    environment = {
      # Set any necessary environment variables
    }
  }

  depends_on = [null_resource.create_bootstrap_secret]
}

resource "null_resource" "create_clusterrolebinding" {
  provisioner "local-exec" {
    command = "kubectl apply -f ./modules/kubelet-bootstrap-csr/files/kubelet-bootstrap-csr.yaml"


    environment = {
      # Set any necessary environment variables
    }
  }

  depends_on = [null_resource.bind_role]
}
