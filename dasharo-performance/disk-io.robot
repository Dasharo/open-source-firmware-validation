*** Settings ***
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Resource            ../lib/performance/common.robot
Resource            ../lib/platform/power.robot

Suite Setup         Disk IO Suite Setup
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Variables ***
${FIO_LATEST_RELEASE_URL}=      https://api.github.com/repos/axboe/fio/releases/latest
${RESULTS_DIR_UBUNTU}=          fio_results
${RESULTS_DIR_WINDOWS}=         C:\fio-results


*** Test Cases ***
DIO001.201 Sequential Read Performance (Ubuntu) (AC)
    [Documentation]    Check various scenarios of single threaded read
    ...    performance, while connected to power supply unit. (Ubuntu)
    Sleep    20s
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${AC_CONNECTED}    The platform is not connected to AC
    Power Cycle Into Ubuntu
    Run FIO On Ubuntu    sequential_with_queues
    ...    --rw=read --bs=1M --iodepth=32 --numjobs=1 --size=2G
    Run FIO On Ubuntu    sequential_without_queues
    ...    --rw=read --bs=1M --iodepth=1 --numjobs=1 --size=2G
    ${seq_read_queued}=    Parse FIO Result    sequential_with_queues.json    read
    ${seq_read_nonque}=    Parse FIO Result    sequential_without_queues.json    read
    Should Be True    ${seq_read_queued} >= ${UBU_SEQ_READ_QUEUED}*0.85    Sequential Read Queued is below expected
    Should Be True    ${seq_read_nonque} >= ${UBU_SEQ_READ_NONQUE}*0.85    Sequential Read Non-Queued is below expected

DIO002.201 Sequential Read Performance (Ubuntu) (Battery)
    [Documentation]    Check various scenarios of single threaded read
    ...    performance, while powered by inbuilt battery. (Ubuntu)
    Sleep    20s
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Skip If    ${AC_CONNECTED}    The platform is not connected to AC
    Skip If Battery Level Below 30 Percent
    Power Cycle Into Ubuntu
    Switch To Root User
    Run FIO On Ubuntu    sequential_with_queues
    ...    --rw=read --bs=1M --iodepth=32 --numjobs=1 --size=4G
    Run FIO On Ubuntu    sequential_without_queues
    ...    --rw=read --bs=1M --iodepth=1 --numjobs=1 --size=4G
    Run FIO On Ubuntu    sequential_with_queues_mt
    ...    --rw=read --bs=1M --iodepth=32 --numjobs=${DEF_THREADS_TOTAL} --size=4G
    ${seq_read_queued}=    Parse FIO Result    sequential_with_queues.json    read
    ${seq_read_nonque}=    Parse FIO Result    sequential_without_queues.json    read
    Should Be True    ${seq_read_queued} >= ${UBU_SEQ_READ_QUEUED}*0.85    Sequential Read Queued is below expected
    Should Be True    ${seq_read_nonque} >= ${UBU_SEQ_READ_NONQUE}*0.85    Sequential Read Non-Queued is below expected

DIO003.201 Sequential Write Performance (Ubuntu) (AC)
    [Documentation]    Check various scenarios of single-threaded write
    ...    performance while powered by AC adapter. (Ubuntu)
    Sleep    20s
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${AC_CONNECTED}    The platform is not connected to AC
    Power Cycle Into Ubuntu
    Switch To Root User
    Run FIO On Ubuntu    sequential_write_with_queues
    ...    --rw=write --bs=1M --iodepth=32 --numjobs=1 --size=4G
    Run FIO On Ubuntu    sequential_write_without_queues
    ...    --rw=write --bs=1M --iodepth=1 --numjobs=1 --size=4G
    Run FIO On Ubuntu    sequential_write_with_queues_mt
    ...    --rw=write --bs=1M --iodepth=32 --numjobs=${DEF_THREADS_TOTAL} --size=4G
    ${seq_write_queued}=    Parse FIO Result    sequential_write_with_queues.json    write
    ${seq_write_nonque}=    Parse FIO Result    sequential_write_without_queues.json    write
    Should Be True    ${seq_write_queued} >= ${UBU_SEQ_WRITE_QUEUED}*0.85    Sequential Write Queued is below expected
    Should Be True
    ...    ${seq_write_nonque} >= ${UBU_SEQ_WRITE_NONQUE}*0.85
    ...    Sequential Write Non-Queued is below expected

