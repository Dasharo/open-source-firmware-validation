"""
REMOTE TESTING ENVIRONMENT CONFIGS
"""
rte_1 = {
    'device_name':          'RTE',
    'rte_ip':               '192.168.4.233',
    'cpuid':                '02c0014266f49b55',
    'pcb_rev':              '1.1.0'
}

"""
-------------------------------------------------------------------------------
DEVICES UNDER TEST CONFIGS
"""
device_1 = {
    'device_name':          'MSI PRO Z690-A DDR5',
    'platform_ip':          'not set',
    'platform':             'pro-z690-a-ddr5',
    'vendor':               'MSI Co., Ltd'
}

"""
-------------------------------------------------------------------------------
POWER CONTROL DEVICES CONFIGS
"""
sonoff_1 = {
    'device_name':          'SONOFF',
    'sonoff_ip':            '192.168.4.43'
}

"""
-------------------------------------------------------------------------------
MINOR HARDWARE CONFIGS - USB STICKS
"""
usb_1 = {
    'device_name':          'Kingston DataTraveler 3.1Gen1 16 GB',
    'vendor':               'Kingston',
    'volume':               '16 GB',
    'protocol':             '3.1',
    'recognized_name':      '',
    'recognized_model':     ''
}

"""
-------------------------------------------------------------------------------
MINOR HARDWARE CONFIGS - NVME DISKS
"""
nvme_1 = {
    'device_name':          'Intel 670p 512 GB M26472-201 NVME',
    'vendor':               'Intel',
    'volume':               '512 GB',
    'interface':            'PCIe x4',
    'recognized_name':      '',
    'recognized_model':     ''
}

"""
-------------------------------------------------------------------------------
MINOR HARDWARE CONFIGS - SD CARDS
"""
sd_card_1 = {
    'device_name':          'kingston...',
    'vendor':               'SanDisk',
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
    'firmware_name':        'kingston...',
    "os_name": "kingston...",
    "model_name": "?",
    "size": "500GB"
}

"""
-------------------------------------------------------------------------------
TEST STANDS CONFIGURATIONS
"""
config_1 = [rte_1, device_1, sonoff_1]

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
        
