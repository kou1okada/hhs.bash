#!/usr/bin/env bash
#
# hhs.bash - Happy hacking script for bash
# Copyright (c) 2018 Koichi OKADA. All rights reserved.
# This script is destributed under the MIT license.
#

(( 5 <= DEBUG )) && {
  PS4='+ \e[1;35m\t\e[0m \e[1;4m${BASH_SOURCE}\e[0m: ${LINENO}: ${FUNCNAME:+[${#FUNCNAME[@]}] \e[1;4m$FUNCNAME\e[0m (): }\n'
  set -x
}

HHS_VERSION=0.2.0
HHS_VERSION_COMPATIBILITY=0.1.0

HHS_VERSIONS_DIR="${HOME}/.config/hhs/versions"

HHS_PATH="$BASH_SOURCE"
HHS_FILE="${HHS_PATH##*/}"
HHS_NAME="${HHS_FILE%.*}"
HHS_DIR="${HHS_PATH%/*}"
HHS_REALPATH="$(readlink -f "$HHS_PATH")"
HHS_REALFILE="${HHS_REALPATH##*/}"
HHS_REALNAME="${HHS_REALFILE%.*}"
HHS_REALDIR="${HHS_REALPATH%/*}"

SCRIPT_PATH="$0"
SCRIPT_FILE="${SCRIPT_PATH##*/}"
SCRIPT_NAME="${SCRIPT_FILE%.*}"
SCRIPT_DIR="${SCRIPT_PATH%/*}"
SCRIPT_REALPATH="$(readlink -f "$SCRIPT_PATH")"
SCRIPT_REALFILE="${SCRIPT_REALPATH##*/}"
SCRIPT_REALNAME="${SCRIPT_REALFILE%.*}"
SCRIPT_REALDIR="${SCRIPT_REALPATH%/*}"

function hhsinc () #= FILE
{
  local -n include_guard="HHS_${1^^}_BASH"
  [ -n "$include_guard" ] && return
  source "${HHS_REALDIR%%/}/hhs_${1}.bash"
  include_guard=1
}

if (( 2 == ${#BASH_SOURCE[@]} )) && [[ "$1" != "$HHS_VERSION" ]]; then
  # Fallback to target versions.
  hhsinc target_version
  prepare_target_version "$1"
  source "${HHS_VERSIONS_DIR}/v$1/hhs.bash"
elif [ "$SCRIPT_FILE" = "$HHS_REALFILE" ]; then
  hhsinc main
  hhs "$@"
else
  [ -z "$HHS_NOT_ALL" ] && hhsinc all
fi
