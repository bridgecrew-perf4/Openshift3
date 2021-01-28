#! /bin/bash
# Runs ansible against the new machine and installs git/jq + firewall changes
# Colours
RED='\033[0;31m'       ; BLACK='\033[0;30m'
DARKGRAY='\033[1;30m'  ; LIGHTRED='\033[1;31m'
GREEN='\033[0;32m'     ; LIGHTGREEN='\033[1;32m'
ORANGE='\033[0;33m'    ; YELLOW='\033[1;33m'
BLUE='\033[0;34m'      ; LIGHTBLUE='\033[1;34m'
PURPLE='\033[0;35m'    ; LIGHTPURPLE='\033[1;35m'
CYAN='\033[0;36m'      ; LIGHTCYAN='\033[1;36m'
LIGHTGRAY='\033[0;37m' ; WHITE='\033[1;37m'
NC='\033[0m' # No Color
PS4='[${LINENO}]'
SUBDOMAIN=app
IDENT=$(id -nu)
clear
[[ ! -e vars.tfvars ]] && FILE=staticip.tf || FILE=vars.tfvars
OCT=($(grep -i octetIP ${FILE} | sed 's!^\(.*\)\[\(.*\)\]\(.*\)$!\2!' | tr -d ',' | head -n 1))
eval $(grep -i prefixIP ${FILE} | tr -d '"')
NODES=($(grep host_names ${FILE} | sed 's!^\(.*\)\[\(.*\)\]\(.*\)$!\2!' | tr -d ',"'))
eval $(grep -i domain ${FILE} | tr -d '"')

printf "[OSEv3:children]\nmaster\nworkers\n\n[OSEv3:vars]\nmaster=${NODES[0]}.${domain}\nmasterip=${prefixIP}.${OCT[0]}\nworker1=${NODES[1]}.${domain}\nworker1ip=${prefixIP}.${OCT[1]}\nworker2=${NODES[2]}.${domain}\nworker2ip=${prefixIP}.${OCT[2]}\nsub=${SUBDOMAIN}\ndomain=${domain}\nid=${IDENT}\n\n[master]\n${prefixIP}.${OCT[0]}\n[workers]\n${prefixIP}.${OCT[1]}\n${prefixIP}.${OCT[2]}\n" > inv

printf "Expunging ssh keys if present"
make ssh

printf "\n${CYAN}Lets ping the nodes to check they are available: \n${WHITE}ansible -vi inv -m ping all${NC}\n"
ansible -vi inv -m ping all

printf "${CYAN}\nRun our play: ${WHITE}ansible-playbook -vi inv site.yml${NC}\n"
printf "${GREEN}>>>"
read
ansible-playbook -v -i inv site.yml
printf "${ORANGE}Login to the master (${NODES[0]}) and run the install script.\n\n"
