[ -n "${HHS_USAGE_BASH}" ] && return
:     ${HHS_USAGE_BASH:=1}

hhsinc utils
hhsinc function



function usage__commands #= [CMD]
{
  local PAT_FUNC_CMD_SUB="function +${1:-$CMD}_([^ ]+) *\( *\)"
  local lines src srcs
  
  readarray -t srcs < <(grep -lE "$PAT_FUNC_CMD_SUB" "${BASH_SOURCE[@]}" | tac | uniqex)
  
  for src in "${srcs[@]}"; do
    cat "$src" \
    | grep -A1 -nE "^$PAT_FUNC_CMD_SUB" \
    | awk '
      match($0, /^[0-9]+:'"$PAT_FUNC_CMD_SUB"' *(# (.*))?/, m) {
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
  local PAT_FUNC_OPTPARSE_CMD="function +optparse_${1:-$CMD} *\( *\)"
  local lines src srcs
  
  readarray -t srcs < <(grep -lE "$PAT_FUNC_OPTPARSE_CMD" "${BASH_SOURCE[@]}" | tac | uniqex)
  
  for src in "${srcs[@]}"; do
    readarray -t lines < <(function_get_lines "$PAT_FUNC_OPTPARSE_CMD" "$src")
    cat "$src" \
    | headtail $(( lines[1] + 1 )) $(( lines[2] - 1 )) \
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
  local PAT_FUNC_CMD="function +${1:-$CMD} *\( *\)"
  local lines src srcs
  
  readarray -t srcs < <(grep -lE "$PAT_FUNC_CMD" "${BASH_SOURCE[@]}" | tac | uniqex)
  [ -z "$srcs" ] && { error "function ${1:-$CMD} is not founded."; exit 1; }

  src="$srcs"
  readarray -t lines < <(function_get_lines "$PAT_FUNC_CMD" "$src")
  cat "$src" \
  | headtail $(( lines[0] )) $(( lines[1] - 1 )) \
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
