*** Settings ***
Documentation       Collection of keywords related to UEFI Secure Boot

Resource            ../keywords.robot


*** Variables ***
${SHIMX64_URL}=     https://cloud.3mdeb.com/index.php/s/TipPHgsCj6MCZHi/download/shimx64.efi
${GRUBX64_URL}=     https://cloud.3mdeb.com/index.php/s/e2JjYANjMsgyXtS/download/grubx64.efi


*** Keywords ***
Populate /EFI With System Folders
    [Documentation]    Adds all supported system folders and files to /EFI
    # given that most of our machines have ubuntu installed,
    # it's best not to mess with ubuntu EFI files in any way.
    Add System Folder To /EFI    manager    Suse
    Add System Folder To /EFI    windows
    Add System Folder To /EFI    manager    Redhat
    @{basic_linux}=    Create List
    ...    Fedora    opensuse    Redhat    Centos    qubes    DTS    debian
    FOR    ${system}    IN    @{basic_linux}
        Add System Folder To /EFI    linux    ${system}
    END

Add System Folder To /EFI
    [Documentation]    This keyword creates directories and .efi files for
    ...    given systems. Available options:
    ...    ${type} - linux, windows, manager (for handling linux boot managers)
    ...    ${folder_name} - usually simply system name, ignored for windows
    [Arguments]    ${type}    ${folder_name}=Microsoft

    IF    "${type}"=="windows"
        Execute Command In Terminal    mkdir Microsoft
        Execute Command In Terminal    mkdir Microsoft/Boot
        Execute Command In Terminal    wget ${SHIMX64_URL} -O Microsoft/Boot/bootmgfw.efi
    END
    IF    "${type}"=="manager"
        Execute Command In Terminal    mkdir ${folder_name}
        Execute Command In Terminal    wget ${SHIMX64_URL} -O ${folder_name}/elilo.efi
    END
    IF    "${type}"=="linux"
        Execute Command In Terminal    mkdir ${folder_name}
        Execute Command In Terminal    wget ${SHIMX64_URL} -O ${folder_name}/shimx64.efi
    END
    Execute Command In Terminal    wget ${GRUBX64_URL} -O ${folder_name}/grubx64.efi
    Execute Command In Terminal    cp -r ${folder_name}/ /boot/efi/EFI/
    Execute Command In Terminal    sync
    Execute Command In Terminal    rm ${folder_name} -r

Check Boot Menu For All Supported Systems
    [Documentation]    This keyword scans the boot menu, and depending on the
    ...    mode verifies that all or none of the supported OSes are listed.
    ...    Available modes:
    ...    normal - default, checks that all supported systems are listed in
    ...    boot menu
    ...    empty - expects the boot menu to be empty, no additional OSes listed
    ...    double_entry_check - additionally verifies there is only one entry
    ...    per OS
    [Arguments]    ${mode}=normal

    # You need to scroll down to see some of the entries. As a result,
    # simply getting a single menu construction won't do.

    IF    "${mode}"!="empty"
        ${boot_list_a}=    Get Boot Menu Construction
        Press Key N Times    1    ${ARROW_UP}
        ${boot_list_b}=    Get Menu Construction    Qubes OS    0    0
        ${boot_list}=    Merge Two Lists    ${boot_list_a}    ${boot_list_b}
    ELSE
        ${boot_list}=   Get Boot Menu Construction
    END

    IF    "${mode}"=="empty"
        Only N Occurrences    ${boot_list}    0    *Suse*
        Only N Occurrences    ${boot_list}    0    *RedHat*
    ELSE
        Only N Occurrences    ${boot_list}    2    *Suse*
        Only N Occurrences    ${boot_list}    2    *RedHat*
    END
    @{systems}=    Create List    Fedora    OpenSuse    Windows    CentOS
    ...    Dasharo Tools Suite    Debian    Ubuntu
    FOR    ${system}    IN    @{systems}
        IF    "${mode}"=="empty"
            Should Not Contain Match    ${boot_list}    *${system}*
        END
        IF    "${mode}"=="normal"
            Should Contain Match    ${boot_list}    *${system}*
        END
        IF    "${mode}"=="double_entry_check"
            Only N Occurrences    ${boot_list}    1    *${system}*
        END
    END

Only N Occurrences
    [Documentation]    This keyword ensures that there's Only N Occurrences
    ...    of a given entry in a list
    [Arguments]    ${list}    ${n}    ${entry}
    ${x}=    Get Match Count    ${list}    ${entry}
    Should Be Equal As Integers    ${x}    ${n}

Remove All Supported Systems From Efi
    @{systems}=    Create List
    ...    Fedora    Suse    opensuse    Microsoft
    ...    Redhat    Centos    qubes    DTS    debian
    FOR    ${system}    IN    @{systems}
        Remove System From Efi    ${system}
    END

Remove System From Efi
    [Arguments]    ${folder_name}
    Execute Command In Terminal    rm -r /boot/efi/EFI/${folder_name}

Upload And Mount Tinycore
    [Documentation]    Mounts a tiny bootable ISO as a flash stick for testing purposes.

    Upload Image To PiKVM    ${PIKVM_IP}
    ...    https://distro.ibiblio.org/tinycorelinux/14.x/x86/release/CorePlus-current.iso
    Mount Image On PiKVM    ${PIKVM_IP}    CorePlus-current.iso
