###
### Basic configuration
###
setopt autocd extendedglob notify
bindkey -v

autoload colors zsh/terminfo
colors


###
### Key bindings
###
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line
bindkey "\e[5~" beginning-of-history
bindkey "\e[6~" end-of-history
bindkey "\e[3~" delete-char
bindkey "\e[2~" quoted-insert
bindkey "\e[5C" forward-word
bindkey "\eOc" emacs-forward-word
bindkey "\e[5D" backward-word
bindkey "\eOd" emacs-backward-word
bindkey "\e\e[C" forward-word
bindkey "\e\e[D" backward-word
# for rxvt
bindkey "\e[8~" end-of-line
bindkey "\e[7~" beginning-of-line
# for non RH/Debian xterm, can't hurt for RH/DEbian xterm
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line
# for freebsd console
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line
# for my own custom needs
bindkey "^a" beginning-of-line
bindkey "^e" end-of-line
# completion in the middle of a line
bindkey '^i' expand-or-complete-prefix


###
### Completion
###
zstyle :compinstall filename '/home/martin/.zshrc'

autoload -Uz compinit
compinit

# For gentoo
if [ -e /etc/gentoo-release ]; then
	autoload -U compinit promptinit
	compinit
	promptinit; prompt gentoo
fi

# allow approximate
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# tab completion for PID
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always

# cd not select parent dir. 
zstyle ':completion:*:cd:*' ignore-parents parent pwd


###
### History
###
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000


###
### Prompt
###
precmd() {
	# ripped from /etc/bash_completion.d/git from the git devs
	git_ps1() {
		if which git > /dev/null; then
			local g="$(git rev-parse --git-dir 2>/dev/null)"
			if [ -n "$g" ]; then
				local r
				local b
				if [ -d "$g/rebase-apply" ]; then
					if test -f "$g/rebase-apply/rebasing"; then
						r="|REBASE"
					elif test -f "$g/rebase-apply/applying"; then
						r="|AM"
					else
						r="|AM/REBASE"
					fi
					b="$(git symbolic-ref HEAD 2>/dev/null)"
				elif [ -f "$g/rebase-merge/interactive" ]; then
					r="|REBASE-i"
					b="$(cat "$g/rebase-merge/head-name")"
				elif [ -d "$g/rebase-merge" ]; then
					r="|REBASE-m"
					b="$(cat "$g/rebase-merge/head-name")"
				elif [ -f "$g/MERGE_HEAD" ]; then
					r="|MERGING"
					b="$(git symbolic-ref HEAD 2>/dev/null)"
				else
					if [ -f "$g/BISECT_LOG" ]; then
						r="|BISECTING"
					fi
					if ! b="$(git symbolic-ref HEAD 2>/dev/null)"; then
						if ! b="$(git describe --exact-match HEAD 2>/dev/null)"; then
							b="$(cut -c1-7 "$g/HEAD")..."
						fi
					fi
				fi
				if [ -n "$1" ]; then
					printf "$1" "${b##refs/heads/}$r"
				else
					printf "%s" "${b##refs/heads/}$r"
				fi
			fi
		else
			printf ""
		fi
	}

	if [ -n "$(git_ps1)" ]; then
		GITBRANCH="${PR_BRIGHT_GREEN}G:$(git_ps1) ${PR_RESET}"
	else
		GITBRANCH=""
	fi

	if [ `pwd` = $HOME ]; then
		GITBRANCH=""
	fi


	# The following 9 lines of code comes directly from Phil!'s ZSH prompt
	# http://aperiodic.net/phil/prompt
	local TERMWIDTH
	(( TERMWIDTH = ${COLUMNS} - 1 ))

	local PROMPTSIZE=${#${(%):--- %D{%R.%S %a %b %d %Y}\! ---}}
	local PWDSIZE=${#${(%):-%~}}

	if [[ "$PROMPTSIZE + $PWDSIZE" -gt $TERMWIDTH ]]; then
		(( PR_PWDLEN = $TERMWIDTH - $PROMPTSIZE ))
	fi

	# check if jobs are executing
	if [[ $(jobs | wc -l) -gt 0 ]]; then
		JOBS="${PR_BRIGHT_MAGENTA}J:%j ${PR_RESET}"
	else
		JOBS=""
	fi

	# find battery percentage
	if which ibam &> /dev/null; then
		BATTSTATE="$(ibam --percentbattery)"
		BATTPRCNT="${BATTSTATE[(f)1][(w)-2]}"
		BATTTIME="${BATTSTATE[(f)2][(w)-1]}"
		PR_BATTERY="B:${BATTPRCNT}%% (${BATTTIME}) "
		if [[ "${BATTPRCNT}" -lt 15 ]]; then
			PR_BATTERY="$PR_BRIGHT_RED$PR_BATTERY"
		elif [[ "${BATTPRCNT}" -lt 50 ]]; then
			PR_BATTERY="$PR_BRIGHT_YELLOW$PR_BATTERY"
		elif [[ "${BATTPRCNT}" -lt 75 ]]; then
			PR_BATTERY="$PR_RESET$PR_BATTERY"
		elif [[ "${BATTPRCNT}" -gt 76 ]]; then
			PR_BATTERY=""
		fi
	else
		PR_BATTERY=""
	fi

	case $TERM in
		screen)
			print -Pn "\e]2;%n@%m: %~\a"
			print -Pn "\ek%n@%m: %~\e\\"
			;;
		xterm*|rxvt*)
			print -Pn "\e]2;%n@%m: %~\a"
	esac
}

function preexec() {
	case $TERM in
		screen)
			print -Pn "\e]2;%n@%m: $1\a"
			print -Pn "\ek%n@%m: $1\e\\"
			;;
		xterm*|rxvt*)
			print -Pn "\e]2;%n@%m: $1\a"
	esac
	print -Pn "$terminfo[sgr0]"
}

setprompt() {
	setopt prompt_subst

	for COLOR in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE BLACK; do
		eval PR_$COLOR='%{$fg[${(L)COLOR}]%}'
		eval PR_BRIGHT_$COLOR='%{$fg_bold[${(L)COLOR}]%}'
	done

	PR_RESET="%{$reset_color%}"

	PROMPT='\
${PR_BATTERY}${JOBS}${GITBRANCH}\
%(!.${PR_BRIGHT_RED}%%.${PR_BRIGHT_BLUE}%%)${PR_RESET} '
	RPROMPT='${PR_BRIGHT_GREEN}%30<..<%~${PR_RESET}%(?.. ${PR_BRIGHT_RED}[%?]${PR_RESET})'
}

setprompt

###
### Environment
###
export TZ="America/New_York"
export LANG="en_US.UTF-8"
export PATH="$HOME/Bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
if which vim &> /dev/null; then
	export EDITOR="vim"
else
	export EDITOR="vi"
fi
if which most &> /dev/null; then
	export PAGER="most"
else
	export PAGER="less"
fi
export BROWSER="firefox"
export GREP_COLOR="1;33"

# Aliases
alias ls='ls -h'
alias ll='ls -l'
alias la='ls -a'
alias vi='vim'

if [ `ls --version |& head -n1 | cut -c 5-7` = "GNU" ]
then
	alias ls='ls --color=auto'
fi

if [ `grep --version | head -n1 | cut -c 1-3` = "GNU" ]
then
	alias grep='grep --color=auto'
else if [ `grep --version | head -n1 | cut -c 7-10` = "GNU" ]
	alias grep='grep --color=auto'
fi
