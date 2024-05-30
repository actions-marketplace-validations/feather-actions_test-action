#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

REPO_ROOT="$(git -C "$PWD" rev-parse --show-toplevel)"
UNACCEPTABLE_LANGUAGE_PATTERNS_PATH="${REPO_ROOT}/unacceptable-language.txt"
EXCLUDE_COMMAND=(-- ":(exclude)${UNACCEPTABLE_LANGUAGE_PATTERNS_PATH}")

if ! test -f ${UNACCEPTABLE_LANGUAGE_PATTERNS_PATH}; then
  EXCLUDE_COMMAND = (:)
  CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  UNACCEPTABLE_LANGUAGE_PATTERNS_PATH="${CURRENT_SCRIPT_DIR}/unacceptable-language.txt"
  log "⚠️ There was no 'unacceptable-language.txt' file in the repository, so we use the one that is included with the github action."
fi

log "Checking for unacceptable language..."

PATHS_WITH_UNACCEPTABLE_LANGUAGE=$(git -C "${REPO_ROOT}" grep \
-l -F -w \
-f "${UNACCEPTABLE_LANGUAGE_PATTERNS_PATH}" \
"${EXCLUDE_COMMAND[@]}" \
) || true | /usr/bin/paste -s -d " " -

if [ -n "${PATHS_WITH_UNACCEPTABLE_LANGUAGE}" ]; then
  fatal "❌ Found unacceptable language in files: ${PATHS_WITH_UNACCEPTABLE_LANGUAGE}."
fi

log "✅ Found no unacceptable language."