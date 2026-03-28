#!/bin/bash
# PAINEL BYPASS EXTERNAL - @SIZEPULAYBOTA v2.1

# CORES
RED="\033[1;31m"; GREEN="\033[1;32m"; YELLOW="\033[1;33m"; 
CYAN="\033[1;36m"; MAGENTA="\033[1;35m"; WHITE="\033[1;37m"; RESET="\033[0m"; BOLD="\033[1m"

# BANCO DE DADOS LOCAL
DB_LOCAL="$HOME/.database_keys"
[ ! -f "$DB_LOCAL" ] && echo "SIZE-ADM|1|ADM|4102444800" > "$DB_LOCAL"

# VARIÁVEIS DE CONTROLE
MODELO="Desconectado"; STATUS="$RED● OFFLINE$RESET"; CURRENT_USER=""

# ANIMAÇÃO
loading(){
    echo -ne "$CYAN [>] $1 "
    for i in {1..3}; do echo -ne "."; sleep 0.2; done
    echo -e "$RESET"
}

# VERIFICAÇÃO DE STATUS ADB
check_status(){
    MY_IP=$(ip addr show wlan0 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    [ -z "$MY_IP" ] && MY_IP="127.0.0.1"
    
    if adb devices | grep -q -w "device"; then
        STATUS="$GREEN● ONLINE$RESET"
        MODELO=$(adb shell getprop ro.product.model 2>/dev/null || echo "Android Device")
    else
        STATUS="$RED● OFFLINE$RESET"
        MODELO="Aguardando ADB..."
    fi
}

banner(){
    clear; check_status
    echo -e "$MAGENTA"
    echo "  ██████╗ ██╗   ██╗██████╗  █████╗ ███████╗███████╗"
    echo "  ██╔══██╗╚██╗ ██╔╝██╔══██╗██╔══██╗██╔════╝██╔════╝"
    echo "  ██████╔╝ ╚████╔╝ ██████╔╝███████║███████╗███████╗"
    echo "  ██╔══██╗  ╚██╔╝  ██╔═══╝ ██╔══██║╚════██║╚════██║"
    echo "  ██████╔╝   ██║   ██║     ██║  ██║███████║███████║"
    echo "  ╚═════╝    ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝"
    echo -e "$WHITE           BYPASS ANALISTA | @SIZEPULAYBOTA$RESET"
    echo -e "$CYAN--------------------------------------------------$RESET"
    echo -e "$WHITE DEVICE: $CYAN$MODELO$RESET  $WHITE STATUS: $STATUS"
    echo -e "$WHITE USER: $YELLOW$CURRENT_USER$RESET"
    echo -e "$CYAN--------------------------------------------------$RESET"
}

# --- MENU ADM ---
painel_adm(){
    banner
    echo -e "$BOLD$RED [ PAINEL ADMINISTRATIVO ]$RESET"
    echo -e "$WHITE [1] GERAR KEY (USUÁRIO)"
    echo -e "$WHITE [2] LISTAR TODOS OS USUÁRIOS"
    echo -e "$WHITE [3] DELETAR USUÁRIO / KEY"
    echo -e "$WHITE [4] ACESSAR MENU ANALISTA"
    echo -e "$WHITE [S] SAIR"
    echo -ne "\n$CYAN ► SELECIONE ADM:$RESET "; read adm_op
    
    case $adm_op in
        1)  banner; echo -ne "NOME DO NOVO USUÁRIO: "; read n_user
            echo "$n_user|1|USER|4102444800" >> "$DB_LOCAL"
            loading "Salvando Acesso"; painel_adm ;;
        2)  banner; echo -e "$YELLOW [ LISTA DE USUÁRIOS ATIVOS ]$RESET"
            printf "%-15s %-10s %-10s\n" "USUARIO" "TIPO" "STATUS"
            while IFS='|' read -r u s t e; do
                printf "%-15s %-10s %-10s\n" "$u" "$t" "ATIVO"
            done < "$DB_LOCAL"
            echo -ne "\n$YELLOW Enter para voltar...$RESET"; read; painel_adm ;;
        3)  banner; echo -ne "USUARIO PARA REMOVER: "; read r_user
            sed -i "/^$r_user|/d" "$DB_LOCAL"
            loading "Removendo"; painel_adm ;;
        4)  menu ;;
        *)  exit 0 ;;
    esac
}

