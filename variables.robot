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

${DL_CACHE_DIR}=            ${CURDIR}/dl-cache

${RE_FRAME_START}=          ^.*/-{3,}\\\\.*$
${RE_FRAME_END}=            ^.*\\\\-{3,}/.*$

# Name of boot menu entry to boot the given OS
${OS_WINDOWS}=              Windows Boot Manager
${OS_UBUNTU}=               ubuntu

# RTE database:
# Vitro Technology ----------------------------------------------------
&{RTE05}=                   ip=192.168.4.167    cpuid=02c00042d55c19d3
...                         platform=crystal
...                         platform_vendor=unknown
&{RTE06}=                   ip=192.168.4.168    cpuid=02c000426978d2a7
...                         platform=dht-dev
...                         platform_vendor=unknown
&{RTE07}=                   ip=192.168.4.169    cpuid=02c00042fdc96eda
...                         platform=dht-prod
...                         platform_vendor=unknown
# PCEngines production platforms ------------------------------------------------
&{RTE08}=                   ip=192.168.10.171    cpuid=02c000429e34aeca
...                         platform=apu1
...                         platform_vendor=PC Engines
&{RTE09}=                   ip=192.168.10.172    cpuid=02c000420c4ce851
...                         platform=apu2
...                         platform_vendor=PC Engines
&{RTE10}=                   ip=192.168.10.173    cpuid=02c00042a3b72a65
...                         platform=apu3
...                         platform_vendor=PC Engines
&{RTE11}=                   ip=192.168.10.174    cpuid=02c000426621f7ea
...                         platform=apu4
...                         platform_vendor=PC Engines
&{RTE12}=                   ip=192.168.10.175    cpuid=02c000420334dd56
...                         platform=apu5
...                         platform_vendor=PC Engines
&{RTE13}=                   ip=192.168.10.176    cpuid=02c00042c70883cf
...                         platform=apu6
...                         platform_vendor=PC Engines
&{RTE14}=                   ip=192.168.10.200    cpuid=02c0004204bf6561
...                         platform=LT1000
...                         platform_vendor=unknown
&{RTE15}=                   ip=192.168.10.179    cpuid=02c0004222cfa701
...                         platform=solidpc
...                         platform_vendor=unknown
&{RTE16}=                   ip=192.168.10.180    cpuid=02c00042d455092d
...                         platform=mbt_2210
...                         platform_vendor=unknown
&{RTE17}=                   ip=192.168.10.181    cpuid=02c0004200242187
...                         platform=mbt_4210
...                         platform_vendor=unknown
&{RTE18}=                   ip=192.168.10.XXX    cpuid=XXX
...                         platform=fw2b
...                         platform_vendor=unknown
&{RTE19}=                   ip=192.168.4.182    cpuid=02c001423b9f9efa
...                         platform=fw4b
...                         platform_vendor=protectli
&{RTE20}=                   ip=192.168.4.183    cpuid=02c0004258ac3935
...                         platform=apu2
...                         platform_vendor=PC Engines
&{RTE21}=                   ip=192.168.4.157    cpuid=02c00042888f8467
...                         platform=apu2
...                         platform_vendor=PC Engines
&{RTE22}=                   ip=192.168.10.162    cpuid=02c00042f3ba1188
...                         platform=apu2
...                         platform_vendor=PC Engines
&{RTE23}=                   ip=192.168.10.163    cpuid=02c00042ea860eca
...                         platform=apu3
...                         platform_vendor=PC Engines
&{RTE24}=                   ip=192.168.10.71    cpuid=02c0004225f66d15
...                         platform=apu4
...                         platform_vendor=PC Engines
&{RTE25}=                   ip=192.168.4.50    cpuid=02c00042e90c36f2
...                         platform=optiplex-9010
...                         platform_vendor=DELL    sonoff_ip=192.168.4.134
&{RTE26}=                   ip=192.168.4.133    cpuid=02c0014296737c0d
...                         platform=talosII
...                         platform_vendor=Raptor Engineering, LLC    sonoff_ip=192.168.4.106
&{RTE27}=                   ip=192.168.4.223    cpuid=02c00042921d288f
...                         platform=optiplex-7010
...                         platform_vendor=DELL    sonoff_ip=192.168.4.134
# Immunefi --------------------------------------------------------------------
&{RTE28}=                   ip=192.168.10.70    cpuid=02c000423e00d488
...                         platform=KGPE-D16-8MB
...                         platform_vendor=ASUS    sonoff_ip=192.168.10.125
&{RTE29}=                   ip=192.168.20.15    cpuid=02c0004282a2891c
...                         platform=KGPE-D16-16MB
...                         platform_vendor=ASUS    sonoff_ip=192.168.10.144
# 3mdeb Protectli -----------------------------------------------------
&{RTE30}=                   ip=192.168.4.190    cpuid=02c0014270499deb
...                         platform=FW6_CML
...                         platform_vendor=fw66_cml
&{RTE31}=                   ip=192.168.4.121    cpuid=02c000423305c959
...                         platform=fw6e
...                         platform_vendor=fw6e
# PCEngines developer platforms -----------------------------------------------
&{RTE32}=                   ip=192.168.20.6    cpuid=02c000425de69477
...                         platform=apu1
...                         platform_vendor=PC Engines
# MSI-PRO-Z690-A platforms (Zir-Blazer) -----------------------------
&{RTE33}=                   ip=192.168.10.107    cpuid=02c00042a74281e6
...                         platform=msi-pro-z690-a-wifi-ddr4
...                         platform_vendor=MSI Co., Ltd    sonoff_ip=192.168.10.170
...                         pikvm_ip=192.168.10.99
&{RTE34}=                   ip=192.168.10.199    cpuid=02c000424753a7fb
...                         platform=msi-pro-z690-a-wifi-ddr4
...                         platform_vendor=MSI Co., Ltd    sonoff_ip=192.168.10.169
...                         pikvm_ip=192.168.10.16
&{RTE39}=                   ip=192.168.10.188    cpuid=02c0014266f49b55
...                         platform=msi-pro-z690-a-ddr5
...                         platform_vendor=MSI Co., Ltd    sonoff_ip=192.168.10.69
...                         pikvm_ip=192.168.10.45
# MSI-PRO-Z790-P platforms (Zir-Blazer) -----------------------------
&{RTE46}=                   ip=192.168.10.127    cpuid=02c00142a99e60ef
...                         platform=msi-pro-z790-p-ddr5
...                         platform_vendor=MSI Co., Ltd    sonoff_ip=192.168.10.253
...                         pikvm_ip=192.168.10.226
# PC Engines APU7 platform -----------------------------------------------------
&{RTE35}=                   ip=192.168.10.177    cpuid=02c00042522d9294
...                         platform=apu7
...                         platform_vendor=PC Engines
# 3mdeb Protectli vp4630 -----------------------------------------------------
&{RTE36}=                   ip=192.168.10.244    cpuid=02c0014248d5bffc
...                         platform=protectli-vp4630
...                         platform_vendor=protectli
# 3mdeb Protectli vp4670 -----------------------------------------------------
&{RTE37}=                   ip=192.168.10.228    cpuid=02c00042b2a75f00
...                         platform=protectli-vp4670    sonoff_ip=192.168.10.19
...                         platform_vendor=protectli
# 3mdeb Protectli vp4670_2 ---------------------------------------------------
&{RTE49}=                   ip=192.168.10.14    cpuid=02c00042f1d72c95
...                         platform=protectli-vp4670    sonoff_ip=192.168.10.144
...                         platform_vendor=protectli
# * this RTE is currently repurposed for VP6650
# 3mdeb Protectli vp4650 -----------------------------------------------------
&{RTE38}=                   ip=192.168.10.203    cpuid=02c00142076840cf
...                         platform=protectli-vp4650    sonoff_ip=192.168.10.251
...                         platform_vendor=protectli
# 3mdeb Protectli vp4650_2 ---------------------------------------------------
&{RTE50}=                   ip=192.168.10.160    cpuid=02c000421dfebcdb
...                         platform=protectli-vp4650
...                         platform_vendor=protectli
# 3mdeb Protectli vp2420 -----------------------------------------------------
&{RTE40}=                   ip=192.168.10.221    cpuid=02c00142959df458
...                         platform=protectli-vp2420
...                         platform_vendor=protectli
# 3mdeb Protectli FW4C -------------------------------------------------------
&{RTE41}=                   ip=192.168.10.168    cpuid=02c00042bd1a7dee
...                         platform=protectli-fw4c
...                         platform_vendor=protectli
# 3mdeb Protectli VP2410 ------------------------------------------------------
&{RTE42}=                   ip=192.168.10.233    cpuid=02c00042661f9013
...                         platform=protectli-vp2410
...                         platform_vendor=protectli
# 3mdeb Protectli V1210 ------------------------------------------------------
&{RTE43}=                   ip=192.168.10.55    cpuid=02c0004278eb1b72
...                         platform=protectli-v1210
...                         platform_vendor=protectli
# 3mdeb Protectli V1410 ------------------------------------------------------
&{RTE44}=                   ip=192.168.10.198    cpuid=02c00042df7b6fc2
...                         platform=protectli-v1410
...                         platform_vendor=protectli
# 3mdeb Protectli V1610 ------------------------------------------------------
&{RTE45}=                   ip=192.168.10.218    cpuid=02c00142033c4387
...                         platform=protectli-v1610
...                         platform_vendor=protectli
# 3mdeb RPi 3B for Yocto -----------------------------------------------------
&{RTE47}=                   ip=192.168.10.65    cpuid=02c00042a0dd0cd0
...                         platform=RPi-3-model-B-V1.2    sonoff_ip=192.168.10.27
...                         platform_vendor=element14
# QEMU
&{RTE48}=                   ip=127.0.0.1    cpuid=02c0014296737c0d
...                         platform=qemu
...                         platform_vendor=qemu
# NovaCustom NV4x ADL --------------------------------------------------------
&{RTE51}=                   ip=0.0.0.0
...                         platform=novacustom-nv41pz    platform_vendor=Clevo
# NovaCustom automated laptop testing station --------------------------------
&{RTE52}=                   ip=192.168.10.91
...                         platform=novacustom-ts1    platform_vendor=3mdeb
...                         sonoff_ip=192.168.10.53    pikvm_ip=192.168.10.52
# 3mdeb Protectli VP6670 -----------------------------------------------------
&{RTE53}=                   ip=192.168.10.110
...                         platform=protectli-vp6670    platform_vendor=protectli
...                         sonoff_ip=192.168.10.113
# 3mdeb Protectli VP6650 -----------------------------------------------------
&{RTE54}=                   ip=192.168.10.14    cpuid=wip
...                         platform=protectli-vp6650    sonoff_ip=192.168.10.119
...                         platform_vendor=protectli
# MinnowBoard Turbot
&{RTE55}=                   ip=192.168.10.112
...                         platform=minnowboard-turbot
# NovaCustom NS5x TGL --------------------------------------------------------
&{RTE56}=                   ip=0.0.0.0
...                         platform=novacustom-ns50mu    platform_vendor=Clevo

