[ -n "${HHS_USAGE_BASH}" ] && return
:     ${HHS_USAGE_BASH:=1}

function usage__commands #= [CMD]
{
  local i lines src=()
  local -A checked
  
  for (( i = ${#BASH_SOURCE[@]} - 1; 0 <= i; --i )); do
    [ -n "${checked[${BASH_SOURCE[i]}]}" ] && continue
    : ${checked[${BASH_SOURCE[i]}]:=1}
    if cat "${BASH_SOURCE[i]}" | grep -qE "^function +${1:-$CMD}_([^ ]+) *\( *\)"; then
      src+=( "${BASH_SOURCE[i]}" )
    fi
  done
  
  for i in "${src[@]}"; do
    cat "$i" \
    | grep -A1 -nE "^function +${1:-$CMD}_([^ ]+) *\( *\)" \
    | awk '
      match($0, /^[0-9]+:function +'${1:-$CMD}'_([^ ]+) *\( *\) *(# (.*))?/, m) {
        s=s sprintf("  %s %s\n", gensub(/_/, "-", "g", m[1]), m[3]);
      }
      match($0, /^[0-9]+-(# (.*))/, m) {
        s=s sprintf("    %s\n", m[2]);
      }
      END{
        if (s != "") {
          s="Commands:\n" s;
        }
        printf("%s",s);
      }
    '
  done
}

function usage__options #= [CMD]
{
  local i lines src=()
  local -A checked
  
  for (( i = ${#BASH_SOURCE[@]} - 1; 0 <= i; --i )); do
    [ -n "${checked[${BASH_SOURCE[i]}]}" ] && continue
    : ${checked[${BASH_SOURCE[i]}]:=1}
    if cat "${BASH_SOURCE[i]}" | grep -qE "^function +optparse_${1:-$CMD} *\( *\)"; then
      src+=( "${BASH_SOURCE[i]}" )
    fi
  done
  
  for i in "${src[@]}"; do
    readarray -t lines < <(
      cat "$i" \
      | grep -nE "^function +optparse_${1:-$CMD} *\( *\)|^{|^}" \
      | grep -A2 -E "^[0-9]+:function +optparse_${1:-$CMD} +\( *\)" \
      | sed -r -e 's/^([0-9]+).*/\1/g')
    cat "$i" \
    | head -n+$(( lines[2] - 1 )) \
    | tail -n+$(( lines[1] + 1 )) \
    | awk '
      opt == 1 && match($0, /^ *(# (.*))/, m) {
        s=s sprintf("      %s\n", m[2]);
      }
      {opt = 0;}
      match($0, /^ *(-[^)]*)\) *(# ((\[)?(.*)))?/, m) {
        s=s sprintf("  %s%s%s\n", gensub(/\|/, ", ", "g", m[1]), m[3] == "" ? "" : length(m[1]) == 2 ? m[4] == "[" ? m[4] : " " : m[4] "=", m[5]);
        opt = 1;
      }
      END{
        if (s != "") {
          s="Options:\n" s;
        }
        printf("%s",s);
      }
    '
  done
}

function usage_default () #= [CMD]
#   Auto generate default usage from documentation
# Args:
#   CMD : Whole name of subcommand 
{
  local i lines src
  
  for (( i = ${#BASH_SOURCE[@]} - 1; 0 <= i; --i )); do
    if cat "${BASH_SOURCE[i]}" | grep -qE "^function +${1:-$CMD} *\( *\)"; then
      src="${BASH_SOURCE[i]}"
      break
    fi
  done
  
  [ -z "$src" ] && { error "function ${1:-$CMD} is not founded."; exit 1; }
  
  readarray -t lines < <(
    cat "$src" \
    | grep -nE "^function +${1:-$CMD} *\( *\)|^{" \
    | grep -A1 -E "^[0-9]+:function +${1:-$CMD} *\( *\)" \
    | sed -r -e 's/^([0-9]+).*/\1/g')
  cat "$src" \
  | head -n+$(( lines[1] - 1 )) \
  | tail -n+$(( lines[0] )) \
  | sed -r -e 's/^function +([^ ]+)[^#]*(#=? *(.*))?/Usage: \1 \3/g' \
           -e 's/^#\?? (.*)/\1/g'
  
  usage__commands
  usage__options
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
