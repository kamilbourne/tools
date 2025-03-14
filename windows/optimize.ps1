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
#Disable NewsFeed
$allgood = $false
while ($allgood -eq $false -and $OptionsSwitch[0].WinNews)
{
    if ($SystemVersion -ge 10)
    {
        $RegistryPath = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\DSH'
        $Name         = 'AllowNewsAndInterests'
        $Value        = $OptionsSwitch[0].WinNewsValue
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
                    Write-Host "Wartosc Nie jest ustawiona pod wiadomosci tak jak chcesz, zmieniono ;)"
                    Set-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -Force 
                    $allgood = $true
                }
                else 
                {
                    Write-Host "Windows News juz byl ustawiony"
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