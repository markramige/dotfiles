case $- in
  *i*) ;;
    *) return;;
esac

HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=-1
HISTFILESIZE=-1

shopt -s checkwinsize
shopt -s globstar

## make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

## set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

## set a fancy prompt
case "$TERM" in
  xterm-color|*-256color) color_prompt=yes;;
esac
force_color_prompt=yes
if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
if [ -v WSLENV ]; then
  case "$TERM" in
  xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}`echo ${WSL_DISTRO_NAME^^} |head -c1`:\u@\h: \w\a\]$PS1"
    ;;
  *)
    ;;
  esac
else
  case "$TERM" in
  xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
  *)
    ;;
  esac
fi

## colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

## Alias definitions.
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

## enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

## gf
complete -W "\$(gf -list)" gf

## ssh-agent
if [ -v WSLENV ] && [ $WSL_DISTRO_NAME == "Debian" ]; then
  if [ ! -d "$HOME/.ssh" ]; then
    mkdir $HOME/.ssh
    chmod 700 {$HOME,$HOME/.ssh}
  fi
  if [ ! -d "$HOME/winhome" ]; then
    ln -s /mnt/c/Users/mark $HOME/winhome
  fi
  if [ ! -e "/usr/bin/socat" ]; then
    echo "installing socat"
    sudo apt install socat -y
  fi
  export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock
  ss -a | grep -q $SSH_AUTH_SOCK
  if [ $? -ne 0 ]; then
    rm -f $SSH_AUTH_SOCK
    ( setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"$HOME/winhome/.wsl/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork & ) >/dev/null 2>&1
  fi
fi

