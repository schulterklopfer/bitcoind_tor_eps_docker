#!/bin/bash

# This configuration script is based on the ones found in
# this awesome project: https://github.com/rootzoll/raspiblitz

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

RPCUSERFILE=/setup/data/rpcuser
RPCPASSWORDFILE=/setup/data/rpcpassword
SETUP_STATE=/setup/data/.setupState

## default menu settings
HEIGHT=17
WIDTH=72
CHOICE_HEIGHT=6
BACKTITLE="Configure OpenVPN"
TITLE=""
MENU="Setup suff."
OPTIONS=()

if [ ! -f ~/.dialogrc ]; then
    echo "screen_color = (CYAN,YELLOW,ON)" > ~/.dialogrc
fi

setupState=4;
if [ -f "$SETUP_STATE" ]; then
  setupState=$( cat $SETUP_STATE )
fi

if [ ${setupState} -eq 3 ]; then

    # start setup
    BACKTITLE="Configure Bitcoind"
    TITLE="Generate config"
    MENU="This screen will generate a random rpc user with a random password \
used by electrum personal server to connect ro bitcoinds rpc interface.\n\
If you want to use your bitcoin node with Samurai wallet, be sure to write \
the uername and password down. If you forget to do that or loose the piece \
of paper, they can be found in the files rpcuser and rpcpassword.\n\n"
    OPTIONS+=("Generate config" "Generate config with random rpc username and password")   

elif [ ${setupState} -gt 3 ]; then

    # continue setup
    BACKTITLE="Configuration done"
    TITLE="Cool cool"
    MENU="Bitcoind config was (already) generated. You will find the username and password inside the files \
rpcuser and rpcpassword. You can change those values and restart the bitcoind configuration \
process. The new values will be used instead of the random ones. If you want to create a new \
user and password, simply delete the rpcuser and rpcpassword file and restart bitcoind \
configuration.\n\n"
    OPTIONS+=("Continue" "Jump to electrum personal server configuration")
    OPTIONS+=(Restart "Restart the process without deleting")   
    OPTIONS+=("Delete and restart" "Delete rpcuser and rpcpassword and restart the process")   
fi


 
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

            echo "Creating random RPC data"

            rpcuser=''
            rpcpassword=''

            if [ -f $RPCUSERFILE ]; then
                rpcuser=$( cat $RPCUSERFILE)
                echo "Using old user: $rpcuser"
            else
                rpcuser=$( pwgen 20 -n 1 )
                echo $rpcuser > $RPCUSERFILE
            fi


            if [ -f $RPCPASSWORDFILE ]; then
                rpcpassword=$( cat $RPCPASSWORDFILE)
                echo "Using old password: $rpcpassword"
            else
                rpcpassword=$( pwgen 20 -n 1 )
                echo $rpcpassword > $RPCPASSWORDFILE
            fi


            echo ""
            echo "RPC username is: $rpcuser"
            echo "RPC password is: $rpcpassword"
            echo ""

            cp /bitcoin/.bitcoin/bitcoin.conf.sample /bitcoin/.bitcoin/bitcoin.conf

            sed -i.bak "s/%RPCUSER%/${rpcuser}/" /bitcoin/.bitcoin/bitcoin.conf
            sed -i.bak "s/%RPCPASSWORD%/${rpcpassword}/" /bitcoin/.bitcoin/bitcoin.conf

            rm /bitcoin/.bitcoin/bitcoin.conf.bak

            echo "4" > $SETUP_STATE
            
            echo "" && \
            echo "Press any key to return to menu" && \
            read key && \

            $DIR/start.sh

            ;;
        Restart)
            echo "3" > $SETUP_STATE
            $DIR/start.sh
            #exit 1;
            ;;
        "Delete and restart")
            rm $RPCUSERFILE $RPCPASSWORDFILE 2>/dev/null
            echo "3" > $SETUP_STATE
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
