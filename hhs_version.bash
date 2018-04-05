[ -n "${HHS_VERSION_BASH}" ] && return
:     ${HHS_VERSION_BASH:=1}

hhsinc debug



function ver_eq () #= V1 V2
#   Version V1 is less then or equal to V2.
{
  [ "$1" = "$2" ]
}

function ver_ge () #= V1 V2
#   Version V1 is greater or equal then V2.
{
  local s
  readarray -t s < <(echo -e "${1}\n${2}" | sort -V)
  [ "$s" = "$2" ]
}

function ver_gt () #= V1 V2
#   Version V1 is greater then V2.
{
  local s
  readarray -t s < <(echo -e "${1}\n${2}" | sort -V)
  [ "$s" = "$2" -a "$1" != "$2" ]
}

function ver_le () #= V1 V2
#   Version V1 is less then or equal to V2.
{
  local s
  readarray -t s < <(echo -e "${1}\n${2}" | sort -V)
  [ "$s" = "$1" ]
}

function ver_lt () #= V1 V2
#   Version V1 is less then V2.
{
  local s
  readarray -t s < <(echo -e "${1}\n${2}" | sort -V)
  [ "$s" = "$1" -a "$1" != "$2" ]
}

function ver_nq () #= V1 V2
#   Version V1 is not equal to V2.
{
  [ "$1" != "$2" ]
}



function hhs_minimum_required () #= FEATURE VALUE [QUIT]
# Args:
#   FEATURE : feature name.
#   VALUE   : required minimum value of feature
#   QUIT    : return or abort. default is abort.
{
  local -n feature="HHS_$1"
  local quit="${3:-abort}"
  [ -n "$feature" ] || { fatal "Feature was not found: $1"; abort 1; }
  ver_le "$2" "$feature" || { fatal "required ${!feature} >= $2, but ${!feature} = $feature"; $quit 1; }
}

function hhs_maximum_required () #= FEATURE VALUE [QUIT]
#   FEATURE : feature name.
#   VALUE   : required maximum value of feature.
#   QUIT    : return or abort. default is abort.
{
  local -n feature="HHS_$1"
  local state
  local quit="${3:-abort}"
  [ -n "$feature" ] || { fatal "Feature was not found: $1"; abort 1; }
  ver_ge "$2" "$feature" ] || { fatal "required ${!feature} <= $2, but ${!feature} = $feature"; $quit 1; }
}

function hhs_compatibility_check () #= FEATURE VALUE
{
  local -n feature="HHS_${1^^}"
  local -n compatibility="HHS_${1^^}_COMPATIBILITY"
  
  [ -z "$feature"       ] && { fatal "Feature was not found: $1"; abort 1; }
  [ -z "$compatibility" ] && { fatal "Compatibility was not found: $1"; abort 1; }
  
  if ver_lt "$2" "$compatibility" && [ -z "$INHIBIT_COMPATIBILITY_ALERT" ]; then
    fatal "hhs changed specification at $1 $compatibility.\n" \
          " But your script is written for hhs $1 $2.\n" \
          " Please update your script: ${0}"
    abort 1
  fi
  
  if ver_lt "$feature" "$2" && [ -z "$INHIBIT_VERSION_ALERT" ]; then
    fatal "Your script is written for hhs ${1} $2.\n" \
          " But your hhs ${1} is $feature.\n" \
          " Please update your hhs."
  fi
}
