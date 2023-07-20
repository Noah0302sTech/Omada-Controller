#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x Omada_Java-Updater-Executer_Debian-11.sh && sudo bash Omada_Java-Updater-Executer_Debian-11.sh

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





	#----- Install Java
		#--- Add Sid-Main-Repo
			#-		Note: I add the Debian-Unstable-Repo, since OpenJDK-8 does not come with the Standard-Debian-11-Repository.
			#-		Sadly the Omada-Controller does not yet support newer OpenJDK Versions, so I have to do it that way...
			#-		Hopefully I can skip this step with future Releases!
			echo "Füge Sid-Main-Repo hinzu, bitte warten..."
				echo "deb http://deb.debian.org/debian/ sid main" | tee -a /etc/apt/sources.list > /dev/null 2>&1
				echo

		#--- Refresh Packages
			echo "Aktualisiere Package-Listen, bitte warten..."
				aptUpdateVar=$(apt-get update 2>&1)
				echo $aptUpdateVar
				echo

		#--- Install OpenJDK-8-Headless
			echo "Installiere OpenJDK-8-JRE-Headless, bitte warten..."
				javaUpdateOutput=$(DEBIAN_FRONTEND=noninteractive apt-get install openjdk-8-jre-headless -y 2>&1)
				echo $javaUpdateOutput
				echo

		#--- Remove Sid-Main-Repo
			echo "Entferne Sid-Main-Repo, bitte warten..."
				sed -i '\%^deb http://deb.debian.org/debian/ sid main%d' /etc/apt/sources.list > /dev/null 2>&1
				echo





#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#