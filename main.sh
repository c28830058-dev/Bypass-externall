#!/bin/bash
# PAINEL BYPASS - @SIZEPULAYBOTA v5.0

# CORES
RED="\033[1;31m"; GREEN="\033[1;32m"; YELLOW="\033[1;33m"; 
CYAN="\033[1;36m"; MAGENTA="\033[1;35m"; WHITE="\033[1;37m"; 
RESET="\033[0m"; BOLD="\033[1m"; BLUE="\033[1;34m"

# BANCO DE DADOS
DB_LOCAL="$HOME/.size_db"
[ ! -f "$DB_LOCAL" ] && echo "SIZE-ADM|ADM|1893456000" > "$DB_LOCAL"

# VARIÁVEIS
MODELO="Desconectado"; STATUS_ADB="$RED● OFFLINE$RESET"; CURRENT_USER=""

# FUNÇÃO DE TEMPO
get_time_left() {
    local exp=$1
    local now=$(date +%s)
    if [ "$exp" -le "$now" ]; then
        echo -e "$RED● EXPIRADO$RESET"
    else
        local diff=$((exp - now))
        local d=$((diff / 86400))
        local h=$(( (diff % 86400) / 3600 ))
        local m=$(( (diff % 3600) / 60 ))
        echo -e "$GREEN● ATIVO$RESET ($d"d" $h"h" $m"m")$RESET"
    fi
}

check_status(){
    if adb devices | grep -q -w "device"; then
        STATUS_ADB="$GREEN● ONLINE$RESET"
        MODELO=$(adb shell getprop ro.product.model 2>/dev/null || echo "Android")
    else
        STATUS_ADB="$RED● OFFLINE$RESET"; MODELO="Aguardando..."
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
    echo "  ╚═════╝    ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝"
    echo -e "$WHITE           MANAGER BY @SIZEPULAYBOTA$RESET"
    echo -e "$MAGENTA--------------------------------------------------$RESET"
    echo -e "$WHITE DEVICE: $CYAN$MODELO$RESET  $WHITE ADB: $STATUS_ADB"
    echo -e "$WHITE USER:   $YELLOW$CURRENT_USER$RESET"
    echo -e "$MAGENTA--------------------------------------------------$RESET"
}

# --- PAINEL ADM ---
painel_adm(){
    banner
    echo -e "$BOLD$CYAN [ MENU ADMINISTRADOR ]$RESET"
    echo -e "$WHITE [1] CRIAR NOVA KEY        [2] LISTAR KEYS (ON/OFF)"
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
            echo -e "$GREEN [!] SUCESSO!$RESET"; sleep 1; painel_adm ;;
        2)  banner
            printf "${CYAN}%-12s %-6s %-20s${RESET}\n" "USER" "TIPO" "STATUS/TEMPO"
            echo -e "$MAGENTA--------------------------------------------------$RESET"
            while IFS='|' read -r u t e; do
                printf "${WHITE}%-12s ${YELLOW}%-6s ${RESET}%-20s\n" "$u" "$t" "$(get_time_left "$e")"
            done < "$DB_LOCAL"
            echo -ne "\n$YELLOW Enter para voltar...$RESET"; read; painel_adm ;;
        3)  banner; echo -ne "Remover User: "; read r_user
            sed -i "/^$r_user|/d" "$DB_LOCAL"; painel_adm ;;
        4)  menu_bypass ;;
        *)  exit 0 ;;
    esac
}

# --- MENU BYPASS ---
menu_bypass(){
    banner
    echo -e "$BOLD$WHITE [ FUNÇÕES ANALISTA ]$RESET"
    echo -e "$CYAN [00] PAREAR DISPOSITIVO    [05] KEYMAPPER (RESET)"
    echo -e "$CYAN [01] LIMPAR SHIZUKU        [06] BYPASS KELLER SS"
    echo -e "$CYAN [02] LIMPAR BREVENT        [07] OCULTAR APP"
    echo -e "$CYAN [03] GHOSTMODE (LOGS)      [08] RESTAURAR APP"
    echo -e "$CYAN [04] PASSADOR DE REPLAY    [09] LIMPAR TUDO"
    echo -e "$MAGENTA--------------------------------------------------$RESET"
    [ "$(grep "^$CURRENT_USER|" "$DB_LOCAL" | cut -d'|' -f2)" == "ADM" ] && echo -e "$YELLOW [99] VOLTAR AO ADM$RESET"
    echo -e "$RED [S] SAIR DO PAINEL$RESET"
    echo -ne "\n$BOLD$WHITE ► SELECIONE:$RESET "; read op
    
    case $op in
        00|0) banner; echo -ne "Porta: "; read p1; echo -ne "Cod: "; read c1
              adb pair "127.0.0.1:$p1" "$c1"; echo -ne "Porta Conectar: "; read p2; adb connect "127.0.0.1:$p2"; menu_bypass ;;
        01|1) adb shell "pkill -f shizuku; rm -rf /data/local/tmp/shizuku*"; menu_bypass ;;
        02|2) adb shell "pkill -9 brevent; cmd usagestats flush-all"; menu_bypass ;;
        03|3) adb shell "logcat -c; rm -rf /sdcard/MT2"; menu_bypass ;;
        04|4) # PASSADOR DE REPLAY
              echo -e "$YELLOW [>] ATIVANDO PASSADOR DE REPLAY...$RESET"
              adb shell "settings put global window_animation_scale 0.5"
              adb shell "settings put global transition_animation_scale 0.5"
              adb shell "am force-stop com.dts.freefireth" 2>/dev/null
              adb shell "am force-stop com.dts.freefiremax" 2>/dev/null
              echo -e "$GREEN [!] REPLAY ATIVADO!$RESET"; sleep 1; menu_bypass ;;
        05|5) adb shell "pkill -f k2daemon"; menu_bypass ;;
        06|6) adb shell "settings put global time_zone America/Sao_Paulo; touch -t 202401011200 /data/local/tmp"; menu_bypass ;;
        07|7) banner; adb shell pm list packages -3 | cut -d':' -f2 | head -n 10
              echo -ne "\nPacote para OCULTAR: "; read pkg
              adb shell pm suspend "$pkg" && adb shell am force-stop "$pkg"; menu_bypass ;;
        08|8) echo -ne "Pacote para RESTAURAR: "; read pkg; adb shell pm unsuspend "$pkg"; menu_bypass ;;
        09|9) adb shell "pm clear com.android.providers.downloads"; adb shell "pkill -f com.google.android.gms"; menu_bypass ;;
        99) painel_adm ;;
        s|S) exit 0 ;;
        *) menu_bypass ;;
    esac
}

# --- LOGIN ---
login(){
    banner
    echo -ne "\n$WHITE LOGIN: $YELLOW"; read in_user
    USER_DATA=$(grep "^$in_user|" "$DB_LOCAL")
    if [ -z "$USER_DATA" ]; then
        echo -e "$RED [!] USUÁRIO INVÁLIDO$RESET"; sleep 1; login
    fi
    EXP=$(echo "$USER_DATA" | cut -d'|' -f3)
    if [ "$(date +%s)" -gt "$EXP" ]; then
        echo -e "$RED [!] ACESSO EXPIRADO!$RESET"; sleep 2; exit 1
    fi
    CURRENT_USER="$in_user"
    TIPO=$(echo "$USER_DATA" | cut -d'|' -f2)
    [ "$TIPO" == "ADM" ] && painel_adm || menu_bypass
}

adb start-server > /dev/null 2>&1
login
