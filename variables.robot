*** Variables ***
${PXE_IP}=                  192.168.20.206
${HTTP_PORT}=               8000
${FILENAME}=                menu.ipxe
${USERNAME}=                root
${PASSWORD}=                meta-rte
${MEMTEST_HEADER}=          Memtest86+ 5.01 coreboot
${DEBIAN_STABLE_VER}=       4.14.y
${TEARDOWN}=                no
${SNIPEIT}=                 yes
${FIRMWARE_TYPE_VAR}=       ${EMPTY}

# Name of boot menu entry to boot the given OS
${OS_WINDOWS}=              Windows Boot Manager
${OS_UBUNTU}=               ubuntu

# RTE database:
# LPN Plant -----------------------------------------------------------
&{RTE01}=                   ip=192.168.4.197    cpuid=02c000422fc6d77e    pcb_rev=0.5.3
...                         platform=mDot    env=unknown
...                         platform_vendor=unknown    firmware_type=unknown
&{RTE02}=                   ip=192.168.4.198    cpuid=02c00042df7b6fc2    pcb_rev=0.5.3
...                         platform=lpn_gate    env=unknown
...                         platform_vendor=unknown    firmware_type=unknown
&{RTE03}=                   ip=192.168.4.199    cpuid=02c00042b526c2b5    pcb_rev=0.5.3
...                         platform=lpn_gate    env=unknown
...                         platform_vendor=unknown    firmware_type=unknown
&{RTE04}=                   ip=192.168.4.202    cpuid=x    pcb_rev=0.5.3
...                         platform=lpn_gate    env=unknown
...                         platform_vendor=unknown    firmware_type=unknown
# Vitro Technology ----------------------------------------------------
&{RTE05}=                   ip=192.168.4.167    cpuid=02c00042d55c19d3    pcb_rev=0.5.3
...                         platform=crystal    env=dev
...                         platform_vendor=unknown    firmware_type=unknown
&{RTE06}=                   ip=192.168.4.168    cpuid=02c000426978d2a7    pcb_rev=1.0.0
...                         platform=dht-dev    env=dev
...                         platform_vendor=unknown    firmware_type=unknown
&{RTE07}=                   ip=192.168.4.169    cpuid=02c00042fdc96eda    pcb_rev=1.0.0
...                         platform=dht-prod    env=prod
...                         platform_vendor=unknown    firmware_type=unknown
# PCEngines production platforms ------------------------------------------------
&{RTE08}=                   ip=192.168.10.171    cpuid=02c000429e34aeca    pcb_rev=0.5.3
...                         platform=apu1    board-revision=d4    env=prod
...                         platform_vendor=PC Engines    firmware_type=BIOS
&{RTE09}=                   ip=192.168.10.172    cpuid=02c000420c4ce851    pcb_rev=0.5.3
...                         platform=apu2    board-revision=c4    env=prod
...                         platform_vendor=PC Engines    firmware_type=BIOS
&{RTE10}=                   ip=192.168.10.173    cpuid=02c00042a3b72a65    pcb_rev=0.5.3
...                         platform=apu3    board-revision=c4    env=prod
...                         platform_vendor=PC Engines    firmware_type=BIOS
&{RTE11}=                   ip=192.168.10.174    cpuid=02c000426621f7ea    pcb_rev=0.5.3
...                         platform=apu4    board-revision=4d    env=prod
...                         platform_vendor=PC Engines    firmware_type=BIOS
&{RTE12}=                   ip=192.168.10.175    cpuid=02c000420334dd56    pcb_rev=0.5.3
...                         platform=apu5    board-revision=b    env=prod
...                         platform_vendor=PC Engines    firmware_type=BIOS
&{RTE13}=                   ip=192.168.10.176    cpuid=02c00042c70883cf    pcb_rev=0.5.3
...                         platform=apu6    board-revision=b    env=prod
...                         platform_vendor=PC Engines    firmware_type=BIOS
&{RTE14}=                   ip=192.168.10.200    cpuid=02c0004204bf6561    pcb_rev=0.5.3
...                         platform=LT1000    env=prod
...                         platform_vendor=unknown    firmware_type=BIOS
&{RTE15}=                   ip=192.168.10.179    cpuid=02c0004222cfa701    pcb_rev=0.5.3
...                         platform=solidpc    env=prod
...                         platform_vendor=unknown    firmware_type=unknown
&{RTE16}=                   ip=192.168.10.180    cpuid=02c00042d455092d    pcb_rev=0.5.3
...                         platform=mbt_2210    env=prod
...                         platform_vendor=unknown    firmware_type=BIOS
&{RTE17}=                   ip=192.168.10.181    cpuid=02c0004200242187    pcb_rev=0.5.3
...                         platform=mbt_4210    env=prod
...                         platform_vendor=unknown    firmware_type=BIOS
&{RTE18}=                   ip=192.168.10.XXX    cpuid=XXX    pcb_rev=XXX
...                         platform=fw2b    env=prod
...                         platform_vendor=unknown    firmware_type=BIOS
&{RTE19}=                   ip=192.168.4.182    cpuid=02c001423b9f9efa    pcb_rev=1.1.0
...                         platform=fw4b    env=prod
...                         platform_vendor=protectli    firmware_type=BIOS
&{RTE20}=                   ip=192.168.4.183    cpuid=02c0004258ac3935    pcb_rev=0.5.3
...                         platform=apu2    board-revision=c4    env=dev
...                         platform_vendor=PC Engines    firmware_type=BIOS
&{RTE21}=                   ip=192.168.4.157    cpuid=02c00042888f8467    pcb_rev=0.5.3
...                         platform=apu2    board-revision=c4    env=dev
...                         platform_vendor=PC Engines    firmware_type=BIOS
&{RTE22}=                   ip=192.168.10.162    cpuid=02c00042f3ba1188    pcb_rev=0.5.3
...                         platform=apu2    board-revision=d    env=dev
...                         platform_vendor=PC Engines    firmware_type=BIOS
&{RTE23}=                   ip=192.168.10.163    cpuid=02c00042ea860eca    pcb_rev=0.5.3
...                         platform=apu3    board-revision=c    env=dev
...                         platform_vendor=PC Engines    firmware_type=BIOS
&{RTE24}=                   ip=192.168.10.71    cpuid=02c0004225f66d15    pcb_rev=0.5.3
...                         platform=apu4    board-revision=a    env=dev
...                         platform_vendor=PC Engines    firmware_type=BIOS
&{RTE25}=                   ip=192.168.4.50    cpuid=02c00042e90c36f2    pcb_rev=1.1.0
...                         platform=optiplex-9010    board-revision=x    env=prod
...                         platform_vendor=DELL    sonoff_ip=192.168.4.134    firmware_type=UEFI
&{RTE26}=                   ip=192.168.4.133    cpuid=02c0014296737c0d    pcb_rev=1.1.0
...                         platform=talosII    board-revision=1.01    env=dev
...                         platform_vendor=Raptor Engineering, LLC    sonoff_ip=192.168.4.106
&{RTE27}=                   ip=192.168.4.223    cpuid=02c00042921d288f    pcb_rev=1.1.0    firmware_type=unknown
...                         platform=optiplex-7010    board-revision=x    env=prod
...                         platform_vendor=DELL    sonoff_ip=192.168.4.134    firmware_type=UEFI
# Immunefi --------------------------------------------------------------------
&{RTE28}=                   ip=192.168.10.70    cpuid=02c000423e00d488    pcb_rev=1.1.0
...                         platform=KGPE-D16-8MB    board-revision=x    env=dev
...                         platform_vendor=ASUS    sonoff_ip=192.168.10.125    firmware_type=BIOS
&{RTE29}=                   ip=192.168.20.15    cpuid=02c0004282a2891c    pcb_rev=1.1.0
...                         platform=KGPE-D16-16MB    board-revision=x    env=dev
...                         platform_vendor=ASUS    sonoff_ip=192.168.10.144    firmware_type=BIOS
# 3mdeb Protectli -----------------------------------------------------
&{RTE30}=                   ip=192.168.4.190    cpuid=02c0014270499deb    pcb_rev=1.1.0
...                         platform=FW6_CML    board-revision=1.01    env=dev
...                         platform_vendor=fw66_cml    firmware_type=BIOS
&{RTE31}=                   ip=192.168.4.121    cpuid=02c000423305c959    pcb_rev=1.1.0
...                         platform=fw6e    board-revision=1.01    env=dev
...                         platform_vendor=fw6e    firmware_type=BIOS
# PCEngines developer platforms -----------------------------------------------
&{RTE32}=                   ip=192.168.20.6    cpuid=02c000425de69477    pcb_rev=1.0.0
...                         platform=apu1    board-revision=d4    env=dev
...                         platform_vendor=PC Engines    firmware_type=BIOS
# MSI-PRO-Z690-A platforms (Zir-Blazer) -----------------------------
&{RTE33}=                   ip=192.168.10.107    cpuid=02c00042a74281e6    pcb_rev=1.1.0
...                         platform=msi-pro-z690-a-wifi-ddr4    board-revision=1.1.0    env=dev
...                         platform_vendor=MSI Co., Ltd    sonoff_ip=192.168.10.21
...                         firmware_type=UEFI    pikvm_ip=192.168.10.226
&{RTE34}=                   ip=192.168.10.199    cpuid=02c000424753a7fb    pcb_rev=1.1.0
...                         platform=msi-pro-z690-a-wifi-ddr4    board-revision=1.1.0    env=dev
...                         platform_vendor=MSI Co., Ltd    sonoff_ip=192.168.10.169
...                         firmware_type=UEFI    pikvm_ip=192.168.10.153
&{RTE39}=                   ip=192.168.10.188    cpuid=02c0014266f49b55    pcb_rev=1.1.0
...                         platform=msi-pro-z690-a-ddr5    board-revision=1.1.0    env=dev
...                         platform_vendor=MSI Co., Ltd    sonoff_ip=192.168.10.69
...                         firmware_type=UEFI    pikvm_ip=192.168.10.45
# MSI-PRO-Z790-P platforms (Zir-Blazer) -----------------------------
&{RTE46}=                   ip=192.168.10.127    cpuid=02c00142a99e60ef    pcb_rev=1.1.0
...                         platform=msi-pro-z790-p-ddr5    board-revision=1.1.0    env=dev
...                         platform_vendor=MSI Co., Ltd    sonoff_ip=192.168.10.19
...                         firmware_type=UEFI    pikvm_ip=192.168.10.226
# PC Engines APU7 platform -----------------------------------------------------
&{RTE35}=                   ip=192.168.10.177    cpuid=02c00042522d9294    pcb_rev=0.5.3
...                         platform=apu7    board-revision=a    env=prod
...                         platform_vendor=PC Engines    firmware_type=BIOS
# 3mdeb Protectli vp4630 -----------------------------------------------------
&{RTE36}=                   ip=192.168.10.244    cpuid=02c0014248d5bffc    pcb_rev=1.1.0
...                         platform=protectli-vp4630    board-revision=x    env=dev
...                         platform_vendor=protectli    firmware_type=UEFI
# 3mdeb Protectli vp4670 -----------------------------------------------------
&{RTE37}=                   ip=192.168.10.228    cpuid=02c00042b2a75f00    pcb_rev=1.1.0
...                         platform=protectli-vp4670    sonoff_ip=192.168.10.19
...                         board-revision=x    env=dev
...                         platform_vendor=protectli    firmware_type=UEFI
# 3mdeb Protectli vp4650 -----------------------------------------------------
&{RTE38}=                   ip=192.168.10.203    cpuid=02c00142076840cf    pcb_rev=1.1.0
...                         platform=protectli-vp4650    sonoff_ip=192.168.10.251
...                         board-revision=x    env=dev
...                         platform_vendor=protectli    firmware_type=UEFI
# 3mdeb Protectli vp2420 -----------------------------------------------------
&{RTE40}=                   ip=192.168.10.221    cpuid=02c00142959df458    pcb_rev=1.1.0
...                         platform=protectli-vp2420    board-revision=x    env=dev
...                         platform_vendor=protectli    firmware_type=UEFI
# 3mdeb Protectli FW4C -------------------------------------------------------
&{RTE41}=                   ip=192.168.10.168    cpuid=02c00042bd1a7dee    pcb_rev=1.1.0
...                         platform=protectli-fw4c    board-revision=x    env=dev
...                         platform_vendor=protectli    firmware_type=UEFI
# 3mdeb Protectli VP2410 ------------------------------------------------------
&{RTE42}=                   ip=192.168.10.233    cpuid=02c00042661f9013    pcb_rev=1.1.0
...                         platform=protectli-vp2410    board-revision=x    env=dev
...                         platform_vendor=protectli    firmware_type=UEFI
# 3mdeb Protectli PT201 ------------------------------------------------------
&{RTE43}=                   ip=192.168.10.55    cpuid=02c0004278eb1b72    pcb_rev=1.1.0
...                         platform=protectli-PT201    board-revision=x    env=dev
...                         platform_vendor=protectli    firmware_type=UEFI
# 3mdeb Protectli PT201 ------------------------------------------------------
&{RTE44}=                   ip=192.168.10.198    cpuid=02c00042df7b6fc2    pcb_rev=1.1.0
...                         platform=protectli-PT401    board-revision=x    env=dev
...                         platform_vendor=protectli    firmware_type=UEFI
# 3mdeb Protectli PT601 ------------------------------------------------------
&{RTE45}=                   ip=192.168.10.218    cpuid=02c00142033c4387    pcb_rev=1.1.0
...                         platform=protectli-PT601    board-revision=x    env=dev
...                         platform_vendor=protectli    firmware_type=UEFI
# 3mdeb RPi 3B for Yocto ------------------------------------------------------
&{RTE47}=                   ip=192.168.10.65    cpuid=02c00042a0dd0cd0    pcb_rev=a22082
...                         platform=RPi-3-model-B-V1.2    sonoff_ip=192.168.10.27
...                         env=dev    platform_vendor=element14    firmware_type=yocto

