[ -n "${HHS_DEBUG_BASH}" ] && return
:     ${HHS_DEBUG_BASH:=1}



FATAL=0
ERROR=1
WARNING=3
INFO=4
DEBUG=4

function abort () #= [EXITCODE=1 [CALLSTACKSKIP=0]]
{
  dump_callstack $(( 2 + ${2:-0} ))
  exit "${1:-1}"
}

function dump_callstack () #= [N=1]
#? N is a depth to skip the callstack.
#? $CALLSTACK_SKIP is depth to skip the callstack too.
#? N and CALLSTACK_SKIP is summed before skipping.
#? The default value is N = 1 and CALLSTACK_SKIP = 0.
{
  local i
  echo "Callstack:"
  for i in `seq "$(( ${#FUNCNAME[@]} - 1 ))" -1 $(( ${1:-1} + ${CALLSTACK_SKIP:-0} ))`; do
    echo -e "\t${BASH_SOURCE[i]}: ${FUNCNAME[i]}: ${BASH_LINENO[i-1]}"
  done
} #/dump_callstack

function source_at () #= [N=1]
{
  local i=${1:-1}
  echo -e "${DEBUG_COLOR}at :${SGR_reset} ${BASH_SOURCE[0]}: ${FUNCNAME[i]}: ${BASH_LINENO[i-1]}"
}

function fatal () #= [MESSAGES ...]
{
  (( FATAL <= ${VERBOSE:-0} )) || return 1
  echo -e "${FATAL_COLOR}Fatal:${SGR_reset} $@"
  (( FATAL <= SOURCE_AT )) && source_at 2
} >&2 #/fatal

function error () #= [MESSAGES ...]
{
  (( ERROR <= ${VERBOSE:-0} )) || return 1
  echo -e "${ERROR_COLOR}Error:${SGR_reset} $@"
  (( ERROR <= SOURCE_AT )) && source_at 2
} >&2 #/error

function warning () #= [MESSAGES ...]
{
  (( WARNING <= ${VERBOSE:-0} )) || return 1
  echo -e "${WARNING_COLOR}Warning:${SGR_reset} $@"
  (( WARNIGN <= SOURCE_AT )) && source_at 2
} >&2 #/warning

function info () #= [MESSAGES ...]
{
  (( INFO <= ${VERBOSE:-0} )) || return 1
  echo -e "${INFO_COLOR}Info:${SGR_reset} $@"
  (( INFO <= SOURCE_AT )) && source_at 2
} >&2 #/info

function debug () #= [MESSAGES ...]
{
  (( DEBUG <= ${VERBOSE:0} )) || return 1
  echo -e "${DEBUG_COLOR}Debug:${SGR_reset} $@"
  (( DEBUG <= SOURCE_AT )) && source_at 2
} >&2 #/debug
