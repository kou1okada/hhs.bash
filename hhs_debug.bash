[ -n "${HHS_DEBUG_BASH}" ] && return
:     ${HHS_DEBUG_BASH:=1}



THRESHOLD_OF_FATAL=0
THRESHOLD_OF_ERROR=1
THRESHOLD_OF_WARNING=3
THRESHOLD_OF_INFO=4
THRESHOLD_OF_DEBUG=4

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
  echo -e "${DEBUG_COLOR}at :${SGR_reset} ${BASH_SOURCE[i-1]}: ${FUNCNAME[i]}: ${BASH_LINENO[i-1]}"
}

function fatal () #= [MESSAGES ...]
{
  (( THRESHOLD_OF_FATAL <= ${VERBOSE:-0} )) || return 1
  echo -e "${FATAL_COLOR}Fatal:${SGR_reset} $@"
  (( THRESHOLD_OF_FATAL <= SOURCE_AT )) && source_at 2
} >&2 #/fatal

function error () #= [MESSAGES ...]
{
  (( THRESHOLD_OF_ERROR <= ${VERBOSE:-0} )) || return 1
  echo -e "${ERROR_COLOR}Error:${SGR_reset} $@"
  (( THRESHOLD_OF_ERROR <= SOURCE_AT )) && source_at 2
} >&2 #/error

function warning () #= [MESSAGES ...]
{
  (( THRESHOLD_OF_WARNING <= ${VERBOSE:-0} )) || return 1
  echo -e "${WARNING_COLOR}Warning:${SGR_reset} $@"
  (( THRESHOLD_OF_WARNIGN <= SOURCE_AT )) && source_at 2
} >&2 #/warning

function info () #= [MESSAGES ...]
{
  (( THRESHOLD_OF_INFO <= ${VERBOSE:-0} )) || return 1
  echo -e "${INFO_COLOR}Info:${SGR_reset} $@"
  (( THRESHOLD_OF_INFO <= SOURCE_AT )) && source_at 2
} >&2 #/info

function debug () #= [MESSAGES ...]
{
  (( THRESHOLD_OF_DEBUG <= ${VERBOSE:-0} )) || return 1
  echo -e "${DEBUG_COLOR}Debug:${SGR_reset} $@"
  (( THRESHOLD_OF_DEBUG <= SOURCE_AT )) && source_at 2
} >&2 #/debug
