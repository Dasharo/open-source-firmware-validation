dmidecode -s system-manufacturer 0
dmidecode -s system-product-name 0
dmidecode -s baseboard-product-name 0
dmidecode -s processor-version 0
dmidecode -s bios-vendor 0
dmidecode -s bios-version 0
fsread_tool test -f /sys/firmware/efi/efivars/FirmwareUpdateMode-d15b327e-ff2d-4fc1-abf6-c12bd08c1359 1
dmidecode -s system-manufacturer 0
dmidecode -s system-product-name 0
dmidecode -s baseboard-product-name 0
dmidecode -s processor-version 0
dmidecode -s bios-vendor 0
dmidecode -s bios-version 0
dmidecode  0
dmidecode  0
dmidecode -s system-manufacturer 0
dmidecode -s system-product-name 0
dmidecode -s baseboard-product-name 0
dmidecode -s processor-version 0
dmidecode -s bios-vendor 0
dmidecode -s bios-version 0
lspci -nnvvvxxxx 0
lsusb -vvv 0
superiotool -deV 0
ectool -ip 0
msrtool  1
dmidecode  0
dmesg  0
fsread_tool test -f /sys/class/sound/card0/hw*/init_pin_configs 1
fsread_tool test -f /sys/class/sound/card0/hw*/init_pin_configs 1
fsread_tool test -f /sys/class/sound/card0/hw*/init_pin_configs 1
fsread_tool test -f /sys/class/sound/card0/hw*/init_pin_configs 1
fsread_tool test -f /sys/class/sound/card0/hw*/init_pin_configs 1
fsread_tool test -f /sys/class/sound/card0/hw*/init_pin_configs 1
fsread_tool test -f /sys/class/sound/card0/hw*/init_pin_configs 1
fsread_tool test -f /sys/class/sound/card0/hw*/init_pin_configs 1
fsread_tool test -f /sys/class/sound/card0/hw*/init_pin_configs 1
fsread_tool test -f /sys/class/sound/card0/hw*/init_pin_configs 1
fsread_tool test -f /sys/class/sound/card0/hw*/init_pin_configs 1
fsread_tool test -f /sys/class/sound/card0/hw*/init_pin_configs 1
flashrom -p internal --flash-name 0
flashrom -p internal --flash-size 0
flashrom -p internal 0
flashrom -V -p internal:laptop=force_I_want_a_brick -r logs/rom.bin --ifd -i fd -i bios -i me -i gbe 0
dmesg  0
cbmem  1
cbmem -1 1
mei-amt-check  1
intelmetool -m 0
dmidecode -s system-manufacturer 0
dmidecode -s system-product-name 0
dmidecode -s bios-version 0
dmidecode -s system-product-name 0
dmidecode -s system-manufacturer 0
dmidecode -s system-manufacturer 0
dmidecode -s system-product-name 0
dmidecode -s baseboard-product-name 0
dmidecode -s processor-version 0
dmidecode -s bios-vendor 0
dmidecode -s bios-version 0
fsread_tool test -f /sys/class/mei/mei0/fw_status 1
flashrom -p internal --flash-name 0
flashrom -p internal --flash-size 0
fsread_tool test -e /sys/class/power_supply/AC/online 1
flashrom -p internal 0
flashrom -p internal -r /fw_backup/rom.bin --ifd -i fd -i bios -i me -i gbe 0
flashrom -p internal 0
flashrom -p internal 0
ifdtool -d /tmp/biosupdate 1
fsread_tool test -d /sys/class/pci_bus/0000:00/device/0000:00:16.0 1
cbmem -1 1
cbmem -1 1
cbfstool /tmp/biosupdate extract -r COREBOOT -n config -f /tmp/biosupdate_config 0
dmidecode -s system-uuid 0
dmidecode -s baseboard-serial-number 0
cbfstool /tmp/biosupdate layout -w 0
cbfstool /tmp/biosupdate layout -w 0
cbfstool /tmp/biosupdate layout -w 0
cbfstool /tmp/biosupdate add -f /tmp/serial_number.txt -n serial_number -t raw -r COREBOOT 0
cbfstool /tmp/biosupdate add -f /tmp/system_uuid.txt -n system_uuid -t raw -r COREBOOT 0
cbfstool /tmp/biosupdate add -f /tmp/_O9010A30.exe.extracted/65C10_output/pfsobject/section-7ec6c2b0-3fe3-42a0-a316-22dd0517c1e8/volume-0x50000/file-d386beb8-4b54-4e69-94f5-06091f67e0d3/section0.raw -n sch5545_ecfw.bin -t raw 1
cbfstool /tmp/biosupdate add -f /tmp/_O9010A30.exe.extracted/65C10_output/pfsobject/section-7ec6c2b0-3fe3-42a0-a316-22dd0517c1e8/volume-0x500000/file-2d27c618-7dcd-41f5-bb10-21166be7e143/object-0.raw -n txt_bios_acm.bin -t raw -a 0x20000 1
cbfstool /tmp/biosupdate add -f /tmp/SNB_IVB_SINIT_20190708_PW.bin -n txt_sinit_acm.bin -t raw -c lzma 0
flashrom -p internal -N --ifd -i bios -w /tmp/biosupdate 0
reboot  0
dmidecode  0
