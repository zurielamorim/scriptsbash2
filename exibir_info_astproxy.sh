#!/bin/bash

# Solicita o número do tronco ao usuário
read -p "Digite o número do tronco/recurso: " trunk_number

# Executa o comando no Docker para mostrar os AORs
aors_output=$(docker exec -it astproxy-$trunk_number asterisk -rx 'pjsip show aors')

# Extrai o primeiro IP após "sip:"
ip_address=$(echo "$aors_output" | grep -m 1 -oP 'sip:\K[0-9.]+')

# Verifica se o IP foi encontrado
if [ -z "$ip_address" ]; then
    echo "Não foi possível encontrar o IP do primeiro AOR."
    exit 1
fi

# Executa o comando no Docker para obter a rota IP
route_output=$(docker exec -it astproxy-$trunk_number ip route get $ip_address)

# Extrai o gateway da operadora (segundo IP na rota)
gateway_ip=$(echo "$route_output" | awk '{print $3}')

# Verifica se o gateway foi encontrado
if [ -z "$gateway_ip" ]; then
    echo "Não foi possível encontrar o gateway da operadora."
    exit 1
fi

# Verifica a conectividade com o gateway da operadora
ping -c 1 $gateway_ip &> /dev/null
if [ $? -eq 0 ]; then
    echo "O gateway da operadora está acessível."
else
    echo "O gateway da operadora está desligado."
    exit 1
fi

# Verifica a conectividade com o SBC da operadora
ping -c 1 $ip_address &> /dev/null
if [ $? -eq 0 ]; then
    echo "Comunicação com o SBC da operadora está ok."
else
    echo "Será necessário entrar em contato com a operadora."
fi
