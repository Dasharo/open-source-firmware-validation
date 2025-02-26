*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../lib/common.robot

Suite Setup         CPU Performance Suite Setup
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
CPP001.001 Single Threaded CPU Benchmark (Ubuntu) (AC)
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Ubuntu, while connected to power supply.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Phoronix Test Suite (Ubuntu)
    #CPU Performance Suite Setup    # na dole, jest w suite setup
    Run C-Ray Single-thread 4K Render    # na dole

    # ${cmd}=    Set Variable    phoronix-test-suite pts/coremark
    # ${result}=    Execute Linux Command    ${cmd}    3600CPU Performance Suite Setup
{
# CPP001.002 Single Threaded CPU Benchmark (Ubuntu) (Battery)
#     [Documentation]    Test single threaded performance using phoronix
#     ...    test suite, for Ubuntu, while powered by inbuilt battery.
#     Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
#     Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
#     Skip If    not ${BATTERY_PRESENT}    Battery not present
#     Power Cycle Into Ubuntu

# CPP001.003 Single Threaded CPU Benchmark (Windows) (AC)
#     [Documentation]    Test single threaded performance using phoronix
#     ...    test suite, for Windows, while connected to power supply.
#     Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
#     Power Cycle Into Windows

# CPP001.004 Single Threaded CPU Benchmark (Windows) (Battery)
#     [Documentation]    Test single threaded performance using phoronix
#     ...    test suite, for Windows, while powered by inbuilt battery.
#     Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
#     Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
#     Skip If    not ${BATTERY_PRESENT}    Battery not present
#     Power Cycle Into Windows

# CPP002.001 Multi Threaded CPU Benchmark (Ubuntu) (AC)
#     [Documentation]    Test multi threaded performance using phoronix
#     ...    test suite, for Ubuntu, while connected to power supply.
#     Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
#     Power Cycle Into Ubuntu

# CPP002.002 Multi Threaded CPU Benchmark (Ubuntu) (Battery)
#     [Documentation]    Test multi threaded performance using phoronix
#     ...    test suite, for Ubuntu, while powered by inbuilt battery.
#     Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
#     Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
#     Skip If    not ${BATTERY_PRESENT}    Battery not present
#     Power Cycle Into Ubuntu

# CPP002.003 Multi Threaded CPU Benchmark (Windows) (AC)
#     [Documentation]    Test multi threaded performance using phoronix
#     ...    test suite, for Windows, while connected to power supply.
#     Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
#     Power Cycle Into Windows

# CPP002.004 Multi Threaded CPU Benchmark (Windows) (Battery)
#     [Documentation]    Test multi threaded performance using phoronix
#     ...    test suite, for Windows, while powered by inbuilt battery.
#     Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
#     Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
#     Skip If    not ${BATTERY_PRESENT}    Battery not present
#     Power Cycle Into Windows
}

*** Keywords ***
CPU Performance Suite Setup
    Prepare Test Suite
    Skip If    not ${CPU_PERFORMANCE_TESTS_SUPPORT}
    # Install phoronix-test-suite

Run C-Ray Single-thread 4K Render
    [Documentation]  Run C-Ray benchmark with 4K resolution and 1 thread
    Log To Console    \nRun: phoronix-test-suite batch-benchmark pts/c-ray
    ${cmd}=    Set Variable    echo 1 | phoronix-test-suite batch-benchmark pts/c-ray
    ${result}=    Execute Command In Terminal    ${cmd}
    # ${result}=    Execute Command In Terminal    ${cmd}    timeout=30
    # Log To Console    ${result}
    # Execute Command In Terminal     1
    # Execute Command In Terminal     y
    # Execute Command In Terminal     robotTest    timeout=60
    # Execute Command In Terminal    typical    timeout=60

# Run C-Ray Single-thread 4K Render
#     [Documentation]
#     #phoronix-test-suite run pts/c-ray --test render --resolution=3840x2160 --threads=1
#     Log To Console    \nRun: phoronix-test-suite run pts/c-ray --test render --resolution=3840x2160 --threads=1
#     ${cmd}=    Set Variable    phoronix-test-suite
#     ${cmd}=    Catenate    ${cmd}    run pts/c-ray
#     ${cmd}=    Catenate    ${cmd}    --test render
#     ${cmd}=    Catenate    ${cmd}    --resolution=3840x2160
#     ${cmd}=    Catenate    ${cmd}    --threads=1
#     ${cmd}=    Catenate    ${cmd}    --threads=1
#     ${result}=    Execute Linux Command    ${cmd}    300
#     Execute Linux Command    y    15
#     Execute Linux Command    robotTest    15
#     Execute Linux Command    typical    15

    # Would you like to save these test results (Y/n): y
    # Enter a name for the result file: hdRender1
    # Enter a unique name to describe this test run / configuration: typical

    # zaposuje w: var/lib/phoronix-test-suite/test-results/

    #przy 4k się zacina chyba albo trwa dużo dłyżej niż HD


7-Zip Multi-thread Compression Average
    Execute Command In Terminal    phoronix-test-suite run pts/7zip --test compression --threads=auto
    Log    ${result}

Detect Or Install Phoronix Test Suite (Ubuntu)
    [Documentation]    Detects and installs PTS
    ${out}=    Execute Linux Command    test -f /usr/bin/phoronix-test-suite && echo "PTS Installed"
    Run Keyword If    '${out}' != 'PTS Installed'    Install Phoronix Test Suite

Install Phoronix Test Suite
    Execute Linux Command    wget https://github.com/phoronix-test-suite/phoronix-test-suite/archive/refs/tags/v10.8.4.zip
    Execute Linux Command    unzip v10.8.4.zip && cd phoronix-test-suite-10.8.4    #nie widzi ale komenda trwa więcej niż 30sec
    ${out}=    Execute Linux Command    sudo ./install-sh    #'sudo: ./install-sh: command not found' does not contain 'Phoronix Test Suite Installation Completed'
    Should Contain    ${out}    Phoronix Test Suite Installation Completed
    Execute Linux Command    apt-get install php-cli php-xml -y
    # Trzeba dodać sprawdzenie czy sie zainstalowało

    # Przy pierwszym puszczeniu pyta o instalowanie testów więc to trzeba też sprawdzić i zainstalować

# Detect Or Install Phoronix Test Suite (Ubuntu)
#     [Documentation]    Detects and installs PTS
#     ${out}=    Execute Linux Command    test -f /usr/bin/phoronix-test-suite && echo "PTS Installed"
#     IF    '${out}' == 'PTS Installed'
#         Execute Linux Command
#         ...    wget https://github.com/phoronix-test-suite/phoronix-test-suite/archive/refs/tags/v10.8.4.zip
#         Execute Linux Command
#         ...    unzip v10.8.4.zip && cd phoronix-test-suite-10.8.4
#         ${out}=    Execute Linux Command    sudo ./install-sh
#         Should Contain    ${out}    Phoronix Test Suite Installation Completed
#     END