@{RTE_LIST}=                &{RTE01}    &{RTE02}    &{RTE03}    &{RTE04}    &{RTE05}
...                         &{RTE06}    &{RTE07}    &{RTE08}    &{RTE09}    &{RTE10}
...                         &{RTE11}    &{RTE12}    &{RTE13}    &{RTE14}    &{RTE15}
...                         &{RTE16}    &{RTE17}    &{RTE18}    &{RTE19}    &{RTE20}
...                         &{RTE21}    &{RTE22}    &{RTE23}    &{RTE24}    &{RTE25}
...                         &{RTE26}    &{RTE27}    &{RTE28}    &{RTE29}    &{RTE30}
...                         &{RTE31}    &{RTE32}    &{RTE33}    &{RTE34}    &{RTE35}
...                         &{RTE36}    &{RTE37}    &{RTE38}    &{RTE39}    &{RTE40}
...                         &{RTE41}    &{RTE42}    &{RTE43}    &{RTE44}    &{RTE45}
...                         &{RTE46}    &{RTE47}

# hardware database:
# -----------------------------------------------------------------------------
&{HDD01}=                   vendor=SAMSUNG    volume=500GB    type=HDD_Storage
...                         interface=${SPACE}SATA    count=1
...                         sbo_name=ST500LM012
@{HDD_LIST}=                &{HDD01}
# -----------------------------------------------------------------------------
&{SSD01}=                   vendor=SanDisk    volume=16GB    type=Storage_SSD
...                         interface=mSATA    count=1
...                         sbo_name=SATA Flash Drive ATA-11 Hard-Disk
&{SSD02}=                   vendor=Phison    volume=16GB    type=Storage_SSD
...                         interface=mSATA    count=1
...                         sbo_name=SATA SSD ATA-10 Hard-Disk
&{SSD03}=                   vendor=Hoodisk    volume=32GB    type=Storage_SSD
...                         interface=mSATA    count=1
...                         sbo_name=Hoodisk SSD ATA-10 Hard-Disk
&{SSD04}=                   vendor=Hoodisk    volume=16GB    type=Storage_SSD
...                         interface=mSATA    count=1
...                         sbo_name=Hoodisk SSD ATA-11 Hard-Disk
&{SSD05}=                   vendor=Apacer    volume=30GB    type=Storage_SSD
...                         interface=mSATA    count=1
...                         sbo_name=30GB SATA Flash Drive ATA-11 Hard-Disk
&{SSD06}=                   vendor=Apacer    volume=60GB    type=Storage_SSD
...                         interface=mSATA    count=1
...                         sbo_name=60GB SATA Flash Drive ATA-11 Hard-Disk
&{SSD07}=                   vendor=Samsung    volume=250GB    type=Storage_SSD
...                         interface=SATA M.2    count=1
...                         boot_name=SSDPR-CL100-240-G2
&{SSD08}=                   vendor=Intel    volume=512GB    type=Storage_SSD
...                         interface=NVME    count=1
...                         boot_name=INTEL SSDPEKNU512GZ
&{SSD09}=                   vendor=Kingston    volume=250    type=Storage_SSD
...                         interface=NVME    count=1
...                         boot_name=KINGSTON SNVS250G
@{SSD_LIST}=                &{SSD01}    &{SSD02}    &{SSD03}    &{SSD04}    &{SSD05}
...                         &{SSD06}    &{SSD07}    &{SSD08}    &{SSD09}
# -----------------------------------------------------------------------------
&{CARD01}=                  vendor=SanDisk    volume=16GB    type=SD_Storage
...                         interface=SDCARD    count=1
...                         sbo_name=SD card SA16G
&{CARD02}=                  vendor=SanDisk    volume=8GB    type=SD_Storage
...                         interface=SDCARD    count=1
...                         sbo_name=SD card SS08G
&{CARD03}=                  vendor=SanDisk    volume=16GB    type=SD_Storage
...                         interface=USB_bridge    count=1
...                         sbo_name=USB MSC Drive Multiple Card${SPACE*2}Reader
&{CARD04}=                  vendor=Goodram    volume=16GB    type=SD_Storage
...                         interface=SDCARD    count=1
...                         sbo_name=USB MSC Drive Multiple Card${SPACE*2}Reader
&{CARD05}=                  vendor=SanDisk    volume=16GB    type=SD_Storage
...                         interface=SDCARD    count=1
...                         sbo_name=SD card SB16G
&{CARD06}=                  vendor=SanDisk    volume=16GB    type=SD_Storage
...                         interface=SDCARD    count=1
...                         sbo_name=SD card SL16G
@{CARD_LIST}=               &{CARD01}    &{CARD02}    &{CARD03}    &{CARD04}    &{CARD05}
...                         &{CARD06}
# -----------------------------------------------------------------------------
&{USB01}=                   vendor=Kingston    volume=16GB    type=USB_Storage
...                         protocol=3.0    interface=USB    count=2
...                         sbo_name=USB
&{USB02}=                   vendor=ADATA    volume=16GB    type=USB_Storage
...                         protocol=3.0    interface=USB    count=2
...                         sbo_name=USB
&{USB03}=                   vendor=SanDisk    volume=16GB    type=USB_Storage
...                         protocol=3.0    interface=USB    count=2
...                         sbo_name=USB
&{USB04}=                   vendor=Corsair    volume=16GB    type=USB_Storage
...                         protocol=3.0    interface=USB    count=2
...                         sbo_name=USB
# pfSense stick installer
&{USB05}=                   vendor=Kingston    volume=16GB    type=USB_Storage
...                         protocol=2.0    interface=USB    count=1
...                         sbo_name=USB
&{USB06}=                   vendor=SiliconMotion    volume=8GB    type=USB_Storage
...                         protocol=3.0    interface=USB    count=1
...                         sbo_name=USB
&{USB07}=                   vendor=SanDisk    volume=16GB    type=USB_Storage
...                         protocol=3.0    interface=USB    count=1
...                         sbo_name=USB
&{USB08}=                   vendor=Adata    volume=16GB    type=USB_Storage
...                         protocol=3.1    interface=USB    count=1
...                         sbo_name=USB
&{USB09}=                   vendor=Kingston    volume=16GB    type=USB_Storage
...                         protocol=3.0    interface=USB    count=1
...                         sbo_name=USB
&{USB10}=                   vendor=Goodram    volume=16GB    type=USB_Storage
...                         protocol=2.0    interface=USB    count=1
...                         sbo_name=USB
&{USB11}=                   vendor=SanDisk    volume=32GB    type=USB_Storage
...                         protocol=3.0    interface=USB    count=1
...                         sbo_name=USB    name=USB SanDisk 3.2Gen1
&{USB12}=                   vendor=SanDisk    volume=32GB    type=USB_Storage
...                         protocol=3.0    interface=USB    count=1
...                         sbo_name=USB    name=SanDisk Ultra USB 3.0
&{USB13}=                   vendor=Artificial    volume=1GB    type=USB_Storage
...                         protocol=3.0    interface=USB    count=1
...                         sbo_name=USB    name=PiKVM Composite KVM Device
&{USB14}=                   vendor=Kingston    volume=32GB    type=USB_Storage
...                         protocol=3.0    interface=USB    count=2
...                         sbo_name=USB    name=USB DISK 3.0
@{USB_LIST}=                &{USB01}    &{USB02}    &{USB03}    &{USB04}    &{USB05}
...                         &{USB06}    &{USB07}    &{USB08}    &{USB09}    &{USB10}
...                         &{USB11}    &{USB12}    &{USB13}    &{USB14}
# -----------------------------------------------------------------------------
&{MODULE01}=                vendor=HUAWEI    type=LTE_Module    interface=mPCIe
...                         count=1
&{MODULE02}=                vendor=WLE200NX    type=WiFi_Module    interface=mPCIe
...                         count=1
&{MODULE03}=                vendor=ASM1061    type=SATA_Module    interface=mPCIe
...                         count=1
&{MODULE04}=                vendor=TL-WN722N    type=WiFi_Adapter    interface=USB
...                         count=1
&{MODULE06}=                vendor=WLE900VX    type=WiFi_Module    interface=mPCIe
...                         count=1
&{MODULE07}=                vendor=Quectel_EP06    type=LTE_Module    interface=mPCIe
...                         count=1
&{MODULE08}=                vendor=WLE1216V5-20    type=WiFi_Module    interface=mPCIe
...                         count=1
&{MODULE09}=                vendor=WLE600VX    type=WiFi_Module    interface=mPCIe
...                         count=1
&{MODULE10}=                vendor=Infineon-SLB9665 TT 2.0    type=TPM_Module
...                         interface=LPC    count=1
&{MODULE11}=                vendor=Quectel_EC25-E    type=LTE_Module    interface=mPCIe
...                         count=1
&{MODULE12}=                vendor=Infineon-SLB9635 TT 1.2    type=TPM_Module
...                         interface=LPC    count=1
@{MODULE_LIST}=             &{MODULE01}    &{MODULE02}    &{MODULE03}    &{MODULE04}
...                         &{MODULE06}    &{MODULE07}    &{MODULE08}    &{MODULE09}
...                         &{MODULE10}    &{MODULE11}    &{MODULE12}
# -----------------------------------------------------------------------------
&{EXPANDER01}=              type=USB_Expander    slots=2    slot1=&{USB05}
...                         slot2=&{MODULE04}    interface=USB    count=1
&{EXPANDER02}=              type=USB_Expander    slots=2    slot1=&{USB07}
...                         slot2=&{EMPTY}    interface=USB    count=1
@{EXPANDER_LIST}=           &{EXPANDER01}    &{EXPANDER02}
# -----------------------------------------------------------------------------
&{ADAPTER01}=               type=UART_USB_Adapter    interface=UART    count=1
@{ADAPTER_LIST}=            &{ADAPTER01}
# -----------------------------------------------------------------------------

