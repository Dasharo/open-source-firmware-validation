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
flashrom -p internal --flash-name 0
flashrom -p internal --flash-size 0
flashrom -p internal -r /tmp/dts-temp-files/rom_seabios_check 0
cbfstool /tmp/dts-temp-files/rom_seabios_check extract -n config -f /tmp/dts-temp-files/config 0
flashrom -p internal 0
flashrom -p internal 0
ifdtool -d /tmp/biosupdate 0
fsread_tool test -d /sys/class/pci_bus/0000:00/device/0000:00:16.0 0
setpci -s 00:16.0 42.B 0
cbfstool /tmp/biosupdate extract -r COREBOOT -n config -f /tmp/biosupdate_config 1
dmidecode -s system-uuid 0
dmidecode -s baseboard-serial-number 0
cbfstool /tmp/biosupdate layout -w 1
cbfstool /tmp/biosupdate layout -w 1
cbfstool /tmp/biosupdate layout -w 1
flashrom -p internal -N --ifd -i bios -i fd -w /tmp/biosupdate 0
reboot  0
dmidecode  0
