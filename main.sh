#!/bin/bash
# PAINEL BYPASS - @SIZEPULAYBOTA v5.1 (FIXED)

# CORES
RED="\033[1;31m"; GREEN="\033[1;32m"; YELLOW="\033[1;33m"; 
CYAN="\033[1;36m"; MAGENTA="\033[1;35m"; WHITE="\033[1;37m"; 
RESET="\033[0m"; BOLD="\033[1m"; BLUE="\033[1;34m"

# BANCO DE DADOS (Garante que existe e tem permissão)
DB_LOCAL="$HOME/.size_db"
touch "$DB_LOCAL"
if [ ! -s "$DB_LOCAL" ]; then
    echo "ADM|ADM|1893456000" > "$DB_LOCAL"
fi

# VARIÁVEIS
MODELO="Desconectado"; STATUS_ADB="$RED● OFFLINE$RESET"; CURRENT_USER=""

# FUNÇÃO DE STATUS ADB
check_status(){
    if adb get-state &>/dev/null; then
        STATUS_ADB="$GREEN● ONLINE$RESET"
        MODELO=$(adb shell getprop ro.product.model 2>/dev/null || echo "Android")
    else
        STATUS_ADB="$RED● OFFLINE$RESET"; MODELO="Aguardando..."
    fi
}

get_time_left() {
    local exp=$1
    local now=$(date +%s)
    if [ "$exp" -le "$now" ]; then
        echo -e "$RED● EXPIRADO$RESET"
    else
        local diff=$((exp - now))
        local d=$((diff / 86400))
        echo -e "$GREEN● ATIVO$RESET ($d Dias)"
    fi
}

banner(){
    clear; check_status
    echo -e "$CYAN"
    echo "  ██████╗ ██╗   ██╗██████╗  █████╗ ███████╗███████╗"
    echo "  ██╔══██╗╚██╗ ██╔╝██╔══██╗██╔══██╗██╔════╝██╔════╝"
    echo "  ██████╔╝ ╚████╔╝ ██████╔╝███████║███████╗███████╗"
    echo "  ██╔══██╗  ╚██╔╝  ██╔═══╝ ██╔══██║╚════██║╚════██║"
    echo "  ██████╔╝   ██║   ██║     ██║  ██║███████║███████║"
    echo -e "$WHITE           MANAGER BY @SIZEPULAYBOTA$RESET"
    echo -e "$MAGENTA--------------------------------------------------$RESET"
    echo -e "$WHITE DEVICE: $CYAN$MODELO$RESET  $WHITE ADB: $STATUS_ADB"
    echo -e "$WHITE USER:   $YELLOW$CURRENT_USER$RESET"
    echo -e "$MAGENTA--------------------------------------------------$RESET"
}

# --- PAINEL ADM (FIXED) ---
painel_adm(){
    banner
    echo -e "$BOLD$CYAN [ MENU ADMINISTRADOR ]$RESET"
    echo -e "$WHITE [1] CRIAR NOVA KEY        [2] LISTAR KEYS"
    echo -e "$WHITE [3] DELETAR USUÁRIO       [4] ENTRAR NO BYPASS"
    echo -e "$RED [0] SAIR$RESET"
    echo -ne "\n$BOLD$WHITE ► OPÇÃO ADM:$RESET "; read adm_op
    
    case $adm_op in
        1)  banner
            echo -ne "$WHITE Nome do User: $YELLOW"; read n_user
            echo -ne "$WHITE Tipo (1:USER 2:ADM): $YELLOW"; read t_opt
            [ "$t_opt" == "2" ] && n_tipo="ADM" || n_tipo="USER"
            echo -ne "$WHITE Dias de Validade: $YELLOW"; read n_dias
            EXP=$(( $(date +%s) + (n_dias * 86400) ))
            echo "$n_user|$n_tipo|$EXP" >> "$DB_LOCAL"
            echo -e "$GREEN [!] KEY SALVA COM SUCESSO!$RESET"; sleep 2; painel_adm ;;
        2)  banner
            printf "${CYAN}%-15s %-6s %-20s${RESET}\n" "USER" "TIPO" "STATUS"
            echo -e "$MAGENTA--------------------------------------------------$RESET"
            while IFS='|' read -r u t e; do
                [ -z "$u" ] && continue
                printf "${WHITE}%-15s ${YELLOW}%-6s ${RESET}%-20s\n" "$u" "$t" "$(get_time_left "$e")"
            done < "$DB_LOCAL"
            echo -ne "\n$YELLOW Pressione Enter...$RESET"; read; painel_adm ;;
        3)  banner; echo -ne "Nome exato para remover: "; read r_user
            sed -i "/^$r_user|/d" "$DB_LOCAL"
            echo -e "$RED [!] USUÁRIO REMOVIDO$RESET"; sleep 1; painel_adm ;;
        4)  menu_bypass ;;
        0)  exit 0 ;;
        *)  painel_adm ;;
    esac
}

