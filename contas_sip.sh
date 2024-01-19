#!/bin/bash

# Função para obter conta e senha do ramal
get_account_password() {
    ramal=$1
    cat /etc/asterisk/sip.d/00000_from_database.conf | grep -P "(username|secret|$ramal)" | sed 's/username/Conta/g' | sed 's/secret/Senha/g' | sed 's/Senha.*/&\'$'\n/g' | tr -d '$'
}

# Perguntar ao usuário se deseja informar um ramal
read -p "Deseja informar um número de ramal? (S/N): " choice

if [ "$choice" == "S" ] || [ "$choice" == "s" ]; then
    # Solicitar número do ramal
    read -p "Digite o número do ramal: " ramal_number

    # Obter conta e senha
    ramal_info=$(cat /etc/asterisk/sip.d/00000_from_database.conf | grep -P "(username|secret|$ramal)" | sed 's/username/Conta/g' | sed 's/secret/Senha/g' | sed 's/Senha.*/&\'$'\n/g' | tr -d '$' | grep -a1 $ramal_number)

    # Exibir informações se houver
    if [ -n "$ramal_info" ]; then
        echo -e "\nInformações para o Ramal $ramal_number:\n$ramal_info"
    else
        echo "Nenhuma informação encontrada para o Ramal $ramal_number."
    fi
else
    # Se o usuário pressionar Enter sem fornecer um número de ramal, imprimir tudo
    result=$(cat /etc/asterisk/sip.d/00000_from_database.conf | grep -P '(username|secret)' | sed 's/username/Conta/g' | sed 's/secret/Senha/g' | sed 's/Senha.*/&\'$'\n/g' | tr -d '$')
    echo -e "\nInformações para todos os Ramais:\n$result"
fi
