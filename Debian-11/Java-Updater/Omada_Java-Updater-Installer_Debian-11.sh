#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x Omada_Java-Updater-Installer_Debian-11.sh && sudo bash Omada_Java-Updater-Installer_Debian-11.sh

#TODO:	Check if Update-Installer was executed without being called from Full-Installer
#		If called by Full-Installer, do not move Files

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

#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#




#----- Create Java Update-Script
	echo "----- Update-Script -----"

	#--- Download Java-Update-Executer
		start_spinner "Downloade Java-Updater-Executer..."
			wget https://raw.githubusercontent.com/Noah0302sTech/Omada-Controller/master/Debian-11/Java-Updater/Executer/Omada_Java-Updater-Executer_Debian-11.sh > /dev/null 2>&1
		stop_spinner $?

	#-- Modify Debug for Java-Update-Executer
		start_spinner "Modify Java-Updater-Executer..."
			echo "
#Debug
	echo "'Java-Updater Cron-Job ran @:'" >> $folder2File1Path
	date >> $folder2File1Path
	echo "'$aptUpdateVar'" >> $folder2File1Path
	echo "'$javaUpdateOutput'" >> $folder2File1Path
	echo '' >> $folder2File1Path" >> /home/$SUDO_USER/$folder1Sub1File1
		stop_spinner $?

	#--- Make Java-Updater.sh executable
        start_spinner "Mache Java-Updater.sh ausführbar..."
            chmod +x /home/$SUDO_USER/$folder1Sub1File1
        stop_spinner $?

	echoEnd



#----- Create Crontab
	echo "----- Cron-Job -----"
	start_spinner "Erstelle Crontab..."
		touch /etc/cron.d/Noah0302sTech_Omada-Controller_Debian-11_Java-Updater
	stop_spinner $?

	#--- Create Cron-Check
		start_spinner "Erstelle Cron-Check.txt..."
			touch /home/$SUDO_USER/$folder2File1
			echo "#Init
" > /home/$SUDO_USER/$folder2File1
		stop_spinner $?

	#--- Variables
		cronVariable="0 0 * * 1"

		#- Prompt for custom values
			read -p "Passe den Cron-Job an [default Montags 0 Uhr: $cronVariable]: " input
			cronVariable=${input:-$cronVariable}
	
	#--- Adjust Schedule
		start_spinner "Passe Crontab an..."
			echo "#	Made by Noah0302sTech
#Update Java
"'PATH="/usr/local/bin:/usr/bin:/bin"'"
$cronVariable root $folder1Sub1File1Path" > /etc/cron.d/Noah0302sTech_Omada-Controller_Debian-11_Java-Updater
		stop_spinner $?
	
	echoEnd



#----- Create Alias
	echo "----- Bash-Alias -----"
    if grep -q "^alias omadaJavaUpdaterCC=" /home/$SUDO_USER/.bashrc; then
		echo "Der Alias existiert bereits in /home/$SUDO_USER/.bashrc"
	else
		start_spinner "Erstelle Alias..."
			echo "


#Omada
alias omadaJavaUpdaterCC='cat $folder2File1Path'
alias omadaJavaUpdaterExecute='sudo bash $folder1Sub1File1Path'
"  >> /home/$SUDO_USER/.bashrc
		stop_spinner $?
	fi

	echoEnd



#----- Create MOTD
	echo "----- MOTD -----"
	if grep -q "^Java-Updater Logs" /etc/motd; then
		echo "Der MOTD Eintrag exisitert bereits in /etc/motd"
	else
		start_spinner "Passe MOTD an..."
			echo "----- Java -----
Java-Updater Logs:					omadaJavaUpdaterCC
Java-Updater manual Execution:	omadaJavaUpdaterExecute
" >> /etc/motd
		stop_spinner $?
	fi

	echoEnd





#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#