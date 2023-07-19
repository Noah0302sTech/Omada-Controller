#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x Omada-Full-Installer-Deb11-Noah0302sTech.sh && sudo bash Omada-Full-Installer-Deb11-Noah0302sTech.sh
#	curl -sSL https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Omada/Omada-Full-Installer-Deb11-Noah0302sTech.sh | sudo bash

#---------- Initial Checks & Functions
	#----- Check for administrative privileges
		if [[ $EUID -ne 0 ]]; then
			echo "Das Skript muss mit Admin-Privilegien ausgeführt werden! (sudo)"
			exit 1
		fi



	#----- Source of Spinner-Function: https://github.com/tlatsas/bash-spinner
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
						delay=${SPINNER_DELAY:-0.15}

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



	#----- Refresh Packages
		start_spinner "Aktualisiere Package-Listen..."
			apt update -y > /dev/null 2>&1
		stop_spinner $?
		echo
		echo



	#----- Variables
		javaUpdaterUrl="https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Omada/Java-Updater/Java-Updater-Installer-Debian-Noah0302sTech.sh"

		folderVar=Omada
			fullInstallerFolder=Omada-Full-Installer
				fullInstaller=Omada-Full-Installer-Deb11-Noah0302sTech.sh
			subFolderVar=Java-Updater
				folder1=Updater-Installer
					bashInstaller=Java-Updater-Installer-Debian-Noah0302sTech.sh
				folder2=Updater-Executer
					updaterExecuter=Java-Updater-Debian-Noah0302sTech.sh
				cronCheck=Cron-Check.txt

		omadaFolderPath="/home/$SUDO_USER/Noah0302sTech/$folderVar"
			omadaFullInstallerFolderPath="/home/$SUDO_USER/Noah0302sTech/$folderVar/$fullInstallerFolder"
			javaUpdaterFolderPath="/home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar"
				updaterInstallerFolderPath="/home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder1"
					updaterInstallerPath="/home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder1/$bashInstaller"
				updaterExecuterFolderPath="/home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder2"
					updaterExecuterPath="/home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder2/$updaterExecuter"
				cronCheckPath="/home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$cronCheck"

#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#





#----- Install Java
	#--- Add Sid-Main-Repo
		#-		Note: I add the Debian-Unstable-Repo, since OpenJDK-8 does not come with the Standard-Debian-11-Repository.
		#-		Sadly the Omada-Controller does not yet support newer OpenJDK Versions, so I have to do it that way...
		#-		Hopefully I can skip this step with future Releases!
		echo "----- Java -----"
		start_spinner "Füge Sid-Main-Repo hinzu, bitte warten..."
			echo "deb http://deb.debian.org/debian/ sid main" | tee -a /etc/apt/sources.list > /dev/null 2>&1
		stop_spinner $?

	#--- Refresh Packages
		start_spinner "Aktualisiere Package-Listen, bitte warten..."
			apt update > /dev/null 2>&1
		stop_spinner $?

	#--- Install OpenJDK-8-Headless
		start_spinner "Installiere OpenJDK-8-JRE-Headless, bitte warten..."
			DEBIAN_FRONTEND=noninteractive apt install openjdk-8-jre-headless -y > /dev/null 2>&1
		stop_spinner $?

	#--- Remove Sid-Main-Repo
		#-		Note: I remove the Repo here after installing it, so Debian does not upgrade all other Packages to the Unstable-Release.
		#-		With that, Java will not be updated with apt update && apt upgrade, since its missing in the Stable-Repository...ss
		#-		But you can just run the first part of the Script again to update Java.
		#-		I plan on adding a Script that you can run, to check for OpenJDK-8 Updates!
		start_spinner "Entferne Sid-Main-Repo, bitte warten..."
			sed -i '\%^deb http://deb.debian.org/debian/ sid main%d' /etc/apt/sources.list > /dev/null 2>&1
		stop_spinner $?

	#--- Install Java-Updater
		while IFS= read -n1 -r -p "Möchtest du Java-Updater installieren? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)	echo
				#--- Curl Java-Updater
					start_spinner "Installiere Java-Updater..."
						wget $javaUpdaterUrl > /dev/null 2>&1
					stop_spinner $?
					chmod +x Java-Updater-Installer-Debian-Noah0302sTech.sh
					bash ./Java-Updater-Installer-Debian-Noah0302sTech.sh
				break;;

			n)  echo
				break;;

			*)  echo
				echo "Antoworte mit y oder n";;

		esac
		done

	echo
	echo
	echo
	echo
	echo



#----- Install jsvc curl gnupg2
	echo "----- jsvc curl gnupg2 -----"
	#--- Refresh Packages
		start_spinner "Aktualisiere Package-Listen, bitte warten..."
			apt update > /dev/null 2>&1
		stop_spinner $?

	#--- Install jsvc curl gnupg2
		start_spinner "Installiere jsvc curl gnupg2, bitte warten..."
			apt install jsvc curl gnupg2 -y > /dev/null 2>&1
		stop_spinner $?

	echo
	echo
	echo
	echo
	echo



