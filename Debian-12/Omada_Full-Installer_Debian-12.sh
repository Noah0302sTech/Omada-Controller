#!/bin/bash
#	Made by Noah0302sTech
#	nano Omada_Full-Installer_Debian-12.sh && sudo bash Omada_Full-Installer_Debian-12.sh
#	wget https://raw.githubusercontent.com/Noah0302sTech/Omada-Controller/refs/heads/master/Debian-12/Omada_Full-Installer_Debian-12.sh && sudo bash Omada_Full-Installer_Debian-12.sh



#---------- Initial Checks & Functions & Folder-Structure
	#-------- Functions
		#----- echoEnd
			function echoEnd {
				echo
				echo
				echo
			}



		#----- Spinner - Source of Spinner-Function: https://github.com/tlatsas/bash-spinner
				function _spinner() {
					# $1 start/stop
					#
					# on start: $2 display message
					# on stop : $2 process exit status
					#           $3 spinner function pid (supplied from stop_spinner)

					local on_success="DONE"
					local on_fail="FAIL"
					local white="\e[1;37m"
					local green="\e[1;32m"
					local red="\e[1;31m"
					local nc="\e[0m"

					case $1 in
						start)
							# calculate the column where spinner and status msg will be displayed
							let column=$(tput cols)-${#2}-8
							# display message and position the cursor in $column column
							echo -ne ${2}
							printf "%${column}s"

							# start spinner
							i=1
							sp='\|/-'
							# I needed to change it to 0.25, since slow Machines might run into an Overflow if it gets recalled too often!
							delay=0.25

							while :
							do
								printf "\b${sp:i++%${#sp}:1}"
								sleep $delay
							done
							;;
						stop)
							if [[ -z ${3} ]]; then
								echo "spinner is not running.."
								exit 1
							fi

							kill $3 > /dev/null 2>&1

							# inform the user uppon success or failure
							echo -en "\b["
							if [[ $2 -eq 0 ]]; then
								echo -en "${green}${on_success}${nc}"
							else
								echo -en "${red}${on_fail}${nc}"
							fi
							echo -e "]"
							;;
						*)
							echo "invalid argument, try {start/stop}"
							exit 1
							;;
					esac
				}

				function start_spinner {
					# $1 : msg to display
					_spinner "start" "${1}" &
					# set global spinner pid
					_sp_pid=$!
					disown
				}

				function stop_spinner {
					# $1 : command exit status
					_spinner "stop" $1 $_sp_pid
					unset _sp_pid
				}
		echoEnd




	#-------- Checks
		#----- Visualize initial Checks
			start_spinner "Performing initial Checks..."
				sleep 1
				stop_spinner $?
		#----- Check for administrative Privileges
			if [[ $EUID -ne 0 ]]; then
				echo -e "\e[1;31m[!] The Script needs to be executed with Root-Permissions! (sudo) \e[0m"
				exit 1
			fi

		#----- Check for APT-Proxy
			#--- Detect if the APT-Proxy File exists
				FILE="/etc/apt/apt.conf.d/30proxy"
				PROXY_DISABLED=0  # Flag to track if APT-Proxy is NOT present

				if [ -f "$FILE" ]; then
					echo -e "\e[1;31m[!] An APT-Proxy seems to be configured, which might lead to Issues. \e[0m"
					read -p "Do you want to disable it for now? (y/n): " choice

					if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
						echo "Disabling APT-Proxy Settings..."
						sudo sed -i 's/^\([^#]\)/#\1/' "$FILE"
						PROXY_DISABLED=1  # Proxy NOT present
					fi
				fi
		echoEnd





	#----- Refresh Packages
		start_spinner "Updating Package-Repositories..."
			apt-get -qq update > /dev/null 2>&1
		stop_spinner $?
		echoEnd



#-----	-----#	#-----	-----#	#-----	-----#	#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#	#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#	#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#		Modified Script from https://github.com/monsn0/omada-installer			#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#	#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#	#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#	#-----	-----#	#-----	-----#	#-----	-----#



