# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

FROM python:3.13-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        curl \
        ca-certificates \
        gcc \
        libc6-dev \
        pkg-config \
        jq \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
    --root-user-action ignore \
    pre-commit

ARG TASK_VERSION=3.45.4
RUN curl -fsSL "https://github.com/go-task/task/releases/download/v${TASK_VERSION}/task_linux_amd64.tar.gz" \
      | tar -xz -C /usr/local/bin task

ENV PRE_COMMIT_HOME=/opt/pre-commit-cache

RUN git config --system --add safe.directory '*'

WORKDIR /opt/warmup
COPY .pre-commit-config.yaml .
RUN git init -q . \
    && pre-commit install-hooks

WORKDIR /workspace
