# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
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
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

[ -n "$PS1" ];
CODE_PATH="/home/viktor/projects"
SCRIPTS_PATH="/home/viktor/skripte"

# CODE REPOS
alias ohm='cd $CODE_PATH/oblo_ohm'
alias osm='cd $CODE_PATH/oblo_sysmgr'
alias omb='cd $CODE_PATH/oblo_omb'
alias ogb='cd $CODE_PATH/oblo_ogb'
alias wise='cd $CODE_PATH/oblo_wise'
alias sdk='cd $CODE_PATH/oblo_sdk'
alias util='cd $CODE_PATH/oblo_utility'

# RUN APPS
alias ohmgo='$SCRIPTS_PATH/./ohmgo.sh'
alias osmgo='$SCRIPTS_PATH/./osmgo.sh'
alias ombgo='$SCRIPTS_PATH/./ombgo.sh'
alias ogbgo='$SCRIPTS_PATH/./ogbGo.sh'
alias wisego='$SCRIPTS_PATH/./wisego.sh'
alias examplego='$SCRIPTS_PATH/./examplego.sh'
alias examplerun='$SCRIPTS_PATH/./examplerun.sh'
alias many_examplerun='$SCRIPTS_PATH/./many_examplerun.sh "$PWD"'
alias cloud='$SCRIPTS_PATH/./cloud.sh'

# TERMINAL
alias aliases='subl ~/.bashrc'
alias upa='source ~/.bashrc' # apply alias changes without restart
alias c='cd -'
alias ..='cd ..'
alias cls='clear'
alias wt='node ~/WorkTimer/index.js'
alias wtm='$SCRIPTS_PATH/./wtm.sh'
alias lsc='ls -1'
alias apply='source ~/.bashrc'

# OPEN FILES
alias properties='subl -n ~/projects/oblo_ohm/bins/cfg/ohm.properties; subl ~/projects/oblo_sysmgr/bins/cfg/osm.properties; subl ~/projects/oblo_omb/bins/cfg/oblomb.properties; subl ~/projects/oblo_ogb/bins/cfg/ogb.properties'
alias skripte='subl -n $SCRIPTS_PATH/*.sh'

# GIT
alias branches='git branch -a'
alias gst='git stash'
alias lg='cls; unwrap; git lg'
alias puluj='$SCRIPTS_PATH/./puluj.sh'
alias pulujweather='$SCRIPTS_PATH/./pulujweather.sh'
alias pushtomaster='git push origin HEAD:refs/for/master'
alias s='git status -s'
alias che='git checkout'
alias adampush='$SCRIPTS_PATH/./adampush.sh'
alias dif='git difftool --dir-diff'
alias epush='$SCRIPTS_PATH/./epush.sh'
alias st='$SCRIPTS_PATH/./statuses.sh'
alias lgvik='$SCRIPTS_PATH/./ordinal.sh'

# DOCKER
alias dimages='sudo docker images'
alias dcontainers='sudo docker ps -as'
alias dload='sudo docker load -i'      # absolute path + image_file.tar.gz
alias drmi='sudo docker rmi'           # image
alias drmc='sudo docker rm'            # container
alias dstart='sudo docker start'       # container
alias dstop='sudo docker stop -t 5'    # container
alias dinspect='sudo docker inspect'   # container
# alias drun

# OTHER
alias bridge='$SCRIPTS_PATH/./bridgeSetup.sh'
alias tcpvik='$SCRIPTS_PATH/./tcpvik.sh'
alias brisi='$SCRIPTS_PATH/./brisi.sh'
alias files='stat -c "%n" * .*'
alias telnetbrisi='$SCRIPTS_PATH/./tel.sh'
alias telr='$SCRIPTS_PATH/./telr.sh'
alias resetr='$SCRIPTS_PATH/./resetr.sh'
alias viksize='~/./viksize.sh'
alias unwrap='tput rmam'
alias wrap='tput smam'
alias resetmo='$SCRIPTS_PATH/./resetmo.sh'
alias logmrg='$SCRIPTS_PATH/./logmrg.sh "$PWD"'
alias win='subl -n $SCRIPTS_PATH/WeeklyReleaseFormatting/input.txt'
alias wout='$SCRIPTS_PATH/WeeklyReleaseFormatting/./weekly.sh'
alias kbo='xinput set-prop 16 "Device Enabled" 0' # gasenje laptop tastature
alias cpw='$SCRIPTS_PATH/./copy_weeklies.sh'

function same() {
  $SCRIPTS_PATH/find_same_file_changes.sh "$1"
}

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

complete -a alias

complete -F _command_complete *
set -o vi

# Shell prompt based on the Solarized Dark theme.
# Screenshot: http://i.imgur.com/EkEtphC.png
# Heavily inspired by @necolas’s prompt: https://github.com/necolas/dotfiles
# iTerm → Profiles → Text → use 13pt Monaco with 1.1 vertical spacing.

