#!/bin/bash

services=(
  "rudder-agent"
  "cron"
  "mysql"
  "docker"
  "apache2"
  "openvpn"
  "supervisorctl"
)

# Definindo códigos de cores ANSI
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

for service in "${services[@]}"; do
  case "$service" in
    "supervisorctl")
      status=$($service status)
      echo -e "$status"
      ;;
    *)
      status=$(/etc/init.d/"$service" status)
      case "$status" in
        *running*)
          echo -e "$service: ${GREEN}OK${NC}"
          ;;
        *inactive*|*stopped*)
          echo -e "$service: ${RED}OFF${NC}"
          ;;
        *error*|*BACKOFF*|*EXITED*)
          echo -e "$service: ${RED}ERROR${NC}"
          ;;
        *)
          echo -e "$service: ${YELLOW}UNKNOWN STATUS${NC}"
          ;;
      esac
      ;;
  esac
done
