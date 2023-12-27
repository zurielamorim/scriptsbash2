#!/bin/bash

# Solicitar ao usuário para inserir manualmente o endereço IP da sub-rede
read -p "Insira o endereço IP da sub-rede (exemplo: 10.0.0.0/16): " subnet

# Verificar se o formato do endereço IP é válido
if [[ ! "$subnet" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
    echo -e "Formato de endereço IP inválido. Por favor, insira um endereço válido."
    exit 1
fi

# Obter o diretório do script
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Definir o caminho do arquivo de saída no mesmo diretório do script
output_file="$script_dir/resultado_scan.txt"

# Usar fping para identificar hosts ativos
hosts=$(fping -r 0 -t 100 -a -g $subnet 2> /dev/null)

subnetFilter=$(echo -e ${subnet} | cut -c1-$((${#subnet} - 4)))
myIpAddr=$(ifconfig | grep ${subnetFilter} | awk '{print $2}' | awk -F ':' '{print $2}')

# Salvar a lista de hosts ativos em um arquivo
echo -e "Informações Detalhadas:" > "$output_file"

for host in $hosts; do

    if [[ ${host} == ${myIpAddr} ]]
    then
        continue
    fi

    echo -e "Obtendo MAC do host ${host}...\n"    
    mac=$(arp -n $host | grep ether | awk '{print $3}')

    if [[ -z ${mac} ]]
    then
	echo -e "Ignorando ${host}, pois retornou um MAC invalido para consulta\n"
	continue
    fi

    echo -e "Formatando MAC do host ${mac}...\n"
    formated_mac=$(echo -e ${mac} | awk -F ':' '{print $1 $2 $3}')

    echo -e "Consultando Vendor ${formated_mac}...\n"
    manufacturer_info=$(grep -i ${formated_mac} mac_reference.txt | awk '{print $2, $3, $4}')

    echo -e "Imprimindo Vendor no arquivo ${output_file}\n\n"
    echo -e "IP: $host | MAC: $mac | Fabricante: $manufacturer_info" >> ${output_file}
done
    echo -e "Resultados salvos em: $output_file"
    exit
