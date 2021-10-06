brew install koekeishiya/formulae/yabai
brew install koekeishiya/formulae/skhd
ln "${HOME}/.dotfiles/yabai/.yabairc" "${HOME}/.yabairc"
ln "${HOME}/.dotfiles/yabai/.skhdrc" "${HOME}/.skhdrc"
sudo yabai --install-sa
sudo yabai --load-sa
brew services start skhd
brew services start yabai

ln -s $HOME/.dotfiles/zsh/.zshrc $HOME/.zshrc
ln -s $HOME/.dotfiles/tmux/.tmux.conf $HOME/.tmux.conf
ln -s $HOME/.dotfiles/git/.gitconfig $HOME/.gitconfig
ln -s $HOME/.dotfiles/config/alacritty.yml  $HOME/.config/alacritty.yml

ln $HOME/.dotfiles/rime/default.custom.yaml  $HOME/Library/Rime/default.custom.yaml
ln $HOME/.dotfiles/rime/squirrel.custom.yaml  $HOME/Library/Rime/squirrel.custom.yaml
ln $HOME/.dotfiles/rime/luna_pinyin_simp.custom.yaml  $HOME/Library/Rime/luna_pinyin_simp.custom.yaml
ln $HOME/.dotfiles/rime/luna_pinyin.extended.dict.yaml  $HOME/Library/Rime/luna_pinyin.extended.dict.yaml
ln $HOME/.dotfiles/rime/luna_pinyin.sougou.dict.yaml  $HOME/Library/Rime/luna_pinyin.sougou.dict.yaml
cp $HOME/.dotfiles/rime/fonts/HanaMinA.ttf $HOME/Library/Fonts
cp $HOME/.dotfiles/rime/fonts/HanaMinB.ttf $HOME/Library/Fonts

cd ~/Library/Fonts && curl -fLo "Meslo LG M Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/M/Regular/complete/Meslo%20LG%20M%20Regular%20Nerd%20Font%20Complete.ttf
cd ~/Library/Fonts && curl -fLo "Meslo LG M Regular Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/M/Regular/complete/Meslo%20LG%20M%20Regular%20Nerd%20Font%20Complete%20Mono.ttf
cd ~/Library/Fonts && curl -fLo "Meslo LG M DZ Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/M-DZ/Regular/complete/Meslo%20LG%20M%20DZ%20Regular%20Nerd%20Font%20Complete.ttf
