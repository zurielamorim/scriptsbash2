#!/bin/bash

# Solicitar o número de contato ao usuário
read -p "Digite o número de contato: " numero_contato

# Verificar se o número de contato foi fornecido
if [ -z "$numero_contato" ]; then
    echo "Número de contato não fornecido. Saindo do script."
    exit 1
fi

# Executar o loop para finalizar os contatos
for i in $(php /home/futurofone/web/core/test/chats/contatos.php | grep "$numero_contato" | cut -d " " -f1); do
    php /home/futurofone/web/core/cmd/chat/finalizarContato.php $i
done

# Mensagem de conclusão
echo "Processo concluído."
