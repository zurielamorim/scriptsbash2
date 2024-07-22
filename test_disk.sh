#!/bin/bash

# Solicitar confirmação do usuário
read -p "Esse script irá escrever um arquivo de 1 GB. Deseja continuar? 

(Pressione Enter para continuar ou Ctrl+C para cancelar) "

# Teste de escrita
echo "Iniciando teste de escrita..."
velocidade_escrita=$(dd if=/dev/zero of=testfile bs=1M count=1024 conv=fdatasync 2>&1)
velocidade_formatada1=$(echo "$velocidade_escrita" | grep -o '[0-9,\.]* [MG]B/s')
echo "Velocidade de escrita: $velocidade_formatada1"

# Teste de leitura
echo "Iniciando teste de leitura..."
velocidade_leitura=$(dd if=testfile of=/dev/null bs=1M count=1024 2>&1)
velocidade_formatada2=$(echo "$velocidade_leitura" | grep -o '[0-9,\.]* [MG]B/s')
echo "Velocidade de leitura: $velocidade_formatada2"

# Remover o arquivo de teste
rm testfile
