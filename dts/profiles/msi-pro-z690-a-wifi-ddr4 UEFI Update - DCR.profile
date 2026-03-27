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
fsread_tool test -e /sys/class/power_supply/AC/online 1
flashrom -p internal 0
cbfstool /tmp/biosupdate layout -w 0
cbfstool /tmp/biosupdate print -r COREBOOT 0
flashrom -p internal -r /tmp/rom.bin --ifd -i bios 0
cbfstool /tmp/rom.bin layout -w 0
cbfstool /tmp/rom.bin read -r ROMHOLE -f /tmp/romhole.bin 0
cbfstool /tmp/biosupdate write -r ROMHOLE -f /tmp/romhole.bin -u 0
flashrom -p internal -r /tmp/dasharo_dump.rom --fmap -i FMAP -i SMMSTORE 0
cbfstool /tmp/dasharo_dump.rom read -r SMMSTORE -f /tmp/smmstore.bin 0
cbfstool /tmp/biosupdate write -r SMMSTORE -f /tmp/smmstore.bin -u 0
flashrom -p internal -r /tmp/dasharo_dump.rom --fmap -i FMAP -i BOOTSPLASH 1
cbfstool /tmp/dasharo_dump.rom extract -r BOOTSPLASH -n logo.bmp -f /tmp/logo.bmp 1
cbfstool /tmp/biosupdate extract -r COREBOOT -n config -f /tmp/biosupdate_config 0
flashrom -p internal 0
ifdtool -d /tmp/biosupdate 1
fsread_tool test -d /sys/class/pci_bus/0000:00/device/0000:00:16.0 1
cbmem -1 0
cbmem -1 0
flashrom -p internal -N --ifd -i bios -r /tmp/bios.bin 0
cbfstool /tmp/bios.bin layout -w 0
cbfstool /tmp/biosupdate layout -w 0
futility show /tmp/biosupdate 0
flashrom -p internal --ifd -i bios -r /tmp/bios.bin 0
futility show /tmp/bios.bin 0
flashrom -p internal --ifd -i bios -w /tmp/biosupdate 0
flashrom -p internal --ifd -i bios -w /tmp/biosupdate 0
reboot  0
dmidecode  0
