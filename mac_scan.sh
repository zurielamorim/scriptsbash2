#!/bin/bash

# Solicitar ao usuário que insira o endereço MAC
read -p "Digite o endereço MAC do dispositivo: " mac_address

# Executar o comando arp e filtrar o resultado usando grep e cut
ip_address=$(arp -a | grep $mac_address | cut -f2 -d " ")

# Verificar se o endereço IP foi encontrado
if [ -n "$ip_address" ]; then
    echo "O endereço IP correspondente ao MAC $mac_address é: $ip_address"
else
    echo "Não foi possível encontrar um endereço IP para o MAC $mac_address"
fi
