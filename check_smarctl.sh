#!/bin/bash

# Verifica o dispositivo onde está montado o root (/)
root_device=$(df / | tail -1 | awk '{print $1}')

# Converte o UUID para o caminho do dispositivo real, se necessário
if [[ $root_device =~ /dev/disk/by-uuid/ ]]; then
  root_device=$(readlink -f "$root_device")
fi

# Verifica se o root_device é uma partição
if [[ $root_device =~ /dev/[a-zA-Z]+[0-9]+ ]]; then
  # Remove o número da partição para obter o dispositivo principal
  root_device=$(echo $root_device | sed 's/[0-9]*$//')
fi

# Verifica se o smartctl está instalado
if ! command -v smartctl &> /dev/null; then
    echo "smartctl não está instalado. Instale-o para continuar."
    exit 1
fi

# Executa o comando smartctl para o dispositivo identificado
smartctl_output=$(smartctl -a "$root_device")

# Verifica se o comando smartctl foi bem-sucedido
if [ $? -ne 0 ]; then
    echo "Erro ao executar smartctl em $root_device."
    exit 1
fi

# Filtra e exibe as informações relevantes
echo "Informações Relevantes do Disco: $root_device"
echo "---------------------------------"
echo "$smartctl_output" | grep -E "Reallocated_Sector_Ct|Power_On_Hours|Power_Cycle_Count|Reported_Uncorrect|Temperature_Celsius|UDMA_CRC_Error_Count|Total_LBAs_Written|Total_LBAs_Read" | awk '
{
  if ($1 == "194" || $1 == "231") {
    temp = $10 " °C";
    print $2 ": " temp;
  } else if ($1 == "9" || $1 == "12" || $1 == "5" || $1 == "187" || $1 == "199" || $1 == "241" || $1 == "242") {
    print $2 ": " $10;
  }
}'

# Saída de script com sucesso
exit 0
