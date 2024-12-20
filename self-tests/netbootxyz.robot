*** Settings ***
Documentation       This suite verifies the correct operation of keywords parsing Secure Boot menus from the lib/secure-boot-lib.robot.

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../pikvm-rest-api/pikvm_comm.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection
Test Setup          Run Keyword
...                     Make Sure That Network Boot Is Enabled


*** Test Cases ***
Enter Netboot.Xyz Menu
    [Documentation]    Test Enter Netboot.Xyz Menu kwd
    Power On
    Enter Netboot.Xyz Menu
    ${out}=    Read From Terminal Until    netboot.xyz [ enabled: true ]
    Should Contain    ${out}    netboot.xyz v2.x
    Should Contain    ${out}    Linux Network Installs (64-bit)
    Should Contain    ${out}    netboot.xyz [ enabled: true ]

Enter Netboot.Xyz Menu And Return Construction
    [Documentation]    Test Enter Netboot.Xyz Menu And Return Construction kwd
    Power On
    ${nb_menu}=    Enter Netboot.Xyz Menu And Return Construction
    Should Not Contain    ${nb_menu}    Default
    Should Not Contain    ${nb_menu}    Distributions
    Should Not Contain    ${nb_menu}    Tools
    Should Not Contain    ${nb_menu}    Signature Checks
    Should Contain    ${nb_menu}[-1]    netboot.xyz [ enabled: true ]

Enter Netboot.Xyz Linux Install Menu And Return Construction
    [Documentation]    Test Enter Netboot.Xyz Linux Install Menu And Return
    ...    Construction kwd
    Power On
    ${nb_menu}=    Enter Netboot.Xyz Linux Install Menu And Return Construction
    Should Contain    ${nb_menu}    AlmaLinux
    Should Contain    ${nb_menu}    Alpine Linux
    Should Contain    ${nb_menu}    Arch Linux
    Should Contain    ${nb_menu}    BlackArch
    Should Contain    ${nb_menu}    CentOS
    Should Contain    ${nb_menu}    Debian
    Should Contain    ${nb_menu}    Devuan
    Should Contain    ${nb_menu}    Fedora
    Should Contain    ${nb_menu}    Fedora CoreOS
    Should Contain    ${nb_menu}    Flatcar Container Linux
    Should Contain    ${nb_menu}    Gentoo
    Should Contain    ${nb_menu}    Harvester
    Should Contain    ${nb_menu}    IPFire
    Should Contain    ${nb_menu}    k3OS
    Should Contain    ${nb_menu}    Kali Linux
    Should Contain    ${nb_menu}    Mageia
    Should Contain    ${nb_menu}    NixOS
    Should Contain    ${nb_menu}    openEuler
    Should Contain    ${nb_menu}    openSUSE
    Should Contain    ${nb_menu}    Oracle Linux
    Should Contain    ${nb_menu}    Proxmox
    Should Contain    ${nb_menu}    Red Hat Enterprise Linux
    Should Contain    ${nb_menu}    Rocky Linux
    Should Contain    ${nb_menu}    Slackware
    Should Contain    ${nb_menu}    Talos
    Should Contain    ${nb_menu}    Tiny Core Linux
    Should Contain    ${nb_menu}    Ubuntu
    Should Contain    ${nb_menu}    VMware ESXi
    Should Contain    ${nb_menu}    VMware Photon
    Should Contain    ${nb_menu}    VyOS
    Should Contain    ${nb_menu}    Zen Installer Arch
    Should Not Contain    ${nb_menu}    ...

Enter Netboot.Xyz Linux Distro Install Menu And Return Construction (Debian)
    [Documentation]    Test Enter Netboot.Xyz Linux Install Menu And Return
    ...    Construction kwd
    Power On
    ${nb_menu}=    Enter Netboot.Xyz Linux Distro Install Menu And Return Construction    Debian
    Should Contain    ${nb_menu}    Debian 12.0 (bookworm)
    Should Contain    ${nb_menu}    Debian 11.0 (bullseye)
    Should Contain    ${nb_menu}    Debian 10.0 (buster)
    Should Contain    ${nb_menu}    Debian trixie (testing)
    Should Contain    ${nb_menu}    Debian sid (unstable)
    Should Contain    ${nb_menu}    Set release codename...
    Should Not Contain    ${nb_menu}    Latest Releases
    Should Not Contain    ${nb_menu}    Older Releases
    Should Not Contain    ${nb_menu}    Testing Releases

