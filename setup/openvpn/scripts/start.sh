#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
SETUP_STATE=/setup/data/.setupState
screen_color=(WHITE,BLACK,OFF)
INITPKI='ovpn_initpki'
CREATECLIENT='easyrsa build-client-full electrum nopass'
EXPORTCONFIG='ovpn_getclient electrum > /setup/data/electrum.ovpn'

## default menu settings
HEIGHT=14
WIDTH=72
CHOICE_HEIGHT=6
BACKTITLE="Configure OpenVPN"
TITLE=""
MENU="Setup suff."
OPTIONS=()


if [ ! -f ~/.dialogrc ]; then
    echo "screen_color = (CYAN,BLUE,ON)" > ~/.dialogrc
fi

## get actual setup state
setupState=0;
if [ -f "$SETUP_STATE" ]; then
  setupState=$( cat $SETUP_STATE)
fi
if [ ${setupState} -eq 0 ]; then

    # start setup
    BACKTITLE="Configure OpenVPN"
    TITLE="Generate config"
    MENU="Whats happening? Description here"
    OPTIONS+=("Generate config" "Generate config for server side")   


elif [ ${setupState} -eq 1 ]; then

    # continue setup
    BACKTITLE="Configure OpenVPN"
    TITLE="PKI setup"
    MENU="Whats happening? Description here"
    OPTIONS+=("PKI setup" "Setup keys and certificates")   


elif [ ${setupState} -eq 2 ]; then

    # continue setup
    BACKTITLE="Configure OpenVPN"
    TITLE="Client setup"
    MENU="Whats happening? Description here"
    OPTIONS+=("Client setup" "Setup a client entry to be exported later")   


elif [ ${setupState} -eq 3 ]; then

    # continue setup
    BACKTITLE="Configure OpenVPN"
    TITLE="Export config"
    MENU="Whats happening? Description here"
    OPTIONS+=("Export config" "Export config to be used with OpenVPN client")   

elif [ ${setupState} -gt 3 ]; then

    # continue setup
    BACKTITLE="Configuration done"
    TITLE="Cool cool"
    MENU="All is cool, file is there and there"
    OPTIONS+=("Continue" "Jump to bitcoind configuration")  
fi

if [ ${setupState} -gt 0 ]; then 
    OPTIONS+=(Back "Go back one step")   
fi

OPTIONS+=(Restart "Clear everything and restart the process")   


CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)
clear
case $CHOICE in
        "Generate config")

            rm /etc/openvpn/ovpn_env.sh 2> /dev/null
            rm /etc/openvpn/openvpn.conf 2> /dev/null
    

            echo ""
            echo "Please enter the external IP Address or servername for the openvpn server:"

            read ipaddr

            echo ""
            echo "Your server address is $ipaddr"
            echo ""
            ovpn_genconfig -N -d -p "route 10.11.12.0 255.255.255.0" -u udp://${ipaddr} && \
            echo "1" > $SETUP_STATE

            echo "" && \
            echo "Press any key to return to menu" && \
            read key && \
            
            $DIR/start.sh
            #exit 1;
            ;;
        "PKI setup")

            rm -rf /etc/openvpn/pki 2> /dev/null

            eval $INITPKI && \
            echo "2" > $SETUP_STATE

            echo "" && \
            echo "Press any key to return to menu" && \
            read key && \

            $DIR/start.sh
            #exit 1;
            ;;
        "Client setup")

            rm /etc/openvpn/pki/reqs/electrum.req 2> /dev/null
            rm /etc/openvpn/pki/private/electrum.key 2> /dev/null

            eval $CREATECLIENT && \
            echo "3" > $SETUP_STATE
            
            echo "" && \
            echo "Press any key to return to menu" && \
            read key && \

            $DIR/start.sh
            #exit 1;
            ;;
        "Export config")
            eval $EXPORTCONFIG && \
            echo "" && \
            echo "Configuration was exported to electrum.ovpn" && \

            echo "4" > $SETUP_STATE
            
            echo "" && \
            echo "Press any key to return to menu" && \
            read key && \

            $DIR/start.sh
            #exit 1;
            ;;
        Back)
            setupState=$(($setupState-1))
            if [ ${setupState} -lt 0 ]; then
                setupState=0;
            fi
            echo $setupState > $SETUP_STATE
            $DIR/start.sh
            ;;
        Restart)
            rm -rf /etc/openvpn/* 2>/dev/null
            echo "0" > $SETUP_STATE
            $DIR/start.sh
            #exit 1;
            ;;
        Continue)
            exit 0
            ;;
        *)
            echo "SUCH WOW come back with ./setup.sh"
            exit 1
            ;;
esac