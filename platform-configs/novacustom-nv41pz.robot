*** Settings ***
Resource    include/novacustom-common.robot


*** Variables ***
# TODO check w/ hw
${CPU}=                             Intel(R) Core(TM) i5-1240P CPU
${INITIAL_CPU_FREQUENCY}=           2100
${DEF_CORES_PER_SOCKET}=            12
${DEF_THREADS_PER_CORE}=            2
${DEF_THREADS_TOTAL}=               16
# TODO: remove, the value below can be inferred from the one above
${DEF_ONLINE_CPU}=                  0-15
${DEF_SOCKETS}=                     1
${DEVICE_IP}=                       192.168.4.240

# Platform flashing flags

${CLEVO_BATTERY_CAPACITY}=          3200*1000
${DEVICE_NVME_DISK}=                Non-Volatile memory controller
${CLEVO_DISK}=                      Samsung SSD 980 PRO
${DEVICE_USB_KEYBOARD}=             Logitech, Inc. Keyboard K120
${CLEVO_USB_C_HUB}=                 4-port
${DEVICE_AUDIO1}=                   ALC256
${DEVICE_AUDIO2}=                   Alderlake-P HDMI
${3_MDEB_WIFI_NETWORK}=             3mdeb_abr
${SD_CARD_VENDOR}=                  TS-RDF5A
${SD_CARD_MODEL}=                   Transcend
${WIFI_CARD}=                       Intel(R) Wi-Fi 6 AX201 160MHz
${WIFI_CARD_UBUNTU}=                Intel Corporation Alder Lake-P PCH CNVi WiFi (rev 01)
${BLUETOOTH_CARD_UBUNTU}=           Intel Corp. AX201 Bluetooth
${DEVICE_AUDIO1_WIN}=               Realtek High Definition Audio
${USB_MODEL}=                       USB Flash Memory
${EXTERNAL_HEADSET}=                USB PnP Audio Device
${USB_DEVICE}=                      Kingston

${DMIDECODE_SERIAL_NUMBER}=         N/A
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v1.6.0
${DMIDECODE_PRODUCT_NAME}=          NV4xPZ
${DMIDECODE_RELEASE_DATE}=          03/17/2022
${DMIDECODE_MANUFACTURER}=          Notebook
${DMIDECODE_VENDOR}=                3mdeb
${DMIDECODE_FAMILY}=                Not Applicable
${DMIDECODE_TYPE}=                  Notebook
