#!/bin/bash
# PAINEL SUPREMO - @SIZEPULAYBOTA v3.1

# CORES
RED="\033[1;31m"; GREEN="\033[1;32m"; YELLOW="\033[1;33m"; 
CYAN="\033[1;36m"; MAGENTA="\033[1;35m"; WHITE="\033[1;37m"; 
RESET="\033[0m"; BOLD="\033[1m"

# BANCO DE DADOS (Garante que a pasta existe)
DB_LOCAL="$HOME/.size_db"
if [ ! -f "$DB_LOCAL" ]; then
    # Cria o ADM com validade até o ano 2030 (Timestamp: 1893456000)
    echo "SIZE-ADM|ADM|1893456000" > "$DB_LOCAL"
fi

# VARIÁVEIS
MODELO="Desconectado"; STATUS_ADB="$RED● OFFLINE$RESET"; CURRENT_USER=""

# CALCULA TEMPO RESTANTE (SEM ERROS)
get_time_left() {
    local exp=$1
    local now=$(date +%s)
    if [ "$exp" -le "$now" ]; then
        echo -e "$RED● EXPIRADO$RESET"
    else
        local diff=$((exp - now))
        local d=$((diff / 86400))
        local h=$(( (diff % 86400) / 3600 ))
        echo -e "$GREEN● ATIVO$RESET (${d}d ${h}h)$RESET"
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
    echo -e "$MAGENTA"
    echo "  ██████╗ ██████╗ ███████╗██╗███████╗███████╗"
    echo "  ██╔══██╗██╔══██╗██╔════╝██║╚══███╔╝██╔════╝"
    echo "  ██████╔╝██████╔╝███████╗██║  ███╔╝ █████╗  "
    echo "  ██╔═══╝ ██╔══██╗╚════██║██║ ███╔╝  ██╔══╝  "
    echo "  ██║     ██║  ██║███████║██║███████╗███████╗"
    echo "  ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝╚══════╝╚══════╝"
    echo -e "$WHITE           MANAGER BY @SIZEPULAYBOTA$RESET"
    echo -e "$CYAN--------------------------------------------------$RESET"
    echo -e "$WHITE  DEVICE: $CYAN$MODELO$RESET  $WHITE ADB: $STATUS_ADB"
    echo -e "$WHITE  USER:   $YELLOW$CURRENT_USER$RESET"
    echo -e "$CYAN--------------------------------------------------$RESET"
}

# --- PAINEL ADM ---
painel_adm(){
    banner
    echo -e "$BOLD$MAGENTA [ GERENCIAMENTO DE ACESSOS ]$RESET"
    echo -e "$CYAN [1]$RESET GERAR KEY       $CYAN [2]$RESET LISTAR KEYS"
    echo -e "$CYAN [3]$RESET DELETAR KEY      $CYAN [4]$RESET MENU ANALISTA"
    echo -e "$RED [0]$RESET SAIR"
    echo -ne "\n$BOLD$WHITE ► OPÇÃO ADM:$RESET "; read adm_op
    
    case $adm_op in
        1)  banner; echo -ne "NOME DO USER: "; read n_user
            echo -ne "TIPO (1:USER 2:ADM): "; read t_opt
            [ "$t_opt" == "2" ] && n_tipo="ADM" || n_tipo="USER"
            echo -ne "DIAS DE VALIDADE: "; read n_dias
            # Cálculo de segundos (86400 seg = 1 dia)
            SEC=$((n_dias * 86400))
            EXP_KEY=$(( $(date +%s) + SEC ))
            echo "$n_user|$n_tipo|$EXP_KEY" >> "$DB_LOCAL"
            echo -e "$GREEN [!] SUCESSO!$RESET"; sleep 1; painel_adm ;;
        2)  banner
            printf "${MAGENTA}%-12s %-6s %-20s${RESET}\n" "USER" "TIPO" "STATUS"
            while IFS='|' read -r u t e; do
                printf "${WHITE}%-12s ${YELLOW}%-6s ${RESET}%-20s\n" "$u" "$t" "$(get_time_left "$e")"
            done < "$DB_LOCAL"
            echo -ne "\n$YELLOW Enter para voltar...$RESET"; read; painel_adm ;;
        3)  banner; echo -ne "Remover qual User? "; read r_user
            sed -i "/^$r_user|/d" "$DB_LOCAL"
            painel_adm ;;
        4)  menu_analista ;;
        *)  exit 0 ;;
    esac
}

# --- MENU ANALISTA ---
menu_analista(){
    banner
    echo -e "$WHITE [01] PAREAR       [05] KEYMAPPER"
    echo -e "$WHITE [02] SHIZUKU      [06] KELLER SS"
    echo -e "$WHITE [03] BREVENT      [07] OCULTAR APP"
    echo -e "$WHITE [04] GHOSTMODE    [08] RESTAURAR"
    echo -e "$CYAN--------------------------------------------------$RESET"
    [ "$(grep "^$CURRENT_USER|" "$DB_LOCAL" | cut -d'|' -f2)" == "ADM" ] && echo -e "$MAGENTA [99] VOLTAR AO ADM$RESET"
    echo -ne "\n$BOLD$WHITE ► SELECIONE:$RESET "; read op
    case $op in
        99) painel_adm ;;
        s|S|0) exit 0 ;;
        *) menu_analista ;; # Loop para manter o menu aberto
    esac
}

# --- LOGIN ---
login(){
    banner
    echo -ne "\n$WHITE USUÁRIO: $YELLOW"; read in_user
    USER_DATA=$(grep "^$in_user|" "$DB_LOCAL")
    if [ -z "$USER_DATA" ]; then
        echo -e "$RED [!] NÃO ENCONTRADO$RESET"; sleep 1; login
    fi
    EXP=$(echo "$USER_DATA" | cut -d'|' -f3)
    if [ "$(date +%s)" -gt "$EXP" ]; then
        echo -e "$RED [!] KEY EXPIRADA!$RESET"; sleep 2; exit 1
    fi
    CURRENT_USER="$in_user"
    TIPO=$(echo "$USER_DATA" | cut -d'|' -f2)
    [ "$TIPO" == "ADM" ] && painel_adm || menu_analista
}

adb start-server > /dev/null 2>&1
login
