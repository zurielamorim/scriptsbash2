#!/bin/bash

# Caminho do primeiro arquivo
arquivo1="/home/futurofone/web/core/cmd/chat/FinalizarContatoPorAgente.php"

# Conteúdo do primeiro arquivo
conteudo1="<?php

require_once __DIR__ . DIRECTORY_SEPARATOR . \"..\" . DIRECTORY_SEPARATOR . \"..\" . DIRECTORY_SEPARATOR . \"init.php\";

use FuturofoneCore\Futurofone\Service\Cache\ChatAtendimentoCacheService;
use FuturofoneCore\Futurotec\Exception\SistemaException;
use FuturofoneManager\Chat\Futurofone\ChatEventoPublish;

echo \"\n\";

\$codigoAgente = \$argv[1];

if (!is_numeric(\$codigoAgente)) {
    echo \"É esperado o CÓDIGO DO AGENTE como parametro!\n\";
    die();
}

\$contFinalizados=0;
try {
    foreach (ChatAtendimentoCacheService::getChatAtendimentos() as \$chatAtendimentoDTO) {

        if (\$chatAtendimentoDTO[\"agente\"][\"codigo\"] == \$codigoAgente) {
            if(\$contFinalizados == 0){
                echo \"\nIniciando processo de finalização dos chats do agente \".\$chatAtendimentoDTO['agente']['nome'];
                echo \"\n ID  |  Contato\";
            }
            ChatEventoPublish::finalizarContatoInatividade(\$chatAtendimentoDTO[\"chatContato\"][\"id\"]);
            echo \"\n\".\$chatAtendimentoDTO['chatContato']['id'].' | '.\$chatAtendimentoDTO['chatContato']['hash'].' ==> Finalizado!';
            \$contFinalizados++;
        }
    }
} catch (SistemaException \$ex) {
    echo \$ex->getMessage() . \"\n\n\";
    die();
}


if (\$contFinalizados == 0) {
    echo \"NENHUM CONTATO FINALIZADO!\n\";
} else {
    echo \"\nQUANTIDADE DE CONTATOS FINALIZADOS: \" . \$contFinalizados . \"\n\";
}

echo \"\n\";

########################################################################################################################
"

# Criação do primeiro arquivo
echo -e "$conteudo1" > "$arquivo1"

# Permissões do primeiro arquivo
chmod +x "$arquivo1"

echo "Arquivo criado em: $arquivo1"

# Caminho do segundo arquivo
arquivo2="/home/futurofone/web/core/cmd/chat/FinalizarContatosPorMidia.php"

# Conteúdo do segundo arquivo
conteudo2="<?php

require_once __DIR__ . DIRECTORY_SEPARATOR . \"..\" . DIRECTORY_SEPARATOR . \"..\" . DIRECTORY_SEPARATOR . \"init.php\";

use FuturofoneCore\Futurofone\Service\Cache\ChatAtendimentoCacheService;
use FuturofoneCore\Futurotec\Exception\SistemaException;
use FuturofoneManager\Chat\Futurofone\ChatEventoPublish;

echo \"\n\";

\$codigoMidiaSocial = \$argv[1];

if (!is_numeric(\$codigoMidiaSocial)) {
    echo \"É esperado o ID da Midia como parametro!\n\";
    die();
}

\$contFinalizados=0;
try {
    foreach (ChatAtendimentoCacheService::getChatAtendimentos() as \$chatAtendimentoDTO) {

        if (\$chatAtendimentoDTO[\"chatContato\"][\"idMidiaSocial\"] == \$codigoMidiaSocial) {
            if(\$contFinalizados == 0){
                echo \"\nIniciando processo de finalização dos chats da midia \".\$chatAtendimentoDTO['chatContato']['nomeMidiaSocial'];
                echo \"\n ID  |  Contato\";
            }
            ChatEventoPublish::finalizarContatoInatividade(\$chatAtendimentoDTO[\"chatContato\"][\"id\"]);
            echo \"\n\".\$chatAtendimentoDTO['chatContato']['id'].' | '.\$chatAtendimentoDTO['chatContato']['hash'].' ==> Finalizado!';
            \$contFinalizados++;
        }
    }
} catch (SistemaException \$ex) {
    echo \$ex->getMessage() . \"\n\n\";
    die();
}


if (\$contFinalizados == 0) {
    echo \"NENHUM CONTATO FINALIZADO!\n\";
} else {
    echo \"\nQUANTIDADE DE CONTATOS FINALIZADOS: \" . \$contFinalizados . \"\n\";
}

echo \"\n\";

########################################################################################################################
"

# Criação do segundo arquivo
echo -e "$conteudo2" > "$arquivo2"

# Permissões do segundo arquivo
chmod +x "$arquivo2"

echo "Arquivo criado em: $arquivo2"
