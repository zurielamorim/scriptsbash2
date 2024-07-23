#!/bin/bash

echo -e "\n"
echo "Favor verificar o recurso digitando | docker ps | antes de executar." 
echo -e "\n"

# Solicita o número do tronco ao usuário
read -p "Digite o número do tronco/recurso: " trunk_number
echo -e "\n"

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
docker exec -it astproxy-$trunk_number ping -c 1 $gateway_ip &> /dev/null
if [ $? -eq 0 ]; then
    echo "O gateway $gateway_ip da operadora está acessível."
    echo -e "\n"
else
    echo "O gateway $gateway_ip da operadora está desligado."
    echo -e "\n"
    exit 1
fi

# Verifica a conectividade com o SBC da operadora
docker exec -it astproxy-$trunk_number ping -c 1 $ip_address &> /dev/null
if [ $? -eq 0 ]; then
    echo "Comunicação com o SBC $ip_address da operadora está ok."
    echo -e "\n"
else
    echo "Será necessário entrar em contato com a operadora, SBC $ip_address não está respondendo."
    echo -e "\n"
fi
