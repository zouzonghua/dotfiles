#!/bin/bash
dotfiles_folder=~/dotfiles
backup_rand=$RANDOM

# detect if there's a dotfiles folder
if [ -d $dotfiles_folder  ]
then
  echo "\033[0;31mYou already have a dotfiles folder in your home directory.\033[0;m"
    read -p "Would you like to backup your dotfiles folder first? [y/n] " ans
    if [ "$ans" == "y"  ]
      then
        echo "backup your original $dotfiles_folder to $dotfiles_folder-$(date +%Y%m%d)-$backup_rand"
        mv $dotfiles_folder $dotfiles_folder-$(date +%Y%m%d)-$backup_rand
      else
        echo "You have a $dotfiles_folder now, please backup this first."
        exit
  fi
fi

# check if Git is installed
hash git >/dev/null && /usr/bin/env git clone -b 'main' git@github.com:zouzonghua/dotfiles.git ~/dotfiles && cd ~/dotfiles || {
    echo "Sorry, Git is not installed yet!"
  exit
}

# check if stow is installed
hash stow >/dev/null || {
    echo "Sorry, Stow is not installed yet!"
  exit
}

# run install all config
items=(
    "alacritty"
    "zsh"
    "tmux"
    "git"
    "yabai"
    "skhd"
    "hammerspoon"
)

for item in "${items[@]}" ; do
    stow -t "$HOME" -R "${item}"
    echo "${item} done."
done

echo ""
echo "\033[0;34mNice! Seems everything is going well.\033[0m"
echo "\033[0;34mGithub Repository: https://github.com/zouzonghua/dotfiles/\033[0m"
echo "\033[0;34mfeel free to fork it :)\033[0m"
echo ""
echo "\033[0;34mPeace :)\033[0m"
echo ""

exit
