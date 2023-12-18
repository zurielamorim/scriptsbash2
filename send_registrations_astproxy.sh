#!/bin/bash

# Comando para enviar unregister para todos os PJSIP
echo "### PJSIP Send Unregister *all ###"
docker exec -it astproxy asterisk -rx 'pjsip send unregister *all'
echo "##################################"
echo ""

# Comando para enviar register para todos os PJSIP
echo "### PJSIP Send Register *all ###"
docker exec -it astproxy asterisk -rx 'pjsip send register *all'
echo "################################"
echo ""

# Esperar 8 segundos
sleep 8

# Comando para exibir registros PJSIP
echo "### PJSIP Show Registrations ###"
docker exec -it astproxy asterisk -rx 'pjsip show registrations'
echo "################################"
echo ""
