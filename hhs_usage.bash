[ -n "${HHS_USAGE_BASH}" ] && return
:     ${HHS_USAGE_BASH:=1}



function usage_default () #= [CMD]
#   Auto generate default usage from documentation
# Args:
#   CMD : Whole name of subcommand 
{
  local i lines src

  for (( i = ${#BASH_SOURCE[@]} - 1; 0 <= i; --i )); do
    if cat "${BASH_SOURCE[i]}" | grep -qE "^function +${1:-$CMD} +\( *\)"; then
      src="${BASH_SOURCE[i]}"
      break
    fi
  done
  
  [ -z "$src" ] && { error "function ${1:-$CMD} is not founded."; exit 1; }
  
  readarray -t lines < <(
    cat "$src" \
    | grep -nE "^function +${1:-$CMD} +\( *\)|^{" \
    | grep -A1 -E "^[0-9]+:function +${1:-$CMD} +\( *\)" \
    | sed -r -e 's/^([0-9]+).*/\1/g')
  cat "$src" \
  | head -n+$(( lines[1] - 1 )) \
  | tail -n+$(( lines[0] )) \
  | sed -r -e 's/^function +([^ ]+)[^#]*(#=? *(.*))?/Usage: \1 \3/g' \
           -e 's/^#\?? (.*)/\1/g'
}

function invoke_usage () #= [CMD]
{
  local usage="usage_${1:-${CMD//-/_}}"
  if type "$usage" >&/dev/null; then
    "$usage"
  else
    usage_default "${1:-${CMD//-/_}}"
  fi
}