Enter Netboot.Xyz Linux Distro Install Menu And Return Construction (Ubuntu)
    [Documentation]    Test Enter Netboot.Xyz Linux Install Menu And Return
    ...    Construction kwd
    Power On
    ${nb_menu}=    Enter Netboot.Xyz Linux Distro Install Menu And Return Construction    Ubuntu
    Should Contain    ${nb_menu}    Ubuntu 24.10 Oracular Oriole
    Should Contain    ${nb_menu}    Ubuntu 24.04 LTS Noble Numbat
    Should Contain    ${nb_menu}    Ubuntu 22.04 LTS Jammy Jellyfish
    Should Contain    ${nb_menu}    Ubuntu 20.04 LTS Focal Fossa (Subiquity)
    Should Contain    ${nb_menu}    Ubuntu 20.04 LTS Focal Fossa (Legacy)
    Should Contain    ${nb_menu}    Ubuntu 18.04 LTS Bionic Beaver
    Should Contain    ${nb_menu}    Ubuntu 16.04 LTS Xenial Xerus
    Should Contain    ${nb_menu}    Set release codename...
    Should Not Contain    ${nb_menu}    Latest Releases
    Should Not Contain    ${nb_menu}    Older Releases
    Should Not Contain    ${nb_menu}    Testing Releases

Enter Netboot.Xyz Linux Distro Install Menu And Return Construction (Fedora)
    [Documentation]    Test Enter Netboot.Xyz Linux Install Menu And Return
    ...    Construction kwd
    Power On
    ${nb_menu}=    Enter Netboot.Xyz Linux Distro Install Menu And Return Construction    Fedora
    Should Contain    ${nb_menu}    Fedora 41
    Should Contain    ${nb_menu}    Fedora 40
    Should Contain    ${nb_menu}    Fedora rawhide
    Should Not Contain    ${nb_menu}    Latest Releases

