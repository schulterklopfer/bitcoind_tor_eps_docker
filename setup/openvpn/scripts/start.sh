#!/bin/bash

# This configuration script is based on the ones found in
# this awesome project: https://github.com/rootzoll/raspiblitz

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
SETUP_STATE=/setup/data/.setupState
screen_color=(WHITE,BLACK,OFF)
INITPKI='ovpn_initpki'
CREATECLIENT='easyrsa build-client-full electrum nopass'
EXPORTCONFIG='ovpn_getclient electrum > /setup/data/electrum.ovpn'

## default menu settings
HEIGHT=17
WIDTH=79
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
    TITLE="1. Generate server config"
    MENU="First we need to create a server side configuration \
for your dockerised OpenVPN server. The only thing \
this tool needs to know from you is your external \
IP or server name your server is reachable over.\n\
If you are using a hosted solution you can look up your \
IP in the config section of your provider. If you \
are running this at home you can find out you \
external ip with tools like www.whatsmyip.org.\n\n"
    OPTIONS+=("Generate config" "Generate config for server side")   


elif [ ${setupState} -eq 1 ]; then

    # continue setup
    HEIGHT=20
    BACKTITLE="2. Configure OpenVPN"
    TITLE="Key and certificate setup"
    MENU="In this step we will setup all the keys and certificates \
needed by your OpenVPN server.\n
This step will first ask you to enter a PEM passphrase and verify it. \
Everytime the process asks you to enter a passphrase again, you use \
the one entered above. This is a bit cumbersome, but since this \
configuration process uses several simple tools chained together \
there is no good way around it. But repeating the passphrase will \
help you remember it. ;-)\n
When asked for a Common Name, you can enter something or leave it \
blank. This makes no difference for this process.\n\n"
    OPTIONS+=("PKI setup" "Setup keys and certificates")   


elif [ ${setupState} -eq 2 ]; then

    # continue setup
    BACKTITLE="Configure OpenVPN"
    TITLE="3. Client setup"
    MENU="Now we need to create the certificate which will be stored in the
configuration file you will use later to connect to your OpenVPN server.\n\
Please enter the same passphrase you used in the last step, when asked \
for it.\n
Finally a file called electrum.ovpn will be created. Do not share this \
file with anyone, since it contains a private key.\n\n"
    OPTIONS+=("Client setup" "Setup a client certificate and create configuration file")   

elif [ ${setupState} -gt 2 ]; then

    # continue setup
    BACKTITLE="Configuration done"
    TITLE="Cool cool"
    MENU="OpenVPN is configured now and a configuration file for \
your OpenVPN clients was written to electrum.ovpn in the same folder \
as setup.sh.\n\
Do not share this file with anyone, since it contains a private key\n\n"
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
            eval $EXPORTCONFIG && \
            echo "3" > $SETUP_STATE
            
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