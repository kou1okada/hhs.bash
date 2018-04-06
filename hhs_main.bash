[ -n "${HHS_MAIN_BASH}" ] && return
:     ${HHS_MAIN_BASH:=1}



function is_same_entity () #= FILE1 FILE2
{
  local files
  readarray -t files < <(readlink -f -- "$[@:0:2]")
  [ "${files[0]}" = "${files[1]}" -a -n "$files" ]
}

function optparse_hhs_init ()
{
  case "$1" in
    -)
      nparams 0
      ARGS+=( "$1" )
      ;;
    -w|--wara)
      nparams 0
      echo "wara"
      ;;
    *)
      return 1
      ;;
  esac
}

function hhs_init () #= 
{
  if (( $# == 0 )); then
    local TARGET="$(type -p "${SCRIPT_FILE}")"
    [ -z "$TARGET" ] && { echo "Fatal"; exit 1; }
    is_same_entity "$TARGET" "$SCRIPT_PATH" && TARGET="${SCRIPT_FILE}"
    cat<<-EOD
		# hhs.bash init
		# include hhs by appending
		# the following to your bash script:
		
		# hhs.bash - Happy hacking script for bash
		eval "\$("${TARGET}" init -)"
		EOD
  else
    case "$1" in
      -)
        cat<<-EOD
				source "\$(type -p "${HHS_PATH}" )"
				EOD
        ;;
      *)
        hhsinc command
        CMD=hhs_init invoke_command "$@"
        ;;
    esac
  fi
}



has_subcommand_hhs=1

function hhs () #= [OPTIONS] [COMMAND]
# Commands:
#   init       init library
{
  if (( 0 < $# )); then
    case "$1" in
      init)
        hhs_init "${@:2}"
        exit $?
        ;;
      *)
        hhsinc command
        CMD=hhs invoke_command "$@"
        ;;
    esac
  fi
}
