*** Settings ***
Library     BuiltIn
Library     Process


*** Keywords ***
Check If ME Is Disabled
    ${out}=    Run Process    /usr/sbin/setpci    -s    16.0    40.L
    RETURN    Should Not Be Equal As Strings    ${out.stdout}[3]    0