# --- MENU ANALISTA ---
menu(){
    banner
    echo -e "$CYAN [00]$RESET PAREAR (PORTA+CÓD) $WHITE (IP: $MY_IP)$RESET"
    echo -e "$MAGENTA [01]$RESET LIMPAR SHIZUKU    $MAGENTA [02]$RESET LIMPAR BREVENT"
    echo -e "$MAGENTA [03]$RESET GHOSTMODE (LOGS)  $MAGENTA [05]$RESET RESET KEYMAPPER"
    echo -e "$YELLOW [06]$RESET BYPASS KELLER SS (ANTI-SCAN)"
    echo -e "$RED [07]$RESET OCULTAR APP (HIDDEN)"
    echo -e "$GREEN [08]$RESET RESTAURAR APP OCULTO"
    [ "$(grep "^$CURRENT_USER|" "$DB_LOCAL" | cut -d'|' -f3)" == "ADM" ] && echo -e "$RED [99] VOLTAR AO ADM$RESET"
    echo -e "$WHITE [S] SAIR DO PAINEL$RESET"
    echo -ne "\n$BOLD$WHITE ► SELECIONE:$RESET "; read op
    
    case $op in
        00|0) banner; echo -ne "Porta Pareamento: "; read p1; echo -ne "Código 6 Dígitos: "; read c1
              adb pair "$MY_IP:$p1" "$c1"
              echo -ne "Porta Conexão: "; read p2; adb connect "$MY_IP:$p2"
              loading "Conectando ao Dispositivo"; sleep 2; menu ;;
        01|1) adb shell "pkill -f shizuku; rm -rf /data/local/tmp/shizuku*"; loading "Limpando Shizuku"; menu ;;
        02|2) adb shell "pkill -9 brevent; cmd usagestats flush-all"; loading "Limpando Brevent"; menu ;;
        03|3) adb shell "logcat -c; rm -rf /sdcard/MT2"; loading "Ativando GhostMode"; menu ;;
        05|5) adb shell "pkill -f k2daemon"; loading "Limpando Keymapper"; menu ;;
        06|6) loading "Aplicando Keller SS"
              adb shell "settings put global time_zone America/Sao_Paulo"
              adb shell "touch -t 202401011200 /data/local/tmp"
              menu ;;
        07|7) banner; adb shell pm list packages -3 | cut -d':' -f2 | head -n 12
              echo -ne "\nPacote para OCULTAR: "; read pkg
              if [ ! -z "$pkg" ]; then
                adb shell pm suspend "$pkg" >/dev/null 2>&1
                adb shell am force-stop "$pkg" >/dev/null 2>&1
                loading "Ocultando $pkg"
              fi
              menu ;;
        08|8) echo -ne "Pacote para RESTAURAR: "; read pkg
              if [ ! -z "$pkg" ]; then
                adb shell pm unsuspend "$pkg" >/dev/null 2>&1
                loading "Restaurando $pkg"
              fi
              menu ;;
        99) painel_adm ;;
        s|S) adb kill-server; exit 0 ;;
        *) menu ;;
    esac
}

# --- SISTEMA DE LOGIN ---
login(){
    banner
    echo -ne "$WHITE USUARIO: $YELLOW"; read in_user
    loading "Verificando Credenciais"
    USER_DATA=$(grep "^$in_user|" "$DB_LOCAL")
    
    if [ -z "$USER_DATA" ]; then
        echo -e "$RED [!] Acesso Negado!$RESET"; sleep 1; login
    fi
    
    CURRENT_USER="$in_user"
    TIPO=$(echo "$USER_DATA" | cut -d'|' -f3)
    [ "$TIPO" == "ADM" ] && painel_adm || menu
}

# Iniciar ADB e Login
adb start-server > /dev/null 2>&1
login
