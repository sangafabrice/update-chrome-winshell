[CmdletBinding()]
Param (
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-InstallLocation $_ $PSScriptRoot })]
    [string]
    $InstallLocation = "${Env:ProgramData}\Local",
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-InstallerLocation $_ })]
    [string]
    $SaveTo = $PSScriptRoot
)

& {
    Try {
        $UpdateModule =
            Import-CommonScript chrome-installer |
            Import-Module -PassThru -Force -Verbose:$False
        @{
            UpdateInfo = $(
                Write-Verbose 'Retrieve install or update information...'
                Try { Get-DownloadInfo -From Local }
                Catch { }
            )
            NameLocation = "$InstallLocation\Local.exe"
            SaveTo = $SaveTo
            SoftwareName = 'Local'
            InstallerDescription = 'Create local WordPress sites with ease.'
            InstallerType = 'NSIS'
            NsisType = 32
            Verbose = $VerbosePreference -ine 'SilentlyContinue'
        } | ForEach-Object { Invoke-CommonScript @_ }
    }
    Catch { }
    Finally { $UpdateModule | Remove-Module -Verbose:$False }
}

<#
.SYNOPSIS
    Updates Local software.
.DESCRIPTION
    The script installs or updates Local on Windows.
.NOTES
    Required: at least Powershell Core 7.
.PARAMETER InstallLocation
    Path to the installation directory.
    It is restricted to file system paths.
    It does not necessary exists.
    It defaults to "%ProgramData%\Local".
.PARAMETER SaveTo
    Path to the directory of the downloaded installer.
    It is an existing file system path.
    It defaults to the script directory.
.EXAMPLE
    Get-ChildItem 'C:\ProgramData\Local' -ErrorAction SilentlyContinue

    PS > .\UpdateLocal.ps1 -InstallLocation 'C:\ProgramData\Local' -SaveTo .

    PS > Get-ChildItem 'C:\ProgramData\Local' | Select-Object Name -First 5
    Name
    ----
    locales
    resources
    swiftshader
    chrome_100_percent.pak
    chrome_200_percent.pak

    PS > Get-ChildItem | Select-Object Name
    Name
    ----
    local_6.4.3.exe
    UpdateLocal.ps1

    Install Local to 'C:\ProgramData\Local' and save its setup installer to the current directory.
#>