# TrenchBoot tests

These are the tests of [TrenchBoot] functionality meant to be used with
[meta-trenchboot] distribution.

The tests check sanitity of the environment with and without the DRTM.

[TrenchBoot]: https://trenchboot.org/
[meta-trenchboot]: https://github.com/3mdeb/meta-trenchboot

## Example usage

From the root of the repository.

### With UEFI firmware on APU2

```bash
CONFIG=pcengines-apu2 RTE_IP=192.168.10.172 SNIPEIT_NO=1 scripts/run.sh trenchboot
```

### With SeaBIOS firmware on APU2

```bash
CONFIG=pcengines-apu2 RTE_IP=192.168.10.172 SNIPEIT_NO=1 scripts/run.sh trenchboot -- -v SEABIOS_BOOT_DEVICE:2
```

Here `SEABIOS_BOOT_DEVICE` specifies a device to boot from via SeaBIOS boot
menu.  It should correspond to the drive with the [meta-trenchboot] image.
