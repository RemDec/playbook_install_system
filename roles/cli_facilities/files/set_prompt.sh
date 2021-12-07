#!/usr/bin/bash

# ---- Color stuff
BASE="\[\e[0m\]"
color() {
  code="$1"
  echo "\[\e[${code}m\]"
}

color_256() {
  code="$1"
  echo "\[\e[38;5;${code}m\]"
}

bg_color_256() {
  code="$1"
  echo "\[\e[48;5;${code}m\]"
}

bold_it() {
  text="$1"
  echo "\[\e[1m\]$text${BASE}"
}

light_it() {
  text="$1"
  echo "\[\e[2m\]$text${BASE}"
}

DEFAULT=$(color "39")
BG_DEFAULT=$(color "49")
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
BG_LIGHTYELLOW=$(color "103")
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

LAST_STATUS="$?"

IS_ROOT=false
if [ "$UID" = 0 ]; then IS_ROOT=true; fi
MY_USER=$(whoami)

# 'Energy' determines wire's color between boxes + load bar color in the resources box
BG_ENERGY="$BG_LIGHTYELLOW"
ENERGY="$SHARPYELLOW"

PROC_USAGE="??"  # Overall current CPU usage in %
RAM_USAGE="??"  # Overall RAM usage in %
TOTAL_USAGE="??"  # A bit dumb metric combininb CPU + Mem load
compute_resource() {
  PROC_USAGE="$(echo 100 - $(mpstat -P all | tail -1 | awk '{print $NF}') | bc | cut -d'.' -f1)"
  RAM_USAGE="$(free | grep Mem | awk '{print $3/$2 * 100}' | cut -d'.' -f1)"
  TOTAL_USAGE=$(( (PROC_USAGE + RAM_USAGE)/2 ))
  if (( $TOTAL_USAGE < 65 )); then
    BG_ENERGY=$(bg_color_256 "226")
    ENERGY=$(color_256 "226")
  elif (( $TOTAL_USAGE < 80 )); then
    BG_ENERGY=$(bg_color_256 "214")
    ENERGY=$(color_256 "214")
  elif (( $TOTAL_USAGE < 90 )); then
    BG_ENERGY=$(bg_color_256 "202")
    ENERGY=$(color_256 "202")
  else
    BG_ENERGY=$(bg_color_256 "196")
    ENERGY=$(color_256 "196")
  fi
}

# ---- Blocks

info_user() {
  u_col="$LIGHTCYAN"
  block_col="$WHITE"
  if [ "$IS_ROOT" = true ]; then
    u_col="$RED"
    block_col="$RED"
  fi
  echo -e "$block_col⟦$u_col$(bold_it '\u')$WHITE$(bold_it '@')$DEEPBLUE\h$block_col⟧"
}

short_pwd() {
  cwd=$(pwd | sed "s#${HOME}#~#g" | perl -F/ -ane 'print join( "/", map { $i++ < @F - 1 ?  substr $_,0,1 : $_ } @F)')
  echo -n $cwd
}

info_cwd() {
  cwd=$(pwd | sed "s#${HOME}#~#g")
  if [[ "${#cwd}" > 80 ]]; then  # let's short the path keeping first letters of parent directories
    cwd=$(echo "$cwd" | perl -F/ -ane 'print join( "/", map { $i++ < @F - 1 ?  substr $_,0,1 : $_ } @F)')
  fi
  perms=$(stat -c '%a' .)
  is_owner_col="$GRAY"
  if [ "$MY_USER" = $(stat -c '%U' .) ]; then
    is_owner_col="$LIGHTGREEN"
  fi
  # Info about the files in cwd
  nbr_files=$(find .  -maxdepth 1 -mindepth 1 -type f -printf '.' | wc -c)
  files=""
  if [ ! "$nbr_files" = "0" ]; then
    files="$WHITE${nbr_files}$(bold_it 'f')"
    if (( ${nbr_files} > 99 )); then files="$SHARPRED⍏$(bold_it 'f')"; fi
  fi
  # Info about the subdirectories in cwd
  nbr_dir=$(find .  -maxdepth 1 -mindepth 1 -type d -printf '.' | wc -c)
  dir=""
  if [ ! "$nbr_dir" = "0" ]; then
    dir="$WHITE${nbr_dir}$(bold_it 'd')"
    if (( ${nbr_dir} > 99 )); then dir="$SHARPRED⍏$(bold_it 'd')"; fi
  fi
  # Info about the symbolic links in cwd
  nbr_syml=$(find .  -maxdepth 1 -mindepth 1 -type l -printf '.' | wc -c)
  symlinks=""
  if [ ! "$nbr_syml" = "0" ]; then
    symlinks="$WHITE${nbr_syml}$(bold_it 'l')"
    if (( ${nbr_syml} > 99 )); then symlinks="$SHARPRED⍏$(bold_it 'l')"; fi
  fi

  counters="${files}${dir}${symlinks}"
  if [ -z "$counters" ]; then counters="Ø"; fi
  content="${is_owner_col}$perms $WHITE${cwd} ${counters}"
  block_col="$WHITE"
  if [[ "$content" =~ "$SHARPRED" ]];then
    block_col="$DEEPRED"
  fi
  echo -e "$ENERGY─$block_col⟦${content}$block_col⟧"
}


