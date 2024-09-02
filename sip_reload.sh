#!/bin/bash

# Caminhos dos scripts PHP
caminho_script1="/home/futurofone/scripts/new/ajustaAsteriskIncludes.php"
caminho_script2="/home/futurofone/scripts/new/ajustaAsteriskConf.php"

# Executa os scripts PHP
php "${caminho_script1}"
php "${caminho_script2}"

# Recarrega os módulos IAX2, SIP e DIALPLAN no Asterisk
asterisk -rx 'iax2 reload'
asterisk -rx 'sip reload'
sleep 2
asterisk -rx 'reload'
asterisk -rx 'dialplan reload'

# Mensagem de sucesso
echo "Todos os comandos foram executados com sucesso!"
