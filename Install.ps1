param (
  [switch]$Link = $false,
  [switch]$PSProfile = $false,
  [switch]$ChocoPackages = $false,
  [switch]$CodeExtensions = $false,
  [switch]$PipModules = $false
)

if ([string]::IsNullOrEmpty($env:DOTFILES)) {
  $env:DOTFILES=Split-Path -parent $PSCommandPath
}

function Test-IsAdmin {
  ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

function Link() {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory=$true)]
    [string]$dest,
    [Parameter(Mandatory=$true)]
    [string]$src
  )
  Begin {
    Write-Host "Linking $dest" -ForegroundColor 'DarkGray'
  }
  Process {
    if (-Not (Test-Path $src)) {
      Write-Host "$src does not exist" -ForegroundColor 'Yellow'
    } else {
      if (Test-Path $dest) {
        (Remove-Item $dest -Recurse -Force -Confirm:$false) | Out-Null
      } else {
        $parent=Split-Path -parent $dest
        if (-Not (Test-Path $parent -PathType Container)) {
          (New-Item $parent -ItemType Directory) | Out-Null
        }
      }
      if (Test-Path $src -PathType Container) {
        (New-Item -Path $dest -ItemType Junction -Value $src) | Out-Null
      } elseif (Test-Path $src -PathType Leaf) {
        (New-Item -Path $dest -ItemType HardLink -Value $src) | Out-Null
      }
    }
  }
}

function Install-Links() {
  [CmdletBinding()]
  Param ()
  Begin {
    if (Test-IsAdmin) { Throw "Do not run as admin" }
    Write-Host "Installing links..." -ForegroundColor 'Blue'
  }
  Process {
    Link "$env:USERPROFILE\.PowerShell_profile.ps1" "$env:DOTFILES\profile.ps1"
    Link "$env:USERPROFILE\.PowerShell_profile.local.ps1" "$env:DOTFILES\local\profile.ps1"
    Link "$env:USERPROFILE\.gitconfig" "$env:DOTFILES\git\gitconfig"
    Link "$env:USERPROFILE\.gitconfig.local" "$env:DOTFILES\local\gitconfig"
    Link "$env:USERPROFILE\.gitignore" "$env:DOTFILES\git\gitignore"
    Link "$env:USERPROFILE\.editorconfig" "$env:DOTFILES\editorconfig"
    Link "$env:USERPROFILE\.ideavimrc" "$env:DOTFILES\ideavimrc"
    Link "$env:APPDATA\Code\User\settings.json" "$env:DOTFILES\vscode\settings.json"
    Link "$env:APPDATA\Code\User\keybindings.json" "$env:DOTFILES\vscode\keybindings.json"
  }
  End {
    Write-Host "Finished installing links" -ForegroundColor 'Green'
  }
}

if ($Link) {
  Install-Links
}

function Install-Profile() {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory=$true)]
    [string]$useProfile
  )
  Begin {
    if (Test-IsAdmin) { Throw "Do not run as admin" }
    Write-Host "Installing delegated PowerShell profile..." -ForegroundColor 'Blue'
  }
  Process {
    $newProfile=Join-Path -Path "$env:USERPROFILE" -ChildPath ".PowerShell_profile.ps1"
    $profileContent = @"
if ([System.IO.File]::Exists("$newProfile")) { . $newProfile } else { Write-Host "$newProfile not found..." }
"@
    if ([System.IO.File]::Exists($useProfile)) {
      $content = Get-Content $useProfile
      if ($content -ne $profileContent) {
        Throw "$useProfile exists, back it up and then remove it first"
      }
    } else {
      (New-Item -path $useProfile -type file -force) | Out-Null
      Write-Output $profileContent | Out-File $useProfile
    }
  }
  End {
    Write-Host "Finished installing delegated PowerShell profile" -ForegroundColor 'Green'
  }
}

if ($PSProfile) {
  Install-Profile $profile.CurrentUserAllHosts
}

if ($ChocoPackages) {
  # https://chocolatey.org/install#individual
  # choco list --local-only
  # choco upgrade all -y
  # (NOTE: docker must be installed manually)
  # choco feature enable -n=useRememberedArgumentsForUpgrades
  choco install -y --limit-output 7zip
  choco install -y --limit-output coretemp
  choco install -y --limit-output firacode
  # choco install -y --limit-output firefox --params "/NoTaskbarShortcut /NoDesktopShortcut /NoAutoUpdate"
  choco install -y --limit-output git.install --params "/GitOnlyOnPath /NoAutoCrlf /WindowsTerminal /NoShellIntegration /NoGitLfs /SChannel /Editor:Notepad++"
  choco install -y --limit-output libreoffice-fresh
  # https://support.nordvpn.com/Connectivity/Windows/1047410092/How-to-connect-to-NordVPN-with-IKEv2-IPSec-on-Windows-10.htm
  # choco install -y --limit-output nordvpn
  choco install -y --limit-output notepadplusplus
  choco install -y --limit-output veracrypt
  choco install -y --limit-output vlc
  choco install -y --limit-output nodejs
  choco install -y --limit-output python
  choco install -y --limit-output vscode --params "/NoDesktopIcon /NoContextMenuFiles /NoContextMenuFolders"
  choco install -y --limit-output winmerge
  # choco install -y --limit-output visualstudio2019buildtools
  # choco install -y --limit-output webstorm
  # choco install -y --limit-output pycharm-community
  # choco install -y --limit-output chromium
  # choco install -y --limit-output qbittorrent
  # choco install -y --limit-output make
  # choco install -y --limit-output mingw
  # choco install -y --limit-output googledrive
  # choco install -y --limit-output malwarebytes
  choco install -y --limit-output irfanview
  choco install -y --limit-output tinywall
}

if ($CodeExtensions) {
  # code --list-extensions
  code --install-extension EditorConfig.EditorConfig
  # code --install-extension GitHub.copilot
  code --install-extension PKief.material-icon-theme
  # code --install-extension dbaeumer.vscode-eslint
  # code --install-extension eamodio.gitlens
  # code --install-extension esbenp.prettier-vscode
  # code --install-extension mikestead.dotenv
  # code --install-extension ms-python.python
  # code --install-extension ms-python.vscode-pylance
  # code --install-extension stylelint.vscode-stylelint
  code --install-extension vscodevim.vim
}

if ($PipModules) {
  pip install --user --upgrade --force-reinstall black mypy pylint
}
