#!/usr/bin/bash

# ---- Color stuff
BASE="\e[0m"
color() {
  code="$1"
  echo "\e[${code}m"
}

color_256() {
  code="$1"
  echo "\e[38;5;${code}m"
}

bold_it() {
  text="$1"
  echo "\e[1m$text${BASE}"
}

light_it() {
  text="$1"
  echo "\e[2m$text${BASE}"
}

BLACK=$(color "30")
WHITE=$(color "97")
RED=$(color "31")
SHARPRED=$(color_256 "196")
LIGHTRED=$(color "91")
DEEPRED=$(color_256 "160")
GREEN=$(color "32")
LIGHTGREEN=$(color "92")
SHARPGREEN=$(color_256 "46")
YELLOW=$(color "33")  # Brawn actually
LIGHTYELLOW=$(color "93")
SHARPYELLOW=$(color_256 "226")
BLUE=$(color "34")
LIGHTBLUE=$(color "94")
DEEPBLUE=$(color_256 "33")
MAGENTA=$(color "35")
LIGHTMAGENTA=$(color "95")
CYAN=$(color "36")
LIGHTCYAN=$(color "96")
GRAY=$(color "37")
DARKGRAY=$(color "90")


# ---- Common properties

is_root=false
if [ "$UID" = 0 ]; then
  is_root=true
fi

user=$(whoami)


# ---- Blocks

info_user() {
  u_col="$LIGHTCYAN"
  block_col="$WHITE"
  if [ "$is_root" = true ]; then
    u_col="$RED"
    block_col="$RED"
  fi
  echo -e "$block_col⟦$u_col$(bold_it '\u')$WHITE$(bold_it '@')$DEEPBLUE\h$block_col⟧"
}

info_cwd() {
  cwd=$(pwd | sed "s#${HOME}#~#g")
  perms=$(stat -c '%a' .)
  is_owner_col="$GREY"
  if [ "$user" = $(stat -c '%U' .) ]; then
    is_owner_col="$LIGHTGREEN"
  fi
  nbr_files=$(find .  -maxdepth 1 -mindepth 1 -type f -printf '.' | wc -c)
  files="$WHITE${nbr_files}$(bold_it 'f')"
  if (( ${nbr_files} > 99 )); then files="$SHARPRED⍏$(bold_it 'f')"; fi

  nbr_dir=$(find .  -maxdepth 1 -mindepth 1 -type d -printf '.' | wc -c)
  dir="$WHITE${nbr_dir}$(bold_it 'd')"
  if (( ${nbr_dir} > 99 )); then dir="$SHARPRED⍏$(bold_it 'd')"; fi

  nbr_syml=$(find .  -maxdepth 1 -mindepth 1 -type l -printf '.' | wc -c)
  symlinks="$WHITE${nbr_syml}$(bold_it 'l')"
  if (( ${nbr_syml} > 99 )); then symlinks="$SHARPRED⍏$(bold_it 'l')"; fi

  content="${is_owner_col}$perms $WHITE${cwd} ${files}${dir}${symlinks}"
  block_col="$WHITE"
  if [[ "$content" =~ "$SHARPRED" ]];then
    block_col="$DEEPRED"
  fi
  echo -e "$SHARPYELLOW─$block_col⟦${content}$block_col⟧"
}


info_jobs() {
  running=$(jobs -r | wc -l)
  stopped=$(jobs -s | wc -l)
  block_col="$WHITE"
  if [ ! "$stopped" = "0" ]; then block_col="$DEEPRED"; fi
  if [ ! "$running" = "0" ]; then block_col="$LIGHTGREEN"; fi
  if [ ! "${running}${stopped}" = "00" ]; then
    echo -e "$SHARPYELLOW─${block_col}⟦$SHARPGREEN${running}⚡$SHARPRED${stopped}✞${block_col}⟧"
  fi
}

info_git() {
  git_branch=$(git branch --no-color 2>/dev/null | grep \* | sed 's/* //')

  if [ $git_branch ]
  then
    status=$(git status --porcelain 2>/dev/null)

    block_col="$WHITE"
    count_not_staged=$(for i in "$status"; do echo "$i"; done | grep -v '^?? ' | sed '/^$/d' | wc -l | sed "s/ //g")
    color_not_staged="$LIGHTGREEN"
    if [ ! $count_not_staged = "0" ]; then
      color_not_staged="$SHARPRED"
      block_col="$DEEPRED"
    fi

    count_untracked=$(for i in "$status"; do echo "$i"; done | grep '^?? ' | sed '/^$/d' | wc -l | sed "s/ //g")
    color_ut="$LIGHTGREEN"
    if [ ! $count_untracked = "0" ]; then
      color_ut="$SHARPRED"
      block_col="$DEEPRED"
    fi

    echo -e "$SHARPYELLOW─${block_col}⟦${git_branch}$WHITE:$color_not_staged${count_not_staged}$WHITE:$color_ut${count_untracked}${block_col}⟧"
  fi
}


prompt_return_code() {
  if [ "$?" -eq "0" ]; then
    echo -e "$SHARPYELLOW└─$GREEN▣$SHARPYELLOW─━╼"
  else
    echo -e "$SHARPYELLOW└─$RED▢$SHARPYELLOW─━╼"
  fi
}


# ---- Main

set_bash_prompt() {
  PS1="${SHARPYELLOW}┌$(info_user)$(info_cwd)$(info_git)$(info_jobs)${DEFAULT}"
  PS1+="\n$(prompt_return_code) ${DEFAULT}"
}

set_bash_prompt
