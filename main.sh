#!/bin/bash
# PAINEL BYPASS - @SIZEPULAYBOTA v6.0 (FINAL VERSION)

# --- CORES E CONFIGURAÇÕES ---
RED="\033[1;31m"; GREEN="\033[1;32m"; YELLOW="\033[1;33m"; CYAN="\033[1;36m"
MAGENTA="\033[1;35m"; WHITE="\033[1;37m"; RESET="\033[0m"; BOLD="\033[1m"
BLUE="\033[1;34m"

DB_LOCAL="$HOME/.size_db"
touch "$DB_LOCAL"
[ ! -s "$DB_LOCAL" ] && echo "ADM|ADM|1893456000" > "$DB_LOCAL"

# --- FUNÇÕES DE ANIMAÇÃO ---
animar_barra() {
    local msg="$1"
    echo -ne "${YELLOW}$msg: [                    ] 0%${RESET}"
    sleep 0.3
    echo -ne "\r${YELLOW}$msg: [#####               ] 25%${RESET}"
    sleep 0.3
    echo -ne "\r${YELLOW}$msg: [##########          ] 50%${RESET}"
    sleep 0.3
    echo -ne "\r${YELLOW}$msg: [###############     ] 75%${RESET}"
    sleep 0.3
    echo -ne "\r${YELLOW}$msg: [####################] 100%${RESET}\n"
}

# --- CABEÇALHO ---
banner(){
    clear
    if adb get-state &>/dev/null; then 
        STATUS_ADB="$GREEN● ONLINE$RESET"
        MODELO=$(adb shell getprop ro.product.model 2>/dev/null || echo "Android")
    else 
        STATUS_ADB="$RED● OFFLINE$RESET"; MODELO="Desconectado"
    fi
    echo -e "${CYAN}"
    echo " ██████╗ ██╗ ██╗██████╗ █████╗ ███████╗███████╗"
    echo " ██╔══██╗╚██╗ ██╔╝██╔══██╗██╔══██╗██╔════╝██╔════╝"
    echo " ██████╔╝ ╚████╔╝ ██████╔╝███████║███████╗███████╗"
    echo " ██╔══██╗ ╚██╔╝ ██╔═══╝ ██╔══██║╚════██║╚════██║"
    echo " ██████╔╝ ██║ ██║ ██║ ██║███████║███████║"
    echo -e "${WHITE}         MANAGER BY @SIZEPULAYBOTA${RESET}"
    echo -e "${CYAN}--------------------------------------------------${RESET}"
    echo -e "${WHITE} DISPOSITIVO: $CYAN$MODELO$RESET | ADB: $STATUS_ADB"
    echo -e "${CYAN}--------------------------------------------------${RESET}"
}

# --- ABA: PASSADOR DE REPLAY ---
aba_replay() {
    banner
    echo -e "${CYAN}[ MÓDULO: TRANSFERÊNCIA DE REPLAY ]${RESET}\n"
    SRC="/sdcard/Android/data/com.dts.freefiremax/files/MReplays"
    DST="/sdcard/Android/data/com.dts.freefireth/files/MReplays"
    VER="1.122.6"

    if ! adb shell "[ -d $SRC ]" 2>/dev/null; then
        echo -e "${RED}[!] Pasta MReplays (FF MAX) não encontrada.${RESET}"
        sleep 2; return
    fi

    count=$(adb shell "ls $SRC/*.bin 2>/dev/null | wc -l")
    echo -e "${WHITE}Arquivos localizados: ${YELLOW}$count${RESET}"
    
    animar_barra "Transferindo Replays"
    adb shell "mkdir -p $DST" 2>/dev/null
    adb shell "cp -f $SRC/*.bin $DST/ && cp -f $SRC/*.json $DST/" 2>/dev/null
    
    echo -e "${BLUE}[#] Aplicando Bypass de Versão ($VER)...${RESET}"
    adb shell "for f in $DST/*.json; do [ -f \"\$f\" ] && sed -i 's/\"[Vv]ersion\":\"[^\"]*\"/\"Version\":\"$VER\"/g' \"\$f\"; done"
    
    echo -e "\n${GREEN}✅ REPLAYS PASSADOS PARA FF NORMAL!${RESET}"
    read -p "Pressione Enter para voltar..."
}

