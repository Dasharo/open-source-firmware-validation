*** Settings ***
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Resource            ../lib/common.robot

Suite Setup         Disk IO Suite Setup
Suite Teardown      Log Out And Close Connection


*** Variables ***
${FIO_LATEST_RELEASE_URL}=      https://api.github.com/repos/axboe/fio/releases/latest
${RESULTS_DIR_UBUNTU}=          ~/fio_results
${RESULTS_DIR_WINDOWS}=         C:\fio-results


*** Test Cases ***
DIO001.001 Sequential Read Performance (Ubuntu) (AC)
    [Documentation]    Check various scenarios of single threaded read
    ...    performance, while connected to power supply unit. (Ubuntu)
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Power Cycle Into Ubuntu
    Run FIO On Ubuntu    sequential_with_queues
    ...    --rw=read --bs=1M --iodepth=32 --numjobs=1 --size=4G
    Run FIO On Ubuntu    sequential_without_queues
    ...    --rw=read --bs=1M --iodepth=1 --numjobs=1 --size=4G
    Run FIO On Ubuntu    sequential_with_queues_mt
    ...    --rw=read --bs=1M --iodepth=32 --numjobs=${DEF_THREADS_TOTAL} --size=4G

DIO001.002 Sequential Read Performance (Ubuntu) (Battery)
    [Documentation]    Check various scenarios of single threaded read
    ...    performance, while powered by inbuilt battery. (Ubuntu)
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Power Cycle Into Ubuntu
    Switch To Root User

DIO001.003 Sequential Read Performance (Windows) (AC)
    [Documentation]    Check various scenarios of single threaded read
    ...    performance, while connected to power supply unit. (Windows)
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    Power Cycle Into Windows

DIO001.004 Sequential Read Performance (Windows) (Battery)
    [Documentation]    Check various scenarios of single threaded read
    ...    performance, while powered by inbuilt battery. (Windows)
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Power Cycle Into Windows

DIO002.001 Sequential Write Performance (Ubuntu) (AC)
    [Documentation]    Check various scenarios of multi threaded read
    ...    performance, while connected to power supply unit. (Ubuntu)
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Power Cycle Into Ubuntu
    Switch To Root User
    Run FIO On Ubuntu    rst_ubuntu_ac    read    1    ${DEF_THREADS_TOTAL}    4k
    #    Run FIO Test    seq_write    --rw=write --bs=1M --iodepth=1 --numjobs=1 --size=10G

DIO002.002 Sequential Write Performance (Ubuntu) (Battery)
    [Documentation]    Check various scenarios of multi threaded read
    ...    performance, while powered by inbuilt battery. (Ubuntu)
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Power Cycle Into Ubuntu
    Switch To Root User

DIO002.003 Sequential Write Performance (Windows) (AC)
    [Documentation]    Check various scenarios of multi threaded read
    ...    performance, while connected to power supply unit. (Windows)
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    Power Cycle Into Windows

DIO002.004 Sequential Write Performance (Windows) (Battery)
    [Documentation]    Check various scenarios of multi threaded read
    ...    performance, while powered by inbuilt battery. (Windows)
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Power Cycle Into Windows

DIO003.001 Random Read Performance (Ubuntu) (AC)
    [Documentation]    Check various scenarios of single threaded write
    ...    performance, while connected to power supply unit. (Ubuntu)
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Power Cycle Into Ubuntu
    Switch To Root User
    #    Run FIO Test    rand_read    --rw=randread --bs=4K --iodepth=32 --numjobs=4 --size=10G

DIO003.002 Random Read Performance (Ubuntu) (Battery)
    [Documentation]    Check various scenarios of single threaded write
    ...    performance, while powered by inbuilt battery. (Ubuntu)
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Power Cycle Into Ubuntu
    Switch To Root User

DIO003.003 Random Read Performance (Windows) (AC)
    [Documentation]    Check various scenarios of single threaded write
    ...    performance, while connected to power supply unit. (Windows)
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    Power Cycle Into Windows

DIO003.004 Random Read Performance (Windows) (Battery)
    [Documentation]    Check various scenarios of single threaded write
    ...    performance, while powered by inbuilt battery. (Windows)
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Power Cycle Into Windows

DIO004.001 Random Write Performance (Ubuntu) (AC)
    [Documentation]    Check various scenarios of multi threaded write
    ...    performance, while connected to power supply unit. (Ubuntu)
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Power Cycle Into Ubuntu
    Switch To Root User
    #    Run FIO Test    rand_write    --rw=randwrite --bs=4K --iodepth=32 --numjobs=4 --size=10G

DIO004.002 Random Write Performance (Ubuntu) (Battery)
    [Documentation]    Check various scenarios of multi threaded write
    ...    performance, while powered by inbuilt battery. (Ubuntu)
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Power Cycle Into Ubuntu
    Switch To Root User

DIO004.003 Random Write Performance (Windows) (AC)
    [Documentation]    Check various scenarios of multi threaded write
    ...    performance, while connected to power supply unit. (Windows)
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    Power Cycle Into Windows

DIO004.004 Random Write Performance (Windows) (Battery)
    [Documentation]    Check various scenarios of multi threaded write
    ...    performance, while powered by inbuilt battery.(Windows)
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Power Cycle Into Windows


*** Keywords ***
Disk IO Suite Setup
    [Documentation]    Load config and download tooling for both windows
    ...    ubuntu.
    Prepare Test Suite
    Skip If    not ${DISK_IO_PERFORMANCE_TESTS}
    ...    Disk IO tests not enabled for this platform config
    IF    ${TESTS_IN_UBUNTU_SUPPORT}
        Power Cycle Into Ubuntu
        Switch To Root User
        Detect Or Install Package    fio
        Exit From Root User
        Execute Linux Command    mkdir ${RESULTS_DIR_UBUNTU}
    END
    # IF    ${TESTS_IN_WINDOWS_SUPPORT}
    #     Power Cycle Into Windows
    #     Log    Hello
    # END

Run FIO On Ubuntu
    [Documentation]    Wrapper for /usr/bin/fio, with adjusted timeout.
    [Arguments]    ${test_name}    ${fio_args}
    # Example arguments we want to pass
    # --rw=randread --bs=4K --iodepth=32 --numjobs=4 --size=10G
    ${cmd}=    Set Variable    /usr/bin/fio
    ${cmd}=    Catenate    ${cmd}    --name=${test_name}
    ${cmd}=    Catenate    ${cmd}    --ioengine=libaio --runtime=60s
    ${cmd}=    Catenate    ${cmd}    --direct=1 --group_reporting
    ${cmd}=    Catenate    ${cmd}    --output=${RESULTS_DIR_UBUNTU}/${test_name}.json
    ${cmd}=    Catenate    ${cmd}    --output-format=json
    ${cmd}=    Catenate    ${cmd}    ${fio_args}
    ${result}=    Execute Linux Command    ${cmd}    300

Run FIO On Windows
    [Documentation]    Wrapper for fio.exe, with adjusted timeout.
    [Arguments]    ${test_name}    ${fio_args}
    ${cmd}=    Set Variable    fio.exe
    ${cmd}+=    --name=${test_name}
    ${cmd}+=    --ioengine=windowsaio --runtime=60s
    ${cmd}+=    --direct=1 --group_reporting
    ${cmd}+=    --output=${RESULTS_DIR_WINDOWS}/${test_name}.json --output-format=json
    ${cmd}+=    ${fio_args}
    ${result}=    Execute Command In Terminal    ${cmd}    300
