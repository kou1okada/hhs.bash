[ -n "${HHS_COMMAND_BASH}" ] && return
:     ${HHS_COMMAND_BASH:=1}

hhsinc optparse
hhsinc usage



function invoke_command () #= [ARGS ...]
#   Invoke subcommand
# Args:
#   CMD    : Name of parent command
#   ARGS   : Arguments for subcommand
{
  local ARGS CMD="${CMD:-${SCRIPT_NAME}}" OPTS cmdtype
  local -n has_subcommand="has_subcommand_${CMD//-/_}"
  unset BASECMD
  
  [ "$(type -t init)" = "function" ] && init
  [ "$(type -t "init_${CMD//-/_}")" = "function" ] && "init_${CMD//-/_}"
  
  if   [ "$(type -t "${CMD//-/_}")" = "function" ]; then
    CMD="${CMD//-/_}"
    cmdtype=function
  elif [ "$(type -t "${CMD//_/-}")" = "file" ]; then
    CMD="${CMD//_/-}"
    cmdtype=file
  elif [ -n "$has_subcommand" ]; then
    debug "Command not found, but has subcommand: $CMD"
  else
    error "Command not found: $CMD"
    exit 1
  fi
  
  if [ "$cmdtype" = "function" ]; then
    optparse "$@"
    set -- "${ARGS[@]}"
    
    [ -n "$OPT_HELP" ] && { invoke_usage; exit; }
  fi
  
  if [ -n "$has_subcommand" ]; then
    (( $# <= 0 )) && { invoke_usage; exit; }
    CMD="${CMD}_$1"
    invoke_command "${@:2}"
  else
    [ -n "$OPT_HELP" ] && { invoke_usage; exit; }
    "$CMD" "$@"
  fi
}
