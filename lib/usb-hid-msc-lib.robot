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

Get PCIE2USB USB Bus Numbers
    [Documentation]    Return newline-separated list of USB bus numbers whose
    ...    host controller is the PCIe-to-USB converter.
    ...
    ...    Uses ${PCIE2USB_PCI_ADDRESS} when set. Otherwise auto-detects the
    ...    converter as the first USB controller not at an integrated PCI
    ...    address (i.e. not on bus 0000:00:).
    VAR    ${pci_addr}=    ${PCIE2_USB_PCI_ADDRESS}
    IF    "${pci_addr}" == "${EMPTY}"
        ${pci_addr}=    Execute Command In Terminal
        ...    lspci -D | grep -i "usb" | grep -v "^0000:00:" | awk '{print $1}' | head -1
        Should Not Be Empty    ${pci_addr}
        ...    Cannot auto-detect PCIe-to-USB converter. Set PCIE2USB_PCI_ADDRESS in the platform config.
    END
    VAR    ${cmd}=
    ...    for u in /sys/bus/usb/devices/usb*; do
    ...    pci=$(readlink -f "$u" | grep -oP '0000:[0-9a-f]{2}:[0-9a-f]{2}\\.[0-9a-f]' | tail -1);
    ...    [ "$pci" = "${pci_addr}" ] && cat "$u/busnum";
    ...    done
    ...    separator=${SPACE}
    ${buses}=    Execute Command In Terminal    ${cmd}
    Should Not Be Empty    ${buses}
    ...    No USB buses found for PCIe-to-USB converter at ${pci_addr}
    RETURN    ${buses}

Verify USB Device On PCIE2USB Converter
    [Documentation]    Verify that a device (matched by substring in lsusb
    ...    output) is visible on a USB bus belonging to the PCIe-to-USB
    ...    converter. Fails if the device is not found on any of those buses.
    [Arguments]    ${device_string}
    ${buses}=    Get PCIE2USB USB Bus Numbers
    @{bus_list}=    Split To Lines    ${buses}
    FOR    ${bus}    IN    @{bus_list}
        ${bus_padded}=    Execute Command In Terminal    printf "%03d" ${bus}
        ${lsusb_out}=    Execute Command In Terminal    lsusb | grep "Bus ${bus_padded}" || true
        ${found}=    Run Keyword And Return Status    Should Contain    ${lsusb_out}    ${device_string}
        IF    ${found}    RETURN
    END
    Fail
    ...    Device "${device_string}" not found on any PCIe-to-USB converter bus (buses: ${buses})
