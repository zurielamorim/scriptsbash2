#!/bin/bash

# Solicitar ao usuário para inserir manualmente o endereço IP da sub-rede
read -p "Insira o endereço IP da sub-rede (exemplo: 10.0.0.0/16): " subnet

# Verificar se o formato do endereço IP é válido
if [[ ! "$subnet" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
    echo "Formato de endereço IP inválido. Por favor, insira um endereço válido."
    exit 1
fi

# Obter o diretório do script
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Definir o caminho do arquivo de saída no mesmo diretório do script
output_file="$script_dir/resultado_scan.txt"

# Usar fping para identificar hosts ativos
hosts=$(fping -a -g $subnet)

subnetFilter=$(echo ${subnet} | cut -c1-$((${#subnet} - 4)))
myIpAddr=$(ifconfig | grep ${subnetFilter} | awk '{print $2}' | awk -F ':' '{print $2}')

# Salvar a lista de hosts ativos em um arquivo
echo "Informações Detalhadas:" > "$output_file"

for host in $hosts; do
    if [ ${host} == ${myIpAddr} ]
    then
        continue
    fi    
    mac=$(arp -n $host | grep ether | awk '{print $3}')

    formated_mac=$(echo ${mac} | awk -F ':' '{print $1 $2 $3}')
    
    manufacturer_info=$(grep -i ${formated_mac} mac_reference.txt | awk '{print $2}')
    
    echo "IP: $host | MAC: $mac | Fabricante: $manufacturer_info" >> ${output_file}
done
    echo "Resultados salvos em: $output_file"
    exit
