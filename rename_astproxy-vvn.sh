#!/bin/bash

original_name="astproxy-vvn"

echo "Digite o novo nome do container (exemplo: astproxy-XXXX):"
read new_name

network="astproxy_host"
ip="192.168.255.6"

container_info=$(docker inspect $original_name)

ASTPROXY_CONFIG_JSON=$(echo "$container_info" | jq -r '.[0].Config.Env[] | select(test("ASTPROXY_CONFIG_JSON")).split("=")[1]')
DEBUG=$(echo "$container_info" | jq -r '.[0].Config.Env[] | select(test("DEBUG")).split("=")[1]')
TZ=$(echo "$container_info" | jq -r '.[0].Config.Env[] | select(test("TZ")).split("=")[1]')

docker run -d \
  --name $new_name \
  --network $network \
  --ip $ip \
  --restart always \
  -e DEBUG=$DEBUG \
  -e ASTPROXY_CONFIG_JSON="$ASTPROXY_CONFIG_JSON" \
  -e TZ=$TZ \
  docker.escallo.com.br/astproxy-vvn:4

# Opcional: Parar e remover o container original (descomente as linhas se necessário)
 docker stop $original_name
 docker rm $original_name
