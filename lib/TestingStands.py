"""
REMOTE TESTING ENVIRONMENT CONFIGS
"""
rte_1 = {
    'device_type':          'RTE',
    'rte_ip':               '192.168.4.233',
    'cpuid':                '02c0014266f49b55',
    'pcb_rev':              '1.1.0'
}

"""
-------------------------------------------------------------------------------
DEVICES UNDER TEST CONFIGS
"""
device_1 = {
    'device_type':          'Device Under Test',
    'platform_ip':          'not set',
    'platform':             'pro-z690-a-ddr5',
    'vendor':               'MSI Co., Ltd'
}

"""
-------------------------------------------------------------------------------
POWER CONTROL DEVICES CONFIGS
"""
sonoff_1 = {
    'device_type':          'Sonoff',
    'device_name':          'Sonoff S20 EU type E ',
    'sonoff_ip':            '192.168.4.43'
}

"""
-------------------------------------------------------------------------------
MINOR HARDWARE CONFIGS - USB STICKS
"""
usb_1 = {
    'device_type':          'USB stick',
    'device_name':          'SanDisk Ultra  Flair USB 3.0 16 GB',
    'vendor':               'SanDisk',
    'volume':               '16 GB',
    'interface':            'USB 3.0',
    'recognized_name':      '',
    'recognized_model':     ''
}

"""
-------------------------------------------------------------------------------
MINOR HARDWARE CONFIGS - SSD DISKS
"""
ssd_1 = {
    'device_type':          'SSD disk',
    'device_name':          'Intel 670p 512 GB M26472-201 NVME',
    'vendor':               'Intel',
    'volume':               '512 GB',
    'interface':            'NVME',
    'recognized_name':      '',
    'recognized_model':     ''
}

"""
-------------------------------------------------------------------------------
MINOR HARDWARE CONFIGS - SD CARDS
"""
sd_card_1 = {
    'device_name':          '',
    'vendor':               '',
    'volume':               '16 GB',
    'interface':            'SDCARD',
    'recognized_name':      '',
    'recognized_model':     ''
}

"""
-------------------------------------------------------------------------------
MINOR HARDWARE CONFIGS - TPM MODULES
"""
tpm_1 = {
    'device_name':          '',
    'vendor':               '',
}

"""
-------------------------------------------------------------------------------
TEST STANDS CONFIGURATIONS
"""
config_1 = [rte_1, device_1, sonoff_1, usb_1, ssd_1]

configs = [config_1]

"""
-------------------------------------------------------------------------------
KEYWORDS FOR GETTING INFORMATION FROM TEST STANDS CONFIGURATIONS
"""
class TestingStands(object):
    ROBOT_LIBRARY_VERSION = '1.0.0'
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def get_rte_cpuid(self, stand_ip):
        for config in configs:
            for device in config:
                if device['device_name'] == 'RTE':
                    if device['rte_ip'] == stand_ip:
                        return device['cpuid']

    def check_rte_provided_ip(self, stand_ip):
        for config in configs:
            for device in config:
                if device['device_name'] == 'RTE':
                    if device['rte_ip'] == stand_ip:
                        return True
        return False

    def check_platform_provided_ip(self, stand_ip):
        for config in configs:
            for device in config:
                if device['device_name'] == 'Device Under Test':
                    if device['platform_ip'] == stand_ip:
                        return True
        return False

    def get_power_control_method(self, stand_ip):
        for config in configs:
            if config[0]['device_type'] == 'RTE':
                if config[0]['rte_ip'] == stand_ip:
                    for device in config:
                        if ['device_type'] == 'Sonoff':
                            return 'sonoff'
                    return 'rte'
            elif config[0]['device_type']== 'Device Under Test':
                if config[0]['platform_ip'] == stand_ip:
                    for device in config:
                        if ['device_type'] == 'Sonoff':
                            return 'sonoff'
