#!/bin/bash

CONFIG_FILE="/home/futurofone/config/config.ini"
LOG_FILE="/var/log/asterisk/ffpainel_integracao.log"
CGI_PATH="/cgi-bin/dwserver.cgi/se1"

echo -e "\n\n--------"

a=$(grep "$CGI_PATH" "$CONFIG_FILE" | tr -d '[:space:]')
if [ -z "$a" ]; then
    echo "Config.ini: $(tput setaf 1)$(tput smso)Fail$(tput sgr 0)"
    a=$(grep "wsClinux" "$CONFIG_FILE" | tr -d '[:space:]')
    b="http://$(echo "$a" | cut -d '/' -f 3)/cgi-bin/dwserver.cgi/se1/doListaVersao"
else
    echo "Config.ini: $(tput setaf 2)$(tput smso)OK$(tput sgr 0)"
    b="$(echo "$a" | cut -d '"' -f 2)/doListaVersao"
fi

b=$(echo "$b" | tr -d '[:space:]')

if ! grep -q "ERRO ::: Retornou código 500" "$LOG_FILE"; then
    echo "ERRO 500: $(tput setaf 2)$(tput smso)OK$(tput sgr 0)"
else
    echo "ERRO 500: $(tput setaf 1)$(tput smso)Fail$(tput sgr 0) (encontrado)"
fi

if ! grep -q "ERRO ::: Retornou código 401" "$LOG_FILE"; then
    echo "ERRO 401: $(tput setaf 2)$(tput smso)OK$(tput sgr 0)"
else
    echo "ERRO 401: $(tput setaf 1)$(tput smso)Fail$(tput sgr 0) (encontrado)"
fi

echo "Versao CLINUX: $b"
curl_output=$(curl -s -S "$b" 2>&1)
echo "$curl_output"

echo -e "\n--------"
