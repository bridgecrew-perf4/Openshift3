#! /bin/bash
# Runs ansible against the new machines
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

clear
printf "${CYAN}Destecting Public IP address...${NC}"
IP=$( az vm list-ip-addresses -g OCP3Group -n oshiftmaster --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" -o tsv)
printf "${WHITE}Found${NC}\n"
printf "${CYAN}PodMantest VM appears to be at public address:${WHITE}${IP}${NC}\n"
printf "[Azure]\n${IP}\n" > inv
printf "\n${CYAN}Lets ping the host to see if it's available: \n${WHITE}ansible -i inv ${IP} -m ping -u azureuser --private-key key${NC}\n"
ansible -i inv ${IP}  -m ping -u azureuser --private-key key
printf "${CYAN}\nRun our play: ${WHITE}ansible-playbook -i inv -u azureuser --private-key key play.yml${NC}\n"
printf "${GREEN}>>>"
read
#ansible-playbook -v -i inv -u azureuser --private-key key site.yml
#Playbook retired: ansible-playbook -i inv -u azureuser --private-key key play.yml
