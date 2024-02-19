#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x Omada-Updater-Executer_Debian-11.sh && sudo bash Omada-Updater-Executer_Debian-11.sh

#---------- Initial Checks & Functions & Folder-Structure
	#-------- Checks & Functions
		#----- Check for administrative privileges
			if [[ $EUID -ne 0 ]]; then
				echo "Das Skript muss mit Admin-Privilegien ausgeführt werden! (sudo)"
				exit 1
			fi

#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#





cd /home/$SUDO_USER/Noah0302sTech/Omada-Controller/Debian-11/Omada-Package
	#----- Install Omada
		echo "----- Omada -----"
		#--- Prompt user for the Omada download URL or use the default if left blank
			while true; do
				read -t 30 -p "Füge die Download-URL für Omada_SDN_Controller_vX.X.X_Linux_x64.deb hier ein (Leer oder warte 30 Sekunden für v5.13.23): " omada_url
				if [ -z "$omada_url" ]; then
					omada_url="https://static.tp-link.com/upload/software/2024/202401/20240112/Omada_SDN_Controller_v5.13.23_linux_x64.deb"
					break
				elif [[ $omada_url =~ ^https://static\.tp-link\.com/upload/software/.*\.deb$ ]]; then
					break
				else
					echo "Falschen Download-Link eingegeben! Das Skript unterstützt nur '.deb', NICHT '.tag.gz' oder '.zip'!"
				fi
			done
			echo "Gewählte Version: $omada_url"

		#--- Download selected Omada-Version
			#start_spinner "Downloade Omada-Controller, bitte warten..."
				apt install wget -y > /dev/null 2>&1
				wget "$omada_url" > /dev/null 2>&1
			#stop_spinner $?

		#--- Install downloaded Omada-Version
			#start_spinner "Installiere Omada-Controller, bitte warten..."
			apt install ./*.deb
			#stop_spinner $?
			echo





#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#