# --- ABA: OCULTAR APP POR NOME ---
aba_ocultar() {
    banner
    echo -e "${CYAN}[ MÓDULO: OCULTAR APLICATIVO ]${RESET}\n"
    echo -ne "${WHITE}Digite o nome do App: ${YELLOW}"; read busca
    
    mapfile -t resultados < <(adb shell "pm list packages -3" | cut -d':' -f2 | grep -i "$busca")
    
    if [ ${#resultados[@]} -eq 0 ]; then
        echo -e "${RED}[!] Nenhum app encontrado.${RESET}"; sleep 2; return
    fi

    for i in "${!resultados[@]}"; do
        printf "${YELLOW} [%02d] ${WHITE}%s${RESET}\n" "$((i+1))" "${resultados[$i]}"
    done

    echo -ne "\n${CYAN}Número para OCULTAR (0 para todos): ${RESET}"; read escolha
    if [ "$escolha" -eq 0 ]; then
        for pkg in "${resultados[@]}"; do adb shell "pm suspend $pkg"; done
    else
        index=$((escolha - 1))
        adb shell "pm suspend ${resultados[$index]}"
    fi
    echo -e "${GREEN}✅ OPERAÇÃO CONCLUÍDA!${RESET}"
    sleep 2
}

# --- ABA: GHOST MODE ---
aba_ghost() {
    banner
    echo -e "${CYAN}[ MÓDULO: GHOST MODE - INVISÍVEL ]${RESET}\n"
    animar_barra "Limpando Logs de Sistema"
    adb shell "logcat -c && pm reset-permissions"
    animar_barra "Deletando Telemetria Garena"
    adb shell "rm -rf /sdcard/Android/data/*/cache/*"
    echo -e "\n${GREEN}✅ GHOST MODE ATIVADO!${RESET}"
    sleep 2
}

# --- ABA: BYPASS KELLER SCANNER ---
aba_keller() {
    banner
    echo -e "${CYAN}[ MÓDULO: ANTI-SCANNER KELLER SS ]${RESET}\n"
    echo -e "${BLUE}[#] Camuflando extensões .sh e .lua...${RESET}"
    adb shell "find /sdcard/Download -name '*.sh' -exec mv {} {}.bak \;" 2>/dev/null
    
    echo -e "${BLUE}[#] Resetando Timeline das pastas (Anti-Data)...${RESET}"
    # Muda a data para Jan/2024 para enganar o scanner
    adb shell "find /sdcard/Android/data/ -maxdepth 2 -exec touch -t 202401101200 {} \;" 2>/dev/null
    
    echo -e "${BLUE}[#] Limpando pastas de gerenciadores...${RESET}"
    adb shell "rm -rf /sdcard/MT2 /sdcard/NP" 2>/dev/null
    
    animar_barra "Enganando Scanner"
    echo -e "\n${GREEN}✅ BYPASS KELLER CONCLUÍDO!${RESET}"
    read -p "Pressione Enter para voltar..."
}

# --- MENU PRINCIPAL ---
menu_bypass(){
    while true; do
        banner
        echo -e "${BOLD}${WHITE} [ SELECIONE UMA FUNÇÃO ]${RESET}"
        printf "${CYAN} [01] %-18s ${CYAN} [05] %-18s ${RESET}\n" "LIMPAR TUDO" "RESTAURAR APP"
        printf "${CYAN} [02] %-18s ${CYAN} [06] %-18s ${RESET}\n" "OCULTAR APP" "GHOST MODE"
        printf "${CYAN} [03] %-18s ${CYAN} [07] %-18s ${RESET}\n" "TIMEZONE/SS" "BYPASS KELLER"
        printf "${CYAN} [04] %-18s ${CYAN} [08] %-18s ${RESET}\n" "PASSAR REPLAY" "CONECTAR ADB"
        echo -e "${CYAN}--------------------------------------------------${RESET}"
        echo -e "${RED} [S] SAIR DO PAINEL${RESET}"
        echo -ne "\n${BOLD}${WHITE} ► ESCOLHA:${RESET} "; read op

        case $op in
            1|01) banner; animar_barra "Limpando logs"; adb shell "logcat -c";;
            2|02) aba_ocultar ;;
            3|03) adb shell "settings put global time_zone America/Sao_Paulo"; echo -e "${GREEN}OK!${RESET}"; sleep 1 ;;
            4|04) aba_replay ;;
            5|05) banner; echo -ne "Nome do App para restaurar: "; read r_pkg; adb shell "pm unsuspend $r_pkg" ;;
            6|06) aba_ghost ;;
            7|07) aba_keller ;;
            8|08) banner; echo -ne "IP e Porta: "; read ip; adb connect "$ip" ;;
            s|S) exit 0 ;;
        esac
    done
}

# --- LOGIN ---
login(){
    banner
    echo -ne "\n${WHITE} LOGIN: ${YELLOW}"; read in_user
    USER_DATA=$(grep "^$in_user|" "$DB_LOCAL" | tail -n 1)
    if [ -z "$USER_DATA" ]; then echo -e "${RED}[!] ACESSO NEGADO${RESET}"; sleep 1; login; fi
    CURRENT_USER="$in_user"
    menu_bypass
}

adb start-server > /dev/null 2>&1
login
