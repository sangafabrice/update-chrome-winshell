$DevDependencies = @{
    ProgramName = 'OperaGX'
    Description = 'The script installs or updates Opera GX browser on Windows.'
    Guid = '1fd836e9-2d1c-4c0d-a43e-2b1798cc719c'
    IconUri = 'https://rawcdn.githack.com/sangafabrice/reg-cli/642e5e98a5620f1841db0694588e3417f9c89535/icon.png'
    Tags = @('opera','opera-gx','chromium','update','browser')
    RemoteRepo = (git ls-remote --get-url) -replace '\.git$'
}

Function New-UpdaterScript {
    <#
    .SYNOPSIS
        Create module manifest
    .NOTES
        Precondition:
        1. latest.json exists
    #>

    $GithubRepo = $DevDependencies.RemoteRepo
    $HeaderPath = '.\Header.ps1'
    Push-Location $PSScriptRoot
    Get-Content .\latest.json -Raw |
    ConvertFrom-Json |
    ForEach-Object {
        @{
            Path = $HeaderPath
            Version = $_.version
            GUID = $DevDependencies.Guid
            Author = 'Fabrice Sanga'
            CompanyName = 'sangafabrice'
            Copyright = "© $((Get-Date).Year) SangaFabrice. All rights reserved."
            Description = $DevDependencies.Description
            RequiredModules = @(@{
                ModuleName = 'DownloadInfo'
                ModuleVersion = '5.0.0'
            },@{
                ModuleName = 'RegCli'
                ModuleVersion = '6.0.0'
            })
            ExternalModuleDependencies = 'RegCli'
            Tags = $DevDependencies.Tags
            LicenseUri = "$GithubRepo/blob/main/LICENSE.md"
            ProjectUri = "$GithubRepo/tree/$(git branch --show-current)"
            IconUri = $DevDependencies.IconUri
            ReleaseNotes = $_.releaseNotes
        }
    } | ForEach-Object { New-ScriptFileInfo @_ -Force }
    ((Get-Content $HeaderPath).Where({$_ -like "`<`# "}, 'Until') +
    (Get-Content .\Update.ps1)) -join "`n" | Out-String
    Remove-Item $HeaderPath
    Pop-Location
}

Function Publish-UpdaterScript {
    <#
    .SYNOPSIS
        Publish script to PSGallery
    .NOTES
        Precondition:
        1. The NUGET_API_KEY environment variable is set.
    #>

    @{
        Path = "$PSScriptRoot\Update$($DevDependencies.ProgramName).ps1" |
            ForEach-Object {
                New-UpdaterScript | Out-File $_
                Return $_
            }
        NuGetApiKey = $Env:NUGET_API_KEY
    } | ForEach-Object { 
        Try {
            Publish-Script @_
            Write-Host "$((Get-Item $_.Path).Name) published"
        } Catch { }
        Remove-Item $_.Path -Exclude Update.ps1
    }
}