# hardware configurations:
@{CONFIG01}=                &{RTE08}    &{MODULE10}    &{SSD04}    &{USB04}
...                         &{CARD03}    &{ADAPTER01}    &{EXPANDER02}
@{CONFIG02}=                &{RTE09}    &{SSD05}    &{CARD05}    &{USB03}
...                         &{MODULE08}    &{MODULE10}    &{MODULE06}    &{ADAPTER01}
@{CONFIG03}=                &{RTE10}    &{HDD01}    &{CARD02}    &{USB01}
...                         &{MODULE01}    &{MODULE02}    &{MODULE04}    &{EXPANDER01}
...                         &{MODULE10}    &{ADAPTER01}
@{CONFIG04}=                &{RTE11}    &{SSD06}    &{CARD06}    &{USB03}
...                         &{MODULE06}    &{ADAPTER01}    &{MODULE10}
@{CONFIG05}=                &{RTE12}    &{USB03}    &{MODULE07}    &{CARD05}
...                         &{ADAPTER01}    &{MODULE10}
@{CONFIG06}=                &{RTE13}    &{SSD05}    &{CARD01}    &{USB03}
...                         &{MODULE09}    &{MODULE10}    &{MODULE11}    &{ADAPTER01}
@{CONFIG07}=                &{RTE14}    &{USB06}    &{MODULE10}    &{SSD03}
@{CONFIG08}=                &{RTE15}
@{CONFIG09}=                &{RTE16}
@{CONFIG10}=                &{RTE17}
@{CONFIG11}=                &{RTE18}    &{SSD03}
@{CONFIG12}=                &{RTE19}
@{CONFIG13}=                &{RTE20}    &{SSD03}    &{MODULE10}
@{CONFIG14}=                &{RTE21}    &{SSD02}    &{MODULE10}
@{CONFIG15}=                &{RTE22}    &{SSD04}    &{MODULE10}    &{MODULE09}
@{CONFIG16}=                &{RTE23}
@{CONFIG17}=                &{RTE24}
@{CONFIG18}=                &{RTE25}    &{USB07}
@{CONFIG19}=                &{RTE26}
@{CONFIG20}=                &{RTE27}
@{CONFIG21}=                &{RTE28}    &{USB10}    &{MODULE10}
@{CONFIG22}=                &{RTE29}    &{USB10}    &{MODULE12}
@{CONFIG23}=                &{RTE30}    &{MODULE11}    &{CARD04}    &{USB08}
...                         &{MODULE09}    &{USB09}    &{SSD05}    &{MODULE10}
@{CONFIG24}=                &{RTE32}    &{USB09}
@{CONFIG25}=                &{RTE33}    &{USB14}    &{SSD08}
@{CONFIG26}=                &{RTE34}    &{USB14}    &{SSD08}
@{CONFIG27}=                &{RTE35}    &{USB07}    &{SSD02}    &{MODULE10}
@{CONFIG28}=                &{RTE36}    &{USB11}    &{SSD09}
@{CONFIG29}=                &{RTE37}    &{USB11}
@{CONFIG30}=                &{RTE38}    &{USB11}
@{CONFIG31}=                &{RTE39}    &{USB14}    &{SSD08}
@{CONFIG32}=                &{RTE40}    &{USB12}    &{SSD07}
@{CONFIG33}=                &{RTE41}
@{CONFIG34}=                &{RTE42}
@{CONFIG35}=                &{RTE43}
@{CONFIG36}=                &{RTE44}
@{CONFIG37}=                &{RTE45}
@{CONFIG38}=                &{RTE46}    &{USB13}    &{SSD08}
@{CONFIG39}=                &{RTE47}

@{CONFIG_LIST}=             @{CONFIG01}    @{CONFIG02}    @{CONFIG03}    @{CONFIG04}
...                         @{CONFIG05}    @{CONFIG06}    @{CONFIG08}    @{CONFIG09}
...                         @{CONFIG10}    @{CONFIG11}    @{CONFIG12}    @{CONFIG13}
...                         @{CONFIG14}    @{CONFIG15}    @{CONFIG16}    @{CONFIG17}
...                         @{CONFIG18}    @{CONFIG19}    @{CONFIG20}    @{CONFIG21}
...                         @{CONFIG22}    @{CONFIG23}    @{CONFIG24}    @{CONFIG25}
...                         @{CONFIG26}    @{CONFIG27}    @{CONFIG28}    @{CONFIG29}
...                         @{CONFIG30}    @{CONFIG31}    @{CONFIG32}    @{CONFIG33}
...                         @{CONFIG34}    @{CONFIG35}    @{CONFIG36}    @{CONFIG37}
...                         @{CONFIG38}    @{CONFIG39}
