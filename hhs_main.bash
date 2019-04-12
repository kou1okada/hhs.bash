[ -n "${HHS_MAIN_BASH}" ] && return
:     ${HHS_MAIN_BASH:=1}



function is_same_entity () #= FILE1 FILE2
{
  local files
  readarray -t files < <(readlink -f -- "${@:1:2}")
  [ "${files[0]}" = "${files[1]}" -a -n "$files" ]
}



function hhs_clean_versions ()
#   Remove files from HHS_VERSIONS_DIR directory.
#   HHS_VERSIONS_DIR is the directory for caching
#   the specific versions to keep compatibility.
{
  if [ -z "$HHS_VERSIONS_DIR" -o "$HHS_VERSIONS_DIR" == "/" ]; then
    hhsinc debug
    error "HHS_VERSIONS_DIR is invalid: ${HHS_VERSIONS_DIR@Q}"
    abort 1
  fi
  local clean=( rm -frv "${HHS_VERSIONS_DIR}" )
  echo "${clean[@]:0:2}" "${clean[2]@Q}"
  hhsinc ask
  if ask "Are you sure?" ; then
    "${clean[@]}"
  fi
}



function hhs_sample ()
#   Show a sample file for skeleton script.
{
  cat "${HHS_REALDIR%%/}/sample"
}



function optparse_hhs_init ()
{
  case "$1" in
    -)
      nparams 0
      ARGS+=( "$1" )
      ;;
    *)
      return 1
      ;;
  esac
}

function hhs_init ()
#   Helper for initializing hhs.
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
#   hhs.bash - Happy Hacking Script for Bash
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
