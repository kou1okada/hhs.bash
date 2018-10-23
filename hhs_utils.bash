[ -n "${HHS_UTILS_BASH}" ] && return
:     ${HHS_UTILS_BASH:=1}



function headtail () # FIRST_LINE LAST_LINE
# Split lines from FIRST_LINE to LAST_LINE.
{
  head -n+$2 | tail -n+$1
}

function uniqex ()
# An alternative uniq command which is not required sort
{
  awk '!c[$0]++'
}
