#!/bin/sh
# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

set -eu

if [ -z "${CI_PIPELINE_EVENT:-}" ] && [ -n "${GITHUB_ACTIONS:-}" ]; then
  case "${GITHUB_EVENT_NAME:-}" in
    pull_request)
      CI_PIPELINE_EVENT=pull_request
      CI_COMMIT_TARGET_BRANCH="${GITHUB_BASE_REF:-}"
      ;;
    push)
      CI_PIPELINE_EVENT=push
      CI_PREV_COMMIT_SHA="${GITHUB_EVENT_BEFORE:-}"
      CI_COMMIT_SHA="${GITHUB_SHA:-}"
      ;;
    *)
      CI_PIPELINE_EVENT=manual
      ;;
  esac
fi

case "${CI_PIPELINE_EVENT:-local}" in
  pull_request)
    git fetch origin "$CI_COMMIT_TARGET_BRANCH"
    pre-commit run --show-diff-on-failure \
      --from-ref "origin/$CI_COMMIT_TARGET_BRANCH" \
      --to-ref HEAD
    ;;
  push)
    git fetch origin "$CI_PREV_COMMIT_SHA"
    pre-commit run --show-diff-on-failure \
      --from-ref "$CI_PREV_COMMIT_SHA" \
      --to-ref "$CI_COMMIT_SHA"
    ;;
  *)
    pre-commit run --show-diff-on-failure --all-files
    ;;
esac
