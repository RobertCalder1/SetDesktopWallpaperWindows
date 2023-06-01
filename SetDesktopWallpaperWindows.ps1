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
            [string]$FileName = "SetDesktopWallpaper.log",
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

    #Function to apply Desktop Wallpaper

    Function DownloadDesktopWallpaper {
        #Define URL and download directory
        $url = "<url>"
        $DownloadDirectory = $directory + "\Wallpaper.jpg"
        (New-Object System.Net.WebClient).DownloadFile($url,$DownloadDirectory)
    }
    Function ApplyDesktopWallpaper {

        #Create registry file values
        $RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
        $DesktopPath = "DesktopImagePath"
        $DesktopStatus = "DesktopImageStatus"
        $DesktopUrl = "DesktopImageUrl"
        $StatusValue = "1"
        $DesktopImageValue = $directory + "\Wallpaper.jpg"

        #Build Registry and deploy Desktop Wallpaper

        if (!(Test-Path $RegKeyPath)) {
	        Write-Host "Creating registry path $($RegKeyPath)."
	        New-Item -Path $RegKeyPath -Force | Out-Null
        }
        
        Try {
        Write-Host "Attempting to create $($DesktopSatus) Registry and assign Value of $($StatusValue)..."
        Write-LogEntry -Value "Attempting to create $($DesktopSatus) Registry and assign Value of $($StatusValue)..."
        New-ItemProperty -Path $RegKeyPath -Name $DesktopStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null
        Write-Host "Successfully created new registry value."
        Write-LogEntry -Value "Successfully created new registry value."
        }
        Catch [System.Exception] {
        Write-Host " (Failed)"
        Write-LogEntry -Value "Failed to create $($DesktopStatus) Registry."
        }

        Try {
        Write-Host "Attempting to create $($DesktopPath) Registry and assign Value of $($DesktopImageValue)..."
        Write-LogEntry -Value "Attempting to create $($DesktopPath) Registry and assign Value of $($DesktopImageValue)..."
        New-ItemProperty -Path $RegKeyPath -Name $DesktopPath -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
        Write-Host "Successfully created new registry value."
        Write-LogEntry -Value "Successfully created new registry value."
        }
        Catch [System.Exception] {
        Write-Host " (Failed)"
        Write-LogEntry -Value "Failed to create $($DesktopPath) Registry."
        }

        Try {
            Write-Host "Attempting to create $($DesktopUrl) Registry and assign Value of $($DesktopImageValue)..."
            Write-LogEntry -Value "Attempting to create $($DesktopUrl) Registry and assign Value of $($DesktopImageValue)..."
            New-ItemProperty -Path $RegKeyPath -Name $DesktopUrl -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
            Write-Host "Successfully created new registry value."
            Write-LogEntry -Value "Successfully created new registry value."
        }
        Catch [System.Exception] {
            Write-Host " (Failed)"
            Write-LogEntry -Value "Failed to create $($DesktopUrl) Registry."
        }

        RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True
    }

    Write-LogEntry -Value "##################################"
    Write-LogEntry -Stamp -Value "Set Desktop Wallpaper Started"
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
        DownloadDesktopWallpaper
        Write-Host "Downloaded Image successfully."
        Write-LogEntry "Downloaded Image successfully."
    }
    Catch {
        Write-Warning $_.Exception
        Write-LogEntry -Value "$($_.Exception)"
    }

    Try {
    Write-Host "Attempting to set Image as Desktop Wallpaper..."
    Write-LogEntry "Attempting to set Image as Desktop Wallpaper..."
    ApplyDesktopWallpaper
    Write-Host "Successfully set Desktop Wallpaper"
    Write-LogEntry "Successfully set Desktop Wallpaper"
    }
    Catch {
        Write-Warning $_.Exception
        Write-LogEntry -Value "$($_.Exception)"
    }
}
