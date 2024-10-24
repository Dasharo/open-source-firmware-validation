#!/bin/bash

SCRIPTDIR=$(readlink -f "$(dirname "$0")")
TESTNAME=$1
CRYP_ALG=$2
PKG_MNG=""
DISTRO=""

error_exit() {
    _error_msg="$1"
    echo "$_error_msg"
    exit 1
}

error_check() {
    _error_code=$?
    _error_msg="$1"
    [ "$_error_code" -ne 0 ] && error_exit "$_error_msg : ($_error_code)"
}

check_using_pkg_mng() {
    # Get the distribution name
    distribution_name=$(lsb_release -is 2>/dev/null | tr '[:upper:]' '[:lower:]' || cat /etc/*-release | grep 'ID=' | awk -F= '{print $2}' | tr -d '"')
    error_check "Cannot read information about distribution"

    # Initialize the variable to an empty string
    PKG_MNG=""

    # Map distribution names to package managers
    case "$distribution_name" in
        debian|ubuntu)
            PKG_MNG="apt"
            ;;
        fedora)
            PKG_MNG="dnf"
            ;;
        arch)
            PKG_MNG="pacman"
            ;;
        gentoo)
            PKG_MNG="emerge"
            ;;
        *)
            PKG_MNG="Unknown"
            ;;
    esac

    DISTRO=$distribution_name
    # Display the detected package manager or "Unknown" if none is detected
    if [ "$PKG_MNG" != "Unknown" ]; then
        echo "Detected Package Manager: $PKG_MNG"
        echo "Detected Distro: $DISTRO"
    else
        echo "Unknown Package Manager"
        exit 1
    fi
}

install_deps() {
    echo "Installing dependencies"
    check_using_pkg_mng

    # Distros may have different names for packages:
    if [ "$DISTRO"  == "fedora" ] || [ "$DISTRO" == "arch" ] || [ "$DISTRO" == "gentoo" ]; then
        deps_list="sbsigntools libfaketime"
    elif [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ]; then
        deps_list="sbsigntool faketime"
    fi

    if [ $DISTRO == "arch" ]; then
        sudo $PKG_MNG -S $deps_list 2>&1
        error_check "Cannot install $deps_list"
    else
        sudo $PKG_MNG install $deps_list 2>&1
        error_check "Cannot install $deps_list"
    fi
}

# Create image to which we will put certs and efi files
create_iso_image() {
    # make the new image, with the correct label
    IMAGELABEL=$TESTNAME$CRYP_ALG

    if [ "$IMAGELABEL" == "INTERMEDIATE" ]; then
        # this unfortunately has to be here, otherwise mks.fat says:
        # mkfs.fat: Label can be no longer than 11 characters
        IMAGELABEL=INTERMED
    fi

    dd if=/dev/zero of=image.img bs=1M count=8 > /dev/null 2>&1
    error_check "Cannot create empty image file to store created certs and efi files"
    sudo mkfs.fat -F 12 image.img -n $IMAGELABEL > /dev/null 2>&1
    error_check "Cannot assign label: $IMAGELABEL"
}

create_rsa_key() {
    algo=$1
    openssl req -new -x509 -newkey rsa:$algo -subj "/CN=3mdeb_test/" -keyout cert.key -out cert.crt -days 3650 -nodes -sha256 > /dev/null 2>&1
    error_check "Cannot create rsa key pair"
    openssl x509 -in cert.crt -outform der -out cert.der > /dev/null 2>&1
    error_check "Cannot create rsa der cert"
}

create_ecdsa_key() {
    algo=$1
    openssl req -new -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-$algo -subj "/CN=3mdeb_key/" -keyout cert.key -out cert.crt -days 3650 -nodes -sha256 > /dev/null 2>&1
    error_check "Cannot create ecdsa key pair"
    openssl base64 -d -in cert.crt -out cert.der > /dev/null 2>&1
    error_check "Cannot create ecdsa der cert"
}

create_intermediate_key() {
    # generate two key pairs, make CSR
    openssl req -new -x509 -newkey rsa:2048 -subj "/CN=3mdeb_test/" -keyout cert.key -out cert.crt -days 3650 -nodes -sha256 > /dev/null 2>&1
    error_check "Cannot create rsa first key for intermediate"
    openssl req -new -x509 -newkey rsa:2048 -subj "/CN=3mdeb_test/" -keyout PK.key -out PK.crt -days 3650 -nodes -sha256 > /dev/null 2>&1
    error_check "Cannot create rsa first key for intermediate"
    openssl req -new -key cert.key -out cert.csr -subj "/C=PL/O=3mdeb" > /dev/null 2>&1
    error_check "Cannot create csr"
    # sign the CSR with the second key pair
    # its necessary to `touch cert.ext`, otherwise it says its not there
    touch cert.ext
    openssl x509 -req -in cert.csr -CA PK.crt -CAkey PK.key -out cert.crt -CAcreateserial -extfile cert.ext > /dev/null 2>&1
    error_check "Cannot sign csr"
    openssl x509 -in cert.crt -outform der -out cert.der > /dev/null 2>&1
    error_check "Cannot create der from signed cert"
}

create_bad_format_key() {
    algo=$1
    openssl req -new -x509 -newkey rsa:$algo -subj "/CN=3mdeb_test/" -keyout cert.key -out cert.crt -days 3650 -nodes -sha256 > /dev/null 2>&1
    error_check "Cannot create rsa key pair"
    # here we copy .crt to .der to leave wrong format for BIOS menu
    cp cert.crt cert.der
    error_check "Cannot create fake cert.der"
}

create_expired_cert() {
    faketime '10 days ago' openssl req -new -x509 -newkey rsa:2048 -subj "/CN=ExpiredCert/" -keyout cert.key -out cert.crt -days 10 -nodes -sha256 > /dev/null 2>&1
    error_check "Cannot create expired rsa key pair"
    openssl x509 -in cert.crt -outform der -out cert.der
    error_check "Cannot create expired rsa der cert"
}

sign_img_and_create_iso() {
    local _object_to_mount
    # sign hello.efi
    cp "$SCRIPTDIR"/hello.efi .
    error_check "Cannot copy hello.efi"
    if [ "$TESTNAME" != "BAD_FORMAT" ] && [ "$TESTNAME" != "NOT_SIGNED" ]; then
        sbsign --key cert.key --cert cert.crt --output signed-hello.efi hello.efi
        error_check "Cannot sign hello.efi"
    fi
    # Copy all things to the image.
    # Extract loop* from udisksctl output:
    _object_to_mount="$(udisksctl loop-setup -f image.img | grep -o 'loop[0-9]\+' | sed 's/\.$//')"
    error_check "Cannot run udisksctl to create ISO"
    MOUNT_POINT=$(mount | grep $IMAGELABEL | awk '{print $3}')
    while [ ! -d "$MOUNT_POINT" ]; do
        echo "Mounting $IMAGELABEL..."
        udisksctl mount -p "block_devices/$_object_to_mount"
        error_check "Cannot mount created ISO"
        sleep 0.2
        MOUNT_POINT=$(mount | grep $IMAGELABEL | awk '{print $3}')
    done
    # copy everything to the image (except for the image itself)
    for file in *; do

        if [ "$file" != "image.img" ]; then
            cp $file "$MOUNT_POINT/"
        fi

    done
    umount "$MOUNT_POINT"
    # now the image is ready, all we have to do is copy it to the desired location
    IMAGENAME=$TESTNAME$CRYP_ALG
    cp -f image.img "$SCRIPTDIR"/../images/$IMAGENAME.img
}

echo "Creating image for $TESTNAME $CRYP_ALG"
echo ""

# make sure images directory exists
mkdir -p "$SCRIPTDIR"/../images/
error_check "Cannot create directory for images"

# go into a separate directory to make cleanup easier
TEMPDIR=$(mktemp -d)
cd "$TEMPDIR" || exit 1
error_check "Cannot enter tempdir: $TEMPDIR"

install_deps
create_iso_image

# prepare keys for signing
case "$TESTNAME" in
    INTERMEDIATE)
        create_intermediate_key
        ;;
    RSA)
        create_rsa_key $CRYP_ALG
        ;;
    ECDSA)
        create_ecdsa_key $CRYP_ALG
        ;;
    GOOD_KEYS|BAD_KEYS)
        create_rsa_key 2048
        ;;
    BAD_FORMAT)
        create_bad_format_key 2048
        ;;
    EXPIRED)
        create_expired_cert
        ;;
    NOT_SIGNED)
        ;;
    *)
        echo "Invalid TESTNAME"
        exit 1
        ;;
esac
sign_img_and_create_iso
echo "Done"
# and clean up
rm -rf "$TEMPDIR"
