# iptablesSETSbyCC
This is a bash script to implement country blocking via iptables\
Desenvolvido por Duilio Beojone Neto

#	(PT-BR)																																										   	         
\#	Bash Script para adicionar um ipset ao iptables o qual bloqueará pais(es) especificado(s) pelo usuário

\# Melhorias a fazer:		

\# - Trabalhar também com ipv6																																			       
\# - verificar se os arquivos fornecidos pela ripe e afrinc ainda apresentam erros (culpa deles)\
\     - Foi feita uma validação para as redes que estão fora do formato CIDR nos arquivos de terceiros
\# - suporte à mac \
\# [OK] Criar função para remover sets criados\
\# [OK] Melhorar o sed na func criaset() para redes menores que 256 hosts															       
\# [OK] bloquear também a rede TOR																																		         

#	 (EN-US)                                                                                               
\#  Bash script to add ipsets to iptables based on country code(s) provided by user

\# Things to improve:			\
\
\# - IPv6 support\
\# - check if ripe and afrinic files still corrupted (they were reporting a crazy number of hosts on some networks)					\
\     - A validation is in place for networks reported out of CIDR notation on third party files \
\# - mac support (since I dont have a mac I think this will take some more time to go...) \
\# [OK] Create a function to remove the sets previously created\
\# [OK] SED on criaset(), aiming networks smaller than 256 hosts\
\# [OK] Block Tor network exit nodes\
\
\
\
\
Usage: "$0 CountryCode ex: $0 CN BR AU"\
ex: ./iptablesSETSbyCC.sh TOR CN BR AU\
\
\
\
\
"I guess that makes MINIX the most widely used computer operating system in the world, even more than Windows, Linux, or MacOS. And I didn't even know until I read a press report about it." AS Tanenbaum
