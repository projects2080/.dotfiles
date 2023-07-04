#! /bin/bash

set -e

errcho() {
  >&2 echo $1
}

xerrcho() {
  >&2 echo $1
  exit ${2:-1}
}

ensure_sudo() {
  if [[ $EUID > 0 ]]; then
    xerrcho "Please run as root" 1
  fi
}

ensure_not_sudo() {
  if [[ $EUID = 0 ]]; then
    xerrcho "Do not run as root" 1
  fi
}

if [ "$1" = "manjaro-xfce-packages" ]; then
  # sudo pacman -Syu
  sudo pacman -S --needed --noconfirm base-devel git
  # to update mirrors:
  # sudo pacman-mirrors -f && sudo pacman -Syyu
  git clone https://aur.archlinux.org/yay-git.git && sudo mv yay-git /opt/ && cd /opt/yay-git && makepkg -si
  sudo pacman -S \
    xfce4-systemload-plugin xfce4-notes-plugin \
    veracrypt \
    vlc \
    libreoffice-fresh \
    vim \
    dos2unix \
    remmina \
    python python-pip \
    nodejs npm \
    ttf-fira-code \
    chromium \
    pycharm-community-edition
  yay -S \
    visual-studio-code-bin \
    webstorm
fi

link() {
  if [ -z "$2" ]; then
    xerrcho "Need to specify link target"
  fi
  local source="${DOTFILES:-$HOME/.dotfiles}/${1}"
  echo "Linking $source to $2"
  local parent="$(dirname -- "$2")"
  mkdir -p "$parent"
  if [ -d "$source" ]; then
    ln -sfn "$source" "$2"
  elif [ -f "$source" ]; then
    ln -sf "$source" "$2"
  else
    if [ -z "$3" ]; then
      xerrcho "$source is not valid"
    fi
  fi
}

if [ "$1" = "link" ]; then
  ensure_not_sudo
  link editorconfig $HOME/.editorconfig
  link git/gitignore $HOME/.gitignore
  link git/gitconfig $HOME/.gitconfig
  link local/gitconfig $HOME/.gitconfig.local optional
  link ideavimrc $HOME/.ideavimrc
  link vscode/settings.json $HOME/.config/Code/User/settings.json
  link vscode/keybindings.json $HOME/.config/Code/User/keybindings.json
  link bash_aliases $HOME/.bash_aliases
  exit 0
fi

xerrcho 'Unknown command, check the file'
