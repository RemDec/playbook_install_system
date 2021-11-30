#!/usr/bin/bash

RESET='\[\017\]'
WHITE='\[\033[1;37m\]'
LIGHTGRAY='\[\033[0;37m\]'
GRAY='\[\033[1;30m\]'
BLACK='\[\033[0;30m\]'
RED='\[\033[0;31m\]'
LIGHTRED='\[\033[1;31m\]'
GREEN='\[\033[0;32m\]'
LIGHTGREEN='\[\033[1;32m\]'
BROWN='\[\033[0;33m\]' #Orange
YELLOW='\[\033[1;93m\]'
BLUE='\[\033[0;34m\]'
LIGHTBLUE='\[\033[1;34m\]'
PURPLE='\[\033[0;35m\]'
PINK='\[\033[1;35m\]' #Light Purple
CYAN='\[\033[0;36m\]'
LIGHTCYAN='\[\033[1;36m\]'
DEFAULT='\[\033[0m\]'

info_git() {
  git_branch=$(git branch --no-color 2>/dev/null | grep \* | sed 's/* //')

  if [ $git_branch ]
  then
    status=$(git status --porcelain 2>/dev/null)

    count_not_staged=$(for i in "$status"; do echo "$i"; done | grep -v '^?? ' | sed '/^$/d' | wc -l | sed "s/ //g")
    color_not_staged=$RED
    if [ $count_not_staged = "0" ]; then color_not_staged=$BLUE; fi

    count_ut=$(for i in "$status"; do echo "$i"; done | grep '^?? ' | sed '/^$/d' | wc -l | sed "s/ //g")
    color_ut=$RED
    if [ $count_ut = "0" ];then color_ut=$BLUE; fi

    echo -e "─⟦$YELLOW${git_branch}$WHITE:$color_not_staged${count_not_staged}$WHITE:$color_ut${count_ut}⟧"
  fi
}

info_user() {
  echo -e "⟦\u@\h⟧"
}

info_cwd() {
  cwd=$(pwd | sed "s#${HOME}#~#g")
  nbr_children=$(ls -l | tail -n +2 | wc -l)
  size=$(du -h -d 1 -a | tail -n 1 | awk '{print $1;}')
  echo -e "─⟦ ${cwd} ${nbr_children}=${size}⟧"
}


info_jobs() {
  running=$(jobs -r | wc -l)
  stopped=$(jobs -s | wc -l)
  if [ ! "${running}${stopped}" = "00" ]; then
    echo -e "─⟦$GREEN${running}⚡$RED${stopped}✞⟧"
  fi
}

prompt_return_code() {
  if [ "$?" -eq "0" ]; then
    echo -e "$YELLOW└─$GREEN▣$YELLOW─━╼"
  else
    echo -e "$YELLOW└─$RED▢$YELLOW─━╼"
  fi
}

set_bash_prompt() {
  if [ "$UID" = 0 ]; then
    #root
    PS1="\[\033[0;31m\]\u\[\033[0;37m\]@\h\[\033[1;37m\] \[\033[0;31m\]\$(short_pwd)\$(git_branch)\[\033[0;36m\]# \[\033[0m\]"
  else
    #non-root
    PS1="${YELLOW}┌$(info_user)$(info_cwd)$(info_git)$(info_jobs)${DEFAULT}"
    PS1+="\n$(prompt_return_code) "
  fi
}

set_bash_prompt
