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
    pre-commit \
    requests

ARG TASK_VERSION=3.45.4
RUN curl -fsSL "https://github.com/go-task/task/releases/download/v${TASK_VERSION}/task_linux_amd64.tar.gz" \
      | tar -xz -C /usr/local/bin task

# Docker CLI only (no daemon): release-image pipeline talks to the host socket
ARG DOCKER_VERSION=28.3.3
RUN curl -fsSL "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" \
      | tar -xz -C /usr/local/bin --strip-components=1 docker/docker

ENV PRE_COMMIT_HOME=/opt/pre-commit-cache

RUN git config --system --add safe.directory '*'

WORKDIR /opt/warmup
COPY .pre-commit-config.yaml .
RUN git init -q . \
    && pre-commit install-hooks

WORKDIR /workspace
