cat > ~/brevente.sh << 'SHEOF'
#!/bin/bash

# CORES - @SIZEPULAYBOTA
RED="\033[1;31m"; GREEN="\033[1;32m"; YELLOW="\033[1;33m"; CYAN="\033[1;36m"; 
MAGENTA="\033[1;35m"; WHITE="\033[1;37m"; RESET="\033[0m"; BOLD="\033[1m"

# BORDAS
LINE="--------------------------------------------------"
DBL_LINE="=================================================="

# INFO SISTEMA
DB_LOCAL="$HOME/.database_keys"
MODELO="Aguardando ADB..."
CURRENT_USER=""; CURRENT_STATUS="$RED● OFFLINE$RESET"

[ ! -f "$DB_LOCAL" ] && echo "SIZE-ADM|1|ADM|ANY|4102444800" > "$DB_LOCAL"

# ANIMAÇÃO DE CARREGAMENTO
loading(){
    local msg="$1"
    echo -ne "$CYAN [>] $msg "
    for i in {1..3}; do echo -ne "."; sleep 0.2; done
    echo -e "$RESET"
}

# VERIFICAÇÃO DE STATUS REAL
check_status(){
    MY_IP=$(ip addr show wlan0 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    [ -z "$MY_IP" ] && MY_IP="127.0.0.1"

    if adb devices | grep -q -w "device"; then
        CURRENT_STATUS="$GREEN● ONLINE$RESET"
        MODELO=$(adb shell getprop ro.product.model 2>/dev/null || echo "Android Device")
    else
        CURRENT_STATUS="$RED● OFFLINE$RESET"
        MODELO="Aguardando ADB..."
    fi
}

banner(){
    clear
    check_status
    echo -e "$MAGENTA"
    echo "  ██████╗ ██╗   ██╗██████╗  █████╗ ███████╗███████╗"
    echo "  ██╔══██╗╚██╗ ██╔╝██╔══██╗██╔══██╗██╔════╝██╔════╝"
    echo "  ██████╔╝ ╚████╔╝ ██████╔╝███████║███████╗███████╗"
    echo "  ██╔══██╗  ╚██╔╝  ██╔═══╝ ██╔══██║╚════██║╚════██║"
    echo "  ██████╔╝   ██║   ██║     ██║  ██║███████║███████║"
    echo "  ╚═════╝    ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝"
    echo -e "$WHITE               BYPASS ANALISTA ATUALIZADO"
    echo -e "$CYAN             SUPPORT DISCORD: @SIZEPULAYBOTA$RESET"
    echo -e "$CYAN$DBL_LINE$RESET"
}

aba_status(){
    banner
    loading "$2"
    echo -e "$MAGENTA$LINE$RESET"
    echo -e "$BOLD$WHITE [!] $1 FINALIZADO$RESET"
    echo -e "$MAGENTA$LINE$RESET"
    echo -e "$CYAN Desenvolvido por @SIZEPULAYBOTA$RESET"
    echo -e "$CYAN$DBL_LINE$RESET"
    echo -ne "\n$YELLOW Pressione ENTER para retornar...$RESET"
    read
}

login(){
    banner
    echo -e "\n$WHITE [ LOGIN REQUERIDO ]$RESET"
    echo -ne "$WHITE USUARIO: $YELLOW"; read input_user
    loading "Autenticando"
    LINE_KEY=$(grep "^$input_user|" "$DB_LOCAL")
    if [ -z "$LINE_KEY" ] || [ "$(echo "$LINE_KEY" | cut -d'|' -f2)" == "0" ]; then
        echo -e "$RED [!] Acesso Negado$RESET"; sleep 1; login
    fi
    CURRENT_USER="$input_user"
    [ "$(echo "$LINE_KEY" | cut -d'|' -f3)" == "ADM" ] && painel_adm || menu
}

menu(){
    banner
    echo -e "$BOLD$WHITE [ CONECTIVIDADE ]$RESET"
    echo -e "$CYAN [00]$RESET PAREAR PORTA+CÓD $WHITE (IP: $MY_IP)$RESET"
    echo ""
    echo -e "$BOLD$WHITE [ LIMPEZA ]$RESET"
    echo -e "$MAGENTA [01]$RESET SHIZUKU    $MAGENTA [02]$RESET BREVENT"
    echo -e "$MAGENTA [03]$RESET GHOSTMODE  $MAGENTA [05]$RESET KEYMAPPER"
    echo ""
    echo -e "$BOLD$WHITE [ BYPASS ANALISTA ]$RESET"
    echo -e "$CYAN [04]$RESET PASSAR REPLAY (MAX > NORMAL)"
    echo -e "$YELLOW [06]$RESET KELLER SS (ANTI-SCANNER)"
    echo -e "$RED [07]$RESET BYPASS HIDDEN (OCULTAR APP)"
    echo -e "$CYAN [08]$RESET RESTAURAR APP OCULTO"
    echo -e "$CYAN$DBL_LINE$RESET"
    echo -e "$WHITE DEVICE: $CYAN$MODELO$RESET"
    echo -e "$WHITE STATUS: $CURRENT_STATUS"
    echo -e "$WHITE USER: $YELLOW$CURRENT_USER$RESET"
    echo -e "$MAGENTA DISCORD: @SIZEPULAYBOTA$RESET"
    echo -e "$CYAN$DBL_LINE$RESET"
    echo -ne " ► Selecione: "; read op
    
    case $op in
        00|0)
            banner
            echo -e "$CYAN [ PAREAMENTO ]$RESET"
            echo -ne "$WHITE Porta Parear: $YELLOW"; read v_port_pair
            echo -ne "$WHITE Código: $YELLOW"; read v_code
            loading "Pareando"
            adb pair "$MY_IP:$v_port_pair" "$v_code"
            echo -ne "\n$WHITE Porta Conexão: $YELLOW"; read v_port_conn
            loading "Conectando"
            adb connect "$MY_IP:$v_port_conn"
            sleep 1; menu ;;
            
        01|1) adb shell "pkill -f shizuku; rm -rf /data/local/tmp/shizuku*"; aba_status "SHIZUKU" "Limpando rastros" ;;
        02|2) adb shell "pkill -9 brevent; cmd usagestats flush-all"; aba_status "BREVENT" "Encerrando stats" ;;
        03|3) adb shell "logcat -c; rm -rf /sdcard/MT2"; aba_status "GHOST" "Limpando Logs" ;;
        04|4) adb shell "mkdir -p /sdcard/Android/data/com.dts.freefireth/files/MReplays; cp -f /sdcard/Android/data/com.dts.freefiremax/files/MReplays/*.bin /sdcard/Android/data/com.dts.freefireth/files/MReplays/ 2>/dev/null"
              aba_status "REPLAY" "Sincronizando Replays" ;;
        05|5) adb shell "pkill -f k2daemon"; aba_status "KEYMAPPER" "Resetando K2" ;;
        06|6) adb shell "settings put global time_zone America/Sao_Paulo; touch -t 202401011200 /data/local/tmp"; aba_status "KELLER" "Alterando Timestamp" ;;
        
        07|7)
            banner
            echo -e "$YELLOW [ LISTA DE APPS ]$RESET"
            adb shell pm list packages -3 | cut -d':' -f2 | head -n 12
            echo -ne "\n$WHITE Pacote para OCULTAR: $YELLOW"
            read pkg_hide
            if [ ! -z "$pkg_hide" ]; then
                loading "Ocultando $pkg_hide"
                adb shell pm suspend "$pkg_hide" >/dev/null 2>&1
                adb shell am force-stop "$pkg_hide" >/dev/null 2>&1
                aba_status "HIDDEN" "App removido da vista"
            fi ;;
            
        08|8)
            banner
            echo -ne "$WHITE Pacote para RESTAURAR: $YELLOW"
            read pkg_show
            if [ ! -z "$pkg_show" ]; then
                loading "Restaurando"
                adb shell pm unsuspend "$pkg_show" >/dev/null 2>&1
                aba_status "RESTORE" "App visível novamente"
            fi ;;
            
        s|S|Sair) adb kill-server; clear; exit 0 ;;
        *) menu ;;
    esac
    menu
}

login
SHEOF
chmod +x ~/brevente.sh && bash ~/brevente.sh
