#Get-ExecutionPolicy
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
#Unblock-File -Path .\optimize.ps1
#Script for windows optimisations
#Detect Windows version - because not all windows versions have websearch etc and i want to make it compatible with other versions as well
$OptionsSwitch=
@(
    [PSCustomObject]@{
        SearchBox = $true;
        SearchBoxValue = 1;
        WinUpdates = $true;
        WinUpdatesValue = 2; #2 - ask before download and install, 3 - auto download, ask before install, 4 - auto download and schedule install, 5 - local admin to choose
        WinNews = $true;
        WinNewsValue = 0;
        WinAutoStart = $true;
        WinTasks = $true;
        WinSchedule = $true;
    }
)
$allgood = $false
$SystemVersion = [System.Environment]::OSVersion.Version.Major
Write-Host "Windows Version: $($SystemVersion)"
#Import-Module -Name ActiveDirectory
#Disable SearchBox Suggestions for all Users
while ($allgood -eq $false -and $OptionsSwitch[0].SearchBox)
{
    if ($SystemVersion -ge 10)
    {
        $RegistryPath = 'HKLM:\Software\Policies\Microsoft\Windows\Explorer'
        $Name         = 'DisableSearchBoxSuggestions'
        $Value        = $OptionsSwitch[0].SearchBoxValue
        If (-NOT (Test-Path $RegistryPath)) 
        {
            Write-Host "Sciezka nie istnieje"
            New-Item -Path $RegistryPath -Force | Out-Null
            Write-Host "Sciezka $($RegistryPath) utworzona"
        }  
        else 
        {
            if(-NOT (Get-ItemProperty -Path $RegistryPath -Name $Name -ErrorAction SilentlyContinue))
            {
                Write-Host "Wpis nie istnieje"
                New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -Force 
                Write-Host "Wpis $($RegistryPath)\$($Name) utworzony"
                $allgood = $true
            }
            else 
            {
                if ((Get-ItemProperty -Path $RegistryPath | Select-Object -ExpandProperty $Name -ErrorAction SilentlyContinue) -ne $Value)
                {
                    Write-Host "Wartosc nie jest ustawiona aby wylaczyc sugestie wyszukiwania, Ustawiam zeby bylo ;)"
                    Set-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -Force 
                    $allgood = $true
                }
                else 
                {
                    Write-Host "Sugestie wyszukiwania juz byly wylaczone"
                    $allgood = $true
                }
            }
        }
    }
    else
    {
        Write-Host "Windows 10 lub wyzej wymagany lecimy dalej"
        $allgood = $true
    }
}
#Change windows Update
$allgood = $false
while ($allgood -eq $false -and $OptionsSwitch[0].WinUpdates)
{
    if ($SystemVersion -ge 5)
    {
        $RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
        $Name         = 'AUOptions'
        $Value        = $OptionsSwitch[0].WinUpdatesValue
        If (-NOT (Test-Path $RegistryPath)) 
        {
            Write-Host "Sciezka nie istnieje"
            New-Item -Path $RegistryPath -Force | Out-Null
            Write-Host "Sciezka $($RegistryPath) utworzona"
        }  
        else 
        {
            if(-NOT (Get-ItemProperty -Path $RegistryPath -Name $Name -ErrorAction SilentlyContinue))
            {
                Write-Host "Wpis nie istnieje"
                New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -Force
                Write-Host "Wpis $($RegistryPath)\$($Name) utworzony"
                $allgood = $true
            }
            else 
            {
                if ((Get-ItemProperty -Path $RegistryPath | Select-Object -ExpandProperty $Name -ErrorAction SilentlyContinue) -ne $Value)
                {
                    Write-Host "Wartosc nie jest ustawiona zeby skonfigurowac WindowsUpdate tak jak chcesz, zmieniono ;)"
                    Set-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -Force 
                    $allgood = $true
                }
                else 
                {
                    Write-Host "Windows Update juz byl ustawiony"
                    $allgood = $true
                }
            }
        }
    }
    else
    {
        Write-Host "Windows Xp lub wyzej wymagany lecimy dalej"
        $allgood = $true
    }
}
#Disable Autostart Of the Apps
if ($SystemVersion -ge 6 -and $OptionsSwitch[0].WinAutoStart)
{
    $RegistryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
    $Name         = 'OneDrive'
        if(-NOT (Get-ItemProperty -Path $RegistryPath -Name $Name -ErrorAction SilentlyContinue))
        {
            Write-host "One Drive juz byl wylaczony" 
        }
        else 
        {
            Remove-ItemProperty -Path $RegistryPath -Name $Name
            Write-Host "Wylaczono autostrat OneDrive"
        }
    $Name         = 'MicrosoftEdgeAutoLaunch*'
        if(-NOT (Get-ItemProperty -Path $RegistryPath -Name $Name -ErrorAction SilentlyContinue))
        {
            Write-host "Autosatrt Edge juz byl wylaczony" 
        }
        else 
        {
            Remove-ItemProperty -Path $RegistryPath -Name $Name
            Write-Host "Wylaczono autostrat Edge"
        }
}
elseif ($SystemVersion -lt 6)
{
    Write-Host "Winddows xp chyba do tego jest wymagany"
}
else {Write-Host "Nie wylaczamy nic z auotstartu lecimy dalej"}
#Disable Schedulled Tasks like windows defrag!
if ($SystemVersion -ge 6 -and $OptionsSwitch[0].WinSchedule)
{
    if (Get-ScheduledTask ScheduledDefrag -ErrorAction SilentlyContinue) {Unregister-ScheduledTask -TaskName "ScheduledDefrag" -TaskPath "\Microsoft\Windows\Defrag\" -Confirm:$false} #disable defrag
}
elseif ($SystemVersion -lt 6)
{
    Write-Host "Winddows xp chyba do tego jest wymagany"
}
else {Write-Host "Nie wylaczamy z zadan"}