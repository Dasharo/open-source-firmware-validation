*** Variables ***

# Basic communication variables

${dut_connection_method}                pikvm
${payload}                              tianocore
${rte_s2n_port}                         13541
${flash_size}                           ${32*1024*1024}
${tianocore_string}                     to boot directly
${boot_menu_key}                        F11

# Regression test flags
# Default flashing method


# Test module: Dasharo Compatibility

# Test module: Dasharo Security

# Test module: Dasharo Performance

# Dasharo Performance counters

**Keywords**

Power On
    [Documentation]    Keyword clears buffers and sets the Device Under Test
    ...                into Power On state using RTE OC buffers. Implementation
    ...                must be compatible with the theory of operation of a
    ...                specific platform.
    Return From Keyword If    '${dut_connection_method}' == 'SSH'
    Sleep    2s
    RteCtrl Power Off
    Sleep    5s
    Telnet.Read
    RteCtrl Power On

Read firmware with internal programmer
    [Documentation]    Keyword reads firmware based on the internal programmer
    ...                - flashrom - installed in the Operating System.
    No operation

Read firmware with external programmer
    [Documentation]    Keyword reads firmware based on external programmer.
    ...                Implementation must be compatible with the theory of
    ...                operation of a specific platform.
    No operation

Flash firmware with internal programmer
    [Documentation]    Keyword flashes firmware to the DUT based on the
    ...                internal programmer - flashrom - installed in the
    ...                Operating System.
    No operation

Flash firmware with external programmer
    [Documentation]    Keyword flashes firmware to the DUT based on the
    ...                external programmer. Implementation must be compatible
    ...                with the theory of operation of a specific platform.
    No operation


