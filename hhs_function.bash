[ -n "${HHS_FUNCTION_BASH}" ] && return
:     ${HHS_FUNCTION_BASH:=1}



function function_get_lines () # PAT_FUNC [FILE]
# Return lines of function about declare, begin and end.
{
  grep -nE "^$1|^{|^}" "${@:2:1}" \
  | grep -A2 -E "^[0-9]+:$1" \
  | grep  -o -E "^[0-9]+"
}
