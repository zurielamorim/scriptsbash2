#!/bin/bash

read -p "Digite o IP de destino: " DEST_IP

# Teste de conexão UDP na porta 5060 com netcat
echo "Testando conexão com $DEST_IP na porta 5060/UDP..."
nc -vz -u "$DEST_IP" 5060
