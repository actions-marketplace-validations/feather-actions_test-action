#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "%s\n" "$*" >&2; }

REPO_ROOT="$(git -C "$PWD" rev-parse --show-toplevel)"
SWIFT_FORMAT_JSON_PATH="${REPO_ROOT}/.swift-format"
SWIFTFORMAT_BIN=${SWIFTFORMAT_BIN:-$(command -v swift-format)}
if [[ -z "${SWIFTFORMAT_BIN}" ]]; then
  log "❌ SWIFTFORMAT_BIN unset and no swift-format on PATH"
  exit 1
fi
if ! test -f ${SWIFT_FORMAT_JSON_PATH}; then
  CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  SWIFT_FORMAT_JSON_PATH="${CURRENT_SCRIPT_DIR}/.swift-format"
  log "❗ There was no '.swift-format' file in the repository, so we use the one that is included with the github action."
fi

git -C "${REPO_ROOT}" ls-files -z '*.swift' \
  | grep -z -v \
  -e 'Package.swift' \
  | xargs -0 "${SWIFTFORMAT_BIN}" "lint --strict" --parallel \
  --configuration "${SWIFT_FORMAT_JSON_PATH}" \
  && SWIFT_FORMAT_RC=$? || SWIFT_FORMAT_RC=$?
  
if [ "${SWIFT_FORMAT_RC}" -ne 0 ]; then
  log "❌ Running swift-format produced errors."; exit 1;
  exit "${SWIFT_FORMAT_RC}"
fi

log "✅ Ran swift-format with no errors."