DIO004.201 Sequential Write Performance (Ubuntu) (Battery)
    [Documentation]    Check various scenarios of single threaded write
    ...    performance, while powered by inbuilt battery. (Ubuntu)
    Sleep    20s
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Skip If    ${AC_CONNECTED}    The platform is not connected to AC
    Skip If Battery Level Below 30 Percent
    Power Cycle Into Ubuntu
    Switch To Root User
    Run FIO On Ubuntu    sequential_write_with_queues
    ...    --rw=write --bs=1M --iodepth=32 --numjobs=1 --size=4G
    Run FIO On Ubuntu    sequential_write_without_queues
    ...    --rw=write --bs=1M --iodepth=1 --numjobs=1 --size=4G
    Run FIO On Ubuntu    sequential_write_with_queues_mt
    ...    --rw=write --bs=1M --iodepth=32 --numjobs=${DEF_THREADS_TOTAL} --size=4G
    ${seq_write_queued}=    Parse FIO Result    sequential_write_with_queues.json    write
    ${seq_write_nonque}=    Parse FIO Result    sequential_write_without_queues.json    write
    Should Be True    ${seq_write_queued} >= ${UBU_SEQ_WRITE_QUEUED}*0.85    Sequential Write Queued is below expected
    Should Be True
    ...    ${seq_write_nonque} >= ${UBU_SEQ_WRITE_NONQUE}*0.85
    ...    Sequential Write Non-Queued is below expected

DIO005.201 Random Read Performance (Ubuntu) (AC)
    [Documentation]    Check various scenarios of random read performance
    ...    while connected to power supply unit. (Ubuntu)
    Sleep    20s
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${AC_CONNECTED}    The platform is not connected to AC
    Power Cycle Into Ubuntu
    Switch To Root User
    Run FIO On Ubuntu    random_read_with_queues
    ...    --rw=randread --bs=1M --iodepth=32 --numjobs=1 --size=4G
    Run FIO On Ubuntu    random_read_without_queues
    ...    --rw=randread --bs=1M --iodepth=1 --numjobs=1 --size=4G
    Run FIO On Ubuntu    random_read_with_queues_mt
    ...    --rw=randread --bs=1M --iodepth=32 --numjobs=${DEF_THREADS_TOTAL} --size=4G
    ${rand_read_queued}=    Parse FIO Result    random_read_with_queues.json    read
    ${rand_read_nonque}=    Parse FIO Result    random_read_without_queues.json    read
    Should Be True    ${rand_read_queued} >= ${UBU_RAND_READ_QUEUED}*0.85    Random Read BW Queued is below expected
    Should Be True
    ...    ${rand_read_nonque} >= ${UBU_RAND_READ_NONQUE}*0.85
    ...    Random Read BW Non-Queued is below expected

