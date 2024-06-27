#!/bin/sh

# Variables
DOTFILES=$HOME/.dotfiles
TMUX=$HOME/.tmux

# Get OS informatio
OS=`uname -s`
OSREV=`uname -r`
OSARCH=`uname -m`

# Use colors, but only if connected to a terminal, and that terminal
# supports them.
if command -v tput >/dev/null 2>&1; then
    ncolors=$(tput colors)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NORMAL=""
fi

# Functions
is_mac()
{
    [ "$OS" = "Darwin" ]
}

is_linux()
{
    [ "$OS" = "Linux" ]
}

is_debian() {
    command -v apt-get >/dev/null 2>&1
}


sync_repo() {
    local repo_uri="$1"
    local repo_path="$2"
    local repo_branch="$3"

    if [ -z "$repo_branch" ]; then
        repo_branch="master"
    fi

    if [ ! -e "$repo_path" ]; then
        mkdir -p "$repo_path"
        git clone --depth 1 --branch $repo_branch "https://github.com/$repo_uri.git" "$repo_path"
    else
        cd "$repo_path" && git pull --rebase --stat origin $repo_branch; cd - >/dev/null
    fi
}


install_package() {
    if ! command -v ${1} >/dev/null 2>&1; then
        if is_mac; then
            brew -q install ${1}
        elif is_debian; then
            sudo apt-get install -y ${1}
        fi
    else
        if is_mac; then
            brew upgrade -q ${1}
        elif is_debian; then
            sudo apt-get upgrade -y ${1}
        fi
    fi
}

clean_dotfiles() {
    confs="
    .vimrc
    "
    for c in ${confs}; do
        [ -f $HOME/${c} ] && mv $HOME/${c} $HOME/${c}.bak
    done

    rm -rf $TMUX $DOTFILES
}

YES=0
NO=1
promote_yn() {
    eval ${2}=$NO
    read -p "$1 [y/N]: " yn
    case $yn in
        [Yy]* )    eval ${2}=$YES;;
        [Nn]*|'' ) eval ${2}=$NO;;
        *)         eval ${2}=$NO;;
    esac
}

# Clean or not?
if [ -d $DOTFILES ]; then
    promote_yn "${YELLOW}Do you want to reset all configurations?${NORMAL}" "continue"
    if [ $continue -eq $YES ]; then
        clean_dotfiles
    fi
fi

# Install Brew
if is_mac && ! command -v brew >/dev/null 2>&1; then
    printf "${GREEN}▓▒░ Installing Homebrew...${NORMAL}\n"
    # Install homebrew

    # Use mirror
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.bfsu.edu.cn/git/homebrew/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.bfsu.edu.cn/git/homebrew/homebrew-core.git"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.bfsu.edu.cn/homebrew-bottles"

    # /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    /bin/bash -c "$(curl -fsSL https://cdn.jsdelivr.net/gh/Homebrew/install@HEAD/install.sh)"

    # Tap cask and cask-upgrade
    brew tap homebrew/cask
    brew tap homebrew/cask-versions
    brew tap homebrew/cask-fonts
    brew tap buo/cask-upgrade
    brew tap zackelia/formulae

    # Install GNU utilities
    brew install coreutils
fi

# Check git
if ! command -v git >/dev/null 2>&1; then
    printf "${GREEN}▓▒░ Installing git...${NORMAL}\n"
    install_package git
fi

# Check curl
if ! command -v curl >/dev/null 2>&1; then
    printf "${GREEN}▓▒░ Installing curl...${NORMAL}\n"
    install_package curl
fi

# Check zsh
if ! command -v zsh >/dev/null 2>&1; then
    printf "${GREEN}▓▒░ Installing zsh...${NORMAL}\n"
    install_package zsh
fi

# Dotfiles
printf "${GREEN}▓▒░ Installing Dotfiles...${NORMAL}\n"
sync_repo zouzonghua/dotfiles $DOTFILES develop

chmod +x $DOTFILES/install.sh
chmod +x $DOTFILES/install_brew.sh
chmod +x $DOTFILES/install_brew_cask.sh

ln -sf $DOTFILES/.vimrc $HOME/.vimrc

# Packages
printf "${GREEN}▓▒░ Installing packages...${NORMAL}\n"
if is_mac; then
    ./install_brew.sh
elif is_debian; then
    ./install_debian.sh
else
    printf "Noting to install!"
fi


printf "${GREEN}▓▒░ Done. Enjoy!${NORMAL}\n"
