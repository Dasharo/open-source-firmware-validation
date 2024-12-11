*** Settings ***
Library     Telnet    timeout=20 seconds    connection_timeout=120 seconds
Resource    terminal.robot


*** Keywords ***
TrenchBoot Telnet Root Login
    [Documentation]    Telnet login for Trenchboot
    # The login is password-less which makes use of Telnet.Login very
    # inconvenient.
    Telnet.Set Prompt    root@tb:~#
    Telnet.Read Until    login:
    Telnet.Write    root
    # Try to work around prompt detection issues by first matching on a single
    # character.
    Telnet.Set Prompt    \#
    Telnet.Read Until Prompt
    # Now set the real prompt and tell dmesg to shut up.
    Telnet.Set Prompt    root@tb:~#
    Execute Command In Terminal    dmesg -n1
