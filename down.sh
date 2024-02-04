#!/bin/bash
set -e
KUBERNETES_VERSION=${KUBERNETES_VERSION:-v1.26.12}
CNI_VERSION=${CNI_VERSION:-v1.3.0}



function containerd_down_kubernetes(){
    echo containerd_down_kubernetes
    ctr i pull registry.cn-hangzhou.aliyuncs.com/huisebug/kubernetespkg:$KUBERNETES_VERSION
    ctr run --rm  --mount type=bind,src=$(pwd),dst=/tmp,options=rbind:rw registry.cn-hangzhou.aliyuncs.com/huisebug/kubernetespkg:$KUBERNETES_VERSION kubernetespkg
	tar -zxf kubernetes-server-linux-amd64.tar.gz  --strip-components=3 -C /usr/local/bin kubernetes/server/bin/kube{let,ctl}
    
}

function containerd_down_cni(){
    echo containerd_down_cni
    ctr i pull registry.cn-hangzhou.aliyuncs.com/huisebug/cnipkg:${CNI_VERSION}
    ctr run --rm  --mount type=bind,src=$(pwd),dst=/tmp,options=rbind:rw registry.cn-hangzhou.aliyuncs.com/huisebug/cnipkg:${CNI_VERSION} cnipkg sh -c 'cp -rf /opt/cni* /tmp/'
    mkdir -p /opt/cni/bin && tar -zxf cni-plugins-linux-amd64-${CNI_VERSION}.tgz -C /opt/cni/bin 
}




container=$1
if [ "$container"x = "containerd"x ]; then
echo 开始下载kubernetes---------------------------------------------------------------------------------
    [ ! -f kubernetes-server-linux-amd64.tar.gz ] && \
    ${container}_down_kubernetes
echo 开始下载cni---------------------------------------------------------------------------------
    [ ! -f cni-plugins-linux-amd64-${CNI_VERSION}.tgz ] && \
    ${container}_down_cni 
else
echo "请传入参数: containerd "
fi

