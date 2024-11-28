*** Settings ***
Library     OperatingSystem

*** Variables ***

# A list of USB boot device entries that may appear in the Dasharo edk2 boot
# menu. This way we do not care that much which particular stick is connected
# to the DUT. This is not perfect, as we might lose some information there,
# but it's been really problmatic so far to track the USB devices in platform
# configs. What is more, we may have one platform config and multiple instances
# of the same physical devices setup in the lab, with slightly different USB
# sticks.
#
# We may also decide that we always put DTS stick, and test booting with that.
# Thanks to ESP scanning, we always generate similar entry like:
# "Dasharo Tools Suite (on USB XXXX)"

@{USB_DEVICES_IN_EDK2}    Dasharo Tools Suite

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

Check USB Stick Detection in Edk2
    [Documentation]    Checks if the bootable USB devices are visible in the
    ...    boot menu.
    [Arguments]    ${boot_menu}
    Set Local Variable    ${found}    ${FALSE}

    FOR    ${stick}    IN    @{USB_DEVICES_IN_EDK2}
        ${found}=    Run Keyword And Return Status    Should Contain Match    ${boot_menu}    *${stick}*
        IF    '${found}' == '${TRUE}'    BREAK
    END

    IF    '${found}' == '${FALSE}'
        Log To Console    None of the known USB sticks have been found in the boot menu. If a stick is connected, you might need to update USB_DEVICES_IN_EDK2 variable.
        Log    ${boot_menu}
    END

    RETURN    ${found}
