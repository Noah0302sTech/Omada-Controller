#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x Java-Updater-Installer-Debian-Noah0302sTech.sh && sudo bash Java-Updater-Installer-Debian-Noah0302sTech.sh

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




#----- Create Java Update-Script
	start_spinner "Erstelle Updater-Skript..."
		touch /home/$SUDO_USER/$updaterExecuter
		touch /home/$SUDO_USER/$cronCheck
		echo "#Init after Install" > /home/$SUDO_USER/$cronCheck
		echo "" >> /home/$SUDO_USER/$cronCheck
		echo "#!/bin/bash
#	Made by Noah0302sTech

#Java Update
	echo "Update Java..."
	"'javaUpdateOutput=$(DEBIAN_FRONTEND=noninteractive apt-get install openjdk-8-jre-headless -y 2>&1)'"
	echo
	echo

#Debug
	echo "'Java-Updater Cron-Job ran @'" >> $cronCheckPath
	date >> $cronCheckPath
	echo "'$javaUpdateOutput'" >> $cronCheckPath
	echo '' >> $cronCheckPath" > /home/$SUDO_USER/$updaterExecuter
	stop_spinner $?

	#--- Make Java-Updater.sh executable
        start_spinner "Mache Java-Updater.sh ausführbar..."
            chmod +x /home/$SUDO_USER/$updaterExecuter
        stop_spinner $?



#----- Create Crontab
	start_spinner "Erstelle Crontab..."
		touch /etc/cron.d/java-Updater-Noah0302sTech
	stop_spinner $?

	#--- Variables
		cronVariable="0 0 * * 1"

		#- Prompt for custom values
			read -p "Passe den Cron-Job an [default Montags 0 Uhr: $cronVariable]: " input
			cronVariable=${input:-$cronVariable}
	
	#--- Adjust Schedule
		start_spinner "Passe Crontab an..."
			echo "#Update for Java by Noah0302sTech
"'PATH="/usr/local/bin:/usr/bin:/bin"'"
$cronVariable root $updaterExecuterPath" > /etc/cron.d/java-Updater-Noah0302sTech
		stop_spinner $?



#----- Create Alias
    if grep -q "^alias ccJavaUpdater=" /home/$SUDO_USER/.bashrc; then
		echo "Der Alias existiert bereits in /home/$SUDO_USER/.bashrc"
	else
		start_spinner "Erstelle Alias..."
			echo "


#Omada
alias ccJavaUpdater='cat $cronCheckPath'
"  >> /home/$SUDO_USER/.bashrc
		stop_spinner $?
	fi



#----- Create MOTD
	if grep -q "^Omada" /etc/motd; then
		echo "Der MOTD Eintrag exisitert bereits in /etc/motd"
	else
		start_spinner "Passe MOTD an..."
			echo "
Omada
Cron-Check Java-Updater:	ccJavaUpdater
" >> /etc/motd
		stop_spinner $?
	fi




#----- Move Files, if not called by Full-Installer
	if [ -f "/home/$SUDO_USER/$fullInstaller" ]; then
		echo "Called by $fullInstaller, not moving Files just yet!"
	else
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
	fi