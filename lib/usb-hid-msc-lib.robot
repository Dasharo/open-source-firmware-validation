*** Settings ***
Library     OperatingSystem


*** Keywords ***
Upload And Mount DTS Flash ISO
    [Documentation]    Mounts a bootable ISO as flash USB. Currently
    ...    only the Qubes OS ISO seems to work for the platform.
    Upload Image To PiKVM    ${PIKVM_IP}    dts-base-image-v1.2.8.iso
    ...    https://dl.3mdeb.com/open-source-firmware/DTS/v1.2.8/dts-base-image-v1.2.8.iso
    Mount Image On PiKVM    ${PIKVM_IP}    dts-base-image-v1.2.8.iso

Download ISO And Mount As USB
    [Documentation]    Mounts the desired ISO as USB stick,
    ...    either via PiKVM or Qemu
    [Arguments]    ${img_path}    ${img_url}    ${img_sha256sum}

    ${img_dir}    ${img_name}=    Split Path    ${img_path}

    Download To Host Cache
    ...    ${img_name}
    ...    ${img_url}
    ...    ${img_sha256sum}

    IF    "${MANUFACTURER}" == "QEMU"
        Remove Drive From Qemu
        Add USB To Qemu    img_name=${img_path}
    ELSE
        IF    "${DUT_CONNECTION_METHOD}" == "pikvm"
            Upload Image To PiKVM    ${PIKVM_IP}    ${img_url}    ${img_name}
            Mount Image On PiKVM    ${PIKVM_IP}    ${img_name}
        ELSE
            Skip    DUT_CONNECTION_METHOD for hardware platforms is not set to pikvm.
        END
    END

Mount ISO As USB
    [Documentation]    Mounts an ISO file from the local sources. In case of
    ...    PiKVM we need to manually upload images to the device. For UEFI
    ...    Secure Boot tests images, this can be automatically done by running
    ...    `scripts/secure-boot/generate-images/sb-img-wrapper.sh` script.
    [Arguments]    ${img_path}

    ${img_dir}    ${img_name}=    Split Path    ${img_path}

    IF    "${MANUFACTURER}" == "QEMU"
        Remove Drive From Qemu
        Add USB To Qemu    img_name=${img_path}
    ELSE
        IF    "${DUT_CONNECTION_METHOD}" == "pikvm"
            Mount Image On PiKVM    ${PIKVM_IP}    ${img_name}
        ELSE
            Skip    DUT_CONNECTION_METHOD for hardware platforms is not set to pikvm.
        END
    END
