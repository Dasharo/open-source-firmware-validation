#!/bin/bash

set -e

SCRIPTDIR=$(readlink -f "$(dirname "$0")")
IMAGES=(INTERMEDIATE.img RSA2048.img RSA3072.img RSA4096.img ECDSA256.img
ECDSA384.img ECDSA521.img GOOD_KEYS.img EXPIRED.img NOT_SIGNED.img BAD_KEYS.img
BAD_FORMAT.img)

generate_images() {
  "$SCRIPTDIR"/generate-image.sh INTERMEDIATE

  "$SCRIPTDIR"/generate-image.sh RSA 2048
  "$SCRIPTDIR"/generate-image.sh RSA 3072
  "$SCRIPTDIR"/generate-image.sh RSA 4096

  "$SCRIPTDIR"/generate-image.sh ECDSA 256
  "$SCRIPTDIR"/generate-image.sh ECDSA 384
  "$SCRIPTDIR"/generate-image.sh ECDSA 521

  "$SCRIPTDIR"/generate-image.sh GOOD_KEYS
  "$SCRIPTDIR"/generate-image.sh EXPIRED
  "$SCRIPTDIR"/generate-image.sh NOT_SIGNED
  "$SCRIPTDIR"/generate-image.sh BAD_KEYS
  "$SCRIPTDIR"/generate-image.sh BAD_FORMAT
}

send_to_pikvm() {
  # upload images to PiKVM using HTTP API:
  # https://docs.pikvm.org/api/#mass-storage-drive
  if [ $# -eq 1 ]; then
    # Disconnect MSD
    curl -v -X POST -k -u admin:admin https://${1}/api/msd/set_connected\?connected\=0

    for image in "${IMAGES[@]}"
    do
        # Remove previous image because write request can't overwrite existing
        curl -v -X POST -k -u admin:admin https://${1}/api/msd/remove\?image\=$image
        curl -v -X POST --data-binary @"$SCRIPTDIR/../images/$image" \
          -k -u admin:admin https://$1/api/msd/write?image=$image
    done
  else
    echo "Please, provide IP address of PiKVM to which images should be sent."
    exit 1
  fi
}

usage() {
  echo "Usage: $0 <command>"
  echo
  echo "Commands:"
  echo "  generate   Generate images for UEFI Secure Boot tests."
  echo "  send       Generate images for UEFI Secure Boot tests and send them to"
  echo "             PiKVM at given address."
  echo
  echo "Example:"
  echo "  $0 generate"
  echo "  $0 send 192.168.4.4"
}

CMD="$1"

case $CMD in
  generate)
    echo "Generate images for UEFI Secure Boot tests..."
    generate_images
    ;;
  send)
    echo "Generate images for UEFI Secure Boot tests and send to PiKVM..."
    generate_images
    shift
    send_to_pikvm "$1"
    ;;
  *)
    echo "Not supported command: $CMD"
    usage
    ;;
esac
