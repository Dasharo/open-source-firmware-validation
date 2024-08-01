*** Comments ***
@@ -0,0 +1,23 @@


*** Settings ***
Library     BuiltIn
Library     Process


*** Keywords ***
Check ME State
    [Documentation]    Keyword Checks The ME PCI Register Offset 0x40 To Find Current ME State, Returns:
    ...    -Disabled (Soft) For 3
    ...    -Disabled (HAP) for 2
    ...    -Enabled for 0
    TRY
        ${out}=    Execute Command In Terminal    setpci -s 16.0 40.L
        ${char}=    Evaluate    ${out}[3]
        # Current Operation Mode: bits 16:19 of register HFSTS1 (0x40)
    EXCEPT    Evaluating expression 'p' failed: NameError: name 'p' is not defined nor importable as module
        ${char}=    Evaluate    2
    END
    IF    '${char}' == '3'
        ${result}=    Evaluate    'Disabled (Soft)'
    ELSE IF    '${char}' == '2'
        ${result}=    Evaluate    'Disabled (HAP)'
    ELSE IF    '${char}' == '0'
        ${result}=    Evaluate    'Enabled'
    END
    RETURN    ${result}
