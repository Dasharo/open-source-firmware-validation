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
fsread_tool test -e /sys/class/power_supply/AC/online 0
fsread_tool cat /sys/class/power_supply/AC/online 0
flashrom -p internal:boardmismatch=force 0
dasharo_ectool info 0
flashrom -p internal:boardmismatch=force -r /tmp/dasharo_dump.rom --fmap -i FMAP -i SMMSTORE 0
cbfstool /tmp/dasharo_dump.rom read -r SMMSTORE -f /tmp/smmstore.bin 0
cbfstool /tmp/biosupdate write -r SMMSTORE -f /tmp/smmstore.bin -u 0
flashrom -p internal:boardmismatch=force -r /tmp/dasharo_dump.rom --fmap -i FMAP -i BOOTSPLASH 0
cbfstool /tmp/dasharo_dump.rom extract -r BOOTSPLASH -n logo.bmp -f /tmp/logo.bmp 1
cbfstool /tmp/biosupdate extract -r COREBOOT -n config -f /tmp/biosupdate_config 0
flashrom -p internal:boardmismatch=force 0
ifdtool -d /tmp/biosupdate 0
fsread_tool test -d /sys/class/pci_bus/0000:00/device/0000:00:16.0 0
setpci -s 00:16.0 42.B 0
flashrom -p internal:boardmismatch=force -N --ifd -i bios -r /tmp/bios.bin 0
cbfstool /tmp/bios.bin layout -w 0
cbfstool /tmp/biosupdate layout -w 0
flashrom -p internal:boardmismatch=force -N --ifd -i fd -w /tmp/biosupdate 0
flashrom -p internal:boardmismatch=force --ifd -i bios -i fd -i me -w /tmp/biosupdate 0
flashrom -p internal:boardmismatch=force --ifd -i bios -i fd -i me -w /tmp/biosupdate 0
dasharo_ectool flash /tmp/ecupdate 0
reboot  0
dmidecode  0
