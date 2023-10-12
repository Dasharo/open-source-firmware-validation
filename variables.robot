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

${RE_FRAME_START}=          ^.*/-{3,}\\\\.*$
${RE_FRAME_END}=            ^.*\\\\-{3,}/.*$

# Name of boot menu entry to boot the given OS
${OS_WINDOWS}=              Windows Boot Manager
${OS_UBUNTU}=               ubuntu

# MSI-PRO-Z690-A platforms (Zir-Blazer) -----------------------------
&{RTE33}=                   ip=192.168.10.107
...                         platform=msi-pro-z690-a-wifi-ddr4
...                         sonoff_ip=192.168.10.21
&{RTE34}=                   ip=192.168.10.199
...                         platform=msi-pro-z690-a-wifi-ddr4
...                         sonoff_ip=192.168.10.169
&{RTE39}=
...                         sonoff_ip=192.168.10.69
# 3mdeb Protectli vp4630 -----------------------------------------------------
&{RTE36}=                   ip=192.168.10.244
...                         platform=protectli-vp4630
# 3mdeb Protectli vp4670 -----------------------------------------------------
&{RTE37}=                   ip=192.168.10.228
...                         platform=protectli-vp4670    sonoff_ip=192.168.10.19
# 3mdeb Protectli vp4650 -----------------------------------------------------
&{RTE38}=                   ip=192.168.10.203
...                         platform=protectli-vp4650    sonoff_ip=192.168.10.251
# 3mdeb Protectli vp2420 -----------------------------------------------------
&{RTE40}=                   ip=192.168.10.221
...                         platform=protectli-vp2420
# 3mdeb Protectli FW4C -------------------------------------------------------
&{RTE41}=                   ip=192.168.10.168
...                         platform=protectli-fw4c
# 3mdeb Protectli VP2410 ------------------------------------------------------
&{RTE42}=                   ip=192.168.10.233
...                         platform=protectli-vp2410
# 3mdeb Protectli PT201 ------------------------------------------------------
&{RTE43}=                   ip=192.168.10.55
...                         platform=protectli-PT201
# 3mdeb Protectli PT201 ------------------------------------------------------
&{RTE44}=                   ip=192.168.10.198
...                         platform=protectli-PT401
# 3mdeb Protectli PT601 ------------------------------------------------------
&{RTE45}=                   ip=192.168.10.218
...                         platform=protectli-PT601
# 3mdeb RPi 3B for Yocto ------------------------------------------------------
&{RTE47}=                   ip=192.168.10.65    cpuid=02c00042a0dd0cd0    pcb_rev=a22082
...                         platform=RPi-3-model-B-V1.2    sonoff_ip=192.168.10.27
...                         env=dev    platform_vendor=element14    firmware_type=yocto
# QEMU
&{RTE48}=                   ip=127.0.0.1    cpuid=02c0014296737c0d    pcb_rev=1.1.0
...                         platform=qemu    board-revision=1.01    env=dev
...                         platform_vendor=qemu

@{RTE_LIST}=                &{RTE33}    &{RTE34}
...                         &{RTE36}    &{RTE37}    &{RTE38}    &{RTE39}    &{RTE40}
...                         &{RTE41}    &{RTE42}    &{RTE43}    &{RTE44}    &{RTE45}
...                         &{RTE46}    &{RTE47}    &{RTE48}

# -----------------------------------------------------------------------------
&{SSD07}=                   vendor=Samsung    volume=250GB    type=Storage_SSD
...                         interface=SATA M.2    count=1
...                         boot_name=SSDPR-CL100-240-G2
&{SSD08}=                   vendor=Intel    volume=512GB    type=Storage_SSD
...                         interface=NVME    count=1
...                         boot_name=INTEL SSDPEKNU512GZ
&{SSD09}=                   vendor=Kingston    volume=250    type=Storage_SSD
...                         interface=NVME    count=1
...                         boot_name=KINGSTON SNVS250G
&{SSD10}=                   vendor=Samsung    volume=1TB    type=Storage_SSD
...                         interface=NVME    count=1    boot_name=Samsung SSD 980 PRO 1TB
&{SSD11}=                   endor=Samsung    volume=250GB    type=Storage_SSD
...                         interface=NVME    count=1    boot_name=Samsung SSD 980 250GB
@{SSD_LIST}=                &{SSD07}    &{SSD08}    &{SSD09}    &{SSD10}    &{SSD11}
# -----------------------------------------------------------------------------
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
@{USB_LIST}=                &{USB11}    &{USB12}    &{USB13}    &{USB14}
# -----------------------------------------------------------------------------

# hardware configurations:
@{CONFIG25}=                &{RTE33}    &{USB14}    &{SSD08}
@{CONFIG26}=                &{RTE34}    &{USB14}    &{SSD08}
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
@{CONFIG40}=                &{RTE48}

@{CONFIG_LIST}=             @{CONFIG25}
...                         @{CONFIG26}    @{CONFIG28}    @{CONFIG29}
...                         @{CONFIG30}    @{CONFIG31}    @{CONFIG32}    @{CONFIG33}
...                         @{CONFIG34}    @{CONFIG35}    @{CONFIG36}    @{CONFIG37}
...                         @{CONFIG38}    @{CONFIG39}