# --- MENU BYPASS (FIXED FUNCTIONS) ---
menu_bypass(){
    banner
    echo -e "$BOLD$WHITE [ FUNÇÕES ATIVAS ]$RESET"
    echo -e "$CYAN [01] LIMPAR TUDO (SHIZUKU/LOGS)  [04] PASSADOR DE REPLAY"
    echo -e "$CYAN [02] OCULTAR APP (SUSPEND)      [05] RESTAURAR APP"
    echo -e "$CYAN [03] BYPASS TIMEZONE/SS         [06] GHOST MODE (DANGEROUS)"
    echo -e "$MAGENTA--------------------------------------------------$RESET"
    [ "$(grep "^$CURRENT_USER|" "$DB_LOCAL" | cut -d'|' -f2)" == "ADM" ] && echo -e "$YELLOW [99] VOLTAR AO ADM$RESET"
    echo -e "$RED [S] SAIR$RESET"
    echo -ne "\n$BOLD$WHITE ► SELECIONE:$RESET "; read op
    
    case $op in
        01|1) adb shell "pkill -f shizuku; pkill -9 brevent; logcat -c" 2>/dev/null
              echo -e "$GREEN [!] LIMPEZA CONCLUÍDA$RESET"; sleep 1; menu_bypass ;;
        02|2) banner; adb shell pm list packages -3 | cut -d':' -f2 | head -n 15
              echo -ne "\nDigite o pacote para OCULTAR: "; read pkg
              adb shell pm suspend "$pkg" && echo -e "$GREEN [!] $pkg OCULTADO$RESET" || echo -e "$RED [!] FALHA$RESET"
              sleep 1; menu_bypass ;;
        03|3) adb shell "settings put global time_zone America/Sao_Paulo"
              adb shell "touch -t 202401011200 /data/local/tmp" 2>/dev/null
              echo -e "$GREEN [!] TIMEZONE BYPASS ATIVO$RESET"; sleep 1; menu_bypass ;;
        04|4) # PASSADOR DE REPLAY MELHORADO
              echo -e "$YELLOW [>] ATIVANDO REPLAY...$RESET"
              adb shell "settings put global window_animation_scale 0.0" 2>/dev/null
              adb shell "settings put global transition_animation_scale 0.0" 2>/dev/null
              # Tenta fechar ambos os pacotes comuns
              adb shell am force-stop com.dts.freefireth 2>/dev/null
              adb shell am force-stop com.dts.freefiremax 2>/dev/null
              echo -e "$GREEN [!] REPLAY CONFIGURADO (ANIMS OFF)$RESET"; sleep 2; menu_bypass ;;
        05|5) echo -ne "Pacote para RESTAURAR: "; read pkg
              adb shell pm unsuspend "$pkg" 2>/dev/null
              echo -e "$GREEN [!] APP RESTAURADO$RESET"; sleep 1; menu_bypass ;;
        06|6) adb shell "rm -rf /sdcard/Android/data/*/cache/*" 2>/dev/null
              adb shell "rm -rf /data/local/tmp/*" 2>/dev/null
              echo -e "$RED [!] LOGS DEEP CLEAN CONCLUÍDO$RESET"; sleep 1; menu_bypass ;;
        99) painel_adm ;;
        s|S) exit 0 ;;
        *) menu_bypass ;;
    esac
}

# --- LOGIN (FIXED) ---
login(){
    banner
    echo -ne "\n$WHITE LOGIN: $YELLOW"; read in_user
    [ -z "$in_user" ] && login
    USER_DATA=$(grep "^$in_user|" "$DB_LOCAL" | tail -n 1)
    
    if [ -z "$USER_DATA" ]; then
        echo -e "$RED [!] USUÁRIO NÃO ENCONTRADO$RESET"; sleep 2; login
    fi
    
    EXP=$(echo "$USER_DATA" | cut -d'|' -f3)
    if [ "$(date +%s)" -gt "$EXP" ]; then
        echo -e "$RED [!] ACESSO EXPIRADO!$RESET"; sleep 2; exit 1
    fi
    
    CURRENT_USER="$in_user"
    TIPO=$(echo "$USER_DATA" | cut -d'|' -f2)
    [ "$TIPO" == "ADM" ] && painel_adm || menu_bypass
}

# Início do Script
adb start-server > /dev/null 2>&1
login
