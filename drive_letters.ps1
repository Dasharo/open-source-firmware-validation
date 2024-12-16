# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

Get-WmiObject -Query "SELECT * FROM Win32_DiskDrive" | ForEach-Object {
    $disk = $_
    $partitions = "ASSOCIATORS OF {Win32_DiskDrive.DeviceID='$($disk.DeviceID)'} WHERE AssocClass = Win32_DiskDriveToDiskPartition"
    Get-WmiObject -Query $partitions | ForEach-Object {
        $partition = $_
        $logicalDisks = "ASSOCIATORS OF {Win32_DiskPartition.DeviceID='$($partition.DeviceID)'} WHERE AssocClass = Win32_LogicalDiskToPartition"
        Get-WmiObject -Query $logicalDisks | ForEach-Object {
            $logicalDisk = $_
            "$($logicalDisk.DeviceID) $($disk.Model)"
        }
    }
}
