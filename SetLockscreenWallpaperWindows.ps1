Begin {
    #Set global variables
    $directory = "C:\Temp"

    #Log Function
    function Write-LogEntry {
        param (
            [parameter(Mandatory = $true)]
            [ValidateNotNullOrEmpty()]
            [string]$Value,
            [parameter(Mandatory = $false)]
            [ValidateNotNullOrEmpty()]
            [string]$FileName = "SetLockscreenWallpaper.log",
            [switch]$Stamp
        )

        #Build Log File appending System Date/Time to output
        $LogFile = Join-Path -Path $env:SystemRoot -ChildPath $("Temp\$FileName")
        $Time = -join @((Get-Date -Format "HH:mm:ss.fff"), " ", (Get-WmiObject -Class Win32_TimeZone | Select-Object -ExpandProperty Bias))
        $Date = (Get-Date -Format "MM-dd-yyyy")

        If ($Stamp) {
            $LogText = "<$($Value) <time=""$($Time)"" date=""$($Date)"">"
        }
        else {
            $LogText = "$($Value)"
        }

        Try {
            Out-File -InputObject $LogText -Append -NoClobber -Encoding Default -FilePath $LogFile -ErrorAction Stop
        }
        Catch [System.Exception] {
        Write-Warning -Message "Unable to add log entry to $LogFile.log file. Error message at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
        }
    }

    Function DownloadLockscreenWallpaper {
        #Define URL and download directory
        $url = "<url>"
        $DownloadDirectory = $directory + "\Lockscreen.jpg"
        (New-Object System.Net.WebClient).DownloadFile($url,$DownloadDirectory)
    }

    Function ApplyLockscreenWallpaper {

        #Create registry file values
        $RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
        $LockscreenPath = "LockScreenImagePath"
        $LockscreenStatus = "LockScreenImageStatus"
        $LockscreenUrl = "LockScreenImageUrl"
        $StatusValue = "1"
        $LockscreenImageValue = $directory + "\Lockscreen.jpg"

        #Build Registry and deploy Lockscreen Wallpaper
        if (!(Test-Path $RegKeyPath)) {
	        Write-Host "Creating registry path $($RegKeyPath)."
	        New-Item -Path $RegKeyPath -Force | Out-Null
        }

        Try {
            Write-Host "Attempting to create $($LockscreenStatus) Registry and assign Value of $($StatusValue)..."
            Write-LogEntry -Value "Attempting to create $($LockscreenSatus) Registry and assign Value of $($StatusValue)..."
            New-ItemProperty -Path $RegKeyPath -Name $LockscreenStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null
            Write-Host "Successfully created new registry value."
            Write-LogEntry -Value "Successfully created new registry value."
        }
        Catch [System.Exception] {
            Write-Host " (Failed)"
            Write-LogEntry -Value "Failed to create $($LockscreenStatus) Registry."
        }

        Try {
            Write-Host "Attempting to create $($LockscreenPath) Registry and assign Value of $($LockscreenImageValue)..."
            Write-LogEntry -Value "Attempting to create $($LockscreenPath) Registry and assign Value of $($LockscreenImageValue)..."
            New-ItemProperty -Path $RegKeyPath -Name $LockScreenPath -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
            Write-Host "Successfully created new registry value."
            Write-LogEntry -Value "Successfully created new registry value."
        }
        Catch [System.Exception] {
            Write-Host " (Failed)"
            Write-LogEntry -Value "Failed to create $($LockscreenPath) Registry."
        }

        Try {
            Write-Host "Attempting to create $($LockscreenUrl) Registry and assign Value of $($LockscreenImageValue)..."
            Write-LogEntry -Value "Attempting to create $($LockscreenUrl) Registry and assign Value of $($LockscreenImageValue)..."
            New-ItemProperty -Path $RegKeyPath -Name $LockScreenUrl -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
            Write-Host "Successfully created new registry value."
            Write-LogEntry -Value "Successfully created new registry value."
        }
        Catch [System.Exception] {
            Write-Host " (Failed)"
            Write-LogEntry -Value "Failed to create $($LockscreenUrl) Registry."
        }

        RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True
    }

    Write-LogEntry -Value "##################################"
    Write-LogEntry -Stamp -Value "Set Lockscreen Wallpaper Started"
    Write-LogEntry -Value "##################################"
    
    If ((Test-Path -Path $directory) -eq $false) {
        Write-Hosty "Creating directory to download image file..."
        Write-LogEntry -Value "Creating directory to download image file..."
        Try {
	        New-Item -Path $directory -ItemType directory
        }
        Catch {
            Write-Warning "There was an error while attempting to create directory"
            Write-LogEntry -Value "There was an error when attempting to create directory"
        }
        Write-Host "Created directory for image file."
        Write-LogEntry -Value "Created directory for image file."
    }

    Try {
        Write-Host "Downloading Image to Computer..."
        Write-LogEntry -Value "Downloading Image to Computer..."
        DownloadLockscreenWallpaper
        Write-Host "Downloaded Image successfully."
        Write-LogEntry "Downloaded Image successfully."
    }
    Catch {
        Write-Warning $_.Exception
        Write-LogEntry -Value "$($_.Exception)"
    }

    Try {
    Write-Host "Attempting to set Image as Lockscreen Wallpaper..."
    Write-LogEntry "Attempting to set Image as Lockscreen Wallpaper..."
    ApplyLockscreenWallpaper
    Write-Host "Successfully set Lockscreen Wallpaper"
    Write-LogEntry "Successfully set Lockscreen Wallpaper"
    }
    Catch {
        Write-Warning $_.Exception
        Write-LogEntry -Value "$($_.Exception)"
    }
}

