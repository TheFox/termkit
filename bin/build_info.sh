#!/usr/bin/env bash

DATE=$(date +"%F %T %z")
SCRIPT_BASEDIR=$(dirname $0)


cd "${SCRIPT_BASEDIR}/.."

TERMKIT_VERSION=$(ruby -I lib/termkit -rversion -e "puts %{#{TheFox::TermKit::VERSION} (#{TheFox::TermKit::DATE})}")

printf "%s

termkit: %s
id: %s
ref: %s@%s
stage: %s
server: %s %s
" "${DATE}" "${TERMKIT_VERSION}" "${CI_BUILD_ID}" "${CI_BUILD_REF}" "${CI_BUILD_REF_NAME}" "${CI_BUILD_STAGE}" "${CI_SERVER_NAME}" "${CI_SERVER_VERSION}"
