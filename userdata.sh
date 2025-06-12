#!/bin/bash
# Atualiza o sistema
yum update -y

# Instala o Docker
amazon-linux-extras enable docker
yum install -y docker
systemctl start docker
systemctl enable docker

# Adiciona o usuário ec2-user ao grupo docker
usermod -aG docker ec2-user

# Instala Docker Compose v2 como plugin
DOCKER_COMPOSE_VERSION="v2.24.7"
mkdir -p /usr/libexec/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64 -o /usr/libexec/docker/cli-plugins/docker-compose
chmod +x /usr/libexec/docker/cli-plugins/docker-compose

# Instala suporte ao EFS
yum install -y nfs-utils amazon-efs-utils

# Cria diretório e monta o EFS
mkdir -p /mnt/efs/wordpress
chmod 777 /mnt/efs/wordpress

echo "fs-id:/ /mnt/efs efs _netdev,tls 0 0" >> /etc/fstab
mount -a

# Cria diretório do projeto e define docker-compose.yml
mkdir -p /home/ec2-user/wordpress
cat <<EOF > /home/ec2-user/wordpress/docker-compose.yml
services:
  wordpress:
    image: wordpress:latest
    volumes:
      - /mnt/efs/wordpress:/var/www/html
    restart: always
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: 
      WORDPRESS_DB_USER:
      WORDPRESS_DB_PASSWORD:
      WORDPRESS_DB_NAME:
EOF

# Ajusta permissões
chown -R ec2-user:ec2-user /home/ec2-user/wordpress

# Executa o docker compose como ec2-user (sem sudo)
su - ec2-user -c "cd /home/ec2-user/wordpress && docker compose up -d"
