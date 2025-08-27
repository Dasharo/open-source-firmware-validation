dmidecode -s system-manufacturer 0
dmidecode -s system-product-name 0
dmidecode -s baseboard-product-name 0
dmidecode -s processor-version 0
dmidecode -s bios-vendor 0
dmidecode -s bios-version 0
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
flashrom -V -p internal:laptop=force_I_want_a_brick -r logs/rom.bin --ifd -i fd -i bios -i me 0
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
fsread_tool test -f /sys/class/mei/mei0/fw_status 0
fsread_tool cat /sys/class/mei/mei0/fw_status 0
rdmsr 0x13a -0 0
rdmsr 0x13a -0 0
flashrom -p internal --flash-name 0
flashrom -p internal --flash-size 0
fsread_tool test -e /sys/class/power_supply/AC/online 1
flashrom -p internal 0
flashrom -p internal -r /fw_backup/rom.bin --ifd -i fd -i bios -i me 0
flashrom -p internal 0
flashrom -p internal 0
ifdtool -d /tmp/biosupdate 0
fsread_tool test -d /sys/class/pci_bus/0000:00/device/0000:00:16.0 0
setpci -s 00:16.0 42.B 0
cbfstool /tmp/biosupdate extract -r COREBOOT -n config -f /tmp/biosupdate_config 0
cbfstool /tmp/biosupdate layout -w 0
flashrom -p internal -r /tmp/rom.bin --ifd -i bios 0
cbfstool /tmp/biosupdate write -r ROMHOLE -f /tmp/romhole.bin -u 0
flashrom -p internal -r /tmp/dasharo_dump.rom --ifd -i fd -i bios -i me --fmap -i FMAP -i BOOTSPLASH 1
cbfstool /tmp/dasharo_dump.rom extract -r BOOTSPLASH -n logo.bmp -f /tmp/logo.bmp 1
flashrom -p internal -N --ifd -i bios -N -w /tmp/biosupdate 0
reboot  0
dmidecode  0
