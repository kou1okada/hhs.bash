#!/usr/bin/env bash
#
# hhs.bash - Happy hacking script for bash
# Copyright (c) 2018 Koichi OKADA. All rights reserved.
# This script is destributed under the MIT license.
#

(( 5 <= DEBUG )) && set -x

HHS_VERSION=0.1.0
HHS_VERSION_COMPATIBILITY=0.1.0

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

if [ "$SCRIPT_FILE" = "$HHS_REALFILE" ]; then
  hhsinc main
  hhs "$@"
else
  [ -z "$HHS_NOT_ALL" ] && hhsinc all
fi
