*** Settings ***
Library         Collections
Library         Dialogs
Library         OperatingSystem
Library         Process
Library         String
Library         Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library         SSHLibrary    timeout=90 seconds
Library         RequestsLibrary
Resource        ../keywords.robot

Default Tags    automated


*** Test Cases ***
Setup Fwupd Embargo Config Linux
    VAR    ${embargo_config}=    [fwupd Remote]\\n
    ...    Enabled=true\\n
    ...    Title=Embargoed for 3mdeb\\n
    ...    RefreshInterval=3600\\n
    ...    MetadataURI=https://fwupd.org/downloads/firmware-3c81bfdc9db5c8a42c09d38091944bc1a05b27b0.xml.gz\\n
    ...    ReportURI=https://fwupd.org/lvfs/firmware/report\\n
    ...    OrderBefore=lvfs,fwupd\\n
    ...    separator=${EMPTY}
    Run    printf "${embargo_config}" > embargo.conf
