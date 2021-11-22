#!/bin/bash
# ------------------------------------------------------------------------------
# FILE: autossh
# DESCRIPTION: This is an SSH-D proxy with auto-reconnect on disconnect
# AUTHOR: royalgarter
# ORIGINAL AUTHOR: Hector Nguyen (hectornguyen at octopius dot com)
# VERSION: 1.0.1
# ------------------------------------------------------------------------------
ARGS=$@
VERSION="1.0.0"
GITHUB="https://github.com/royalgarter/autossh"
AUTHOR="Hector Nguyen"
SCRIPT=${0##*/}
IFS=$'\n'
ALIVE=0
# HISTFILE="$HOME/.autossh.history"

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

# Progress or something
start_progress() {
	while true
	do
		echo -ne "#"
		sleep 1
	done
}

quick_progress() {
	while true
	do
		echo -ne "#"
		sleep .033
	done
}

long_progress() {
	while true
	do
		echo -ne "#"
		sleep 3
	done
}

dot_progress() {
	for i in {1..3}; do
		printf "." $i -1 $i
		sleep .33
	done
	echo_c green " 100%{$NORMAL}"
	sleep 1
}

stop_progress() {
	kill $1
	wait $1 2>/dev/null
	echo -en "\n"
}

# Case-insensitive for regex matching
shopt -s nocasematch

# Prepare history mode
set -i
history -c
history -r

# Input method
get_input() {
	read -e -p "${BLUE}$1${NORMAL}" "$2"
	history -s "${!2}"
}

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

# Get data from parameters
if [[ ! -n "$remote_param" && -n "$1" ]]; then
		remote_param="$1"
		remote_user="${remote_param%%@*}"
		remote_ip="${remote_param##*@}"
fi

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
		exist=`ps aux | grep "$remote_user@$remote_ip" | grep 22`
		if test -n "$exist"
		then
			if test $ALIVE -eq 0
			then
				echo_c yellow "Connection alive since $(date)"
			fi
			ALIVE=1
		else
			ALIVE=0
			echo_c red "Reconnecting ..."
			clear
			printf "${GREEN}Connecting: "
			dot_progress
			clear
			echo ">ssh ${ARGS[@]}"
			ssh "${ARGS[@]}"
		fi
		sleep 1
	done
}

main() {
	# save_input
	auto_connect
}

main
