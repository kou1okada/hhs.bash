[ -n "${HHS_FUNCTION_OVERRIDE_BASH}" ] && return
:     ${HHS_FUNCTION_OVERRIDE_BASH:=1}



function function_evacuate () # <function> [<asylum>]
#   Evacuate <function> to <asylum> for preparing function override.
# Return:
#   $_ASYLUM : asylum
{
  local orig; readarray -d "" orig < <(declare -fp "${1}")
  _ASYLUM=="${2:-$(printf %04x $RANDOM $RANDOM)}"
  eval "${orig/#${1}/${_ASYLUM}_overridden_${1}}"
}

function call_overridden () # <asylum> <function> [<args> ...]
#   Call overridden function.
{
  local asylum="${1}_overridden_${2}"
  "$asylum" "${@:3}"
}
