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

# Define os limites para os valores SMART
declare -A limits
limits[Reallocated_Sector_Ct]=5
limits[Power_On_Hours]=40000
limits[Power_Cycle_Count]=50000
limits[Reported_Uncorrect]=1
limits[Temperature_Celsius]=50
limits[UDMA_CRC_Error_Count]=1
limits[Total_LBAs_Written]=1000000000000
limits[Total_LBAs_Read]=1000000000000

# Filtra e exibe as informações relevantes
echo "Informações Relevantes do Disco: $root_device"
echo "---------------------------------"

smartctl_output_filtered=$(echo "$smartctl_output" | grep -E "Reallocated_Sector_Ct|Power_On_Hours|Power_Cycle_Count|Reported_Uncorrect|Temperature_Celsius|UDMA_CRC_Error_Count|Total_LBAs_Written|Total_LBAs_Read" | awk -v limits="${limits[*]}" '
BEGIN {
  split(limits, limitArray)
  limitMap["Reallocated_Sector_Ct"] = limitArray[1]
  limitMap["Power_On_Hours"] = limitArray[2]
  limitMap["Power_Cycle_Count"] = limitArray[3]
  limitMap["Reported_Uncorrect"] = limitArray[4]
  limitMap["Temperature_Celsius"] = limitArray[5]
  limitMap["UDMA_CRC_Error_Count"] = limitArray[6]
  limitMap["Total_LBAs_Written"] = limitArray[7]
  limitMap["Total_LBAs_Read"] = limitArray[8]
  translate["Reallocated_Sector_Ct"] = "Setores realocados"
  translate["Power_On_Hours"] = "Horas de operação"
  translate["Power_Cycle_Count"] = "Ciclos de energia"
  translate["Reported_Uncorrect"] = "Erros de leitura/escrita"
  translate["Temperature_Celsius"] = "Temperatura"
  translate["UDMA_CRC_Error_Count"] = "Erros UDMA CRC"
  translate["Total_LBAs_Written"] = "Dados escritos"
  translate["Total_LBAs_Read"] = "Dados lidos"
  explanations["Reallocated_Sector_Ct"] = "Possível falha de disco iminente. Recomenda-se backup e substituição."
  explanations["Power_On_Hours"] = "Disco em uso por muito tempo. Recomenda-se monitoramento e backup frequente."
  explanations["Power_Cycle_Count"] = "Disco com alto desgaste. Recomenda-se monitoramento e substituição preventiva."
  explanations["Reported_Uncorrect"] = "Possível falha de disco. Recomenda-se testes e backup."
  explanations["Temperature_Celsius"] = "Disco superaquecido. Recomenda-se verificar ventilação e resfriamento."
  explanations["UDMA_CRC_Error_Count"] = "Possível falha de cabo ou controlador. Recomenda-se verificar conexões."
  explanations["Total_LBAs_Written"] = "Disco próximo ao limite de vida útil. Recomenda-se monitoramento e backup."
  explanations["Total_LBAs_Read"] = "Disco próximo ao limite de vida útil. Recomenda-se monitoramento e backup."
}
{
  value = ($1 == "194" || $1 == "231") ? $10 : $10
  attr = $2
  translated_attr = translate[attr]
  explanation = explanations[attr]
  if (value > limitMap[attr]) {
    status = "Ponto de Atenção"
    explanation = explanation
  } else {
    status = "Normal"
    explanation = ""
  }
  if ($1 == "194" || $1 == "231") {
    temp = "| " value " °C |"
    print translated_attr ": " temp " (" status ") " explanation "\n"
    if (status == "Ponto de Atenção") {
      pontos_de_atencao[i++] = translated_attr ": " temp " (" status ") " explanation
    }
  } else if ($1 == "9" || $1 == "12" || $1 == "5" || $1 == "187" || $1 == "199" || $1 == "241" || $1 == "242") {
    print translated_attr ": | " value " | (" status ") " explanation "\n"
    if (status == "Ponto de Atenção") {
      pontos_de_atencao[i++] = translated_attr ": | " value " | (" status ") " explanation
    }
  }
}')

echo -e "$smartctl_output_filtered"

# Explicação sobre os pontos de atenção
if [ ${#pontos_de_atencao[@]} -gt 0 ]; then
    echo ""
    echo "Pontos de Atenção:"
    for ponto in "${pontos_de_atencao[@]}"; do
        echo -e "$ponto"
    done

    echo ""
    echo "Explicação:"
    echo "Os pontos de atenção listados acima indicam que determinados parâmetros do disco rígido estão fora dos limites aceitáveis. Esses parâmetros podem sinalizar problemas potenciais com o disco, como setores realocados, alta temperatura, ou erros de comunicação. É recomendável monitorar esses valores e considerar a substituição do disco se os problemas persistirem."
fi

# Saída de script com sucesso
exit 0
