#!/usr/bin/env bash
set -euo pipefail

log() { printf "** %s\n" "$*" >&2; }
error() { printf "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

REPO_ROOT="$(git -C "$PWD" rev-parse --show-toplevel)"
UNACCEPTABLE_LANGUAGE_PATTERNS_PATH="${REPO_ROOT}/unacceptable-language.txt"

log "Checking for unacceptable language..."

if ! test -f "${UNACCEPTABLE_LANGUAGE_PATTERNS_PATH}"; then
  CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  UNACCEPTABLE_LANGUAGE_PATTERNS_PATH="${CURRENT_SCRIPT_DIR}/unacceptable-language.txt"
  log "⚠️ 'unacceptable-language.txt' not found in repository, using the one included with the GitHub action."
fi

PATHS_WITH_UNACCEPTABLE_LANGUAGE=$(git -C "${REPO_ROOT}" grep -l -F -w -f "${UNACCEPTABLE_LANGUAGE_PATTERNS_PATH}" -- ":(exclude)${UNACCEPTABLE_LANGUAGE_PATTERNS_PATH}" || true | paste -s -d " ")

if [ -n "${PATHS_WITH_UNACCEPTABLE_LANGUAGE}" ]; then
  fatal "❌ Found unacceptable language in files:\n${PATHS_WITH_UNACCEPTABLE_LANGUAGE}."
else
  log "✅ Found no unacceptable language."
fi