#----- Initial Checks
	#--- Check the Debian version
		DEBIAN_VERSION=$(grep "^VERSION_ID=" /etc/os-release | cut -d '"' -f 2)
		if [[ "$DEBIAN_VERSION" != "12" ]]; then
			echo -e "\e[1;31m[!] This script requires Debian version 12. Aborting. \e[0m"
			exit 1
		fi
		echo -e "\e[0;32m[~] Debian-Version is 12. Proceeding..."

	#--- Check supported CPU
		if ! lscpu | grep -iq avx; then
			echo -e "\e[1;31m[!] Your CPU does not support AVX. MongoDB 5.0+ requires an AVX supported CPU. \e[0m"
		exit
		fi
		echo -e "\e[0;32m[~] CPU supports AVX. Proceeding..."

	#--- Check if openjdk-17 can be installed
		if ! apt-cache show openjdk-17-jdk &>/dev/null; then
			echo -e "\e[1;31m[!] openjdk-17-jdk is not available in the repositories! Aborting. \e[0m"
			exit 1
		fi
		echo -e "\e[0;32m[~] Openjdk-17-jdk is available and can be installed. Proceeding... \e[0m"
	echoEnd



#-----  Install general Dependencies
	start_spinner "Updating Package-Lists..."
		apt-get -qq update
		stop_spinner $?
	start_spinner "Installing GNUPG, CURL & WGET..."
		apt-get -qq install gnupg curl wget > /dev/null 2>&1
		stop_spinner $?
	echoEnd



#-----  Mongo-DB Repo
	start_spinner "Adding MongoDB-Repository..."
		curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor > /dev/null 2>&1
		echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] http://repo.mongodb.org/apt/debian bookworm/mongodb-org/7.0 main" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list > /dev/null 2>&1
		stop_spinner $?
	start_spinner "Updating Package-Lists..."
		apt-get -qq update
		stop_spinner $?
	echoEnd



#-----  Install required Packages
	start_spinner "Installing MongoDB-7.0..."
		apt-get -qq install mongodb-org > /dev/null 2>&1
		stop_spinner $?
	start_spinner "Installing OpenJDK-17-JRE-Headless..."
		apt-get -qq install openjdk-17-jre-headless > /dev/null 2>&1
		stop_spinner $?
	start_spinner "Installing JSVC..."
		apt-get -qq install jsvc > /dev/null 2>&1
		stop_spinner $?
	echoEnd




#-----  Installing Omada-Software
	start_spinner "Downloading the latest Omada-Controller..."
		OmadaPackageUrl=$(curl -fsSL https://support.omadanetworks.com/us/product/omada-software-controller/?resourceType=download | grep -oPi '<a[^>]*href="\K[^"]*Linux_x64.deb[^"]*' | head -n 1)
		#--- Check if the URL is empty and use Fallback if necessary
			if [[ -z "$OmadaPackageUrl" ]]; then
				echo "Failed to fetch Omada-Package URL, using Fallback."
				OmadaPackageUrl="https://static.tp-link.com/upload/software/2025/202501/20250109/Omada_SDN_Controller_v5.15.8.2_linux_x64.deb"
			fi
		wget -qP /tmp/ $OmadaPackageUrl
		stop_spinner $?
	start_spinner "Installing Omada-Controller $(echo $(basename $OmadaPackageUrl) | tr "_" "\n" | sed -n '4p')..."
		dpkg -i /tmp/$(basename $OmadaPackageUrl) &> /dev/null > /dev/null 2>&1
		stop_spinner $?
	start_spinner "Starting Omada-Controller..."
		sleep 5
		stop_spinner $?
	echoEnd



#----- Restore the APT-Proxy Settings if they were disabled
	if [[ "$PROXY_DISABLED" -eq 1 ]]; then
		read -p "Do you want to restore the APT-Proxy Settings? (y/n): " restore

		if [[ "$restore" == "y" || "$restore" == "Y" ]]; then
			echo "Restoring APT-Proxy Settings..."
			sudo sed -i 's/^#\([^#]\)/\1/' "$FILE"
		else
			echo "APT-Proxy Settings remain disabled."
		fi
	fi
	echoEnd



#----- Delete Script
	read -p "Do you want to delete the Bash-Script? (y/n): " deleteScript
		if [[ "$deleteScript" == "y" || "$deleteScript" == "Y" ]]; then
			echo "Script will be remove from the Machine."
			rm Omada_Full-Installer_Debian-12.sh
		else
			echo "Script will be kept on the Machine."
		fi
	echoEnd



#----- Omada-Webinterface
	echo "Installation complete!"
		hostIP=$(hostname -I | cut -f1 -d' ')
		echo -e "\e[0;32m[~] Omada Software Controller has been successfully installed! \e[0m"
		echo -e "\e[0;32m[~] Please visit https://${hostIP}:8043 to complete the inital setup wizard.\e[0m\n"
	echoEnd