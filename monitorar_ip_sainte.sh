#!/bin/bash

# Obtenha o caminho do diretório onde o script está localizado
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Caminho para o arquivo de log
LOG_FILE="$SCRIPT_DIR/print_ip.log"

# Função para obter o IP e registrar no arquivo de log
get_and_log_ip() {
    # Obter o IP usando o comando curl e salvar no arquivo de log
    date "+%Y-%m-%d %H:%M:%S" >> "$LOG_FILE"
    curl ifconfig.me >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
}
#Executar a função para obter e registrar o IP
get_and_log_ip
