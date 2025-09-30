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
flashrom -p internal --flash-name 1
flashrom -p internal -c W25Q64BV/W25Q64CV/W25Q64FV --flash-name 0
flashrom -p internal -c W25Q64BV/W25Q64CV/W25Q64FV --flash-size 0
fsread_tool test -d /sys/firmware/efi 1
flashrom -p internal:boardmismatch=force -c W25Q64BV/W25Q64CV/W25Q64FV -r /tmp/dts-temp-files/rom_seabios_check 0
cbfstool /tmp/dts-temp-files/rom_seabios_check extract -n config -f /tmp/dts-temp-files/config 0
flashrom -p internal:boardmismatch=force -c W25Q64BV/W25Q64CV/W25Q64FV 0
flashrom -p internal:boardmismatch=force -c W25Q64BV/W25Q64CV/W25Q64FV 0
cbfstool /tmp/biosupdate extract -r COREBOOT -n config -f /tmp/biosupdate_config 0
flashrom -p internal:boardmismatch=force -c W25Q64BV/W25Q64CV/W25Q64FV -r /tmp/dasharo_dump.rom --fmap -i FMAP -i BOOTSPLASH 1
cbfstool /tmp/dasharo_dump.rom extract -r BOOTSPLASH -n logo.bmp -f /tmp/logo.bmp 1
flashrom -p internal:boardmismatch=force -c W25Q64BV/W25Q64CV/W25Q64FV -w /tmp/biosupdate 0
reboot  0
dmidecode  0
