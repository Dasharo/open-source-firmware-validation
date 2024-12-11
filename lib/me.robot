*** Comments ***
@@ -0,0 +1,23 @@


*** Settings ***
Library     BuiltIn
Library     Process


*** Variables ***
${EXPECTED}=    00:16.0


*** Keywords ***
Check ME Out
    [Documentation]    Keyword Runs Lspci To Check Whether The ME Device
    ...    Exists Or Not
    ...
    ${out}=    Execute Command In Terminal    lspci
    ${condition}=    Evaluate    '${EXPECTED}' in """${out}"""
    IF    ${condition}
        ${out_data}=    Check ME State
    ELSE
        ${out_data}=    Evaluate    'Disabled'
    END
    RETURN    ${out_data}

Check ME State
    [Documentation]    Keyword Checks The ME PCI Register Offset 0x40 To Find Current ME State, Returns:
    ...    -Disabled (Soft) For 3
    ...    -Disabled (HAP) for 2
    ...    -Enabled for 0
    ${out}=    Execute Command In Terminal    setpci -s 16.0 40.L
    IF    "No devices selected for operation group 1." in """${out}"""
        ${result}=    Evaluate    'Disabled'
    ELSE
        ${char}=    Evaluate    ${out}[3]
        # Current Operation Mode: bits 16:19 of register HFSTS1 (0x40)
        IF    '${char}' == '3'
            ${result}=    Evaluate    'Disabled (Soft)'
        ELSE IF    '${char}' == '2'
            ${result}=    Evaluate    'Disabled (HAP)'
        ELSE IF    '${char}' == '0'
            ${result}=    Evaluate    'Enabled'
        END
    END
    RETURN    ${result}
