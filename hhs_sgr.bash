[ -n "${HHS_SGR_BASH}" ] && return
:     ${HHS_SGR_BASH:=1}



function init_SGR ()
{
  if [ -n "$COLORIZE" ]; then
    SGR_reset="\e[0m"
    SGR_bold="\e[1m"
    SGR_fg_red="\e[31m"
    SGR_fg_green="\e[32m"
    SGR_fg_yellow="\e[33m"
    SGR_fg_blue="\e[34m"
    SGR_fg_magenta="\e[35m"
  else
    unset SGR_reset SGR_bold SGR_red SGR_green SGR_yellow SGR_blue SGR_magenta
  fi
  FATAL_COLOR="${SGR_fg_magenta}${SGR_bold}"
  ERROR_COLOR="${SGR_fg_red}${SGR_bold}"
  WARNING_COLOR="${SGR_fg_yellow}${SGR_bold}"
  INFO_COLOR="${SGR_fg_green}${SGR_bold}"
  DEBUG_COLOR="${SGR_fg_blue}${SGR_bold}"
}
