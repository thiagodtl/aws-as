#!/bin/bash

# Função para verificar e instalar o Docker
install_docker() {
    if ! command -v docker &> /dev/null; then
        echo "Docker não está instalado. Instalando Docker..."
        sudo yum update -y
        sudo amazon-linux-extras install docker -y
        sudo systemctl enable docker
        sudo systemctl start docker
        sudo usermod -a -G docker ec2-user
    else
        echo "Docker já está instalado."
        if ! sudo systemctl is-active --quiet docker; then
            echo "Iniciando o serviço Docker..."
            sudo systemctl start docker
        else
            echo "Docker já está em execução."
        fi
    fi
}

# Função para verificar e instalar o Docker Compose
install_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        echo "Docker Compose não está instalado. Instalando Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    else
        echo "Docker Compose já está instalado."
    fi
}

# Função para montar o EFS
mount_efs() {
    EFS_ID="fs-0d4a1bf73640d3562"  # Substitua com o seu ID do EFS
    EFS_MOUNT_POINT="/mnt/efs"

    if ! grep -qs "$EFS_MOUNT_POINT" /proc/mounts; then
        echo "Montando o EFS..."
        sudo mkdir -p $EFS_MOUNT_POINT
        sudo yum install -y amazon-efs-utils
        sudo mount -t efs $EFS_ID:/ $EFS_MOUNT_POINT
        echo "$EFS_ID:/ $EFS_MOUNT_POINT efs defaults,_netdev 0 0" | sudo tee -a /etc/fstab
    else
        echo "EFS já está montado."
    fi
}

# Chamar as funções
install_docker
install_docker_compose
mount_efs

echo "Script de inicialização concluído."