if [[ $COLORTERM = gnome-* && $TERM = xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
	export TERM='gnome-256color';
elif infocmp xterm-256color >/dev/null 2>&1; then
	export TERM='xterm-256color';
fi;

prompt_git() {
	local s='';
	local branchName='';

	# Check if the current directory is in a Git repository.
	git rev-parse --is-inside-work-tree &>/dev/null || return;

	# Check for what branch we’re on.
	# Get the short symbolic ref. If HEAD isn’t a symbolic ref, get a
	# tracking remote branch or tag. Otherwise, get the
	# short SHA for the latest commit, or give up.
	branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
		git describe --all --exact-match HEAD 2> /dev/null || \
		git rev-parse --short HEAD 2> /dev/null || \
		echo '(unknown)')";

	# Early exit for Chromium & Blink repo, as the dirty check takes too long.
	# Thanks, @paulirish!
	# https://github.com/paulirish/dotfiles/blob/dd33151f/.bash_prompt#L110-L123
	repoUrl="$(git config --get remote.origin.url)";
	if grep -q 'chromium/src.git' <<< "${repoUrl}"; then
		s+='*';
	else
		# Check for uncommitted changes in the index.
		if ! $(git diff --quiet --ignore-submodules --cached); then
			s+='.uncommited';
		fi;
		# Check for unstaged changes.
		if ! $(git diff-files --quiet --ignore-submodules --); then
			s+='.unstaged';
		fi;
		# Check for untracked files.
		if [ -n "$(git ls-files --others --exclude-standard)" ]; then
			s+='.untracked';
		fi;
		# Check for stashed files.
		if $(git rev- parse --verify refs/stash &>/dev/null); then
			s+='.stashed';
		fi;
	fi;

	[ -n "${s}" ] && s=" ${s}";

	echo -e "${1}${branchName}${2}${s}";
}

if tput setaf 1 &> /dev/null; then
	tput sgr0; # reset colors
	bold=$(tput bold);
	reset=$(tput sgr0);
	# Solarized colors, taken from http://git.io/solarized-colors.
	black=$(tput setaf 0);
	blue=$(tput setaf 33);
	cyan=$(tput setaf 37);
	green=$(tput setaf 64);
	orange=$(tput setaf 166);
	purple=$(tput setaf 125);
	red=$(tput setaf 124);
	violet=$(tput setaf 61);
	white=$(tput setaf 15);
	yellow=$(tput setaf 136);
else
	bold='';
	reset="\e[0m";
	black="\e[1;30m";
	blue="\e[1;34m";
	cyan="\e[1;36m";
	green="\e[1;32m";
	orange="\e[1;33m";
	purple="\e[1;35m";
	red="\e[1;31m";
	violet="\e[1;35m";
	white="\e[1;37m";
	yellow="\e[1;33m";
fi;

# Highlight the user name when logged in as root.
if [[ "${USER}" == "root" ]]; then
	userStyle="${red}";
else
	userStyle="${orange}";
fi;

# Highlight the hostname when connected via SSH.
if [[ "${SSH_TTY}" ]]; then
	hostStyle="${bold}${red}";
else
	hostStyle="${yellow}";
fi;

# Set the terminal title and prompt.
PS1="\[\033]0;\W\007\]"; # working directory base name
PS1+="\[${bold}\]\n"; # newline
PS1+="\[${userStyle}\]\u"; # username
PS1+="\[${white}\] at ";
PS1+="\[${hostStyle}\]\h"; # host
PS1+="\[${white}\] in ";
PS1+="\[${cyan}\]\w"; # working directory full path
PS1+="\$(prompt_git \"\[${white}\] on \[${violet}\]\" \"\[${green}\]\")"; # Git repository details
PS1+="\n";
PS1+="\[${white}\]\$ \[${reset}\]"; # `$` (and reset color)
export PS1;

PS2="\[${yellow}\]→ \[${reset}\]";



DIR_STACK_SIZE=10
declare -a dir_list=()

update_dir_list() {
    local new_dir="$(pwd)"
    
    # Check if the current directory is different from the last one stored in dir_list
    if [[ "${dir_list[0]}" != "$new_dir" ]]; then
        # Add the new directory to the list if it's not already there
        local found=false
        for dir in "${dir_list[@]}"; do
            if [[ "$dir" == "$new_dir" ]]; then
                found=true
                break
            fi
        done

        if ! $found; then
            dir_list=("$new_dir" "${dir_list[@]}")
            if (( ${#dir_list[@]} > DIR_STACK_SIZE )); then
                dir_list=("${dir_list[@]:0:DIR_STACK_SIZE}")
            fi
        fi
    fi
}

ccd() {
    if [[ -n $1 ]]; then
        local index=$(( $1 - 1 ))
        if (( index >= 0 )) && (( index < ${#dir_list[@]} )); then
            cd "${dir_list[$index]}"
        else
            echo "Invalid index"
        fi
    else
        for i in "${!dir_list[@]}"; do
            echo "$((i+1)): ${dir_list[$i]}"
        done
    fi
}

# Update the dir_list variable whenever a command is executed
trap "update_dir_list" DEBUG

function title()
{
    if [ $# -eq 0 ]
        then
        eval set -- "\\u@\\h: \\w"
    fi

    case $TERM in
        xterm*) local title="\[\033]0;$@\007\]";;
        *) local title=''
    esac
    local prompt=$(echo "$PS1" | sed -e 's/\\\[\\033\]0;.*\\007\\\]//')
    PS1="${title}${prompt}"
}

export MY_PASSWORD='Sharkl18vn@firma'
