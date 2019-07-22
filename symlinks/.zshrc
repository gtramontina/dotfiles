# ##############################################################################
#    ███████╗███████╗██╗  ██╗██████╗  ██████╗
#    ╚══███╔╝██╔════╝██║  ██║██╔══██╗██╔════╝
#      ███╔╝ ███████╗███████║██████╔╝██║     
#     ███╔╝  ╚════██║██╔══██║██╔══██╗██║     
# ██╗███████╗███████║██║  ██║██║  ██║╚██████╗
# ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝
# ##############################################################################

export HISTCONTROL=ignoreboth:erasedups

[ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"

[ -r $ZPLUG_HOME/init.zsh ] && source $ZPLUG_HOME/init.zsh
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-autosuggestions"
zplug "plugins/git", from:oh-my-zsh, if:"which git"
zplug "zsh-users/zsh-completions"
zplug "lib/history", from:oh-my-zsh
zplug "lib/key-bindings", from:oh-my-zsh
zplug "lib/completion", from:oh-my-zsh
zplug "sindresorhus/pure", use:"{async,pure}.zsh"
zplug "chriskempson/base16-shell"
zplug "tmux-plugins/tpm", dir:"$HOME/.tmux/plugins/tpm"
(zplug check || zplug install) && zplug load

bindkey '^ ' autosuggest-accept # CTRL+SPACE

[ -r $HOME/.aliases ] && source $HOME/.aliases
[ -r $HOME/.functions ] && source $HOME/.functions
[ -r $HOME/.chpwd ] && source $HOME/.chpwd
[ -r $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh
[ -r $HOME/.motd ] && source $HOME/.motd
[ -r $HOME/.env.local ] && source $HOME/.env.local
