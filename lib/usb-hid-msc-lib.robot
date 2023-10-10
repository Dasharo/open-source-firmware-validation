*** Keywords ***
Upload And Mount DTS Flash ISO
    [Documentation]    Mounts a bootable ISO as flash USB. Currently
    ...    only the Qubes OS ISO seems to work for the platform.
    Upload Image To PiKVM    ${PIKVM_IP}
    ...    https://dl.3mdeb.com/open-source-firmware/DTS/v1.2.8/dts-base-image-v1.2.8.iso
    Mount Image On PiKVM    ${PIKVM_IP}    dts-base-image-v1.2.8.iso
