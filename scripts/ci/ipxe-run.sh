#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

set -e

print_help() {
cat <<EOF
$(basename "$0") [OPTION]... <dts-base-image-path> <bzImage-path>
$(basename "$0") [OPTION]... --uki <ipxe-uki-path>
Prepare ipxe folder so it can be used to boot DTS via iPXE, create dts.ipxe script and start HTTP server.

Options:
  -u|--uki                  Add this flag if you want to use UKI file (ipxe-dtsx64.efi) instead.
  -p|--port <port>          Start HTTP server on port <port>
  -v|--verbose              Enable trace output
  -h|--help                 Print this help
EOF
}

print_usage_error() {
  print_help
  error_exit "$1"
}

print_error() {
  local red="\033[31m"
  local reset="\033[0m"
  echo -e "${red}ERROR: $1${reset}"
}

error_exit() {
  print_error "$1"
  exit 1
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -u|--uki)
        UKI=Y
        shift
        ;;
      -p|--port)
        PORT="$2"
        shift 2
        ;;
      -v|--verbose)
        set -x
        shift
        ;;
      -h|--help)
        print_help
        exit 0
        ;;
      -*)
        print_usage_error "Unknown option $1"
        ;;
      *)
        POSITIONAL_ARGS+=( "$1" )
        shift
        ;;
    esac
  done
}

POSITIONAL_ARGS=()
UKI=N
PORT=4321
parse_args "$@"
set -- "${POSITIONAL_ARGS[@]}"

if [[ "$UKI" = "Y" && $# -ne 1 ]]; then
  print_usage_error "Script requires 1 positional argument with --uki option, got $# instead."
fi

if [[ "$UKI" = "N" && $# -ne 2 ]]; then
  print_usage_error "Script requires 2 positional arguments, got $# instead"
fi

DTS_IMAGE_PATH=$1
DTS_IMAGE_FILENAME=$(basename "$DTS_IMAGE_PATH")
if [[ "$UKI" = "N" ]]; then
  BZ_IMAGE_PATH=$2
  BZ_IMAGE_FILENAME=$(basename "$BZ_IMAGE_PATH")
fi
IPXE_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)/../../ipxe

mkdir -p "$IPXE_PATH"
ln -srf "$DTS_IMAGE_PATH" "$IPXE_PATH"/"$DTS_IMAGE_FILENAME"
if [[ "$UKI" = "N" ]]; then
  ln -srf "$BZ_IMAGE_PATH" "$IPXE_PATH"/"$BZ_IMAGE_FILENAME"
  cat <<EOF > "$IPXE_PATH/dts.ipxe"
#!ipxe
imgfetch --name file_kernel $BZ_IMAGE_FILENAME
imgfetch --name file_initrd $DTS_IMAGE_FILENAME
kernel file_kernel initrd=file_initrd console=ttyUSB0
boot
EOF
else
  cat <<EOF > "$IPXE_PATH/dts.ipxe"
#!ipxe
chain $DTS_IMAGE_FILENAME
EOF
fi

cd "$IPXE_PATH" && python3 -m http.server "$PORT"
