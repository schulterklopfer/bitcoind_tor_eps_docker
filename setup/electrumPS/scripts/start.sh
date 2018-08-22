#!/bin/bash

# This configuration script is based on the ones found in
# this awesome project: https://github.com/rootzoll/raspiblitz

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

RPCUSERFILE=/setup/data/rpcuser
RPCPASSWORDFILE=/setup/data/rpcpassword
XPUBFILE=/setup/data/xpub
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
    echo "screen_color = (CYAN,RED,ON)" > ~/.dialogrc
fi

setupState=5;
if [ -f "$SETUP_STATE" ]; then
  setupState=$( cat $SETUP_STATE )
fi

if [ ${setupState} -eq 4 ]; then

    # start setup
    BACKTITLE="Configure electrum personal server"
    TITLE="Generate config"
    MENU="Lets give electrum personal server a master public key to monitor your \
addresses. If you are using the electrum wallet, you will find this key in the \
menu under 'wallet > information'.\n"
    OPTIONS+=("Generate config" "Generate config for electrum personal server")   


elif [ ${setupState} -gt 4 ]; then

    # continue setup
    BACKTITLE="Configuration done"
    TITLE="Cool cool"
    MENU="Electrum personal server config was (already) generated. If you want to change the \
master public key, just restart this configuration process.\n\n"
    OPTIONS+=("Exit" "Everything is configured. Exit.")   
    OPTIONS+=(Restart "Restart electrum personal server configuration")   
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

            rpcuser=''
            rpcpassword=''

            if [ -f $RPCUSERFILE ]; then
                rpcuser=$( cat $RPCUSERFILE)
                echo "Using user: $rpcuser"
            else
                echo ""
                echo "No rpc user found. Please rerun ./setup.sh and restart bitcoind configuration"
                echo ""
                exit 1
            fi


            if [ -f $RPCPASSWORDFILE ]; then
                rpcpassword=$( cat $RPCPASSWORDFILE)
                echo "Using password: $rpcpassword"
            else
                echo ""
                echo "No rpc password found. Please rerun ./setup.sh and restart bitcoind configuration"
                echo ""
                exit 1
            fi

            if [ -f $XPUBFILE ]; then
                xpub=$( cat $XPUBFILE)
                echo "Using old xpub key: $xpub"
            else

                echo ""
                echo "Please enter the xpub key of your wallet:"

                read xpub

                echo ""
                echo "Your xpub key is $xpub"
                echo ""
                echo $xpub > $XPUBFILE
            fi

            cp /eps/config.cfg.sample /eps/config.cfg

            sed -i.bak "s/%RPCUSER%/${rpcuser}/" /eps/config.cfg
            sed -i.bak "s/%RPCPASSWORD%/${rpcpassword}/" /eps/config.cfg
            sed -i.bak "s/%XPUB%/${xpub}/" /eps/config.cfg

            rm /eps/config.cfg.bak

            echo "5" > $SETUP_STATE
            
            echo "" && \
            echo "Press any key to return to menu" && \
            read key && \

            $DIR/start.sh

            ;;
        Restart)
            rm $XPUBFILE 2>/dev/null
            echo "4" > $SETUP_STATE
            $DIR/start.sh
            #exit 1;
            ;;
        Exit)
            exit 0
            ;;
        *)
            echo "SUCH WOW come back with ./setup.sh"
            exit 1
            ;;
esac

#--------


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

RPCUSERFILE=/setup/data/rpcuser
RPCPASSWORDFILE=/setup/data/rpcpassword


