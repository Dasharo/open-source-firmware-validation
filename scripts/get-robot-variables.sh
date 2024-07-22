#!/usr/bin/env bash

# ---Help Function---
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -p      Print all collected hardware information."
    echo "  -h      Display this help message."
    echo
    echo "Example:"
    echo "  $0 -p   # Run the script and print the hardware information."
    echo "  $0 -h   # Show this help message."
}

# Parse command-line arguments
while getopts ":ph" opt; do
    case ${opt} in
        p )
            PRINT=true
            ;;
        h )
            show_help
            exit 0
            ;;
        \? )
            echo "Invalid option: -$OPTARG" 1>&2
            show_help
            exit 1
            ;;
        : )
            echo "Invalid option: -$OPTARG requires an argument" 1>&2
            show_help
            exit 1
            ;;
    esac
done

# Collect WiFi card information using lspci command
WIFI_CARD_UBUNTU="$(lspci | grep "Network controller:" | awk -F ": " '{print $2}')"

# Collect Webcam information using lsusb command
WEBCAM_UBUNTU="$(lsusb | grep "Cam" | awk '{for (i=7; i<=NF; i++) printf $i" "; print ""}')"

# Collect Bluetooth card information using lsusb command
BLUETOOTH_CARD_UBUNTU="$(lsusb | grep "Bluetooth" | awk '{for (i=7; i<=NF; i++) printf $i" "; print ""}')"

# Collect USB keyboard information using lsusb command
DEVICE_USB_KEYBOARD="$(lsusb | grep -iE "Keyboard|Nano" | awk '{for (i=7; i<=NF; i++) printf $i" "; print ""}')"

# Collect NVMe disk information using lspci command
DEVICE_NVME_DISK="$(lspci | grep "Non-Volatile"| awk -F ": " '{print $2}')"

# Collect eMMC information from sysfs

EMMC_PATH="/sys/class/block/mmcblk0/device/name"
if [ -f "${EMMC_PATH}" ]; then
    E_MMC_NAME="$(cat ${EMMC_PATH})"
fi

# Collect LTE card information
LTE_CARDS=$(lsusb | grep -iv 'wired\|hub\|bluetooth\|ethernet\|dock\|camera\|receiver\|audio\|usb3' | awk '{print $NF}')
NMCLI_OUTPUT=$(nmcli | grep -iv '${LTE_CARDS}')

for LTE_CARD in ${LTE_CARDS}; do
    MATCHED_LINES=$(echo "${NMCLI_OUTPUT}" | grep "${LTE_CARD}")
done
LTE_CARD=$(echo "${MATCHED_LINES}" | awk -F'"' '{if (NF>2) print $2; else print $0}')

# Function to get the minimum and maximum CPU frequencies
get_cpu_frequencies() {
    local min_freq
    min_freq=$(sudo cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)

    local max_freq
    max_freq=$(sudo cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)

    echo $((min_freq / 1000)) $((max_freq / 1000))
}

# Function to get the initial CPU frequency
get_initial_cpu_frequency() {
    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq ]; then
        local initial_freq
        initial_freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)
        echo "$((initial_freq / 1000))"
    elif command -v cpufreq-info &> /dev/null; then
        local initial_freq
        initial_freq=$(cpufreq-info --min | awk '{print $NF}')
        echo "$((initial_freq / 1000))"
    else
        local initial_freq
        initial_freq=$(sudo lshw -C processor | grep "capacity" | head -1 | awk '{print $2}')
        echo "$initial_freq"
    fi
}

# Function to get the platform CPU speed
get_platform_cpu_speed() {
    local cpu_speed
    cpu_speed=$(lscpu | grep "CPU max MHz:" | awk '{print $4}')

    if [ -z "$cpu_speed" ]; then
        echo "No data"
        return 1
    fi

    local cpu_speed_ghz
    cpu_speed_ghz=$(awk -v speed="$cpu_speed" 'BEGIN {printf "%.2f", speed / 1000}')
    echo "$cpu_speed_ghz"
}

