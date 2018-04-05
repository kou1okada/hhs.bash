[ -n "${HHS_OPTPARSE_BASH}" ] && return
:     ${HHS_OPTPARSE_BASH:=1}

hhsinc shopt



function optshift () #= [SHIFT=1]
{
  _ARGS=( "${_ARGS[@]:${1:-1}}" )
}

function optcommit () #= [ARGS ...]
{
  if (( _SHIFT <= _PARAM )); then
    error "Parameter was not used: "
  fi
  _ARGS=( "$@" )
}

shopt_push -s extglob

function optprepare ()
{
  _PARAM=0
  _LONG=
  _SHORT=
  _SHIFT=
  _OPTIONAL=
  shopt_push -s extglob
  case "$1" in
    --+(!(=))=*)
      _PARAM=1
      _LONG=1
      set -- "${1%%=*}" "${1#*=}" "${@:2}"
      ;;
    -[^-]?*)
      _PARAM=1
      _SHORT=1
      set -- "${1::2}" "${1:2}" "${@:2}"
      ;;
  esac
  shopt_pop
  _ARGS=( "$@" )
}

shopt_pop

function nparams () #= [N=0 [OPTIONAL]]
#   Set number of parameters.
# Args:
#   N        : number of parameters
#   OPTIONAL : non-empty value means parameter is optional
# Notes:
#   Optional parameter has style as -c[WHEN] or --color[=WHEN].
#   ex) -cauto or --color=auto
#   In this case, auto is optional parameter.
#   If optional parameter dosed not passed to option,
#   like -c or --color,
#   option uses value which passed optset as default.
{
  local n="${1:-0}"
  _OPTIONAL="$2"
  
  if [ -n "$_SHIFT" ]; then
    fatal "nparams called multiple times."
    abort
  fi
  
  if [ -n "$2" ]; then
    # Parameter is optional
    
    if (( $1 != 1 )); then
      fatal "Optional parameter must be only one."
      abort
    fi
    
    # Optional parameter dis not passed to option.
    [ -z "$_SHORT" -a -z "$_LONG" ] && n=0
  else
    # Parameter is non-optional
    
    # Short option with parameter like -cauto
    if [ -n "$_SHORT" ] && (( $1 < _PARAM )); then
      _ARGS=( "${_ARGS[@]:0:1}" "-${_ARGS[@]:1:1}" "${_ARGS[@]:2}" )
    fi
    
    # Long option with parameter like --color=auto
    if [ -n "$_LONG" ] && (( $1 < _PARAM )); then
      warning "Unexpected parameter: '${_ARGS[0]}' declares non-parameter option: ${_ARGS0[0]}"
    fi
  fi
  
  _SHIFT=$(( n + 1 ))
}

function optset () #= NAME [VALUE]
{
  local -n opt="OPT_$1"
  if [ -n "$_OPTIONAL" ] && [ -n "$_SHORT" -o -n "$_LONG" ]; then
    opt
  else
    opt="$2"
  fi
}

function optunset () #= NAME
{
  unset "OPT_$1"
}

function set_optparser () #= [PARSERS ...]
{
  local parser
  _PARSER=()
  for parser; do
    [ "$(type -t "$parser")" = "function" ] && _PARSER+=( "$parser" )
  done
}

function init_optperser ()
{
  local parser="optparse_$CMD"
  _PARSER=()
  while [ "$parser" != "optparse" -a -n "$parser" ]; do
    _PARSER+=( "$parser" )
    parser="${parser%_*}"
  done
  set_optparser "${_PARSER[@]}" optparse__default optparse__common
}

function optparse ()
{
  local _ARGS _ARGS0 _LONG _OPTIONAL _PARAM _PARSER _SHIFT _SHORT parser
  init_optperser
  
  while (( 0 < $# )); do
    _ARGS0=( "$@" )
    optprepare "$@"
    set -- "${_ARGS[@]}"
    
    for parser in "${_PARSER[@]}"; do
      "$parser" "$@" && break
    done
    
    if [ -z "${_SHIFT}" ]; then
      if [ "{1:0:1}" = "-" ]; then
        fatal "Maybe nparams is not called or case foget return 1 at \*) in optparse_${CMD}: $1"
      else
        fatal "Maybe case foget return 1 at \*) in optparse_${CMD}: $1"
      fi
      : "${_SHIFT:=1}"
    fi
    
    set -- "${_ARGS[@]:_SHIFT}"
  done
}

function optparse__common ()
{
  case "$1" in
    --)
      ARGS=( "$@" )
      NO_MORE_OPTS=1
      _SHIFT=$#
      ;;
    -*)
      error "Unknown option: $1"
      exit 1
      ;;
    *)
      if [ -z "$has_subcommand" ]; then
        ARGS+=( "$1" )
        _SHIFT=1
      else
        ARGS+=( "$@" )
        _SHIFT=$#
      fi
      ;;
  esac
}

function optparse__default ()
{
  case "$1" in
    -h|--help) nparams 0
      optset HELP "$1"
      ;;
    -v|--verbose) nparams 0
      optset VERBOSE "$1"
      ;;
    -V|--version) nparams 0
      optset VERSION "$1"
      ;;
    *)
      return 1
      ;;
  esac
}
