*** Comments ***
Heads for the QEMU qemu-coreboot-* boards, started with:
FW_TYPE=heads ./scripts/ci/qemu-run.sh <mode> firmware
Tests drive Heads over the serial console (Heads mirrors its dialogs and
prompts there) and use QMP for power and USB storage.  See docs/qemu.md.


*** Settings ***
Library     ../lib/QemuMonitor.py    /tmp/qmp-socket
Library     ../lib/heads_usb.py
Resource    include/default.robot


*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=       Telnet
${DUT_CONNECTION_METHOD}=               ${INITIAL_DUT_CONNECTION_METHOD}
${RTE_S2_N_PORT}=                       1234
${FLASH_SIZE}=                          ${16*1024*1024}
${MANUFACTURER}=                        QEMU
${POWER_CTRL}=                          RteCtrl
${FLASHING_METHOD}=                     none

# Supported test environments
${TESTS_IN_FIRMWARE_SUPPORT}=           ${TRUE}
${TESTS_IN_HEADS_SUPPORT}=              ${TRUE}
${HEADS_PAYLOAD_SUPPORT}=               ${TRUE}
${TPM_DETECT_SUPPORT}=                  ${TRUE}
${TPM_SUPPORTED_VERSION}=               2
${RTC_BOOT_SUPPORT}=                    ${FALSE}

# Heads on QEMU: HEADS_ROM_FILE, HEADS_USB_TOKEN, HEADS_TEST_ISO and
# HEADS_QEMU_WORKDIR are set in keys-and-keywords/heads-keywords.robot, so
# they can be overridden on the command line (-v heads_rom_file:<path>)

*** Keywords ***
Power On
    [Documentation]    Start the VM from reset.  With -no-shutdown QEMU keeps
    ...    running after Heads powers off (it powers off instead of rebooting
    ...    on QEMU), so a reset and, if stopped, a resume start it again.
    Read From Terminal
    Qemu Monitor.System Reset
    ${status}=    Get Qemu Status
    IF    '${status}' != 'running'    Resume Qemu
