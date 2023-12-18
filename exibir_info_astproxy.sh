#!/bin/bash

# Comando para exibir registros PJSIP
echo "### PJSIP Show Registrations ###"
docker exec -it astproxy asterisk -rx 'pjsip show registrations'
echo "################################"
echo ""

# Comando para exibir pares IAX2
echo "### IAX2 Show Peers ###"
docker exec -it astproxy asterisk -rx 'iax2 show peers'
echo "################################"
echo ""

# Comando para exibir registros IAX2
echo "### IAX2 Show Registry ###"
docker exec -it astproxy asterisk -rx 'iax2 show registry'
echo "################################"
