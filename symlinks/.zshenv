# ##############################################################################
#    ███████╗███████╗██╗  ██╗███████╗███╗   ██╗██╗   ██╗
#    ╚══███╔╝██╔════╝██║  ██║██╔════╝████╗  ██║██║   ██║
#      ███╔╝ ███████╗███████║█████╗  ██╔██╗ ██║██║   ██║
#     ███╔╝  ╚════██║██╔══██║██╔══╝  ██║╚██╗██║╚██╗ ██╔╝
# ██╗███████╗███████║██║  ██║███████╗██║ ╚████║ ╚████╔╝ 
# ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝  ╚═══╝  
# ##############################################################################

export EDITOR='vim'
export ZPLUG_HOME=/usr/local/opt/zplug
export BASE16_SHELL=$ZPLUG_HOME/repos/chriskempson/base16-shell/
export CIDER_HOME=$HOME/.cider
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=10
export ZSH_AUTOSUGGEST_USE_ASYNC=true

export ASDF_DIR=$(brew --prefix asdf)
export SDKMAN_DIR=$HOME/.sdkman
export PATH="/usr/local/sbin:$PATH"

# Added by n-install (see http://git.io/n-install-repo).
export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"
