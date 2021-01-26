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

source KVM.tfvars

clear
printf "[master]\n${prefixIP}.${octetIP}\n" > inv
printf "${CYAN}oshiftmaster VM appears to be at public address:${WHITE}${prefixIP}.${octetIP}${NC}\n"
printf "\n${CYAN}Lets ping the host to see if it's available: \n${WHITE}ansible -vi inv ${hostname} -m ping${NC}\n"
ansible -i inv ${prefixIP}.${octetIP} -m ping -u pi
printf "${CYAN}\nRun our play: ${WHITE}ansible-playbook -vi inv site.yml${NC}\n"
printf "${GREEN}>>>"
read
ansible-playbook -v -i inv site.yml
printf "${ORANGE}Your cluster should be available @ http://${prefixIP}.${octetIP}:8443${NC}\n\n"
