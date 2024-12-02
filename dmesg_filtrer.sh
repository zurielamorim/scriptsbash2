#!/bin/bash

echo "Digite o termo para buscar no dmesg (ex.: power, reboot):"
read term

# Processar as linhas filtradas pelo termo
dmesg | grep "$term" | while read -r line; do
    # Extraia o tempo relativo (no formato [    0.595651]) e remova os colchetes
    RELATIVE_TIME=$(echo "$line" | grep -oP "^\[\s*\K[0-9]+\.[0-9]+")
    
    if [[ -n $RELATIVE_TIME ]]; then
        # Obtenha a data e hora atual em timestamp
        BOOT_TIME=$(date -d "$(who -b | awk '{print $3, $4}')" +%s)
        
        # Converta o tempo relativo para inteiro (segundos)
        RELATIVE_SECONDS=${RELATIVE_TIME%%.*}
        
        # Some o tempo relativo ao horário de boot
        EVENT_TIMESTAMP=$((BOOT_TIME + RELATIVE_SECONDS))
        
        # Formate o timestamp final para uma data legível
        FORMATTED_DATE=$(date -d "@$EVENT_TIMESTAMP" +"%a %b %d %T %z %Y")
        
        # Imprima a linha com a data formatada
        echo "$FORMATTED_DATE $line"
    else
        # Se não houver tempo relativo, imprima a linha original
        echo "$line"
    fi
done