DIO006.201 Random Read Performance (Ubuntu) (Battery)
    [Documentation]    Check various scenarios of random read performance
    ...    while running on battery power. (Ubuntu)
    Sleep    20s
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Skip If    ${AC_CONNECTED}    The platform is not connected to AC
    Skip If Battery Level Below 30 Percent
    Power Cycle Into Ubuntu
    Switch To Root User
    Run FIO On Ubuntu    random_read_with_queues
    ...    --rw=randread --bs=1M --iodepth=32 --numjobs=1 --size=4G
    Run FIO On Ubuntu    random_read_without_queues
    ...    --rw=randread --bs=1M --iodepth=1 --numjobs=1 --size=4G
    Run FIO On Ubuntu    random_read_with_queues_mt
    ...    --rw=randread --bs=1M --iodepth=32 --numjobs=${DEF_THREADS_TOTAL} --size=4G
    ${rand_read_queued}=    Parse FIO Result    random_read_with_queues.json    read
    ${rand_read_nonque}=    Parse FIO Result    random_read_without_queues.json    read
    Should Be True    ${rand_read_queued} >= ${UBU_RAND_READ_QUEUED}*0.85    Random Read BW Queued is below expected
    Should Be True
    ...    ${rand_read_nonque} >= ${UBU_RAND_READ_NONQUE}*0.85
    ...    Random Read BW Non-Queued is below expected

DIO007.201 Random Write Performance (Ubuntu) (AC)
    [Documentation]    Check various scenarios of random write performance
    ...    while connected to power supply unit. (Ubuntu)
    Sleep    20s
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${AC_CONNECTED}    The platform is not connected to AC
    Power Cycle Into Ubuntu
    Switch To Root User
    Run FIO On Ubuntu    random_write_with_queues
    ...    --rw=randwrite --bs=1M --iodepth=32 --numjobs=1 --size=4G
    Run FIO On Ubuntu    random_write_without_queues
    ...    --rw=randwrite --bs=1M --iodepth=1 --numjobs=1 --size=4G
    Run FIO On Ubuntu    random_write_with_queues_mt
    ...    --rw=randwrite --bs=1M --iodepth=32 --numjobs=${DEF_THREADS_TOTAL} --size=4G
    ${rand_write_queued}=    Parse FIO Result    random_write_with_queues.json    write
    ${rand_write_nonque}=    Parse FIO Result    random_write_without_queues.json    write
    Should Be True    ${rand_write_queued} >= ${UBU_RAND_WRITE_QUEUED}*0.85    Random Write BW Queued is below expected
    Should Be True
    ...    ${rand_write_nonque} >= ${UBU_RAND_WRITE_NONQUE}*0.85
    ...    Random Write BW Non-Queued is below expected

DIO008.201 Random Write Performance (Ubuntu) (Battery)
    [Documentation]    Check various scenarios of sequential write performance
    ...    while connected to power supply unit. (Ubuntu)
    Sleep    20s
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Skip If    ${AC_CONNECTED}    The platform is not connected to AC
    Skip If Battery Level Below 30 Percent
    Power Cycle Into Ubuntu
    Switch To Root User
    Run FIO On Ubuntu    random_write_with_queues
    ...    --rw=randwrite --bs=1M --iodepth=32 --numjobs=1 --size=4G
    Run FIO On Ubuntu    random_write_without_queues
    ...    --rw=randwrite --bs=1M --iodepth=1 --numjobs=1 --size=4G
    Run FIO On Ubuntu    random_write_with_queues_mt
    ...    --rw=randwrite --bs=1M --iodepth=32 --numjobs=${DEF_THREADS_TOTAL} --size=4G
    ${rand_write_queued}=    Parse FIO Result    random_write_with_queues.json    write
    ${rand_write_nonque}=    Parse FIO Result    random_write_without_queues.json    write
    Should Be True    ${rand_write_queued} >= ${UBU_RAND_WRITE_QUEUED}*0.85    Random Write BW Queued is below expected
    Should Be True
    ...    ${rand_write_nonque} >= ${UBU_RAND_WRITE_NONQUE}*0.85
    ...    Random Write BW Non-Queued is below expected

DIO001.003 Sequential Read Performance (Windows) (AC)
    [Documentation]    Check various scenarios of single threaded read
    ...    performance, while connected to power supply unit. (Windows)
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    Skip If    not ${AC_CONNECTED}    The platform is not connected to AC
    Power Cycle Into Windows
    Run FIO On Windows    sequential_with_queues
    ...    --rw=read --bs=1M --iodepth=32 --numjobs=1 --size=4G
    Run FIO On Windows    sequential_without_queues
    ...    --rw=read --bs=1M --iodepth=1 --numjobs=1 --size=4G
    Run FIO On Windows    sequential_with_queues_mt
    ...    --rw=read --bs=1M --iodepth=32 --numjobs=${DEF_THREADS_TOTAL} --size=4G

