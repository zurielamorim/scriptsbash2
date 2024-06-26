#!/bin/bash

# Solicitar a direção da mídia ao usuário
read -p "Digite a direção da mídia (campanha, entrada ou saida): " direcao_midia

# Verificar se a direção da mídia foi fornecida corretamente
if [[ "$direcao_midia" != "campanha" && "$direcao_midia" != "entrada" && "$direcao_midia" != "saida" ]]; then
    echo "Direção da mídia inválida. As opções válidas são: campanha, entrada, saida."
    exit 1
fi

# Executar o comando para obter a lista de contatos e filtrar pelos IDs
ids=$(php /home/futurofone/web/core/test/chats/contatos.php | grep "$direcao_midia" | cut -d "|" -f1 | awk '{$1=$1};1')

# Verificar se foram encontrados contatos para finalizar
if [ -z "$ids" ]; then
    echo "Não foram encontrados contatos para a direção da mídia '$direcao_midia'. Saindo do script."
    exit 1
fi

# Loop para finalizar os contatos
for id in $ids; do
    php /home/futurofone/web/core/cmd/chat/finalizarContato.php $id
done

# Mensagem de conclusão
echo "Processo concluído."
