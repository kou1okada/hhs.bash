[ -n "${HHS_TARGET_VERSION_BASH}" ] && return
:     ${HHS_TARGET_VERSION_BASH:=1}

function prepare_target_version () # VERSION
{
  [ -d "${HHS_VERSIONS_DIR}/v$1" ] && return
  local vers="$1"$'\n'"${HHS_VERSION}"
  if [ "$vers" != "$(sort -V <<<"$vers")" ]; then
    hhsinc debug
    fatal "Your script is written for hhs $1.\n" \
          " But your hhs is $HHS_VERSION.\n" \
          " Please update your hhs."
    abort 1
  fi
  mkdir -p "${HHS_VERSIONS_DIR}"
  if ! (
    git clone --depth 1 --branch "v$1" "file://${HHS_REALDIR}" "${HHS_VERSIONS_DIR}/v$1" \
    && cd "${HHS_VERSIONS_DIR}/v$1" \
    && make
    ) >& /tmp/hhs.bash.log; then
    hhsinc debug
    fatal "Your script is written for hhs $1.\n" \
          " But hhs $HHS_VERSION does not know hhs $1.\n" \
          " Please check your script and your hhs.\n" \
          " For debug information, see /tmp/hhs.bash.log"
    abort 1
  fi
}
