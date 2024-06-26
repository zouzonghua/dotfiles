alias stow="stow --no-folding --verbose"

eval "$(/opt/homebrew/bin/brew shellenv)"

export PS1="%10F%m%f:%11F%1~%f \$ "
export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).
