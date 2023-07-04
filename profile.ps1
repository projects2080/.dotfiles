# from explorer (Win+e) -> Alt+f -> R, or from anywhere Win+x -> i

${function:Set-ParentLocation} = { Set-Location .. }; Set-Alias ".." Set-ParentLocation
${function:...} = { Set-Location ..\.. }
${function:....} = { Set-Location ..\..\.. }
${function:.....} = { Set-Location ..\..\..\.. }
${function:......} = { Set-Location ..\..\..\..\.. }

Set-Alias c cls
${function:x} = { exit }

${function:~} = { Set-Location ~ }
${function:cd.} = { Push-Location $env:DOTFILES }

${function:ls} = { cmd /R dir /OG /ON }
${function:rimraf} = { Remove-Item -Path @args -Recurse -Force }

${function:f} = { explorer . }

Set-Alias g git

Set-Alias n npm
${function:ni} = { npm install --save @args }
${function:nid} = { npm install --save-dev @args }
${function:nig} = { npm install -g @args }
${function:nr} = { npm run @args }

Set-Alias d docker
Set-Alias dc docker-compose
${function:dcd} = { docker-compose down -t 60 @args }
${function:dcs} = { docker-compose stop -t 60 @args }
${function:dcb} = { docker-compose build @args }
${function:dcbb} = { docker-compose build --no-cache @args }
${function:dcu} = { docker-compose up -d @args }
${function:dcuu} = { docker-compose up --force-recreate -d @args }
${function:dls} = { docker ps }

${function:title} = { $host.ui.RawUI.WindowTitle = $args }

function prompt {
  $location = $(Get-Location) -replace ($env:USERPROFILE).Replace('\','\\'), "~"
  $host.UI.RawUI.WindowTitle = $location
  "$location "
}

$localProfile = Join-Path $env:USERPROFILE '.PowerShell_profile.local.ps1'
if ([System.IO.File]::Exists($localProfile)) {
  . $localProfile
}

# cd ~
Clear-Host
