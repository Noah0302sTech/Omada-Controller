#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x Omada-Updater-Installer_Debian-11.sh && sudo bash Omada-Updater-Installer_Debian-11.sh
#	wget https://raw.githubusercontent.com/Noah0302sTech/Omada-Controller/Testing/Debian-11/Omada-Updater/Omada-Updater-Installer_Debian-11.sh && sudo bash Omada-Updater-Installer_Debian-11.sh



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
							delay=${SPINNER_DELAY:-0.25}

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
					folder3File1="Omada_SDN_Controller_"*"_linux_x64.deb"
				folder4="Omada-Updater"
					folder4Sub1="Executer"
						folder4Sub1File1="Omada-Updater-Executer_Debian-11.sh"
					folder4Sub2="Installer"
						folder4Sub2File1="Omada-Updater-Installer_Debian-11.sh"

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
					#Executer
					folder4Sub1Path="/home/$SUDO_USER/Noah0302sTech/$repoVar/$versionVar/$folder4/$folder4Sub1"
						folder4Sub1File1Path="/home/$SUDO_USER/Noah0302sTech/$repoVar/$versionVar/$folder4/$folder4Sub1/$folder4Sub1File1"
					#Installer
					folder4Sub2Path="/home/$SUDO_USER/Noah0302sTech/$repoVar/$versionVar/$folder4/$folder4Sub2"
						folder4Sub2File1Path="/home/$SUDO_USER/Noah0302sTech/$repoVar/$versionVar/$folder4/$folder4Sub2/$folder4Sub2File1"

#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#




#----- Create Omada Update-Script
	echo "----- Update-Script -----"

	#--- Download Omada-Update-Executer
		start_spinner "Downloade Omada-Updater-Executer..."
			wget https://raw.githubusercontent.com/Noah0302sTech/Omada-Controller/Testing/Debian-11/Omada-Updater/Executer/Omada-Updater-Executer_Debian-11.sh > /dev/null 2>&1
		stop_spinner $?

	#--- Make Omada-Updater.sh executable
        start_spinner "Mache Omada-Updater.sh ausführbar..."
            chmod +x /home/$SUDO_USER/$folder4Sub1File1
        stop_spinner $?

	echoEnd



#----- Create Alias
	echo "----- Bash-Alias -----"
    if grep -q "^alias omadaUpdaterExecute=" /home/$SUDO_USER/.bashrc; then
		echo "Der Alias existiert bereits in /home/$SUDO_USER/.bashrc"
	else
		start_spinner "Erstelle Alias..."
			echo "#Omada-Updater
alias omadaUpdaterExecute='sudo bash $folder4Sub1File1Path'
"  >> /home/$SUDO_USER/.bashrc
		stop_spinner $?
	fi

	echoEnd



#----- Create MOTD
	echo "----- MOTD -----"
	if grep -q "^Omada-Updater manual Execution" /etc/motd; then
		echo "Der MOTD Eintrag exisitert bereits in /etc/motd"
	else
		start_spinner "Passe MOTD an..."
			echo "----- Omada -----
Omada-Updater manual Execution:	omadaUpdaterExecute
" >> /etc/motd
		stop_spinner $?
	fi

	echoEnd





#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#