DIO001.004 Sequential Read Performance (Windows) (Battery)
    [Documentation]    Check various scenarios of single threaded read
    ...    performance, while powered by inbuilt battery. (Windows)
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Skip If    ${AC_CONNECTED}    The platform is not connected to AC
    Power Cycle Into Windows
    Run FIO On Windows    sequential_with_queues
    ...    --rw=read --bs=1M --iodepth=32 --numjobs=1 --size=4G
    Run FIO On Windows    sequential_without_queues
    ...    --rw=read --bs=1M --iodepth=1 --numjobs=1 --size=4G
    Run FIO On Windows    sequential_with_queues_mt
    ...    --rw=read --bs=1M --iodepth=32 --numjobs=${DEF_THREADS_TOTAL} --size=4G

DIO002.003 Sequential Write Performance (Windows) (AC)
    [Documentation]    Check various scenarios of multi threaded write
    ...    performance, while connected to power supply unit. (Windows)
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    Skip If    not ${AC_CONNECTED}    The platform is not connected to AC
    Power Cycle Into Windows
    Run FIO On Windows    sequential_write_with_queues
    ...    --rw=write --bs=1M --iodepth=32 --numjobs=1 --size=4G
    Run FIO On Windows    sequential_write_without_queues
    ...    --rw=write --bs=1M --iodepth=1 --numjobs=1 --size=4G
    Run FIO On Windows    sequential_write_with_queues_mt
    ...    --rw=write --bs=1M --iodepth=32 --numjobs=${DEF_THREADS_TOTAL} --size=4G
    Power Cycle Into Ubuntu    # as of march 4 2025, running tests on novacustom is rather
    # primitive and default starting point is ubuntu

DIO002.004 Sequential Write Performance (Windows) (Battery)
    [Documentation]    Check various scenarios of multi threaded write
    ...    performance, while powered by inbuilt battery. (Windows)
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Skip If    ${AC_CONNECTED}    The platform is not connected to AC
    Power Cycle Into Windows
    Run FIO On Windows    sequential_write_with_queues
    ...    --rw=write --bs=1M --iodepth=32 --numjobs=1 --size=4G
    Run FIO On Windows    sequential_write_without_queues
    ...    --rw=write --bs=1M --iodepth=1 --numjobs=1 --size=4G
    Run FIO On Windows    sequential_write_with_queues_mt
    ...    --rw=write --bs=1M --iodepth=32 --numjobs=${DEF_THREADS_TOTAL} --size=4G
    Power Cycle Into Ubuntu

DIO003.003 Random Read Performance (Windows) (AC)
    [Documentation]    Check various scenarios of single threaded write
    ...    performance, while connected to power supply unit. (Windows)
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    Skip If    not ${AC_CONNECTED}    The platform is not connected to AC
    Power Cycle Into Windows
    Run FIO On Windows    random_read
    ...    --rw=randread --bs=4K --iodepth=32 --numjobs=1 --size=10G
    Power Cycle Into Ubuntu

DIO003.004 Random Read Performance (Windows) (Battery)
    [Documentation]    Check various scenarios of single threaded write
    ...    performance, while powered by inbuilt battery. (Windows)
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Skip If    ${AC_CONNECTED}    The platform is not connected to AC
    Power Cycle Into Windows
    Run FIO On Windows    random_read
    ...    --rw=randread --bs=4K --iodepth=32 --numjobs=1 --size=10G
    Power Cycle Into Ubuntu

