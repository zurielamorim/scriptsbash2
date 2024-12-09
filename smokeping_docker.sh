#!/bin/bash

NETWORK_NAME="smokeping"

CONTAINER_NAME="smokeping"

DATA_DIR="/opt/smokeping/data"
CONFIG_DIR="/opt/smokeping/config"

IMAGE="linuxserver/smokeping"

# Validar se a rede existe
if ! docker network ls | grep -q "$NETWORK_NAME"; then
    echo "Criando a rede Docker '$NETWORK_NAME'..."
    docker network create "$NETWORK_NAME"
else
    echo "A rede '$NETWORK_NAME' já existe."
fi

# Validar contêiner
if docker ps -a | grep -q "$CONTAINER_NAME"; then
    echo "O contêiner '$CONTAINER_NAME' já existe. Removendo-o..."
    docker stop "$CONTAINER_NAME" >/dev/null 2>&1
    docker rm "$CONTAINER_NAME" >/dev/null 2>&1
fi

# Cria e inicia o contêiner
echo "Criando o contêiner '$CONTAINER_NAME'..."
docker run -d --name="$CONTAINER_NAME" --restart=always --network="$NETWORK_NAME" \
    -p 10280:80 \
    -v "$DATA_DIR:/data" \
    -v "$CONFIG_DIR:/config" \
    -v /etc/localtime:/etc/localtime:ro \
    "$IMAGE"

if [ $? -ne 0 ]; then
    echo "Houve um erro ao criar o contêiner '$CONTAINER_NAME'."
    exit 1
fi

echo "O contêiner '$CONTAINER_NAME' foi criado com sucesso!"

read -p "Digite o IP de WAN do cliente que deseja monitorar (ou pressione Enter para não alterar nada): " WAN_IP

TARGETS_FILE="$CONFIG_DIR/Targets"

if [ -z "$WAN_IP" ]; then
    echo "Nenhum IP fornecido. O arquivo de configuração não será alterado."
else
    # Substituir Targets
    echo "Atualizando o arquivo de configuração: $TARGETS_FILE..."

    cat <<EOF > "$TARGETS_FILE"
*** Targets ***

probe = FPing

menu = Top
title = Network Latency Grapher
remark = Welcome to the SmokePing website of WORKS Company.          Here you will learn all about the latency of our network.

+ InternetCliente

menu = Ip Cliente
title = Internet Sites

++ Voip
menu = Voip-$WAN_IP
title = Voip-$WAN_IP
host = $WAN_IP
EOF

    if [ $? -eq 0 ]; then
        echo "Arquivo de configuração atualizado com sucesso!"
    else
        echo "Erro ao atualizar o arquivo de configuração."
        exit 1
    fi

    # Reinicia o contêiner para aplicar as mudanças
    echo "Reiniciando o contêiner '$CONTAINER_NAME'..."
    docker restart "$CONTAINER_NAME"

    if [ $? -eq 0 ]; then
        echo "O contêiner '$CONTAINER_NAME' foi reiniciado com sucesso!"
    else
        echo "Erro ao reiniciar o contêiner."
        exit 1
    fi
fi