# Function to get RAM information
get_ram_info() {
    sudo dmidecode --type memory | awk -F": " '
    /Speed:/ {
        match($2, /[0-9]+/);
        speed = substr($2, RSTART, RLENGTH)
    }
    /Size:/ {
        match($2, /[0-9]+/);
        size = substr($2, RSTART, RLENGTH);
        size_mb = size * 1024
    }
    END { print speed, size_mb }
    '
}

# Collecting CPU information
CPU=$(grep -m 1 "model name" /proc/cpuinfo | awk -F": " '{print $2}')
DEF_CORES_PER_SOCKET=$(lscpu | grep "Core(s) per socket:" | awk '{print $4}')
DEF_THREADS_PER_CORE=$(lscpu | grep "Thread(s) per core:" | awk '{print $4}')
DEF_THREADS_TOTAL=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
DEF_SOCKETS=$(lscpu | grep "Socket(s):" | awk '{print $2}')
DEF_ONLINE_CPU="0-$((DEF_THREADS_TOTAL - 1))"

INITIAL_CPU_FREQUENCY=$(get_initial_cpu_frequency)
PLATFORM_CPU_SPEED=$(get_platform_cpu_speed)
read CPU_MIN_FREQUENCY CPU_MAX_FREQUENCY < <(get_cpu_frequencies)
read PLATFORM_RAM_SPEED PLATFORM_RAM_SIZE < <(get_ram_info)

# Collecting Manufacturer information
DMIDECODE_MANUFACTURER=$(sudo dmidecode -t baseboard | grep "Manufacturer:" | awk -F": " '{print $2}')
DMIDECODE_SERIAL_NUMBER=$(sudo dmidecode -t baseboard | grep "Serial Number:" | awk -F": " '{print $2}')
DMIDECODE_PRODUCT_NAME=$(sudo dmidecode -t baseboard | grep "Product Name:" | awk -F": " '{print $2}')
DMIDECODE_FAMILY=$(sudo dmidecode -t system | grep Family | awk -F ":" '{print $2}')
DMIDECODE_TYPE=$(sudo dmidecode -t chassis | grep Type | awk -F ":" '{print $2}')

# Collecting Audio device information
audio_device_names=$(aplay -l 2>/dev/null | awk -F'[][]' '/card [0-9]+: / {print $2}' | sort -u)

counter=0
while IFS= read -r audio_device_name; do
    ((counter++))
    eval "DEVICE_AUDIO$counter='$audio_device_name'"
done <<< "$audio_device_names"

# Print collected information if -p is provided
if [ "$PRINT" = true ]; then
    echo "-----------------------WiFi-------------------------"
    echo "\${WIFI_CARD_UBUNTU}= ${WIFI_CARD_UBUNTU}"
    echo
    echo "-----------------------Webcam-----------------------"
    echo "\${WEBCAM_UBUNTU}= ${WEBCAM_UBUNTU}"
    echo
    echo "-----------------------Bluetooth--------------------"
    echo "\${BLUETOOTH_CARD_UBUNTU}= ${BLUETOOTH_CARD_UBUNTU}"
    echo
    echo "-----------------------Keyboard---------------------"
    echo "\${DEVICE_USB_KEYBOARD}= ${DEVICE_USB_KEYBOARD}"
    echo
    echo "-----------------------NVMe Disk--------------------"
    echo "\${DEVICE_NVME_DISK}= ${DEVICE_NVME_DISK}"
    echo
    echo "-----------------------eMMC-------------------------"
    echo "\${E_MMC_NAME}= ${E_MMC_NAME}"
    echo
    echo "-----------------------LTE Card---------------------"
    echo "\${LTE_CARD}= ${LTE_CARD}"
    echo
    echo "-----------------------CPU---------------------------"
    echo "\${CPU}= ${CPU}"
    echo "\${INITIAL_CPU_FREQUENCY}= ${INITIAL_CPU_FREQUENCY} MHz"
    echo "\${PLATFORM_CPU_SPEED}= ${PLATFORM_CPU_SPEED} GHz"
    echo "\${CPU_MIN_FREQUENCY}= ${CPU_MIN_FREQUENCY} MHz"
    echo "\${CPU_MAX_FREQUENCY}= ${CPU_MAX_FREQUENCY} MHz"
    echo "\${PLATFORM_RAM_SPEED}= ${PLATFORM_RAM_SPEED} MHz"
    echo "\${PLATFORM_RAM_SIZE}= ${PLATFORM_RAM_SIZE} MB"
    echo
    echo "-----------------------DMIDECODE---------------------"
    echo "\${DMIDECODE_MANUFACTURER}= ${DMIDECODE_MANUFACTURER}"
    echo "\${DMIDECODE_SERIAL_NUMBER}= ${DMIDECODE_SERIAL_NUMBER}"
    echo "\${DMIDECODE_PRODUCT_NAME}= ${DMIDECODE_PRODUCT_NAME}"
    echo "\${DMIDECODE_FAMILY}= ${DMIDECODE_FAMILY}"
    echo "\${DMIDECODE_TYPE}= ${DMIDECODE_TYPE}"
    echo
    echo "-----------------------Defaults----------------------"
    echo "\${DEF_THREADS_TOTAL}= ${DEF_THREADS_TOTAL}"
    echo "\${DEF_THREADS_PER_CORE}= ${DEF_THREADS_PER_CORE}"
    echo "\${DEF_CORES_PER_SOCKET}= ${DEF_CORES_PER_SOCKET}"
    echo "\${DEF_SOCKETS}= ${DEF_SOCKETS}"
    echo "\${DEF_ONLINE_CPU}= ${DEF_ONLINE_CPU}"
    echo
    echo "-----------------------Audio Devices----------------"
    for i in $(seq 1 $counter); do
        eval "audio_device_name=\$DEVICE_AUDIO$i"
        echo "\${DEVICE_AUDIO$i}= $audio_device_name"
    done
