#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

REPO_ROOT="$(git -C "$PWD" rev-parse --show-toplevel)"
CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
UNACCEPTABLE_LANGUAGE_PATTERNS_PATH="${CURRENT_SCRIPT_DIR}/unacceptable-language.txt"

log "..................................."
log ${REPO_ROOT}
log ${CURRENT_SCRIPT_DIR}
log ${UNACCEPTABLE_LANGUAGE_PATTERNS_PATH}

if test -f ${UNACCEPTABLE_LANGUAGE_PATTERNS_PATH}; then
  echo "File exists."
fi

log "Checking for unacceptable language..."
PATHS_WITH_UNACCEPTABLE_LANGUAGE=$(git -C "${REPO_ROOT}" grep \
  -l -F -w \
  -f "${UNACCEPTABLE_LANGUAGE_PATTERNS_PATH}" \
  -- \
  ":(exclude)${UNACCEPTABLE_LANGUAGE_PATTERNS_PATH}" \
) || true | /usr/bin/paste -s -d " " -

log "..................................."
log ${UNACCEPTABLE_LANGUAGE_PATTERNS_PATH}


if [ -n "${PATHS_WITH_UNACCEPTABLE_LANGUAGE}" ]; then
  fatal "❌ Found unacceptable language in files:"
  fatal "${PATHS_WITH_UNACCEPTABLE_LANGUAGE}."
fi

log "✅ Found no unacceptable language."
