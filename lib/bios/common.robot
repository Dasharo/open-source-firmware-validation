*** Settings ***
Documentation       Collection of keywords related to common firmware operations.

Library             Collections
Library             String


*** Keywords ***
Enter Boot Menu
    [Documentation]    Enter Boot Menu with tianocore boot menu key mapped in
    ...    keys list.
    Read From Terminal Until    ${FW_STRING}
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Single Key PiKVM    ${BOOT_MENU_KEY}
    ELSE
        Write Bare Into Terminal    ${BOOT_MENU_KEY}
    END
    IF    ${LAPTOP_EC_SERIAL_WORKAROUND} == ${TRUE}
        # FIXME: Laptop EC serial workaround
        Press Key N Times    1    ${ARROW_DOWN}
        Press Key N Times    1    ${ARROW_UP}
    END
