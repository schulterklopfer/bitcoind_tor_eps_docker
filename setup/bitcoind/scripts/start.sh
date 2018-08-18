#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

RPCUSERFILE=/setup/data/rpcuser
RPCPASSWORDFILE=/setup/data/rpcpassword
SETUP_STATE=/setup/data/.setupState

## default menu settings
HEIGHT=14
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

if [ ${setupState} -eq 4 ]; then

    # start setup
    BACKTITLE="Configure Bitcoind"
    TITLE="Generate config"
    MENU="Whats happening? Description here"
    OPTIONS+=("Generate config" "Generate for bitcoind with random rpc username and password")   


elif [ ${setupState} -gt 4 ]; then

    # continue setup
    BACKTITLE="Configuration done"
    TITLE="Cool cool"
    MENU="All is cool, file is there and there"
    OPTIONS+=("Continue" "Jump to electrum personal server configuration")   
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

            echo "5" > $SETUP_STATE
            
            echo "" && \
            echo "Press any key to return to menu" && \
            read key && \

            $DIR/start.sh

            ;;
        Restart)
            rm $RPCUSERFILE $RPCPASSWORDFILE 2>/dev/null
            echo "4" > $SETUP_STATE
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
