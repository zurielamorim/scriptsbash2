#!/bin/bash

# Tela de aviso e confirmação
echo "Antes de iniciar a execução do script, é fundamental garantir que o backup do banco de dados de destino esteja devidamente atualizado."
echo "Atenção: Este script irá parar os seguintes serviços no servidor de origem:"
echo "- cron"
echo "- rudder-agent"
echo "- supervisorctl"
echo "- openvpn"
echo "- mysql"
echo "- apache2"
echo "- docker"
read -p "Deseja prosseguir com a sincronização? (y/n): " confirm

# Verificar a resposta
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    # Parar serviços no servidor de origem
    /etc/init.d/cron stop
    /etc/init.d/rudder-agent stop
    /usr/bin/supervisorctl stop all
    /etc/init.d/openvpn stop
    /etc/init.d/mysql stop
    /etc/init.d/apache2 stop
    /etc/init.d/docker stop

    # Mover o diretório de backup do MySQL
    mv /home/futurofone/backup/mysql/ /home/futurofone/mysql.old

    # Solicitar informações do usuário
    read -p "Digite o nome de usuário de destino: " DEST_USER
    read -p "Digite o IP do servidor de destino: " DEST_IP

    # Array de diretórios a serem sincronizados
    directories=(
        "/home/futurofone/"
        "/var/www/"
        "/srv/tftp/"
        "/root/"
        "/opt/rudder/"
        "/var/rudder/"
        "/etc/"
    )

    # Loop para sincronizar cada diretório
    for dir in "${directories[@]}"; do
        rsync -avz --exclude 'udev/rules.d/70-persistent-net.rules' --exclude 'network/interfaces' --exclude 'fstab' --exclude 'rc.local' "$dir"* "$DEST_USER@$DEST_IP":$dir
    done
else
    echo "Sincronização cancelada."
fi
