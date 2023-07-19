# Omada-Controller
This is an updated Version of my old Repo (https://github.com/Noah0302sTech/Bash-Skripte/tree/master/Omada)!

If you have any Issues, or Questions, please do not hesitate to send me a Message!



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
### Copy Omada-Controller.deb Download-Link from the TP-Link Website and paste it when youre promted (https://www.tp-link.com/de/support/download/omada-software-controller)
~$ Füge die Download-URL für Omada_SDN_Controller_vX.X.X_Linux_x64.deb hier ein (Leer oder warte 30 Sekunden für v5.9.31):
```bash
https://static.tp-link.com/upload/software/2023/202303/20230321/Omada_SDN_Controller_v5.9.31_Linux_x64.deb
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
	│	│	│	└── Executer
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
