#!/bin/bash

# Caminho dos arquivos PHP
arquivo1="/home/futurofone/web/core/cmd/chat/FinalizarContatoPorAgente.php"
arquivo2="/home/futurofone/web/core/cmd/chat/FinalizarContatosPorMidia.php"

# Conteúdo do primeiro arquivo PHP (FinalizarContatoPorAgente.php)
conteudo1=$(cat <<'EOF'
<?php

require_once __DIR__ . DIRECTORY_SEPARATOR . ".." . DIRECTORY_SEPARATOR . ".." . DIRECTORY_SEPARATOR . "init.php";

use FuturofoneCore\Futurofone\Service\Cache\ChatAtendimentoCacheService;
use FuturofoneCore\Futurotec\Exception\SistemaException;
use FuturofoneManager\Chat\Futurofone\ChatEventoPublish;

echo "\n";

$codigoAgente = $argv[1];

if (!is_numeric($codigoAgente)) {
    echo "É esperado o CÓDIGO DO AGENTE como parametro!\n";
    die();
}

$contFinalizados=0;
try {
    foreach (ChatAtendimentoCacheService::getChatAtendimentos() as $chatAtendimentoDTO) {

        if ($chatAtendimentoDTO["agente"]["codigo"] == $codigoAgente) {
            if($contFinalizados == 0){
                echo "\nIniciando processo de finalização dos chats do agente ".$chatAtendimentoDTO['agente']['nome'];
                echo "\n ID  |  Contato";
            }
            ChatEventoPublish::finalizarContatoInatividade($chatAtendimentoDTO["chatContato"]["id"]);
            echo "\n".$chatAtendimentoDTO['chatContato']['id'].' | '.$chatAtendimentoDTO['chatContato']['hash'].' ==> Finalizado!';
            $contFinalizados++;
        }
    }
} catch (SistemaException $ex) {
    echo $ex->getMessage() . "\n\n";
    die();
}

if ($contFinalizados == 0) {
    echo "NENHUM CONTATO FINALIZADO!\n";
} else {
    echo "\nQUANTIDADE DE CONTATOS FINALIZADOS: " . $contFinalizados . "\n";
}

echo "\n";

EOF
)

# Criação do primeiro arquivo PHP
echo "$conteudo1" > "$arquivo1"
chmod +x "$arquivo1"
echo "Arquivo criado em: $arquivo1"

# Conteúdo do segundo arquivo PHP (FinalizarContatosPorMidia.php)
conteudo2=$(cat <<'EOF'
<?php

require_once __DIR__ . DIRECTORY_SEPARATOR . ".." . DIRECTORY_SEPARATOR . ".." . DIRECTORY_SEPARATOR . "init.php";

use FuturofoneCore\Futurofone\Service\Cache\ChatAtendimentoCacheService;
use FuturofoneCore\Futurotec\Exception\SistemaException;
use FuturofoneManager\Chat\Futurofone\ChatEventoPublish;

echo "\n";

// Obtém o código da mídia social do argumento passado
$codigoMidiaSocial = isset($argv[1]) ? $argv[1] : null;

if (!is_numeric($codigoMidiaSocial)) {
    echo "É esperado o ID da mídia como parâmetro!\n";
    die();
}

$contFinalizados = 0;

try {
    foreach (ChatAtendimentoCacheService::getChatAtendimentos() as $chatAtendimentoDTO) {
        if ($chatAtendimentoDTO["chatContato"]["idMidiaSocial"] == $codigoMidiaSocial) {
            
            if ($contFinalizados == 0) {
                echo "\nIniciando processo de finalização dos chats da mídia: " . $chatAtendimentoDTO['chatContato']['nomeMidiaSocial'];
                echo "\n ID  |  Contato";
            }

            // Obtendo o ID do contato
            $idContato = isset($chatAtendimentoDTO["chatContato"]["id"]) ? $chatAtendimentoDTO["chatContato"]["id"] : null;

            if (is_null($idContato)) {
                echo "\n[ERRO] ID do contato está NULL! Pulando...\n";
                continue; // Pula esse contato e segue para o próximo
            }

            // Debug para verificar os valores antes da chamada
            var_dump("ID Contato: " . $idContato);

            // Executando o script externo para finalizar o contato
            $command = "/usr/bin/php /home/futurofone/web/core/cmd/chat/finalizarContato.php " . $idContato;
            $output = shell_exec($command);

            // Verificando se a execução foi bem-sucedida
            if ($output === null) {
                echo "\n[ERRO] Falha ao executar o script de finalização do contato!\n";
            } else {
                echo "\n" . $idContato . ' ==> ' . $output;
                $contFinalizados++;
            }
        }
    }
} catch (SistemaException $ex) {
    echo "\n[ERRO] " . $ex->getMessage() . "\n";
    die();
}

// Exibir resumo
if ($contFinalizados == 0) {
    echo "\nNENHUM CONTATO FINALIZADO!\n";
} else {
    echo "\n\nQUANTIDADE DE CONTATOS FINALIZADOS: " . $contFinalizados . "\n";
}

echo "\n";

EOF
)

# Criação do segundo arquivo PHP
echo "$conteudo2" > "$arquivo2"
chmod +x "$arquivo2"
echo "Arquivo criado em: $arquivo2"
