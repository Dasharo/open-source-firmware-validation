#!/bin/bash

set -e

SCRIPTDIR=$(readlink -f "$(dirname "$0")")

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
