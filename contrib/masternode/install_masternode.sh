#/bin/bash
# This script is a derivative work of the code from the following projects:
# Galactrum - https://www.galactrum.org/
# Innova Coin - https://innovacoin.info/
clear
cd ~
echo "**********************************************************************"
echo "*                                                                    *"
echo "* This script will install and configure your CrowdCoin masternode.  *"
echo "*                                                                    *"
echo "* This script is provided 'AS IS' without any warranties or support. *"
echo "*                                                                    *"
echo "**********************************************************************"
echo && echo && echo
sleep 3

read -p "This script will install & configure a CrowdCoin Masternode.  Do you wish to continue? (y/n)? " response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
	then
	# Gather input from user
	read -e -p "Masternode Private Key (e.g. 7edfjLCUzGczZi3JQw8GHp434R9kNY33eFyMGeKRymkB56G4324h) : " key
	if [[ "$key" == "" ]]; then
		echo "WARNING: No private key entered, exiting!!!"
		echo && exit
	fi
	read -e -p "Server IP Address (Without Port): " ip
	echo && echo "Pressing ENTER will use the default value for the next prompts."
	echo && sleep 3
	read -e -p "Add swap space? (Recommended) [Y/n] : " add_swap
	if [[ ("$add_swap" == "y" || "$add_swap" == "Y" || "$add_swap" == "") ]]; then
		read -e -p "Swap Size [4G] : " swap_size
		if [[ "$swap_size" == "" ]]; then
			swap_size="4G"
		fi
	fi    
	read -e -p "Install Fail2ban? (Recommended) [Y/n] : " install_fail2ban
	read -e -p "Install UFW and configure ports? (Recommended) [Y/n] : " UFW
	
	# Add swap if needed
	if [[ ("$add_swap" == "y" || "$add_swap" == "Y" || "$add_swap" == "") ]]; then
		if [ ! -f /swapfile ]; then
			echo && echo "Adding swap space..."
			sleep 3
			sudo fallocate -l $swap_size /swapfile
			sudo chmod 600 /swapfile
			sudo mkswap /swapfile
			sudo swapon /swapfile
			echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
			sudo sysctl vm.swappiness=10
			sudo sysctl vm.vfs_cache_pressure=50
			echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
			echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf
		else
			echo && echo "WARNING: Swap file detected, skipping add swap!"
			sleep 3
		fi
	fi
	
	# Update system 
	echo && echo "Upgrading system..."
	sleep 3
	sudo apt-get -y update
	sudo apt-get -y upgrade
	sudo apt-get -y dist-upgrade
	
	# Add Berkely PPA
	echo && echo "Installing bitcoin PPA..."
	sleep 3
	sudo apt-get -y install software-properties-common
	sudo apt-add-repository -y ppa:bitcoin/bitcoin
	sudo apt-get -y update
	
	# Install required packages
	echo && echo "Installing base packages..."
	sleep 3
	sudo apt-get -y install \
		wget \
		git \
		libevent-dev \
		libboost-dev \
		libgmp3-dev \
		libboost-all-dev \
		libboost-chrono-dev \
		libboost-filesystem-dev \
		libboost-program-options-dev \
		libboost-system-dev \
		libboost-test-dev \
		libboost-thread-dev \
		libdb4.8-dev \
		libdb4.8++-dev \
		libtool \
		libminiupnpc-dev \
		libzmq5 \
		build-essential \
		autotools-dev \
		automake \
		pkg-config \
		libssl-dev \
		libevent-dev \
		bsdmainutils \
		software-properties-common \
		nano \
		htop \
		autoconf \
		libminiupnpc-dev \
		python-virtualenv \
		virtualenv \
		rpl \
		pwgen
		
	# Install fail2ban if needed
	if [[ ("$install_fail2ban" == "y" || "$install_fail2ban" == "Y" || "$install_fail2ban" == "") ]]; then
		echo && echo "Installing fail2ban..."
		sleep 3
		sudo apt-get -y install fail2ban
		sudo service fail2ban restart 
	fi
	
	# Install firewall if needed
	if [[ ("$UFW" == "y" || "$UFW" == "Y" || "$UFW" == "") ]]; then
		echo && echo "Installing UFW..."
		sleep 3
		sudo apt-get -y install ufw
		echo && echo "Configuring UFW..."
		sleep 3
		sudo ufw default deny incoming
		sudo ufw default allow outgoing
		sudo ufw allow ssh
		sudo ufw limit ssh/tcp
		sudo ufw allow 12875/tcp
		sudo ufw logging on
		echo "y" | sudo ufw enable
		echo && echo "Firewall installed and enabled!"
	fi
	
	# Download CrowdCoin
	echo && echo "Downloading CrowdCoin.."
	sleep 3
	cd
	git clone https://github.com/crowdcoinChain/Crowdcoin.git
	
	# Install CrowdCoin
	echo && echo "Installing CrowdCoin..."
	sleep 3
	cd Crowdcoin
	chmod 755 autogen.sh
	./autogen.sh
	./configure
	chmod 755 share/genbuild.sh
	make
	
	# Create config for CrowdCoin
	echo && echo "Configuring CrowdCoin..."
	sleep 3
	cd ~
	cd Crowdcoin/src
	./crowdcoind -daemon
	sleep 10
	./crowdcoin-cli stop
	sleep 10
	rpcuser=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
	rpcpass=`pwgen -1 20 -n`
	cd /root/.crowdcoincore 
	echo -e "rpcuser=${rpcuser}\nrpcpassword=${rpcpass}\nrpcallowip=127.0.0.1\nrpcport=11998\nrpcthreads=8\nlisten=1\nserver=1\ndaemon=1\nstaking=0\ndiscover=1\nexternalip=${ip}:12875\nmasternode=1\nmasternodeprivkey=${key}\naddnode=84.17.23.43:12875\naddnode=18.220.138.90:12875\naddnode=86.57.164.166:12875\naddnode=86.57.164.146:12875\naddnode=18.217.78.145:12875\naddnode=23.92.30.230:12875\naddnode=35.190.182.68:12875\naddnode=80.209.236.4:12875\naddnode=91.201.40.89:12875" > /root/.crowdcoincore/crowdcoin.conf
	
	# Download and install sentinel
	echo && echo "Installing Sentinel..."
	sleep 3
	cd /root/.crowdcoincore
	git clone https://github.com/crowdcoinChain/sentinelLinux.git && cd sentinelLinux
	export LC_ALL=C
	virtualenv ./venv
	./venv/bin/pip install -r requirements.txt
	echo  "* * * * * cd /root/.crowdcoincore/sentinelLinux && ./venv/bin/python bin/sentinel.py >/dev/null 2>&1" >> mycron
	crontab mycron
	rm mycron
	rpl dash_conf=/home/YOURUSERNAME/.crowdcoincore/crowdcoin.conf dash_conf=/root/.crowdcoincore/crowdcoin.conf sentinel.conf
	
	#Start CrowdCoin Daemon
	sleep 60
	cd /root/Crowdcoin/src
	./crowdcoind -daemon
	cd ~
	echo && echo && echo
	echo "CrowdCoin installation completed successfully.  Please wait 15 minutes and then start your masternode from your local wallet"	
else
    echo "installation cancelled"
fi
