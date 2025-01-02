root@salvacor:scriptsbash2# cat check_smarctl.sh 
#!/bin/bash

# Define o nome do disco a ser testado (por exemplo, /dev/sda)
DISCO="/dev/sda"

# Verifica se o smartctl está instalado
if ! command -v smartctl &> /dev/null; then
    echo "Erro: O utilitário 'smartctl' não está instalado."
    exit 1
fi

# Executa o teste SMART e extrai informações importantes
echo "Iniciando teste SMART para o disco: $DISCO"
SMART_INFO=$(smartctl -a "$DISCO")
SMART_STATUS=$(echo "$SMART_INFO" | grep -i "SMART overall-health" | awk -F": " '{print $2}')

# Extrai informações importantes do teste
REALLOCATED_SECTORS=$(echo "$SMART_INFO" | grep -i "Reallocated_Sector_Ct" | awk '{print $10}')
PENDING_SECTORS=$(echo "$SMART_INFO" | grep -i "Current_Pending_Sector" | awk '{print $10}')
UNRECOVERED_READ=$(echo "$SMART_INFO" | grep -i "Offline_Uncorrectable" | awk '{print $10}')

# Exibe as informações principais
echo "Resumo do teste SMART:"
echo "  Status geral: $SMART_STATUS"
echo "  Setores realocados: $REALLOCATED_SECTORS"
echo "  Setores pendentes: $PENDING_SECTORS"
echo "  Erros de leitura não recuperados: $UNRECOVERED_READ"

# Alerta em caso de falha no teste
if [[ "$SMART_STATUS" == "FAILED!" ]]; then
    echo -e "\n\033[1;31mALERTA CRÍTICO!\033[0m"
    echo -e "SMART overall-health self-assessment test result: FAILED!"
    echo -e "Drive failure expected in less than 24 hours. SAVE ALL DATA IMMEDIATELY.\n"
else
    echo -e "\nO disco parece estar saudável.\n"
fi

# Exibe informações completas do SMART (opcional)
echo "Informações detalhadas do SMART (para referência):"
echo "$SMART_INFO"
