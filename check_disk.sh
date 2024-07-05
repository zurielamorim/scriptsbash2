#!/bin/bash

# Teste de escrita
echo "Iniciando teste de escrita..."
dd if=/dev/zero of=testfile bs=1M count=1024 conv=fdatasync

# Teste de leitura
echo "Iniciando teste de leitura..."
dd if=testfile of=/dev/null bs=1M count=1024

# Removendo o arquivo de teste
rm testfile

# Extrair os resultados do teste de escrita
velocidade_escrita=$(dd if=/dev/zero of=testfile bs=1M count=1024 conv=fdatasync 2>&1 | grep -oP '\d+\.\d+ MB/s' | tail -n 1)
echo "Velocidade de escrita: $velocidade_escrita"

# Extrair os resultados do teste de leitura
velocidade_leitura=$(dd if=testfile of=/dev/null bs=1M count=1024 2>&1 | grep -oP '\d+\.\d+ MB/s' | tail -n 1)
echo "Velocidade de leitura: $velocidade_leitura"

# Remover novamente o arquivo de teste
rm testfile
