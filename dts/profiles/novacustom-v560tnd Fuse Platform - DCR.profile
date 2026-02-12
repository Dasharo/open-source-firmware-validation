dmidecode -s system-manufacturer 0
dmidecode -s system-product-name 0
dmidecode -s baseboard-product-name 0
dmidecode -s processor-version 0
dmidecode -s bios-vendor 0
dmidecode -s bios-version 0
fsread_tool test -f /sys/firmware/efi/efivars/FirmwareUpdateModeRT-d15b327e-ff2d-4fc1-abf6-c12bd08c1359 1
fsread_tool test -f /sys/firmware/efi/efivars/FirmwareUpdateMode-d15b327e-ff2d-4fc1-abf6-c12bd08c1359 1
dmidecode -s system-manufacturer 0
dmidecode -s system-product-name 0
dmidecode -s baseboard-product-name 0
dmidecode -s processor-version 0
dmidecode -s bios-vendor 0
dmidecode -s bios-version 0
dmidecode  0
dmidecode -s system-manufacturer 0
dmidecode -s system-product-name 0
dmidecode -s baseboard-product-name 0
dmidecode -s processor-version 0
dmidecode -s bios-vendor 0
dmidecode -s bios-version 0
flashrom -p internal --flash-name 0
flashrom -p internal --flash-size 0
dmidecode -s baseboard-version 0
fsread_tool test -f /sys/class/mei/mei0/fw_status 1
flashrom -p internal:boardmismatch=force 0
fsread_tool test -d /sys/class/pci_bus/0000:00/device/0000:00:16.0 0
setpci -s 00:16.0 42.B 0
fsread_tool test -e /sys/class/power_supply/AC/online 0
fsread_tool cat /sys/class/power_supply/AC/online 0
dmidecode -s system-manufacturer 0
dmidecode -s system-product-name 0
dmidecode -s baseboard-product-name 0
dmidecode -s processor-version 0
dmidecode -s bios-vendor 0
dmidecode -s bios-version 0
btg_key_validator --file /tmp/biosupdate --key-hash e64b6b0e82c68fecc58f750d3696c26e1c98bf9e3149c81f3b2ed775eb9d2c157a99c103c62c44c0cdc61be971caeae1 0
cap_upd_tool /tmp/biosupdate 0
reboot  0
dmidecode  0
