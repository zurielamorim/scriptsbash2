#!/bin/bash
#############################################
# Name: ipscan.sh
# Created by: Zuriel
# Adapted by: Josimar
#############################################

echo -e "\n#####Para utilizar o script, é necessário ter o fping instalado.#####\n\nCaso não o possua, instale-o antes de executar o script.\n"

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

total_hosts=0
total_no_mac=0

for host in $hosts; do

    if [[ ${host} == ${myIpAddr} ]]
    then
        continue
    fi

    echo -e "Obtendo MAC do host ${host}...\n"    
    mac=$(arp -n $host | grep ether | awk '{print $3}')

    if [[ -z ${mac} ]]
    then
        echo -e "Nenhum MAC encontrado para ${host}, registrando IP no arquivo.\n"
        echo -e "IP: $host | MAC: N/A | Fabricante: Não encontrado" >> ${output_file}
        total_no_mac=$((total_no_mac + 1))
        continue
    fi

    echo -e "Formatando MAC do host ${mac}...\n"
    formated_mac=$(echo -e ${mac} | awk -F ':' '{print $1 $2 $3}')

    echo -e "Consultando Vendor ${formated_mac}...\n"
    manufacturer_info=$(grep -i ${formated_mac} mac_reference.txt | awk '{print $2, $3, $4}')

    echo -e "Imprimindo Vendor no arquivo ${output_file}\n\n"
    echo -e "IP: $host | MAC: $mac | Fabricante: $manufacturer_info" >> ${output_file}

    total_hosts=$((total_hosts + 1))
done

# Adicionar a mensagem ao final do arquivo
echo -e "\nTotal de hosts com MAC encontrado: $total_hosts" >> ${output_file}
echo -e "Total de hosts sem MAC: $total_no_mac" >> ${output_file}

echo -e "\n\nResultados salvos em: $output_file"

echo -e "\n\n##### Para verificar o resultado, basta usar o comando abaixo: #####\n\ncat $output_file e filtrar o IP necessário."
exit
