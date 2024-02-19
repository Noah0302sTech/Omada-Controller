#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x Omada_Full-Installer_Debian-11.sh && sudo bash Omada_Full-Installer_Debian-11.sh
#	wget https://raw.githubusercontent.com/Noah0302sTech/Omada-Controller/master/Debian-11/Omada_Full-Installer_Debian-11.sh && sudo bash Omada_Full-Installer_Debian-11.sh

#---------- Initial Checks & Functions & Folder-Structure
	#-------- Checks & Functions
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



		#----- echoEnd
				function echoEnd {
					echo
					echo
					echo
				}

		#----- Refresh Packages
			start_spinner "Aktualisiere Package-Listen..."
				apt update > /dev/null 2>&1
			stop_spinner $?
			echoEnd



	#----- Variables
		gitURL="https://github.com/Noah0302sTech/Omada-Controller"

		repoVar="Omada-Controller"
			versionVar="Debian-11"
				fullInstallerFolder="Full-Installer"
					fullInstaller="Omada_Full-Installer_Debian-11.sh"
				folder1="Java-Updater"
					folder1Sub1="Executer"
						folder1Sub1File1="Omada_Java-Updater-Executer_Debian-11.sh"
					folder1Sub2="Installer"
						folder1Sub2File1="Omada_Java-Updater-Installer_Debian-11.sh"
				folder2="Cron-Check"
					folder2File1="Cron-Check.txt"
				folder3="Omada-Package"
					folder3File1="Omada_SDN_Controller_v5.9.31_Linux_x64.deb"

		#Omada-Controller
		repoVarPath="/home/$SUDO_USER/Noah0302sTech/$repoVar"
			#Debian-11
			versionVarPath="/home/$SUDO_USER/Noah0302sTech/$repoVar/$versionVar"
				#Full-Installer
				fullInstallerFolderPath="/home/$SUDO_USER/Noah0302sTech/$repoVar/$versionVar/$fullInstallerFolder"
					fullInstallerPath="/home/$SUDO_USER/Noah0302sTech/$repoVar/$versionVar/$fullInstallerFolder/$fullInstaller"
				#Java-Updater
				folder1Path="/home/$SUDO_USER/Noah0302sTech/$repoVar/$versionVar/$folder1"
					#Executer
					folder1Sub1Path="/home/$SUDO_USER/Noah0302sTech/$repoVar/$versionVar/$folder1/$folder1Sub1"
						folder1Sub1File1Path="/home/$SUDO_USER/Noah0302sTech/$repoVar/$versionVar/$folder1/$folder1Sub1/$folder1Sub1File1"
					#Installer
					folder1Sub2Path="/home/$SUDO_USER/Noah0302sTech/$repoVar/$versionVar/$folder1/$folder1Sub2"
						folder1Sub2File1Path="/home/$SUDO_USER/Noah0302sTech/$repoVar/$versionVar/$folder1/$folder1Sub2/$folder1Sub2File1"
				#Cron-Check
				folder2Path="/home/$SUDO_USER/Noah0302sTech/$repoVar/$versionVar/$folder2"
					folder2File1Path="/home/$SUDO_USER/Noah0302sTech/$repoVar/$versionVar/$folder2/$folder2File1"
				#Omada-Package
				folder3Path="/home/$SUDO_USER/Noah0302sTech/$repoVar/$versionVar/$folder3"
					folder3File1Path="/home/$SUDO_USER/Noah0302sTech/$repoVar/$versionVar/$folder3/$folder3File1"
				#Omada-Updater
				folder4Path="/home/$SUDO_USER/Noah0302sTech/$repoVar/$versionVar/$folder4"
					folder4File1Path="/home/$SUDO_USER/Noah0302sTech/$repoVar/$versionVar/$folder4/$folder4File1"

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
			#TODO:	Bash-Segmentation-Fault when writing to /dev/null 2>&1 AND running Spinner Animation
			echo "Installiere OpenJDK-8-JRE-Headless, bitte warten..."
				DEBIAN_FRONTEND=noninteractive apt-get install openjdk-8-jre-headless -y > /dev/null 2>&1

		#--- Remove Sid-Main-Repo
			#-		Note: I remove the Repo here after installing it, so Debian does not upgrade all other Packages to the Unstable-Release.
			#-		With that, Java will not be updated with apt update && apt upgrade, since its missing in the Stable-Repository...ss
			#-		But you can just install the Java-Updater Cron-Job
			start_spinner "Entferne Sid-Main-Repo, bitte warten..."
				sed -i '\%^deb http://deb.debian.org/debian/ sid main%d' /etc/apt/sources.list > /dev/null 2>&1
			stop_spinner $?

		echoEnd



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

		echoEnd



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
			stop_spinner $?

		echoEnd


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
			start_spinner "Downloade Omada-Controller, bitte warten..."
				apt install wget -y > /dev/null 2>&1
				wget "$omada_url" > /dev/null 2>&1
			stop_spinner $?

		#--- Install downloaded Omada-Version
			#start_spinner "Installiere Omada-Controller, bitte warten..."
			apt install ./*.deb
			#stop_spinner $?
			echo

		echoEnd



	#----- Install Java-Updater
		echo "----- Java-Updater -----"
		while IFS= read -n1 -r -p "Möchtest du Java-Updater installieren? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)	echo
				#--- WGET Java-Updater
					start_spinner "Downloade Java-Updater-Installer..."
						wget https://raw.githubusercontent.com/Noah0302sTech/Omada-Controller/master/Debian-11/Java-Updater/Omada_Java-Updater-Installer_Debian-11.sh > /dev/null 2>&1
					stop_spinner $?
					chmod +x Omada_Java-Updater-Installer_Debian-11.sh
					bash ./Omada_Java-Updater-Installer_Debian-11.sh
				break;;

			n)  echo
				break;;

			*)  echo
				echo "Antoworte mit y oder n";;

		esac
		done



	#----- Install Omada-Updater
		echo "----- Omada-Updater -----"
		while IFS= read -n1 -r -p "Möchtest du Omada-Updater installieren? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)	echo
				#--- WGET Omada-Updater
					start_spinner "Downloade Omada-Updater-Installer..."
						wget https://raw.githubusercontent.com/Noah0302sTech/Omada-Controller/Testing/Debian-11/Omada-Updater/Omada-Updater-Installer_Debian-11.sh > /dev/null 2>&1
					stop_spinner $?
					chmod +x Omada-Updater-Installer_Debian-11.sh
					bash ./Omada-Updater-Installer_Debian-11.sh
				break;;

			n)  echo
				break;;

			*)  echo
				echo "Antoworte mit y oder n";;

		esac
		done



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

			#--- Repo
				if [ ! -d $repoVarPath ]; then
					mkdir $repoVarPath > /dev/null 2>&1
				else
					echo "Ordner $repoVarPath bereits vorhanden!"
				fi

				#--- Version
					if [ ! -d $versionVarPath ]; then
						mkdir $versionVarPath > /dev/null 2>&1
					else
						echo "Ordner $versionVarPath bereits vorhanden!"
					fi

					#--- Full-Installer
						if [ ! -d $fullInstallerFolderPath ]; then
							mkdir $fullInstallerFolderPath > /dev/null 2>&1
						else
							echo "Ordner $fullInstallerFolderPath bereits vorhanden!"
						fi

					#--- Folder1
						if [ ! -d $folder1Path ]; then
							mkdir $folder1Path > /dev/null 2>&1
						else
							echo "Ordner $folder1Path bereits vorhanden!"
						fi
						#- Folder1Sub1
							if [ ! -d $folder1Sub1Path ]; then
								mkdir $folder1Sub1Path > /dev/null 2>&1
							else
								echo "Ordner $folder1Sub1Path bereits vorhanden!"
							fi
						#- Folder1Sub2
							if [ ! -d $folder1Sub2Path ]; then
								mkdir $folder1Sub2Path > /dev/null 2>&1
							else
								echo "Ordner $folder1Sub2Path bereits vorhanden!"
							fi

					#--- Folder2
						if [ ! -d $folder2Path ]; then
							mkdir $folder2Path > /dev/null 2>&1
						else
							echo "Ordner $folder2Path bereits vorhanden!"
						fi

					#--- Folder3
						if [ ! -d $folder3Path ]; then
							mkdir $folder3Path > /dev/null 2>&1
						else
							echo "Ordner $folder3Path bereits vorhanden!"
						fi

					#--- Folder4
						if [ ! -d $folder4Path ]; then
							mkdir $folder4Path > /dev/null 2>&1
						else
							echo "Ordner $folder4Path bereits vorhanden!"
						fi
	stop_spinner $?

#----- Move Files
	start_spinner "Verschiebe Files..."
		#--- Full-Installer
			if [ ! -f $fullInstallerPath ]; then
				mv /home/$SUDO_USER/$fullInstaller $fullInstallerPath > /dev/null 2>&1
			else
				echo "Die Datei $fullInstallerPath ist bereits vorhanden!"
			fi

		#---Folder1
			#- Folder1Sub1File1
				if [ ! -f $folder1Sub1File1Path ]; then
					mv /home/$SUDO_USER/$folder1Sub1File1 $folder1Sub1File1Path > /dev/null 2>&1
				else
					echo "Die Datei $folder1Sub1File1Path ist bereits vorhanden!"
				fi
			#- Folder1Sub2File1
				if [ ! -f $folder1Sub2File1Path ]; then
					mv /home/$SUDO_USER/$folder1Sub2File1 $folder1Sub2File1Path > /dev/null 2>&1
				else
					echo "Die Datei $folder1Sub2File1Path ist bereits vorhanden!"
				fi

		#--- Folder2File1
			if [ ! -f $folder2File1Path ]; then
				mv /home/$SUDO_USER/$folder2File1 $folder2File1Path > /dev/null 2>&1
			else
				echo "Die Datei $folder2File1Path ist bereits vorhanden!"
			fi

		#--- Folder3File1
			if [ ! -f $folder3File1Path ]; then
				mv /home/$SUDO_USER/$folder3File1 $folder3File1Path > /dev/null 2>&1
			else
				echo "Die Datei $folder3File1Path ist bereits vorhanden!"
			fi
		
		#--- Folder4File1
			if [ ! -f $folder4File1Path ]; then
				mv /home/$SUDO_USER/$folder4File1 $folder4File1Path > /dev/null 2>&1
			else
				echo "Die Datei $folder4File1Path ist bereits vorhanden!"
			fi
	stop_spinner $?
	echoEnd



#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#



#----- Check for Webinterface
	#--- Fetch the IP
		IP=$(hostname -I)

	#--- Trim Whitespace
		trimmedIP=$(echo "$IP" | cut -d ' ' -f 1)
		portIP="https://"$trimmedIP":8043"

	#--- Loop until the UniFi-Webinterface is accessible
	while true; do
		#- Use wget to fetch the UniFi-Webinterface and save the output to a temporary file
		wget_output=$(wget --no-check-certificate --spider -S "$portIP" 2>&1)

		#- Check if the wget command succeeded
		if [ $? -eq 0 ]; then
			# Extract the HTTP status code from wget output
			http_status=$(echo "$wget_output" | grep "HTTP/" | awk '{print $2}')

			# Check if the HTTP status code is 404
			if [ "$http_status" == "404" ]; then
					echo "UniFi-Webinterface $portIP returned a 404 error... Container startet noch!"
					sleep 5  # Wait for 5 seconds before retrying
					continue  # Continue the loop
			else
					echo
					echo "UniFi-Webinterface ist nun unter folgender Addresse erreichbar:"
					echo "$portIP"
					break  # Break out of the loop if UniFi-Webinterface is accessible
			fi
		else
			echo "UniFi-Webinterface noch nicht erreichbar. Bitte warten..."
		fi
		sleep 5
	done
	echoEnd