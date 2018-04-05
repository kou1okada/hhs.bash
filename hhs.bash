#!/usr/bin/env bash
#
# hhs.bash - Happy hacking script for bash
# Copyright (c) 2018 Koichi OKADA. All rights reserved.
# This script is destributed under the MIT license.
#

(( 5 <= DEBUG )) && set -x

HHS_VERSION=0.0.1
HHS_VERSION_COMPATIBILITY=0.0.1
HHS_DIR="$(dirname "$(realpath "$BASH_SOURCE")")"

function hhsinc () #= FILE
{
  local -n include_guard="HHS_${1^^}_BASH"
  [ -n "$include_guard" ] && return
  source "${HHS_DIR%%/}/hhs_${1}.bash"
  include_guard=1
}

[ -z "$HHS_NOT_ALL" ] && hhsinc all
