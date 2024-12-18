*** Settings ***
Resource    protectli-pro.robot
Resource    protectli-common.robot


*** Variables ***
${FLASH_SIZE}=                                      ${16*1024*1024}

${DEVICE_AUDIO1}=                                   Alderlake-P HDMI
${DEVICE_AUDIO1_WIN}=                               High Definition Audio Device
${INITIAL_CPU_FREQUENCY}=                           2600
${MAX_CPU_TEMP}=                                    82

${CPU_P_CORES_MAX}=                                 2
${CPU_E_CORES_MAX}=                                 8

${DMIDECODE_FIRMWARE_VERSION}=                      Dasharo (coreboot+UEFI) v0.9.0
${DMIDECODE_RELEASE_DATE}=                          07/01/2024

${EMMC_SUPPORT}=                                    ${FALSE}
${HYPER_THREADING_SUPPORT}=                         ${TRUE}
${INTEL_HYBRID_ARCH_SUPPORT}=                       ${TRUE}
@{ETH_PERF_PAIR_2_G}=                               enp5s0    enp6s0
@{ETH_PERF_PAIR_10_G}=                              enp2s0f0    enp2s0f1

${CUSTOM_FAN_CURVE_PERFORMANCE_MODE_SUPPORT}=       ${TRUE}
${CUSTOM_FAN_CURVE_SILENT_MODE_SUPPORT}=            ${TRUE}
${CUSTOM_FAN_CURVE_OFF_MODE_SUPPORT}=               ${TRUE}
${KERNEL_MODULE_IT87_SUPPORT}=                      ${TRUE}

# Variables used in lib/sensors to determine platform-specific methods of
# measuring temperatures, fans etc.

# Can be one of {`lm-sensors`, `hwmon`, `none`}
${CPU_TEMPERATURE_MEASUREMENT_METHOD}=              lm-sensors
# Has to be set if cpu temperature method is hwmon
${CPU_TEMPERATURE_MEASUREMENT_HWMON_PATH}=          none
# Can be one of {`hwmon`, `system76-acpi`, `none`}
${FAN_PWM_MEASUREMENT_METHOD}=                      none
# Has to be set if PWM measurement method is hwmon
${FAN_PWM_MEASUREMENT_HWMON_PATH}=                  none

# Can be one of {`lm-sensors`, `none`}
${FAN_RPM_MEASUREMENT_METHOD}=                      lm-sensors
# The name of the sensor in `sensors` command if FAN_RPM_MEASUREMENT_METHOD
# is set to lm-sensors. For example `w83795g-i2c-1-2f`. `none` if lm-sensors
# is not used
${FAN_RPM_MEASUREMENT_SENSOR}=                      it8786-isa-0a20
# Kernel module that might need to be enabled using modprobe in order to use
# the sensor. Dictionary keys:
# - module - name of the kernel module
# - force_id - optional force_id arg for modprobe
&{FAN_RPM_MEASUREMENT_SENSOR_MODULE}=               module=it87    force_id=0x8786
