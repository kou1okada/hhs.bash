[ -n "${HHS_SHOPT_BASH}" ] && return
:     ${HHS_SHOPT_BASH:=1}

hhsinc debug



function shopt_push () #= [-s|-u] OPTNAME
#   Change the setting of a shell option OPTNAME and save previous state.
#   Saved previous state will be restored by shopt_pop.
# Option:
#   -s  enable (set) OPTNAME
#   -u  disable (unset) OPTNAME
# Args:
#   OPTNAME : see shopt
{
  (( $# == 2 )) || { error "shopt_push was passed wrong number of arguments." ; abort 1; }
  SHOPT_STACK+=( "$(shopt -p "$2">/dev/null)" ); [ -n "${SHOPT_STACK[-1]}" ] && { fatal "Command failed: shopt -p ${2}"; abort 1; }
  case "$1" in
    -s|-u) ;;
    *)
      fatal "Unknown state: $2"
      dump_callstack
      exit 1
  esac
  shopt "$@">/dev/null || { fatal "Command failed: shopt ${@}"; abort 1; }
}

function shopt_pop
#   Recover the setting of a shell option that saved with shopt_push.
{
  ${SHOPT_STACK[-1]} || { fatal "Command failed: ${SHOPT_STACK[-1]}"; abort 1; }
  unset SHOPT_STACK[-1]
}