info_jobs() {
  running=$(jobs -r | wc -l)
  stopped=$(jobs -s | wc -l)
  block_col="$WHITE"
  if [ ! "$stopped" = "0" ]; then block_col="$DEEPRED"; fi
  if [ ! "$running" = "0" ]; then block_col="$LIGHTGREEN"; fi
  if [ ! "${running}${stopped}" = "00" ]; then
    echo -e "$ENERGY─${block_col}⟦$SHARPGREEN${running}⚡$SHARPRED${stopped}✞${block_col}⟧"
  fi
}

info_git() {
  git_branch=$(git branch --no-color 2>/dev/null | grep \* | sed 's/* //')

  if [ $git_branch ]
  then
    readarray -t status_out<<<$(git status -b --porcelain 2>/dev/null)
    branch="${status_out[0]}"
    status=( ${status_out[@]:1} )

    block_col="$WHITE"
    branch_col="$LIGHTGRAY"
    if [[ "$branch" =~ "ahead" ]]; then branch_col="$LIGHTCYAN"; fi
    if [[ "$branch" =~ "behind" ]]; then branch_col="$YELLOW"; fi

    count_unstaged=$(for i in "$status"; do echo "$i"; done | grep -v '^?? ' | sed '/^$/d' | wc -l | sed "s/ //g")
    unstaged_col="$GRAY"
    if [ ! $count_unstaged = "0" ]; then
      unstaged_col="$SHARPRED"
      block_col="$DEEPRED"
    fi

    count_untracked=$(for i in "$status"; do echo "$i"; done | grep '^?? ' | sed '/^$/d' | wc -l | sed "s/ //g")
    untracked_col="$GRAY"
    if [ ! $count_untracked = "0" ]; then
      untracked_col="$SHARPRED"
      block_col="$DEEPRED"
    fi
    counters=""  # save space if all clean
    if [ ! "$count_unstaged$count_untracked" = "00" ]; then
      counters=" $unstaged_col${count_unstaged}$(bold_it 's')$untracked_col${count_untracked}$(bold_it 't')"
    fi
    content="$branch_col${git_branch}${counters}"

    echo -e "$ENERGY─$block_col⟦${content}$block_col⟧"
  fi
}

info_resources() {
  block_col="$WHITE"
  if [[ $PROC_USAGE > 85 || $RAM_USAGE > 85 ]]; then
    block_col="$DEEPRED"
  fi

  content="${PROC_USAGE}%λ ${RAM_USAGE}%Ξ"
  content_col="$BLACK"
  len_content="${#content}"
  pos_load_bar=$(( (len_content * TOTAL_USAGE)/100 ))
  bar_col="$BG_ENERGY"
  content_load_bar="$content_col$bar_col${content:0:pos_load_bar}$BG_DEFAULT$content_col${content:pos_load_bar}"

  echo -e "$ENERGY─$block_col⟦${content_load_bar}$block_col⟧"
}

prompt_return_code() {
  if [ "$LAST_STATUS" = "0" ]; then
    echo -e "$ENERGY└─$GREEN▣$ENERGY─━╼"
  else
    echo -e "$ENERGY└─$RED▢$ENERGY─━╼"
  fi
}


# ---- Main

set_bash_prompt() {
  info_line="${ENERGY}┌$(info_user)$(info_cwd)$(info_git)$(info_jobs)$(info_resources)${DEFAULT}"
  export PS1="${info_line}\n$(prompt_return_code) ${DEFAULT}"
}

compute_resource
set_bash_prompt