DIO004.003 Random Write Performance (Windows) (AC)
    [Documentation]    Check various scenarios of multi threaded write
    ...    performance, while connected to power supply unit. (Windows)
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    Skip If    not ${AC_CONNECTED}    The platform is not connected to AC
    Power Cycle Into Windows
    Run FIO On Windows    random_write
    ...    --rw=randwrite --bs=4K --iodepth=32 --numjobs=4 --size=10G
    Power Cycle Into Ubuntu

DIO004.004 Random Write Performance (Windows) (Battery)
    [Documentation]    Check various scenarios of multi threaded write
    ...    performance, while powered by inbuilt battery.(Windows)
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Skip If    ${AC_CONNECTED}    The platform is not connected to AC
    Power Cycle Into Windows
    Run FIO On Windows    random_write
    ...    --rw=randwrite --bs=4K --iodepth=32 --numjobs=4 --size=10G
    Power Cycle Into Ubuntu


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
        Execute Linux Command    mkdir ~/${RESULTS_DIR_UBUNTU}
    END
    Check Power Supply
    # IF    ${TESTS_IN_WINDOWS_SUPPORT}
    #    Power Cycle Into Windows
    #    Log    Hello
    # END

Run FIO On Ubuntu
    [Documentation]    Wrapper for /usr/bin/fio, with adjusted timeout.
    [Arguments]    ${fio_test_name}    ${fio_args}
    # Example arguments we want to pass
    # --rw=randread --bs=4K --iodepth=32 --numjobs=4 --size=10G
    Execute Linux Command    mkdir ~/${RESULTS_DIR_UBUNTU}
    Execute Linux Command    touch ~/${RESULTS_DIR_UBUNTU}/${fio_test_name}.json
    VAR    ${cmd}=    /usr/bin/fio
    VAR    ${cmd}=    ${cmd}    --name=${fio_test_name}    separator=${SPACE}
    VAR    ${cmd}=    ${cmd}    --ioengine=libaio --runtime=60s    separator=${SPACE}
    VAR    ${cmd}=    ${cmd}    --direct=1 --group_reporting    separator=${SPACE}
    VAR    ${cmd}=    ${cmd}    --output=${RESULTS_DIR_UBUNTU}/${fio_test_name}.json    separator=${SPACE}
    VAR    ${cmd}=    ${cmd}    --output-format=json    separator=${SPACE}
    VAR    ${cmd}=    ${cmd}    --unlink=1    separator=${SPACE}
    VAR    ${cmd}=    ${cmd}    --filename=testfile    separator=${SPACE}

    VAR    ${cmd}=    ${cmd}    ${fio_args}    separator=${SPACE}
    ${result}=    Execute Linux Command    ${cmd}    300
    Sleep    10s

Run FIO On Windows
    [Documentation]    Wrapper for fio.exe, with adjusted timeout.
    [Arguments]    ${fio_test_name}    ${fio_args}
    Execute Command In Terminal    ${RESULTS_DIR_WINDOWS}
    VAR    ${cmd}=    fio.exe --name=${fio_test_name}
    VAR    ${cmd}=    ${cmd} --ioengine=windowsaio --runtime=60s
    VAR    ${cmd}=    ${cmd} --direct=1 --group_reporting
    VAR    ${cmd}=    ${cmd} --output=${RESULTS_DIR_WINDOWS}/${fio_test_name}.json --output-format=json
    VAR    ${cmd}=    ${cmd} ${fio_args}

    ${result}=    Execute Command In Terminal    ${cmd}    300
    Log To Console    ${result}
    Sleep    10s

Parse FIO Result
    [Arguments]    ${filename}    ${operation}
    ${json_data}=    Execute Linux Command    cat ${RESULTS_DIR_UBUNTU}/${filename}
    ${parsed}=    Evaluate    json.loads("""${json_data}""")    json
    VAR    ${bw}=    ${parsed}[jobs][0][${operation}][bw]
    Sleep    10s
    RETURN    ${bw}/1024
