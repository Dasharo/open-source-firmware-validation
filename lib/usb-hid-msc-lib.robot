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
            Skip    unsupported
        END
    END

Copy ISO And Mount As USB
    [Documentation]    Mounts the desired ISO as USB stick,
    ...    either via PiKVM or Qemu
    [Arguments]    ${img_destination}    ${img_source}

    ${img_dir}    ${img_name}=    Split Path    ${img_destination}

    IF    "${MANUFACTURER}" == "QEMU"
        Remove Drive From Qemu
        Add USB To Qemu    img_name=${img_destination}
    ELSE
        IF    "${DUT_CONNECTION_METHOD}" == "pikvm"
            Upload Local Image To PiKVM    ${PIKVM_IP}    ${img_source}    ${img_name}
            Mount Image On PiKVM    ${PIKVM_IP}    ${img_name}
        ELSE
            Skip    unsupported
        END
    END
