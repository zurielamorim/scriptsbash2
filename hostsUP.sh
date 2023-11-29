#!/bin/bash

# Solicitar ao usuário para inserir manualmente a faixa de IP
read -p "Insira a faixa de IP (exemplo: 192.168.0.0/24): " subnet

# Verificar se o formato da faixa de IP é válido
if [[ ! "$subnet" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
    echo -e "Formato de faixa de IP inválido. Por favor, insira uma faixa válida."
    exit 1
fi

# Definir o caminho do arquivo de saída no diretório atual
output_file="$(pwd)/resultado_hostAtivos.txt"

# Usando fping para identificar hosts ativos
hosts=$(fping -r 0 -t 100 -a -g $subnet 2> /dev/null)

# Salvando a lista de hosts ativos em um arquivo
echo "Hosts Ativos:" > "$output_file"
echo "$hosts" >> "$output_file"

# Utilizando nmap para obter informações detalhadas dos hosts ativos
echo -e "\nInformações Detalhadas:" >> "$output_file"
for host in $hosts; do
    nmap_output=$(nmap -sP $host)
    mac=$(echo "$nmap_output" | grep -oE '([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})')
    echo "$host : $mac" >> "$output_file"
done

echo "Resultados salvos em: $output_file"
