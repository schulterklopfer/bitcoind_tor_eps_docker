# Bitcoind, tor, openvpn and electrum personal server bundled


### Why?

This repository aims to provide an easy way to run your own full node and also _*use*_ it
by connecting your wallets to it over VPN to propagate your own transactions with it. 
This setup will enable you to use your hardware wallet with your own full node.

### Prerequisites

#### Root access on a machine in your local area network or on a hosted server.

#### Git

#### Docker

Please refer to [this](https://docs.docker.com/install/) documentation on how to install
docker for your OS.

#### Docker-compose

Please refer to [this](https://docs.docker.com/compose/install/) documentation on how to install
docker-compose for your OS.

### Supported

The scripts should run on every  \*nix like system with a shell and the `docker` and 
`docker-compose` command in your `$PATH`.

### Tested

The setup is tested on OSX. Please let me know, if it works on your system.

### Setting up everything

clone this repository like this `git clone https://github.com/schulterklopfer/bitcoind_tor_eps_docker.git`

After everything has finished:

```bash
cd bitcoind_tor_eps_docker
./setup.sh
``` 

Read everything carefully and follow the steps till the configuration process
is finished.

For connecting to your brand new OpenVPN you need to import the configuration file
`electrum.ovpn` created in the previous setup step into your OpenVPN client of your choice.

In case you are installing this on a machine at home in your local area network
and you want to connect your laptop or mobile device from outside, you need to 
configure your router which connects you to the internet and install a so called
"port forward" from the machine everything is installed on out into the internet.

The IP will be whatever IP your machine has inside the local area network. 
The port needs to be 1194 and the type of the port must be UDP.

If you want to make your full node accessible to other full nodes on the bitcoin
network, you will need to do the same thing for the TCP port 8333.

You don't have to do this, if you are running this docker-compose on a hosted server
unless it is hidden behind a firewall.

### Running and stoping it

You can start your bitcoin full node, 
electrum personal server and OpenVPN by issuing the following command:

```bash
./start.sh
```

Note the everything which needs to store will be stored inside the volumes folder.
Exiting blockchain data can be copied into `volumes/bitcoind`.

To stop everything cd to bitcoind_tor_eps_docker and issue the following command:

```bash
./stop.sh
```


Thanks for reading. :-D

*SKP*

####TODOS

* Write up more doc for OpenVPN clients
* Write up more doc on how to connect electrum


