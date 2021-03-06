#.Synopsis
# This script will be performing below steps,
# 1) Capture teamviewer ID, Kill teamviewer & uninstall teamviewer
# 2) Delete unwanted files, folder & registry key
# 3) Change Mac address
# 4) Install TeamViewer & Open Screenshots

# Please run below command if you get error like, " Cannot execute script on this machine... "
# Set-ExecutionPolicy -scope CurrentUser -executionPolicy Unrestricted -force

$del_fr = @( "C:\Program Files (x86)\TeamViewer", `
"HKCU:\Software\TeamViewer",`
"HKLM:\SYSTEM\CurrentControlSet\services\TeamViewer6", `
"hklm:\Software\Classes\.tvc", `
"hklm:\Software\Classes\.tvs", `
"hklm:\Software\Classes\TeamViewerConfiguration", `
"hklm:\Software\Classes\TeamViewerSession", `
"hklm:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\TeamViewer 6", `
"hklm:\Software\Wow6432Node\TeamViewer", `
"hklm:\SYSTEM\CurrentControlSet\services\SharedAccess\Parameters\FirewallPolicy\FirewallRules")

################ ALL Functions ###############################

# This function is used for deleting files and folders 
function cleanup($action,$paths){
    if($action -match "del"){
        # Loop through users and delete the file
        ForEach ($fpath in $paths){
            $pathstats = Test-Path $fpath
            if($pathstats -match "True"){
                Remove-Item -Path $fpath -Recurse -Force #-whatif
            }
            else{
                #write-output "Path Doesn't Exist"
            }
        } 
        $luser = Get-ChildItem -Path "C:\Users"
        foreach ($lusr in $luser){
            $fpath = "C:\Users\" + $lusr + "\AppData\Roaming\TeamViewer"
            if((Test-Path $fpath) -match "True"){
                Remove-Item $fpath -Recurse -Force #-whatif
            }
        }
    }
    else{
        write-output "Wrong Action"
    }
}

function screenshot($File)
{
    Add-Type -AssemblyName System.Windows.Forms
    Add-type -AssemblyName System.Drawing

    $Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $Width = $Screen.Width
    $Height = $Screen.Height
    $Left = $Screen.Left
    $Top = $Screen.Top

    $bitmap = New-Object System.Drawing.Bitmap $Width, $Height
    $graphic = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphic.CopyFromScreen($Left, $Top, 0, 0, $bitmap.Size)
    $bitmap.Save($File) 
    Write-Output $File
}

####################### Main Script ########################################

# 1) Capture teamviewer ID, Kill teamviewer & uninstall teamviewer
Start-Process "C:\Program Files (x86)\TeamViewer\Version6\TeamViewer.exe"
Start-Sleep -Milliseconds 3000
screenshot "c:\ScreenShot01.bmp"

Stop-Process -Name TeamViewer -Force
start-sleep -Milliseconds 2000
Write-Output "Uninstall will begin............"
Start-Process "C:\Program Files (x86)\TeamViewer\Version6\uninstall.exe" /S
start-sleep -Milliseconds 2000
write-output "Uninstall Completed...!"

# 2) Delete unwanted files, folder & registry key
write-output "Deleting unwanted files, folder, & registry key...!"
cleanup "del" $del_fr
write-output "Completed Deleting...!"

# 3) Change Mac address
write-output "Changing Mac Address...!"
& ((Split-Path $MyInvocation.InvocationName) + "\New-MACaddress.ps1")
write-output "Completed changing Mac Address...!"

# 4) Load to Install TeamViewer 
write-output "Loading TeamViewer Install...!"
& ((Split-Path $MyInvocation.InvocationName) + "\TeamViewer_Setup_6.15803\TeamViewer_Setup 6.15803.exe")

# 5) Switch to Manual Mode
#   5.1) Compare TeamViewer ID from the c:\Screenshot.bmp, if its same then please re-run the script. 
#   5.2) Configure Unattended Configuration, 