fi

# Create Robot Framework file
output_dir="."
if [[ -n "$DMIDECODE_MANUFACTURER" && -n "$DMIDECODE_PRODUCT_NAME" ]]; then
    output_file="${DMIDECODE_MANUFACTURER}-${DMIDECODE_PRODUCT_NAME}.robot"
else
    output_file="sample-config.robot"
fi

get_unique_filename() {
    local file=$1
    local base_name=${file%.*}
    local extension=${file##*.}
    local counter=1

    while [[ -e "${base_name}.${extension}" ]]; do
        base_name="${file%.*}-${counter}"
        ((counter++))
    done
    echo "${base_name}.${extension}"
}

output_file=$(get_unique_filename "${output_dir}/${output_file}")

# Check if default.robot exists
default_robot_file="../platform-configs/include/default.robot"
if [[ -f "$default_robot_file" ]]; then
    default_robot_content=$(sed '1,6d' "$default_robot_file")
else
    default_robot_content=""  # Set empty content if file not found
fi

{
    echo "*** Variables ***"
    echo
    echo "# Automatically found variables"

    [[ -n "$INITIAL_CPU_FREQUENCY" ]] && echo "\${INITIAL_CPU_FREQUENCY}=                           $INITIAL_CPU_FREQUENCY"
    [[ -n "$PLATFORM_CPU_SPEED" ]] && echo "\${PLATFORM_CPU_SPEED}=                              $PLATFORM_CPU_SPEED"
    [[ -n "$CPU_MIN_FREQUENCY" ]] && echo "\${CPU_MIN_FREQUENCY}=                               $CPU_MIN_FREQUENCY"
    [[ -n "$CPU_MAX_FREQUENCY" ]] && echo "\${CPU_MAX_FREQUENCY}=                               $CPU_MAX_FREQUENCY"
    [[ -n "$PLATFORM_RAM_SPEED" ]] && echo "\${PLATFORM_RAM_SPEED}=                              $PLATFORM_RAM_SPEED"
    [[ -n "$PLATFORM_RAM_SIZE" ]] && echo "\${PLATFORM_RAM_SIZE}=                               $PLATFORM_RAM_SIZE"
    [[ -n "$WIFI_CARD_UBUNTU" ]] && echo "\${WIFI_CARD_UBUNTU}=                                $WIFI_CARD_UBUNTU"
    [[ -n "$WEBCAM_UBUNTU" ]] && echo "\${WEBCAM_UBUNTU}=                                   $WEBCAM_UBUNTU"
    [[ -n "$BLUETOOTH_CARD_UBUNTU" ]] && echo "\${BLUETOOTH_CARD_UBUNTU}=                           $BLUETOOTH_CARD_UBUNTU"
    [[ -n "$DEVICE_USB_KEYBOARD" ]] && echo "\${DEVICE_USB_KEYBOARD}=                             $DEVICE_USB_KEYBOARD"
    [[ -n "$DEVICE_NVME_DISK" ]] && echo "\${DEVICE_NVME_DISK}=                                $DEVICE_NVME_DISK"
    [[ -n "$E_MMC_NAME" ]] && echo "\${E_MMC_NAME}=                                      $E_MMC_NAME"
    [[ -n "$CPU" ]] && echo "\${CPU}=                                             $CPU"
    [[ -n "$DMIDECODE_MANUFACTURER" ]] && echo "\${DMIDECODE_MANUFACTURER}=                          $DMIDECODE_MANUFACTURER"
    [[ -n "$DMIDECODE_SERIAL_NUMBER" ]] && echo "\${DMIDECODE_SERIAL_NUMBER}=                         $DMIDECODE_SERIAL_NUMBER"
    [[ -n "$DMIDECODE_PRODUCT_NAME" ]] && echo "\${DMIDECODE_PRODUCT_NAME}=                          $DMIDECODE_PRODUCT_NAME"
    [[ -n "$DMIDECODE_FAMILY" ]] && echo "\${DMIDECODE_FAMILY}=                               $DMIDECODE_FAMILY"
    [[ -n "$DMIDECODE_TYPE" ]] && echo "\${DMIDECODE_TYPE}=                                 $DMIDECODE_TYPE"
    [[ -n "$DEF_THREADS_TOTAL" ]] && echo "\${DEF_THREADS_TOTAL}=                               $DEF_THREADS_TOTAL"
    [[ -n "$DEF_THREADS_PER_CORE" ]] && echo "\${DEF_THREADS_PER_CORE}=                            $DEF_THREADS_PER_CORE"
    [[ -n "$DEF_CORES_PER_SOCKET" ]] && echo "\${DEF_CORES_PER_SOCKET}=                            $DEF_CORES_PER_SOCKET"
    [[ -n "$DEF_SOCKETS" ]] && echo "\${DEF_SOCKETS}=                                     $DEF_SOCKETS"
    [[ -n "$DEF_ONLINE_CPU" ]] && echo "\${DEF_ONLINE_CPU}=                                  $DEF_ONLINE_CPU"

    for i in $(seq 1 $counter); do
        eval "audio_device_name=\$DEVICE_AUDIO$i"
        if [[ -n "$audio_device_name" ]]; then
            echo "\${DEVICE_AUDIO$i}=                                   $audio_device_name"
        fi
    done

    echo
    echo "# Default variables"

    awk -v keys="\
        INITIAL_CPU_FREQUENCY PLATFORM_CPU_SPEED CPU_MIN_FREQUENCY CPU_MAX_FREQUENCY \
        PLATFORM_RAM_SPEED PLATFORM_RAM_SIZE WIFI_CARD_UBUNTU WEBCAM_UBUNTU \
        BLUETOOTH_CARD_UBUNTU DEVICE_USB_KEYBOARD DEVICE_NVME_DISK E_MMC_NAME CPU \
        DMIDECODE_MANUFACTURER DMIDECODE_SERIAL_NUMBER DMIDECODE_PRODUCT_NAME \
        DMIDECODE_FAMILY DMIDECODE_TYPE \
        DEF_THREADS_TOTAL DEF_THREADS_PER_CORE DEF_CORES_PER_SOCKET DEF_SOCKETS \
        DEF_ONLINE_CPU DEVICE_AUDIO1 DEVICE_AUDIO2 DEVICE_AUDIO3" \
        '
        BEGIN { split(keys, arr); for (i in arr) exclude[arr[i]] = 1 }
        !/^(\$\{.*)=/ { print; next }
        {
            split($1, a, "}")
            if (!(a[1] in exclude)) print
        }' <<< "$default_robot_content"
} > "$output_file"

echo "Data has been written to ${output_file}"
