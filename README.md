# .dotfiles

## Install

### Windows

```powershell
Set-Location $env:USERPROFILE
$dotfiles = Join-Path $env:USERPROFILE '.dotfiles'
[Environment]::SetEnvironmentVariable('DOTFILES', $dotfiles, "User")
git clone --recurse-submodules https://github.com/projects2080/.dotfiles.git
Set-Location $dotfiles
& .\Install.ps1 -PSProfile -Link
```

- [Chocolatey](https://chocolatey.org/install)
  - `choco feature enable -n=useRememberedArgumentsForUpgrades`
  - `choco upgrade all -y`
- [O&O ShutUp10++](https://www.oo-software.com/en/shutup10)

### Manjaro (XFCE)

```bash
cd $HOME
export DOTFILES=~/.dotfiles
git clone --recurse-submodules https://github.com/projects2080/.dotfiles.git
cd $DOTFILES
./install.sh manjaro-xfce-packages
./install.sh link
```