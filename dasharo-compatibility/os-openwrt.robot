*** Settings ***
Library             Collections
Library             DateTime
Library             Dialogs
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# Log Out And Close Connection - elementary teardown keyword for all tests.
Suite Setup         Run Keywords
...                     Prepare Test Suite
Suite Teardown      Run Keywords
...                     Log Out And Close Connection
Test Setup          Run Keyword
...                     Restore Initial DUT Connection Method

Default Tags        semiauto


*** Test Cases ***
OWR001.207 Install operating system on disk (OpenWrt)
    [Documentation]    This test installs OpenWrt on NVMe drive using dd program.
    ...    DTS is boot via iPXE and OpenWrt image is downloaded using wget.
    ...    OPENWRT_IMAGE_FILE - core of file name
    ...    OPENWRT_TARGET_DEVICE - target drive to be wiped out using dd (!)
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_OPENWRT_SUPPORT}    OWR001.207 not supported
    Variable Should Exist    ${OPENWRT_TARGET_DEVICE}
    Variable Should Exist    ${OPENWRT_IMAGE_FILE}
    ${selection}=    Get Selection From User
    ...    Caution! You are about to install OpenWrt on ${OPENWRT_TARGET_DEVICE} device. Are you sure?
    ...    Yes, I'd like to wipe all the data existing on ${OPENWRT_TARGET_DEVICE} device.
    ...    No, let's skip OpenWrt installation.
    ${contains_yes}=    Run Keyword And Return Status    Should Contain    ${selection}    Yes, I'd like to
    Skip If    not(${contains_yes})    OpenWrt installation on ${OPENWRT_TARGET_DEVICE} device skipped.
    Power On
    Make Sure That Network Boot Is Enabled
    Boot Dasharo Tools Suite    iPXE
    # Starting SSH server
    Write Bare Into Terminal    K
    Read From Terminal Until    Press Enter to continue.
    Press Enter
    Enter Shell In DTS
    VAR    ${openwrt_image_gz}=    ${OPENWRT_IMAGE_FILE}    .gz    separator=${EMPTY}
    Remove File    ${openwrt_image_gz}
    Remove File    ${OPENWRT_IMAGE_FILE}
    VAR    ${DEVICE_OS_USERNAME}=    root    scope=TEST
    VAR    ${DEVICE_OS_PASSWORD}=    ${EMPTY}    scope=TEST
    Send File To DUT    osfv-test-data/openwrt/${openwrt_image_gz}    /${openwrt_image_gz}
    Execute Linux Command    gzip -cdk ${openwrt_image_gz} | dd of=/dev/${OPENWRT_TARGET_DEVICE} bs=1M
    Execute Linux Command    sync
    Execute Reboot Command
    Boot OpenWrt
    # Disabling DHCP server of OpenWrt
    Execute Command In Terminal    /etc/init.d/odhcpd disable
    Execute Command In Terminal    /etc/init.d/odhcpd stop
    # Enabling DHCP client for all LAN interfaces
    Execute Command In Terminal    uci set network.lan.proto="dhcp"
    Execute Command In Terminal    uci commit network
    Execute Command In Terminal    service network restart

OWR002.207 Boot operating system from disk (OpenWrt)
    [Documentation]    Boot installed OpenWrt from NVMe drive, check identity.
    Skip If    not ${TESTS_IN_OPENWRT_SUPPORT}    OWR002.207 not supported
    Power On
    Boot OpenWrt
    ${out}=    Execute Command In Terminal    uname -a
    Should Contain    ${out}    OpenWrt

OWR003.207 Boot operating system from disk after cold-boot (OpenWrt)
    [Documentation]    Boot OpenWrt from hard disk after cold-boot.
    Skip If    not ${TESTS_IN_OPENWRT_SUPPORT}    OWR003.207 not supported
    Power On
    Boot OpenWrt
    Execute Cold Boot
    ${start_date}=    Get Current Date
    Boot OpenWrt
    ${end_date}=    Get Current Date
    ${delta_time}=    Subtract Date From Date    ${end_date}    ${start_date}
    Log To Console    Cold boot duration in seconds: ${delta_time}

OWR004.207 Boot operating system from disk after warm-boot (OpenWrt)
    [Documentation]    Boot OpenWrt from hard disk after warm-boot.
    Skip If    not ${TESTS_IN_OPENWRT_SUPPORT}    OWR004.207 not supported
    Power On
    Boot OpenWrt
    Download File OpenWrt    https://cloud.3mdeb.com/public.php/dav/files/Aqe5Xj24pkoYLwX    /bin/rtcwake
    Execute Command In Terminal    chmod +x /bin/rtcwake
    Perform Warmboot Using Rtcwake
    ${start_date}=    Get Current Date
    Boot OpenWrt
    ${end_date}=    Get Current Date
    ${delta_time}=    Subtract Date From Date    ${end_date}    ${start_date}
    Log To Console    Warm boot duration in seconds: ${delta_time}

OWR005.207 Boot operating system from disk after reboot (OpenWrt)
    [Documentation]    Boot OpenWrt from hard disk after reboot.
    Skip If    not ${TESTS_IN_OPENWRT_SUPPORT}    OWR005.207 not supported
    Power On
    Boot OpenWrt
    Execute Command In Terminal    reboot
    ${start_date}=    Get Current Date
    Boot OpenWrt
    ${end_date}=    Get Current Date
    ${delta_time}=    Subtract Date From Date    ${end_date}    ${start_date}
    Log To Console    Reboot duration in seconds: ${delta_time}

OWR006.207 Scan WiFi networks (OpenWrt)
    [Documentation]    Enable WiFi and scan for 3mdeb lab network.
    Skip If    not ${TESTS_IN_OPENWRT_SUPPORT}    OWR006.207 not supported
    Power On
    Boot OpenWrt
    Enable WiFi OpenWrt
    Scan WiFi For Network OpenWrt    ${3_MDEB_WIFI_NETWORK}

OWR007.207 Ethernet controller detection (OpenWrt)
    [Documentation]    Check presence of ethernet controller using lspci.
    ...    Install pciutils if missing. Controller name defined in OPENWRT_ETHERNET_CONTROLLER.
    Skip If    not ${TESTS_IN_OPENWRT_SUPPORT}    OWR007.207 not supported
    Variable Should Exist    ${OPENWRT_ETHERNET_CONTROLLER}
    Power On
    Boot OpenWrt
    Detect Or Install Package OpenWrt    pciutils
    ${lspci_out}=    Execute Command In Terminal    lspci
    Should Contain    ${lspci_out}    ${OPENWRT_ETHERNET_CONTROLLER}
