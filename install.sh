#!/bin/bash
dotfiles_folder=~/dotfiles
backup_rand=$RANDOM
font_file=~/Library/Fonts/Meslo\ LG\ M\ Regular\ Nerd\ Font\ Complete.ttf
font_file_url=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/M/Regular/complete/Meslo%20LG%20M%20Regular%20Nerd%20Font%20Complete.ttf
packages=(
    "alacritty"
    "git"
    "hammerspoon"
    "karabiner"
    "rime"
    "tmux"
    "zsh"
)

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
          read -p "whether to use the current folder for installation? [y/n] " ans
          if [ "$ans" == "y"  ]
            then
              for item in "${packages[@]}" ; do
                conflicts=$(stow --no --verbose $item 2>&1 | awk '/\* existing target is/ {print $NF}')
                for filename in ${conflicts[@]}; do
                  if [[ -f $HOME/$filename || -L $HOME/$filename ]]; then
                    echo "DELETE: $filename"
                    rm -f "$HOME/$filename"
                  fi
                done
                # stow --no-folding -t "$HOME" -R "${item}"
                stow --no-folding --verbose $item
                echo "${item} done."
              done
              exit
          else
             exit
          fi
  fi
fi

# check if git is installed
hash git >/dev/null && /usr/bin/env git clone -b 'main' git@github.com:zouzonghua/dotfiles.git ~/Dotfiles && cd ~/Dotfiles || {
    echo "Sorry, Git is not installed yet!"
  exit
}

# check if stow is installed
hash stow >/dev/null || {
    echo "Sorry, Stow is not installed yet!"
  exit
}

# check if font is installed
if [ ! -f "$font_file" ]; then
    echo "install font..."
    cd ~/Library/Fonts && curl -fLo "Meslo LG M Regular Nerd Font Complete.ttf" "$font_file_url"
    echo "install Meslo LG M Regular Nerd Font Complete done."
fi

# run install all config
for item in "${packages[@]}" ; do
  conflicts=$(stow --no --verbose $item 2>&1 | awk '/\* existing target is/ {print $NF}')
  for filename in ${conflicts[@]}; do
    if [[ -f $HOME/$filename || -L $HOME/$filename ]]; then
      echo "DELETE: $filename"
      rm -f "$HOME/$filename"
    fi
  done
  # stow --no-folding -t "$HOME" -R "${item}"
  stow --no-folding --verbose $item
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
