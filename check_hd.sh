#!/bin/bash

#Verificar tipo de disco

lsblk -d -o name,model,rota,type
