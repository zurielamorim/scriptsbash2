#!/bin/bash

# Solicita ao usuário que insira o nome do contêiner astproxy
read -p "Por favor, insira o nome do contêiner astproxy a ser monitorado: " CONTAINER_NAME

# Solicita ao usuário que insira o endereço IP do SBC da operadora
read -p "Por favor, insira o IP do SBC da operadora a ser monitorado: " IP

# Exibe mensagem informativa para o usuário
echo "Monitorando o IP $IP. As falhas de ping serão registradas no arquivo ping_log.txt."

# Flag para controlar o estado do IP
IP_RESPONDENDO=false

# Loop infinito
while :
do
    # Executa o ping para o endereço IP
    docker exec -it $CONTAINER_NAME ping -c 1 $IP > /dev/null

    # Verifica o status de retorno do ping
    if [ $? -eq 0 ]; then
        # Se o ping for bem-sucedido e o IP estava anteriormente não respondendo
        if [ $IP_RESPONDENDO = false ]; then
            # Registra a hora atual em que o IP voltou a responder
            echo "$(date +"%Y-%m-%d %H:%M:%S") - O ping para $IP foi restaurado" >> ping_log.txt
            # Atualiza a flag para indicar que o IP está respondendo
            IP_RESPONDENDO=true
        fi
    else
        # Se o ping falhar
        # Registra a hora atual em que o ping falhou
        echo "$(date +"%Y-%m-%d %H:%M:%S") - O ping para $IP falhou" >> ping_log.txt
        # Atualiza a flag para indicar que o IP não está respondendo
        IP_RESPONDENDO=false
    fi

    # Aguarda 60 segundos antes de repetir o loop
    sleep 60
done

