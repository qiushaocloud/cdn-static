#!/usr/bin/bash
# ~~~~~~~~~
# Ubuntu 22.04 Minikube install
# Author: Leo
# Usage: bash b2204-auto-install-minikube.sh (不要sudo,使用普通用户)
# 如果安装没成功，请在普通用户下执行 sudo usermod -aG docker "$USER" && newgrp docker，然后再切回普通用户: sudo su {你的用户}

echo "正在准备环境..."
sudo apt-get update -y
sudo apt-get install ca-certificates curl gnupg lsb-release apt-transport-https -y

function install_docker() {
    echo "正在卸载旧版本docker..."
    sudo apt-get remove docker docker-engine docker.io containerd runc -y
    echo "正在添加docker gpg..."
    sudo mkdir -p /etc/apt/keyrings
    if [ -f "/etc/apt/keyrings/docker.gpg" ]; then
        sudo rm /etc/apt/keyrings/docker.gpg
    fi

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    echo "正在安装docker..."
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
    echo "正在添加当前用户${USER}到docker组..."
    echo '如果安装没成功，请在普通用户下执行 sudo usermod -aG docker "$USER" && newgrp docker，然后再切回普通用户: sudo su {你的用户}'
    sudo groupadd docker
    sudo usermod -aG docker "$USER" && newgrp docker &
    #sudo usermod -aG docker "$USER" && echo "usermod finsh"
    #newgrp docker && echo "newgrp docker finsh" &
    echo "sleep 5s"
    sleep 5
    echo "正在设置docker registry国内镜像..."
    if [ -f "/etc/docker/daemon.json" ]; then
        sudo mv /etc/docker/daemon.json{,.bak}
    fi
    cat <<EOF | sudo tee /etc/docker/daemon.json >/dev/null
{
 "registry-mirrors": ["https://docker.mirrors.ustc.edu.cn", "https://registry.docker-cn.com"]
}
EOF
    sudo systemctl restart docker.service
    echo "Docker安装完成."
}

function install_minikube() {
    echo "正在下载安装minikube-linux-amd64..."
    rm -rf minikube-linux-amd64
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    [ ! -f ./minikube-linux-amd64 ] && echo "download latest minikube fail, need download backup file" && curl -LO http://www.qiushaocloud.top/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    echo "正在启动minikube..."
    minikube delete
    # --kubernetes-version=v1.23.8 https://github.com/kubernetes/minikube/issues/14477
    # minikube start --kubernetes-version=v1.23.8 --image-mirror-country=cn --driver=virtualbox
    minikube start --kubernetes-version=v1.23.8 --image-mirror-country=cn --driver=docker
    echo "安装minikube完毕..."
}

function install_kubectl() {
  echo "正在下载安装 kubectl..."
  curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.8/bin/linux/amd64/kubectl
  [ ! -f ./kubectl ] && echo "download kubectl v1.23.8 fail, need download backup file" && curl -LO http://www.qiushaocloud.top/kubectl
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
  kubectl version --client
  kubectl version -o json
  echo "安装kubectl完毕..."
}

install_docker
#echo "正在安装virtualbox..."
#sudo apt install virtualbox virtualbox-ext-pack -y
install_minikube
install_kubectl
echo -e "\n\n"
cat <<EOF
**************************************
            docker version
**************************************
EOF
docker version
cat <<EOF
**************************************
    minikube kubectl -- get po -A
**************************************
EOF
minikube kubectl -- get po -A
# 可选
# echo 'alias kubectl="minikube kubectl --"' >> ~/.profile
# source ~/.profile
echo -e "\n更过信息可参考: https://minikube.sigs.k8s.io/docs/start/"
echo '如果安装没成功，请在普通用户下执行 sudo usermod -aG docker "$USER" && newgrp docker，然后再切回普通用户: sudo su {你的用户}，然后再安装一次'

