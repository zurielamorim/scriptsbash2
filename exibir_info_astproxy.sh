#!/bin/bash

echo -e "\n"
echo "Executando o script, por favor, aguarde..."
echo -e "\n"

# Obtém os números dos troncos com base nos containers que seguem o padrão astproxy
trunks=$(docker ps --format "{{.Names}}" | grep 'astproxy' | awk -F '-' '{print $2}')

# Conta o número de troncos encontrados
trunk_count=$(echo "$trunks" | wc -l)

# Verifica se há apenas um tronco
if [ "$trunk_count" -eq 1 ]; then
    # Se houver apenas um tronco, seleciona automaticamente
    trunk_number=$trunks
    echo "Número do tronco encontrado: $trunk_number"
    
    # Se o único tronco encontrado for 'vvn', executa o comando fs_cli
    if [ "$trunk_number" == "vvn" ]; then
        echo "Executando comando fs_cli para o tronco astproxy-vvn..."
        docker exec -it astproxy-vvn fs_cli -x 'sofia status'
        exit 0
    fi
else
    # Se houver mais de um tronco, pede para o usuário escolher
    echo "Foram encontrados múltiplos troncos:"
    select trunk_number in $trunks; do
        if [ -n "$trunk_number" ]; then
            echo "Número do tronco selecionado: $trunk_number"
            
            # Verifica se o tronco selecionado é 'vvn' e executa o comando fs_cli
            if [ "$trunk_number" == "vvn" ]; then
                echo "Executando comando fs_cli para o tronco astproxy-vvn..."
                docker exec -it astproxy-vvn fs_cli -x 'sofia status'
                exit 0
            fi
            break
        else
            echo "Opção inválida. Tente novamente."
        fi
    done
fi

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