#----- Install MongoDB
	echo "----- MongoDB -----"
	#--- Add apt key
		start_spinner "Füge MongoDB Apt-Key hinzu, bitte warten..."
			curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -  > /dev/null 2>&1
		stop_spinner $?

	#--- Configure sources.list
		start_spinner "Füge MongoDB-Repo hinzu, bitte warten..."
			echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list > /dev/null 2>&1
		stop_spinner $?

	#--- Refresh Packages
		start_spinner "Aktualisiere Package-Listen, bitte warten..."
			apt update > /dev/null 2>&1
		stop_spinner $?

	#--- Install MongoDB
		start_spinner "Installiere Mongo-DB, bitte warten..."
			apt install mongodb-org -y > /dev/null 2>&1
		stop_spinner $?

	#--- Enable MongoDB and show Status
		start_spinner "Aktiviere Mongo-DB, bitte warten..."
			systemctl enable mongod --now > /dev/null 2>&1
			systemctl status mongod > /dev/null 2>&1
		stop_spinner $?

	echo
	echo
	echo
	echo
	echo


#----- Install Omada
	echo "----- Omada -----"
	#--- Prompt user for the Omada download URL or use the default if left blank
		while true; do
			read -t 30 -p "Füge die Download-URL für Omada_SDN_Controller_vX.X.X_Linux_x64.deb hier ein (Leer oder warte 30 Sekunden für v5.9.31): " omada_url
			if [ -z "$omada_url" ]; then
				omada_url="https://static.tp-link.com/upload/software/2023/202303/20230321/Omada_SDN_Controller_v5.9.31_Linux_x64.deb"
				break
			elif [[ $omada_url =~ ^https://static\.tp-link\.com/upload/software/.*\.deb$ ]]; then
				break
			else
				echo "Falschen Download-Link eingegeben! Das Skript unterstützt nur '.deb', NICHT '.tag.gz' oder '.zip'!"
			fi
		done
		echo "Gewählte Version: $omada_url"

	#--- Download selected Omada-Version
		start_spinner "Downloade Omada-Controller, bitte warten..."
			apt install wget -y > /dev/null 2>&1
			wget "$omada_url" > /dev/null 2>&1
		stop_spinner $?

	#--- Install downloaded Omada-Version
		#start_spinner "Installiere Omada-Controller, bitte warten..."
		apt install ./*.deb
		#stop_spinner $?
		echo

	echo
	echo





#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#

#----- Create Folders
	start_spinner "Erstelle Verzeichnisse..."
		#--- Noah0302sTech
			if [ ! -d /home/$SUDO_USER/Noah0302sTech ]; then
				mkdir /home/$SUDO_USER/Noah0302sTech > /dev/null 2>&1
			else
				echo "Ordner /home/$SUDO_USER/Noah0302sTech bereits vorhanden!"
			fi

			#--- Omada-Folder
				if [ ! -d $omadaFolderPath ]; then
					mkdir $omadaFolderPath > /dev/null 2>&1
				else
					echo "Ordner $omadaFolderPath bereits vorhanden!"
				fi

				#--- Omada-Full-Installer Folder
					if [ ! -d $omadaFullInstallerFolderPath ]; then
						mkdir $omadaFullInstallerFolderPath > /dev/null 2>&1
					else
						echo "Ordner $omadaFullInstallerFolderPath bereits vorhanden!"
					fi

				#--- Java-Updater Folder
					if [ ! -d $javaUpdaterFolderPath ]; then
						mkdir $javaUpdaterFolderPath > /dev/null 2>&1
					else
						echo "Ordner $javaUpdaterFolderPath bereits vorhanden!"
					fi

					#--- Updater-Installer Folder
						if [ ! -d $updaterInstallerFolderPath ]; then
							mkdir $updaterInstallerFolderPath > /dev/null 2>&1
						else
							echo "Ordner $updaterInstallerFolderPath bereits vorhanden!"
						fi

					#--- Updater-Executer Folder
						if [ ! -d $updaterExecuterFolderPath ]; then
							mkdir $updaterExecuterFolderPath > /dev/null 2>&1
						else
							echo "Ordner $updaterExecuterFolderPath bereits vorhanden!"
						fi
	stop_spinner $?

#----- Move Files
	start_spinner "Verschiebe Files..."
		#--- Omada-Full-Installer-Deb11-Noah0302sTech.sh
			if [ ! -f $omadaFullInstallerFolderPath ]; then
				mv /home/$SUDO_USER/$fullInstaller $omadaFullInstallerFolderPath > /dev/null 2>&1
			else
				echo "Die Datei $omadaFullInstallerFolderPath ist bereits vorhanden!"
			fi

		#--- Omada-Deb-File
			if [ ! -f $omadaFullInstallerFolderPath ]; then
				mv /home/$SUDO_USER/*.deb $omadaFullInstallerFolderPath > /dev/null 2>&1
			else
				echo "Die Datei $omadaFullInstallerFolderPath ist bereits vorhanden!"
			fi

			#--- Java-Updater-Installer-Debian-Noah0302sTech.sh
				if [ ! -f $updaterInstallerPath ]; then
					mv /home/$SUDO_USER/$bashInstaller $updaterInstallerPath > /dev/null 2>&1
				else
					echo "Die Datei $updaterInstallerPath ist bereits vorhanden!"
				fi

			#--- Java-Updater-Debian-Noah0302sTech.sh
				if [ ! -f $updaterExecuterPath ]; then
					mv /home/$SUDO_USER/$updaterExecuter $updaterExecuterPath > /dev/null 2>&1
				else
					echo "Die Datei $updaterExecuterPath ist bereits vorhanden!"
				fi

			#--- Cron-Check.txt
				if [ ! -f $cronCheckPath ]; then
					mv /home/$SUDO_USER/$cronCheck $cronCheckPath > /dev/null 2>&1
				else
					echo "Die Datei $cronCheckPath ist bereits vorhanden!"
				fi
	stop_spinner $?