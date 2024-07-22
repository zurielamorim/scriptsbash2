#!/bin/bash

# Verificar tipo de disco e tamanho
lsblk -d -o name,model,rota,type,size
