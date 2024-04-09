#!/bin/bash

# Solicita que o usuário digite o número do ramal
read -p "Digite o número do ramal: " ramal

# Salva o número do ramal em uma variável
ramal_numero="$ramal"

# Executa o comando do Asterisk para mostrar informações do peer SIP do ramal
info_peer=$(asterisk -rx "sip show peer $ramal_numero" | grep -oP 'Reg\. Contact : sip:[^:]+:[0-9]+')

# Extrai o endereço IP do contato registrado do output
ip_contato=$(echo "$info_peer" | grep -oP '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')

# Exibe o endereço IP público do cliente
echo "O endereço IP público do cliente é: $ip_contato"
