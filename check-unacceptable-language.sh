#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }

REPO_ROOT="$(git -C "$PWD" rev-parse --show-toplevel)"
UNACCEPTABLE_LANGUAGE_PATTERNS_PATH="${REPO_ROOT}/unacceptable-language.txt"

log "Checking for unacceptable language..."

if ! test -f ${UNACCEPTABLE_LANGUAGE_PATTERNS_PATH}; then
  CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  UNACCEPTABLE_LANGUAGE_PATTERNS_PATH="${CURRENT_SCRIPT_DIR}/unacceptable-language.txt"
  log "❗ There was no 'unacceptable-language.txt' file in the repository, so we use the one that is included with the github action."

  PATHS_WITH_UNACCEPTABLE_LANGUAGE=$(git -C "${REPO_ROOT}" grep \
  -l -F -w \
  -f "${UNACCEPTABLE_LANGUAGE_PATTERNS_PATH}" \
  ) || true | /usr/bin/paste -s -d " " -

else
  PATHS_WITH_UNACCEPTABLE_LANGUAGE=$(git -C "${REPO_ROOT}" grep \
  -l -F -w \
  -f "${UNACCEPTABLE_LANGUAGE_PATTERNS_PATH}" \
  -- ":(exclude)${UNACCEPTABLE_LANGUAGE_PATTERNS_PATH}" \
  ) || true | /usr/bin/paste -s -d " " -

fi

if [ -n "${PATHS_WITH_UNACCEPTABLE_LANGUAGE}" ]; then
  log "❌ Found unacceptable language in files:"
  log "${PATHS_WITH_UNACCEPTABLE_LANGUAGE}"
  exit 1;
fi

log "✅ Found no unacceptable language."