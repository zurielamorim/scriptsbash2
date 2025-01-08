#!/bin/bash

echo -e "\n"
echo "Executando o script, por favor, aguarde..."
echo -e "\n"


trunks=$(docker ps --format "{{.Names}}" | grep 'astproxy' | awk -F '-' '{print $2}')

trunk_count=$(echo "$trunks" | wc -l)


if [ "$trunk_count" -eq 1 ]; then
    
    trunk_number=$trunks
    echo "Número do tronco encontrado: $trunk_number"
    
    
    if [ "$trunk_number" == "vvn" ]; then
        echo "Executando comando fs_cli para o tronco astproxy-vvn..."
        docker exec -it astproxy-vvn fs_cli -x 'sofia status'
        exit 0
    fi
else
    
    echo "Foram encontrados múltiplos troncos:"
    select trunk_number in $trunks; do
        if [ -n "$trunk_number" ]; then
            echo "Número do tronco selecionado: $trunk_number"
            
            
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


aors_output=$(docker exec -it astproxy-$trunk_number asterisk -rx 'pjsip show aors')


ip_address=$(echo "$aors_output" | grep -m 1 -oP 'sip:\K[0-9.]+')


if [ -z "$ip_address" ]; then
    echo "Não foi possível encontrar o IP do primeiro AOR."
    exit 1
fi


route_output=$(docker exec -it astproxy-$trunk_number ip route get $ip_address)


gateway_ip=$(echo "$route_output" | awk '{print $3}')


if [ -z "$gateway_ip" ]; then
    echo "Não foi possível encontrar o gateway da operadora."
    exit 1
fi


docker exec -it astproxy-$trunk_number ping -c 1 $gateway_ip &> /dev/null
if [ $? -eq 0 ]; then
    echo "O gateway $gateway_ip da operadora está acessível."
    echo -e "\n"
else
    echo "O gateway $gateway_ip da operadora está desligado."
    echo -e "\n"
    exit 1
fi


docker exec -it astproxy-$trunk_number ping -c 1 $ip_address &> /dev/null
if [ $? -eq 0 ]; then
    echo "Comunicação com o SBC $ip_address da operadora está ok."
    echo -e "\n"
else
    echo "Será necessário entrar em contato com a operadora, SBC $ip_address não está respondendo."
    echo -e "\n"
fi
