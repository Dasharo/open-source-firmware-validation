*** Settings ***
Library     Telnet    timeout=20 seconds    connection_timeout=120 seconds
Resource    terminal.robot


*** Keywords ***
TrenchBoot Telnet Root Login
    [Documentation]    Telnet login for Trenchboot
    # The login is password-less which makes use of Telnet.Login very
    # inconvenient.
    Telnet.Read Until    login:
    Telnet.Write    root
    Telnet.Set Prompt    root@tb:~#
    Telnet.Write Bare    \n
    Telnet.Read Until Prompt