@{RTE_LIST}=                &{RTE05}
...                         &{RTE06}    &{RTE07}    &{RTE08}    &{RTE09}    &{RTE10}
...                         &{RTE11}    &{RTE12}    &{RTE13}    &{RTE14}    &{RTE15}
...                         &{RTE16}    &{RTE17}    &{RTE18}    &{RTE19}    &{RTE20}
...                         &{RTE21}    &{RTE22}    &{RTE23}    &{RTE24}    &{RTE25}
...                         &{RTE26}    &{RTE27}    &{RTE28}    &{RTE29}    &{RTE30}
...                         &{RTE31}    &{RTE32}    &{RTE33}    &{RTE34}    &{RTE35}
...                         &{RTE36}    &{RTE37}    &{RTE38}    &{RTE39}    &{RTE40}
...                         &{RTE41}    &{RTE42}    &{RTE43}    &{RTE44}    &{RTE45}
...                         &{RTE46}    &{RTE47}    &{RTE48}    &{RTE49}    &{RTE50}
...                         &{RTE51}    &{RTE52}    &{RTE53}    &{RTE54}    &{RTE55}
...                         &{RTE56}

# hardware database:
# -----------------------------------------------------------------------------
&{HDD01}=                   vendor=SAMSUNG    volume=500GB    type=HDD_Storage
...                         interface=${SPACE}SATA    count=1
...                         sbo_name=ST500LM012
@{HDD_LIST}=                &{HDD01}
# -----------------------------------------------------------------------------
&{SSD01}=                   vendor=SanDisk    volume=16GB    type=Storage_SSD
...                         interface=mSATA    count=1
...                         boot_name=SATA Flash Drive ATA-11 Hard-Disk
&{SSD02}=                   vendor=Phison    volume=16GB    type=Storage_SSD
...                         interface=mSATA    count=1
...                         boot_name=SATA SSD ATA-10 Hard-Disk
&{SSD03}=                   vendor=Hoodisk    volume=32GB    type=Storage_SSD
...                         interface=mSATA    count=1
...                         boot_name=Hoodisk SSD ATA-10 Hard-Disk
&{SSD04}=                   vendor=Hoodisk    volume=16GB    type=Storage_SSD
...                         interface=mSATA    count=1
...                         boot_name=Hoodisk SSD ATA-11 Hard-Disk
&{SSD05}=                   vendor=Apacer    volume=30GB    type=Storage_SSD
...                         interface=mSATA    count=1
...                         boot_name=30GB SATA Flash Drive ATA-11 Hard-Disk
&{SSD06}=                   vendor=Apacer    volume=60GB    type=Storage_SSD
...                         interface=mSATA    count=1
...                         boot_name=60GB SATA Flash Drive ATA-11 Hard-Disk
&{SSD07}=                   vendor=Samsung    volume=250GB    type=Storage_SSD
...                         interface=SATA M.2    count=1
...                         boot_name=SSDPR-CL100-240-G2
&{SSD08}=                   vendor=Intel    volume=512GB    type=Storage_SSD
...                         interface=NVME    count=1
...                         boot_name=INTEL SSDPEKNU512GZ
&{SSD09}=                   vendor=Kingston    volume=250GB    type=Storage_SSD
...                         interface=NVME    count=1
...                         boot_name=KINGSTON SNVS250G
&{SSD10}=                   vendor=Samsung    volume=1TB    type=Storage_SSD
...                         interface=NVME    count=1
...                         boot_name=Samsung SSD 980 PRO 1TB
&{SSD11}=                   vendor=Samsung    volume=250GB    type=Storage_SSD
...                         interface=NVME    count=1
...                         boot_name=Samsung SSD 860 EVO M.2 250GB
&{SSD12}=                   vendor=Samsung    volume=250GB    type=Storage_SSD
...                         interface=NVME    count=1
...                         boot_name=Samsung SSD 980 PRO 250GB
&{SSD13}=                   vendor=Samsung    volume=500GB    type=Storage_SSD
...                         interface=SATA    count=1
...                         boot_name=CT500MX500SSD1
&{SSD14}=                   vendor=Samsung    volume=1TB    type=Storage_SSD
...                         interface=NVME    count=1
...                         boot_name=Samsung SSD 870 QVO 1TB
&{SSD15}=                   vendor=Samsung    volume=500GB    type=Storage_SSD
...                         interface=NVME    count=1
...                         boot_name=Samsung SSD 980 PRO 500GB
@{SSD_LIST}=                &{SSD01}    &{SSD02}    &{SSD03}    &{SSD04}    &{SSD05}
...                         &{SSD06}    &{SSD07}    &{SSD08}    &{SSD09}    &{SSD10}
...                         &{SSD11}    &{SSD12}    &{SSD13}    &{SSD14}    &{SSD15}
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
#
&{EMMC01}=                  vendor=Samsung    volume=32GB    type=MMC_Storage
...                         interface=eMMC    count=1    boot_name=eMMC Device
&{EMMC02}=                  vendor=Samsung    volume=8GB    type=MMC_Storage
...                         interface=eMMC    count=1    boot_name=eMMC Device
@{MMC_LIST}=                &{EMMC01}

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
@{CONFIG29}=                &{RTE37}    &{SSD12}
@{CONFIG30}=                &{RTE38}    &{USB11}
@{CONFIG31}=                &{RTE39}    &{USB14}    &{SSD08}
@{CONFIG32}=                &{RTE40}    &{USB12}    &{SSD11}
@{CONFIG33}=                &{RTE41}
@{CONFIG34}=                &{RTE42}    &{SSD13}    &{EMMC02}
@{CONFIG35}=                &{RTE43}    &{EMMC01}
@{CONFIG36}=                &{RTE44}    &{EMMC01}
@{CONFIG37}=                &{RTE45}    &{EMMC01}
@{CONFIG38}=                &{RTE46}    &{USB13}    &{SSD08}
@{CONFIG39}=                &{RTE47}
@{CONFIG40}=                &{RTE48}
@{CONFIG41}=                &{RTE49}    &{USB11}    &{SSD14}
@{CONFIG42}=                &{RTE50}    &{USB11}    &{SSD08}
@{CONFIG43}=                &{RTE51}    &{USB11}    &{SSD10}
@{CONFIG44}=                &{RTE52}    &{USB11}    &{SSD10}
@{CONFIG45}=                &{RTE53}    &{USB11}    &{SSD15}
@{CONFIG46}=                &{RTE54}    &{USB11}    &{SSD07}

@{CONFIG_LIST}=             @{CONFIG01}    @{CONFIG02}    @{CONFIG03}    @{CONFIG04}
...                         @{CONFIG05}    @{CONFIG06}    @{CONFIG08}    @{CONFIG09}
...                         @{CONFIG10}    @{CONFIG11}    @{CONFIG12}    @{CONFIG13}
...                         @{CONFIG14}    @{CONFIG15}    @{CONFIG16}    @{CONFIG17}
...                         @{CONFIG18}    @{CONFIG19}    @{CONFIG20}    @{CONFIG21}
...                         @{CONFIG22}    @{CONFIG23}    @{CONFIG24}    @{CONFIG25}
...                         @{CONFIG26}    @{CONFIG27}    @{CONFIG28}    @{CONFIG29}
...                         @{CONFIG30}    @{CONFIG31}    @{CONFIG32}    @{CONFIG33}
...                         @{CONFIG34}    @{CONFIG35}    @{CONFIG36}    @{CONFIG37}
...                         @{CONFIG38}    @{CONFIG39}    @{CONFIG40}    @{CONFIG41}
...                         @{CONFIG42}    @{CONFIG43}    @{CONFIG44}    @{CONFIG45}
...                         @{CONFIG46}
