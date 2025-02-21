# Omada-Controller Install-Script
THIS IS THE DEPRICATED VERSION OF THE SCRIPT!

Issues here probably wont be fixed!



# Features
### Automatic Installation of Omada-Controller-Software
Possibility to choose the Version you desire

### Automatic Installation of Java-Updates (Optional)
Possibility to modify the Update-Interval


# How to Install
### SSH into your *clean* Debian-Server:
```bash
ssh username@ip
```
### Move to Home-Directory
```bash
cd
```
### Download Full-Installer-Script and execute it (Need Sudo-Permissions)
```bash
wget https://raw.githubusercontent.com/Noah0302sTech/Omada-Controller/master/Debian-11/Omada_Full-Installer_Debian-11.sh && sudo bash Omada_Full-Installer_Debian-11.sh
```
### Copy Omada-Controller.deb Download-Link from the TP-Link Website and paste it when you're promted (https://www.tp-link.com/de/support/download/omada-software-controller)
~$ Füge die Download-URL für Omada_SDN_Controller_vX.X.X_Linux_x64.deb hier ein (Leer oder warte 30 Sekunden für v5.13.30.8):
```bash
https://static.tp-link.com/upload/software/2024/202402/20240227/Omada_SDN_Controller_v5.13.30.8_linux_x64.deb
```
### Install Java-Updater when you're promted
~$ Möchtest du Java-Updater installieren? [y]es|[n]o:
```bash
y
```
### Configure Cron-Job-Schedule when you're promted (https://crontab.guru/examples.html)
~$ Passe den Cron-Job an [default Montags 0 Uhr: 0 0 * * 1]:
```bash
0 0 * * 1
```
### Install Omada-Updater when you're promted
~$ Möchtest du Omada-Updater installieren? [y]es|[n]o:
```bash
y
```



# Folder-Structure
	Omada-Controller
	├── Debian-11
	│	├── Cron-Check
	│	│	└── Cron-Check.txt
	│	├── Full-Installer
	│	│	└── Installer
	│	├── Java-Updater
	│	│	├── Executer
	│	│	│	└── Omada_Java-Updater-Executer_Debian-11.sh
	│	│	├── Installer
	│	│	│	└── Installer
	│	│	└── Java-Updater-Installer-Debian-Noah0302sTech.sh
	│	├── Omada-Package
	│	│	└── Download-Links.txt
	│	└── Omada-Full-Installer-Deb11-Noah0302sTech.sh
	├── LICENSE 
	└── README.md



# Support me
Do you like what I do? If the answer is yes, then you can fuel my Coffee-Addiction here!

<a href="https://www.buymeacoffee.com/Noah0302sTech"><img src="https://drive.google.com/uc?id=1rTwdjTiR0sywyDaTxLUNZG1fFgVrlK34" alt="Buy Me A Coffee" width="250" height="250"></a>

This really is not necessary, as I do this a a hobby! BUT I would greatly appreciate it, if you were to support me.