*** Settings ***
Library     OperatingSystem
Resource    terminal.robot


*** Variables ***
# A list of USB boot device entries that may appear in the Dasharo edk2 boot
# menu. This way we do not care that much which particular stick is connected
# to the DUT. This is not perfect, as we might lose some information there,
# but it's been really problematic so far to track the USB devices in platform
# configs. What is more, we may have one platform config and multiple instances
# of the same physical devices setup in the lab, with slightly different USB
# sticks.
#
# We may also decide that we always put DTS stick, and test booting with that.
# Thanks to ESP scanning, we always generate similar entry like:
# "Dasharo Tools Suite (on USB XXXX)"

@{USB_DEVICES_IN_EDK2}=     Dasharo Tools Suite


*** Keywords ***
Mount USB Disk Image
    [Documentation]    Mounts USB disk image - either from URL or from local file.
    [Arguments]    ${img_source}    ${upload_type}=file    ${required}=${TRUE}

    # FXIME: Currently works only for QEMU and PiKVM. Remove when support for
    # other methods is added.
    IF    "${MANUFACTURER}" != "QEMU" and "${DUT_CONNECTION_METHOD}" != "pikvm"
        RETURN
    END

    # TODO:: Move to interface approach, not IF/ELSE tree
    IF    "${upload_type}" == "file"
        ${img_dir}    ${img_path}=    Split Path    ${img_source}

        IF    "${MANUFACTURER}" == "QEMU"
            Add USB To Qemu    img_path=${img_source}
        ELSE IF    "${DUT_CONNECTION_METHOD}" == "pikvm"
            Upload Image To PiKVM    ${img_source}    ${img_path}    ${upload_type}
            Mount Image On PiKVM    ${img_path}
        ELSE
            # For setups with no real ability to mount USB Disk, we may decide whether we assume that certain USB Disk is prepared beforehand, or we skip the test.
            Log To Console    Mounting USB Disk Image at runtime is not supported on this platform.
            IF    ${required}
                Log To Console
                ...    Image marked as required. Make sure that USB drive with image: ${img_source} is already prepared and connected to the DUT.
            ELSE
                Skip    Image not marked as required, skipping test case.
            END
        END
    ELSE IF    "${upload_type}" == "url"
        Fail
        ...    "upload_type=url argument for Mount USB Disk Image is not implemented right now.
        ...    We prefer to store all test data in osfv-test-data repo instead of downloading them at runtime in tests."
    ELSE
        Fail    "Unsupported upload_type argument for Mount USB Disk Image"
    END

Check USB Stick Detection In Edk2
    [Documentation]    Checks if the bootable USB devices are visible in the
    ...    boot menu.
    [Arguments]    ${boot_menu}
    VAR    ${found}=    ${FALSE}

    FOR    ${stick}    IN    @{USB_DEVICES_IN_EDK2}
        ${found}=    Run Keyword And Return Status    Should Contain Match    ${boot_menu}    *${stick}*
        IF    '${found}' == '${TRUE}'    BREAK
    END

    IF    '${found}' == '${FALSE}'
        Log To Console
        ...    None of the known USB sticks have been found in the boot menu. If a stick is connected, you might need to update USB_DEVICES_IN_EDK2 variable.
        Log    ${boot_menu}
    END

    RETURN    ${found}

Get First USB Stick In Linux
    [Documentation]    Return <device> in /dev/<device> that is USB stick
    ...    (removable USB storage). Returns first found device
    ...
    ...    === Requirements ===
    ...    - Logged into Linux OS
    ...
    ...    === Arguments ===
    ...
    ...    === Return Value ===
    ...    - ``string``
    ...
    ...    === Effects ===
    ${devices}=    Execute Command In Terminal
    ...    ls -A1 /dev/disk/by-id/"usb-"* | xargs readlink -f | sed 's|/dev/||g'
    @{dev_list}=    Split To Lines    ${devices}
    FOR    ${device}    IN    @{dev_list}
        # Removable USB storage (size > 0), that is not partition
        VAR    ${command}=
        ...    test ! -f "/sys/class/block/${device}/partition"
        ...    test "\$(cat /sys/class/block/${device}/size)" -gt 0
        ...    cat "/sys/class/block/${device}/removable"
        ...    separator=${SPACE}\&\&${SPACE}
        ${removable}=    Execute Command In Terminal    ${command}
        IF    "${removable}" == "1"    RETURN    ${device}
    END
    Fail    Couldn't find any USB stick
