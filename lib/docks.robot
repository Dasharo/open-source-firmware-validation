***Keywords***
Has DisplayLink Driver Installed Linux
    [Documentation]    Keyword checks if package is installed
    # Assumption: Ubuntu or Ubuntu-derived distro
    ${out}=    Execute Linux Command    apt list
    Should Contain    ${out}    evdi

Ensure DisplayLink Driver Is Installed Linux
    [Documentation]    Keyword installs drivers if they're missing.
    TRY
        Has DisplayLink Driver Installed Linux
    EXCEPT
        Download File    https://www.synaptics.com/sites/default/files/Ubuntu/pool/stable/main/all/synaptics-repository-keyring.deb
        Execute Linux Command    apt install ./synapics-repository-keyring.deb
        Execute Linux Command    apt update
        Execute Linux Command    apt install displaylink-driver
        Execute Linux Command    modprobe evdi
    END

Check DisplayLink Dock In Linux
    [Documentation]    Keyword looks for any enabled outputs on connected
    ...    DisplayLink docks.
    Ensure DisplayLink Driver Is Installed Linux
    ${out}=    Execute Linux Command    cat /sys/devices/platform/evdi.*/drm/card*/card*-*/enabled
    Should Contain    ${out}    enabled
