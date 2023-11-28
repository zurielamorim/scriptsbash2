#!/bin/bash

# Solicitar números de contato ao usuário
read -p "Digite os números de contato (separados por espaço): " numeros_contato

# Verificar se os números de contato foram fornecidos
if [ -z "$numeros_contato" ]; then
    echo "Nenhum número de contato fornecido. Saindo do script."
    exit 1
fi

# Executar o loop para finalizar os contatos
for numero_contato in $numeros_contato; do
    for i in $(php /home/futurofone/web/core/test/chats/contatos.php | grep "$numero_contato" | cut -d " " -f1); do
        php /home/futurofone/web/core/cmd/chat/finalizarContato.php $i
    done
done

# Mensagem de conclusão
echo "Processo concluído."
