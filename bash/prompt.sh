# Formats the prompt to be:
# user:currentDirectory (git branch)$ 

export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export GIT_PS1_SHOWDIRTYSTATE=1
export PS1='\[\033[36m\]\u\[\033[m\]:\[\033[33;1m\]\w\[\033[m\]\[\033[0;35m\]$(__my_git_ps1)\[\033[m\]$ '

# My functions
__my_git_ps1 ()
{
  if [ "`type __git_ps1 2>/dev/null | grep function`" ]; then
    __git_ps1 " (%s)"
  fi
}
