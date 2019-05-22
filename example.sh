#!/bin/bash

# This is example of shell script.
#
# Formated by shfmt. https://github.com/mvdan/sh/cmd/shfmt
# Documentation formated by shdoc. https://github.com/essentialkaos/shdoc

################################################################################

# hogehoge
hoge() {
	if [ "$1" = "describe" ]; then
		echo -e "\t${FUNCNAME}: Print 'hoge'."
		return
	fi

	echo hoge
}

fuga() {
	if [ "$1" = "describe" ]; then
		echo -e "\t${FUNCNAME}: Print 'fuga'."
		return
	fi

	echo fuga
}

piyo() {
	if [ "$1" = "describe" ]; then
		echo -e "\t${FUNCNAME}: Print 'piyo'."
		return
	fi

	echo piyo
}

show_function_list() {
	if [ "$1" = "describe" ]; then
		echo -e "\t${FUNCNAME}: Show function list in $(basename $0)."
		return
	fi

	echo "FunctionList:"

	echo "$functionList" | while read f; do
		"$f" "describe"
	done

	exit 0
}

usage_exit() {
	if [ "$1" = "describe" ]; then
		echo -e "\t${FUNCNAME}: Show this message and function list in $(basename $0)."
		return
	fi

	echo "Usage: $(basename $0) [-h] [-f <function>]"

	echo ""
	echo -e "\tIf no options, execute all function except usage_exit and show_function_list."
	echo ""

	echo "Options:"

	echo -e "\tf: Execute <function>."
	echo -e "\tl: Show function list."
	echo -e "\th: Show this message."

	echo ""

	show_function_list

	exit 1
}

functionList=$(typeset -F | grep '^declare -f' | cut -d ' ' -f 3-)

error() {
	TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
	PID="$$"
	SCRIPT=$(basename "$0")
	ERRORMSG="$@"

	echo "$ERRORMSG" | while read line; do
		echo "$TIMESTAMP [$SCRIPT] [$PID] $line" >&2
	done
}

abort() {
	error "$@"
	exit 1
}

while getopts f:lh OPT; do
	case $OPT in
	f)
		FUNCTION="$OPTARG"
		echo "$functionList" | grep "^${FUNCTION}$" >/dev/null &&
			"$FUNCTION" ||
			abort "No such function."

		exit 0
		;;
	l)
		show_function_list
		;;
	h)
		usage_exit
		;;
	*)
		usage_exit
		;;
	esac
done

shift $((OPTIND - 1))

main() {
	## Execute all function.
	echo "$functionList" | grep -v -e "^usage_exit$" -e "^show_function_list$" | while read f; do
		"$f"
	done
}

main
