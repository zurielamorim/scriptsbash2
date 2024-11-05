#!/bin/bash
################################################################################
# Escallo: verificaSipTrunk.sh
#
# @author Josimar Rocha <josimar@futurotec.com.br>
# @version 20220809
################################################################################

# Configuracoes basicas do script
myVersion="20220809"

# Imprime versão do script (--help ou -h)
# @param ${1} --version ou -v
function version (){
        if [[ $1 == --version || $1 == -v ]]
        then
                        echo -e "Versao do script: ${myVersion}"
                        exit
        fi
}

# Imprime instrucoes de uso (--help ou -h)
# @param ${1} --help ou -h
function helper (){
        if [[ $1 == --help || $1 == -h ]]
        then
                        echo -e "\nModo de utilizacao:\n"
                        echo -e "./checkSipRoute.sh recurso\n"
                        echo -e "Exemplo: ./checkSipRoute.sh sip_trunk_vivo\n"
                        echo -e "Dica: pegue o recurso definido no tronco cadastrado na interface web\n"
                        exit
        fi
}

# Variaveis globais
# Define o "campo" relativo a saida  do comando 'sip show peer' que sera considerado para obter o "host"
hostReference="Addr->IP"

# Define o "campo" relativo a saida do comando 'sip show peer' que sera considerado para obter o "status de qualify"
qualifyReference="Status"

# Expressao regular usada para validar se determinado valor eh um IP
regexIpAddr="\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"

# Printa o resultado das operacoes realizadas na funcaoo validateConnection
#
function printResult () {
		echo -e "Recurso: ${recursoSip}\n"
        echo -e "Outra ponta SIP: ${ipPeer}\n"
        echo -e "Comunicação: ${peerStatus}\n\n"

        echo -e "Rota: ${ipPeer} -> ${router}\n"
        echo -e "Status da rota: ${routeStatus}\n"
}

# Realiza as operacoes necessarias para verificar se o SIP Server e a rota utilizada estao alcancaveis
# @param ${1} "recurso" do tronco
function validateConnection () {

	# Verifica se o parametro eh --help ou -h
	helper $1

	# Caso nao seja --help ou -h, armazena o valor passado como parametro em uma nova variavel
	recursoSip=$1

	# Subshell para obter o valor do campo "Addr->IP" relativo ao recurso informado
	ipPeer=$(asterisk -rx "sip show peer ${recursoSip}" | grep ${hostReference} | awk '{ print $3 }')

	# Valida se o valor do campo "Addr->IP" eh "(Unspecified)"
	if [[ $ipPeer == "(Unspecified)" ]]
	then
		echo -e "O recurso é uma extensao valida, mas nao ha conexao do UA com a conta SIP"
		exit
	else
		# Valida se o valor do campo "Addr->IP" corresponde a um endereco IP (com base no regex definido nas variaveis estaticas)
		if [[ $ipPeer =~ $regexIpAddr ]]
		then
			# Subshell para obter o valor do campo "Status" relativo ao recurso informado
			qualifyStatus=$(asterisk -rx "sip show peer ${recursoSip}" | grep -i ${qualifyReference} | awk '{ print $3 }')

			# Subshell para obter o IP do gateway  utilizada para alcancar o IP armazenado em ${ipPeer}
               		router=$(ip route get $ipPeer | awk '{ print $3 }')
			
			
       	        	echo -e "\n\nTestando conexão...\n"

               		# Valida se os pacotes ICMP com destino a outra ponta (SIP) sao respondidos. Obs: em caso de perdas de pacote, a comunicacao eh entendida como "Disponivel".
			if ! ping -c 5 "$ipPeer" 1> /dev/null 2> /dev/stdout
                	then
       	                	peerStatus="Indisponivel"
               		else
                       		peerStatus="Disponivel"
                	fi

			# Valida se o gateway da rota eh um IP ou uma "interface"
                        if [[ $router =~ $regexIpAddr ]]
                        then
                                # Valida se os pacotes ICMP com destino ao IP do gateway relativo a rota usada para alcancar a outra ponta (SIP) sao respondidos. Obs: em caso de perdas de pacote, a comunicacao eh entendida como "Disponivel".
                                if ! ping -c 5 "${router}" 1> /dev/null 2> /dev/stdout
                                then
                                        routeStatus="Indisponivel"
                                else
                                        routeStatus="Disponivel"
                                fi
                        else
                                routeStatus="Disponivel via IFace"
                        fi		
		
			printResult

		else
			echo "Nao existe uma extensao SIP que corresponda ao recurso '${recursoSip}'"
        	exit
		fi
	fi

}

validateConnection $1

# FIM
