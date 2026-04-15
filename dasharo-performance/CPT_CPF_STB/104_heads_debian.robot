*** Settings ***
Metadata        ORDER_SENSITIVE

Resource        ./common.resource

Suite Setup     Run Keywords
...                 Prepare Test Suite
...                 AND    Skip If    not ${TESTS_IN_HEADS_SUPPORT}
...                 AND    Skip If    '${ENV_ID_DEBIAN}' not in ${TESTED_LINUX_DISTROS}
...                 AND    Skip If    not ${HEADS_BOOT_SUPPORT}    Heads+Debian tests not supported

Default Tags    semiauto


*** Test Cases ***
CPF001.209 CPU not stuck on initial frequency (Heads+Debian)
    [Documentation]    Check whether the CPU is not stuck on the initial
    ...    frequency after booting into Debian via Heads bootloader.
    Execute Manual Step    [1/5] Power on the DUT and boot into Debian via Heads bootloader
    Execute Manual Step    [2/5] Log in and open a terminal
    Execute Manual Step    [3/5] Run: cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq
    Execute Manual Step    [4/5] Apply some load: stress --cpu 1 --timeout 5
    Execute Manual Step
    ...    [5/5] Re-run the frequency check and confirm the CPU frequency has changed from the initial value

CPF002.209 CPU not stuck on initial frequency (Heads+Debian) (battery)
    [Documentation]    Check whether the CPU is not stuck on the initial
    ...    frequency after booting into Debian via Heads, while running on battery.
    Execute Manual Step    [1/5] Disconnect AC power and boot the DUT into Debian via Heads
    Execute Manual Step    [2/5] Log in and open a terminal
    Execute Manual Step    [3/5] Run: cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq
    Execute Manual Step    [4/5] Apply some load: stress --cpu 1 --timeout 5
    Execute Manual Step
    ...    [5/5] Re-run the frequency check and confirm the CPU frequency has changed from the initial value

CPF003.209 CPU not stuck on initial frequency (Heads+Debian) (AC)
    [Documentation]    Check whether the CPU is not stuck on the initial
    ...    frequency after booting into Debian via Heads, while connected to AC.
    Execute Manual Step    [1/5] Connect AC power and boot the DUT into Debian via Heads
    Execute Manual Step    [2/5] Log in and open a terminal
    Execute Manual Step    [3/5] Run: cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq
    Execute Manual Step    [4/5] Apply some load: stress --cpu 1 --timeout 5
    Execute Manual Step
    ...    [5/5] Re-run the frequency check and confirm the CPU frequency has changed from the initial value

CPF004.209 CPU not stuck on initial frequency (Heads+Debian) (USB-PD)
    [Documentation]    Check whether the CPU is not stuck on the initial
    ...    frequency after booting into Debian via Heads, while powered via USB-PD.
    Execute Manual Step    [1/5] Connect USB-PD power supply and boot the DUT into Debian via Heads
    Execute Manual Step    [2/5] Log in and open a terminal
    Execute Manual Step    [3/5] Run: cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq
    Execute Manual Step    [4/5] Apply some load: stress --cpu 1 --timeout 5
    Execute Manual Step
    ...    [5/5] Re-run the frequency check and confirm the CPU frequency has changed from the initial value
