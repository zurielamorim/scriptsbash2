#!/bin/bash

# Verificar se o número de contato foi fornecido como argumento
if [ -z "$1" ]; then
    echo "Uso: ./finalizar_contato.sh \"numero\""
    exit 1
fi

# Definir o número de contato a partir do primeiro argumento
numero_contato=$1

# Executar o loop para finalizar os contatos
for i in $(php /home/futurofone/web/core/test/chats/contatos.php | grep "$numero_contato" | cut -d " " -f1); do
    # Exibir o número antes de finalizar o contato
    echo "Número encontrado: $i"
    php /home/futurofone/web/core/cmd/chat/finalizarContato.php $i
done

# Mensagem de conclusão
echo "Processo concluído."