# Enter Advanced Secure Boot Keys Management
#     [Documentation]    Test Enter Advanced Secure Boot Keys Management kwd
#     Power On
#     ${sb_menu}=    Enter Secure Boot Menu And Return Construction
#     Enter Advanced Secure Boot Keys Management    ${sb_menu}
#     ${out}=    Read From Terminal Until    Esc=Exit
#     Should Contain    ${out}    Advanced Secure Boot Keys Management
#     Should Contain    ${out}    Reset to default Secure Boot Keys
#     Should Contain    ${out}    Erase all Secure Boot Keys
# 
# Reset To Default Secure Boot Keys
#     [Documentation]    Test Reset To Default Secure Boot Keys kwd
#     Power On
#     ${sb_menu}=    Enter Secure Boot Menu And Return Construction
#     Enter Advanced Secure Boot Keys Management    ${sb_menu}
#     Reset To Default Secure Boot Keys
#     Save Changes And Reset    3
# 
#     Enter Secure Boot Menu
#     ${out}=    Read From Terminal Until    Esc=Exit
#     Should Not Contain    ${out}    To enable Secure Boot, set Secure Boot Mode to
#     Should Not Contain    ${out}    Custom and enroll the keys/PK first.
# 
# Erase All Secure Boot Keys
#     [Documentation]    Test Erase All Secure Boot Keys kwd
#     Power On
#     ${sb_menu}=    Enter Secure Boot Menu And Return Construction
#     Enter Advanced Secure Boot Keys Management    ${sb_menu}
#     Erase All Secure Boot Keys
#     Save Changes And Reset    3
# 
#     Enter Secure Boot Menu
#     ${out}=    Read From Terminal Until    Esc=Exit
#     Should Contain    ${out}    To enable Secure Boot, set Secure Boot Mode to
#     Should Contain    ${out}    Custom and enroll the keys/PK first.
# 
# Secure Boot Menu Parsing With Default Keys
#     Power On
#     ${sb_menu}=    Enter Secure Boot Menu And Return Construction
#     Enter Advanced Secure Boot Keys Management    ${sb_menu}
#     Reset To Default Secure Boot Keys
#     Save Changes And Reset    3
# 
#     ${sb_menu}=    Enter Secure Boot Menu And Return Construction
#     Should Not Contain    ${sb_menu}    Secure Boot Configuration
#     Should Match Regexp    ${sb_menu}[0]    ^Current Secure Boot State.*$
#     Should Match Regexp    ${sb_menu}[1]    ^Enable Secure Boot \\[.\\].*$
#     Should Match Regexp    ${sb_menu}[2]    ^Secure Boot Mode \\<.*\\>.*$
#     Should Not Contain    ${sb_menu}    To enable Secure Boot, set Secure Boot Mode to
#     Should Not Contain    ${sb_menu}    Custom and enroll the keys/PK first.
# 
# Secure Boot Menu Parsing With Erased Keys
#     [Documentation]    Test Enter Secure Boot Menu And Return Construction kwd
#     Power On
#     ${sb_menu}=    Enter Secure Boot Menu And Return Construction
#     Enter Advanced Secure Boot Keys Management    ${sb_menu}
#     Erase All Secure Boot Keys
#     Reset To Default Secure Boot Keys
#     Save Changes And Reset    3
# 
#     ${sb_menu}=    Enter Secure Boot Menu And Return Construction
#     Should Not Contain    ${sb_menu}    Secure Boot Configuration
#     Should Match Regexp    ${sb_menu}[0]    ^Current Secure Boot State.*$
#     Should Match Regexp    ${sb_menu}[1]    ^Secure Boot Mode \\<.*\\>.*$
#     Should Not Contain    ${sb_menu}    To enable Secure Boot, set Secure Boot Mode to
#     Should Not Contain    ${sb_menu}    Custom and enroll the keys/PK first.
# 
# Return Secure Boot State
#     [Documentation]    Test Return Secure Boot State kwd
#     Power On
#     ${sb_menu}=    Enter Secure Boot Menu And Return Construction
#     ${sb_state}=    Return Secure Boot State    ${sb_menu}
#     Should Contain Any    ${sb_state}    Enabled    Disabled
# 
# Make Sure That Keys Are Provisioned
#     [Documentation]    Test Make Sure That Keys Are Provisioned kwd
#     # 1. Erase All SB keys
#     Power On
#     ${sb_menu}=    Enter Secure Boot Menu And Return Construction
#     Enter Advanced Secure Boot Keys Management    ${sb_menu}
#     Erase All Secure Boot Keys
#     Exit From Current Menu
#     ${sb_menu}=    Get Secure Boot Menu Construction
#     Should Not Contain Any    ${sb_menu}    Enable Secure Boot [ ]    Enable Secure Boot [X]
# 
#     # 2. Call tke kwd and make sure that the keys are provisioned
#     ${sb_menu}=    Make Sure That Keys Are Provisioned    ${sb_menu}
#     Should Contain Any    ${sb_menu}    Enable Secure Boot [ ]    Enable Secure Boot [X]
# 
#     # 3. Restore default SB keys
#     Enter Advanced Secure Boot Keys Management    ${sb_menu}
#     Reset To Default Secure Boot Keys
#     Exit From Current Menu
#     ${sb_menu}=    Get Secure Boot Menu Construction
#     Should Contain Any    ${sb_menu}    Enable Secure Boot [ ]    Enable Secure Boot [X]
# 
#     # 4. Call tke kwd and make sure that the keys are still provisioned
#     ${sb_menu}=    Make Sure That Keys Are Provisioned    ${sb_menu}
#     Should Contain Any    ${sb_menu}    Enable Secure Boot [ ]    Enable Secure Boot [X]
# 
# Enable Secure Boot
#     [Documentation]    Test Enable Secure Boot kwd
#     Power On
#     ${sb_menu}=    Enter Secure Boot Menu And Return Construction
#     Enable Secure Boot    ${sb_menu}
#     Save Changes And Reset    2
# 
#     ${sb_menu}=    Enter Secure Boot Menu And Return Construction
#     ${sb_state}=    Return Secure Boot State    ${sb_menu}
#     Should Contain    ${sb_state}    Enabled
# 
# Disable Secure Boot
#     [Documentation]    Test Disable Secure Boot kwd
#     Power On
#     ${sb_menu}=    Enter Secure Boot Menu And Return Construction
#     Disable Secure Boot    ${sb_menu}
#     Save Changes And Reset    2
# 
#     ${sb_menu}=    Enter Secure Boot Menu And Return Construction
#     ${sb_state}=    Return Secure Boot State    ${sb_menu}
#     Should Contain    ${sb_state}    Disabled
# 
# Enable and Disable Secure Boot Multiple Times
#     [Documentation]    Test Enabling and Disabling Secure Boot 5 times
#     Power On
#     ${sb_menu}=    Enter Secure Boot Menu And Return Construction
#     FOR    ${index}    IN RANGE    5
#         Set Option State    ${sb_menu}    Enable Secure Boot    ${TRUE}
#         Save Changes And Reset    2
# 
#         ${sb_menu}=    Enter Secure Boot Menu And Return Construction
#         ${sb_state}=    Return Secure Boot State    ${sb_menu}
#         Should Contain    ${sb_state}    Enabled
# 
#         Set Option State    ${sb_menu}    Enable Secure Boot    ${FALSE}
#         Save Changes And Reset    2
# 
#         ${sb_menu}=    Enter Secure Boot Menu And Return Construction
#         ${sb_state}=    Return Secure Boot State    ${sb_menu}
#         Should Contain    ${sb_state}    Disabled
#     END
