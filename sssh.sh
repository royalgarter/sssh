#!/bin/bash
# ------------------------------------------------------------------------------
# FILE: sssh
# DESCRIPTION: This is an SSH-D proxy to screen with auto-reconnect on disconnect
# AUTHOR: royalgarter
# ORIGINAL AUTHOR: Hector Nguyen (hectornguyen at octopius dot com)
# VERSION: 2.0.1
# ------------------------------------------------------------------------------
ARGS=$@

VERSION="2.0.1"
GITHUB="https://github.com/royalgarter/sssh"
AUTHOR="royalgarter (inspired by Hector Nguyen)"
SCRIPT=${0##*/}
IFS=$'\n'
ALIVE=0
HISTFILE="$HOME/.sssh.history"

# Build session name for screen
SESSION=${COMPUTERNAME:-ssh} # Window
SESSION=${NAME:-$SESSION} # Linux / MacOS
SESSION="sssh-${SESSION}" # Build name
# SESSION="${SESSION//[^a-zA-Z0-9]/}" # Remove weird characters
SESSION="${SESSION,,}" # Lowercase

# Get data from parameters
if [[ ! -n "$remote_param" && -n "$1" ]]; then
	remote_param="$1"

	arr=($(echo "$remote_param" | grep -oP "([^@]+)"));
	if [ "${#arr[@]}" = 2 ]; then
		remote_user=${arr[0]}
	else
		remote_user="root"
	fi

	remote_ip=${arr[-1]}
fi

PARAMS="${ARGS[@]}"
ARGS_STR="${ARGS// /|}"
if [[ $ARGS_STR != *" -q "* ]]; then PARAMS="-q $PARAMS"; fi
if [[ $ARGS_STR != *" -t "* ]]; then PARAMS="-t $PARAMS"; fi
if [[ $ARGS_STR != *"screen "* ]]; then	PARAMS="$PARAMS \"screen -R $SESSION\""; fi

# Use colors, but only if connected to a terminal, and that terminal supports them.
if which tput >/dev/null 2>&1; then
	ncolors=$(tput colors)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
	RED="$(tput setaf 1)"
	GREEN="$(tput setaf 2)"
	YELLOW="$(tput setaf 3)"
	BLUE="$(tput setaf 4)"
	BOLD="$(tput bold)"
	NORMAL="$(tput sgr0)"
else
	RED=""
	GREEN=""
	YELLOW=""
	BLUE=""
	BOLD=""
	NORMAL=""
fi

# Case-insensitive for regex matching
shopt -s nocasematch

# Prepare history mode
# set -i
history -c
history -r

# Echo in bold
echo_b() {
	if [ "$1" = "-e" ]; then
		echo -e "${BOLD}$2${NORMAL}"
	else
		echo "${BOLD}$1${NORMAL}"
	fi
}

# Echo in colour
echo_c() {
	case "$1" in
		red | r | -red | -r | --red | --r ) echo "${RED}$2${NORMAL}" ;;
		green | g | -green | -g | --green | --g ) echo "${GREEN}$2${NORMAL}" ;;
		blue | b | -blue | -b | --blue | --b ) echo "${BLUE}$2${NORMAL}" ;;
		yellow | y | -yellow | -y | --yellow | --y ) echo "${YELLOW}$2${NORMAL}" ;;
		* ) echo "$(BOLD)$2$(RESET)" ;;
	esac
}

# Input method
get_input() {
	read -e -p "${BLUE}$1${NORMAL}" "$2"
	history -s "${!2}"
}

# Get input data and save to history
save_input() {
	if [[ ! -n "$remote_user" && ! -n "$1" ]]; then
		while get_input "SSH Username > " remote_user; do
			case ${remote_user%% *} in
				* )
						if [ -n "$remote_user" ]; then
							break
						else
							continue
						fi
				;;
			esac
		done
	fi
	if [[ ! -n "$remote_ip" && ! -n "$1" ]]; then
		while get_input "SSH Alias/IP-address > " remote_ip; do
			case ${remote_ip%% *} in
				* )
						if [ -n "$remote_ip" ]; then
							break
						else
							continue
						fi
				;;
			esac
		done
	fi
}

# Infinitie loop to keep connecting
auto_connect() {
	while true; do
		exist=`ps aux | grep "$remote_ip" | grep 22`
		if test -n "$exist"; then
			if test $ALIVE -eq 0; then
				echo_c yellow "Connection alive since $(date)"
			fi
			ALIVE=1
		else
			ALIVE=0
			echo_c red "Reconnecting ..."
			clear
			
			echo_b ">>> ssh $PARAMS"
			echo_b "    EXIT by Screen-Detach then Terminal-Kill: Ctrl-a Ctrl-d Ctrl-c"

			printf "${GREEN}Connecting: "
			for i in {1..3}; do
				printf "." $i -1 $i
				sleep .33
			done
			echo_c green " 100%{$NORMAL}"
			sleep 1
			clear
			
			eval ssh $PARAMS
		fi
		sleep 1
	done
}

main() {
	# exit 1
	save_input
	auto_connect
}

main
