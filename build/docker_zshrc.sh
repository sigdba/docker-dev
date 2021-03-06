# . /repo/site.conf

if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=clean
plugins=(git)
source $ZSH/oh-my-zsh.sh

export EDITOR=vim

export PS1="($SITE_NAME) %{$fg[blue]%}%B%c/%b%{$reset_color%} $(git_prompt_info)%(!.#.$) "

if [ -f /etc/is_cloud9 ]; then
  echo "We're in Cloud9. Disabling some ZSH fanciness."
  export TERM=vt220
  zle -D zle-line-init
  zle -D zle-line-finish
fi
