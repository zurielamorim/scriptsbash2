#!/bin/bash

# Caminho para o arquivo PHP que realiza a finalização
PHP_SCRIPT="/home/futurofone/web/core/cmd/chat/finalizarContato.php"

# Solicita a data ao usuário
read -p "Digite a data desejada no formato DD/MM/AAAA: " DATA

# Valida se a data está no formato correto
if [[ ! "$DATA" =~ ^[0-9]{2}/[0-9]{2}/[0-9]{4}$ ]]; then
  echo "Formato de data inválido. Use o formato DD/MM/AAAA."
  exit 1
fi

# Comando para buscar contatos do dia com direção "entrada"
CONTATOS=$(php /home/futurofone/web/core/test/chats/contatos.php | grep "$DATA" | grep "entrada")

# Verifica se há contatos a finalizar
if [ -z "$CONTATOS" ]; then
  echo "Nenhum contato para finalizar na data $DATA."
  exit 0
fi

# Itera sobre cada linha de saída
echo "$CONTATOS" | while read -r linha; do
  # Extrai o ID do contato (primeira coluna)
  ID=$(echo "$linha" | awk '{print $1}')

  # Confirma se o ID foi capturado corretamente
  if [[ $ID =~ ^[0-9]+$ ]]; then
    echo "Finalizando contato ID: $ID..."

    # Executa o script PHP para finalizar o contato
    php "$PHP_SCRIPT" "$ID"

    # Verifica se a execução foi bem-sucedida
    if [ $? -eq 0 ]; then
      echo "Contato ID $ID finalizado com sucesso."
    else
      echo "Erro ao finalizar contato ID $ID."
    fi
  else
    echo "ID inválido: $ID. Ignorando."
  fi
done

echo "Finalização concluída."

