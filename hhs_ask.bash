[ -n "${HHS_ASK_BASH}" ] && return
:     ${HHS_ASK_BASH:=1}

function ask () # [MESSAGE [OPTIONS]]
# Ask yes or no.
{
  local answer retcode option
  local MESSAGE="$1"
  local OPTIONS="${2:-y/N}"
  local DEFAULT="$(
    echo "$OPTIONS" \
    | awk -v FS=/ '{for(i=1;i<=NF;i++)if(match(substr($i,1,1),/[A-Z]/)){print $i; exit}}'
    )"
  local SPLIT_OPTIONS
  readarray -t SPLIT_OPTIONS <<<"${OPTIONS/\//$'\n'}"
  while true; do
    echo -n "${MESSAGE}${MESSAGE:+ }[${OPTIONS}] "
    read answer
    retcode=0
    for option in "${SPLIT_OPTIONS[@]}"; do
      if [ "$option" = "${answer:-$DEFAULT}" ]; then
        return $retcode
      fi
      : $(( retcode++ ))
    done
  done
}