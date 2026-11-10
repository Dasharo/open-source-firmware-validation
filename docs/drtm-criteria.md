<!--
SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>

SPDX-License-Identifier: Apache-2.0
-->

# DRTM criteria

What makes a DRTM launch a real one, stated without reference to how a
platform implements it. Each criterion is checked through a binding, the way
one implementation provides the evidence. On x86 that is the TPM: PCR 17 to 22
and the DRTM event log that the Intel SINIT ACM or the AMD Secure Kernel Loader
starts and TrenchBoot Linux continues. The checks are the tests of
[trenchboot/](../trenchboot/), and each test has a `criterion:Cnn` tag for
every criterion it checks. [drtm-report.md](drtm-report.md) describes the
report, which shows the criteria against runs, with a drill-down to the checks.

Another tree of DRTM suites can bind the same criteria to its platforms and put
its runs in the same report, next to the x86 ones. Its criteria table has the
same IDs and levels.

## Levels

- L1, launched: a launch happened and left evidence, and a boot without a
  launch leaves none.
- L2, measured right: the evidence says what ran, in a form a verifier can
  rebuild and check.
- L3, holds under attack: the OS, or a failed or repeated launch, cannot make
  the evidence lie.

## Criteria

| ID  | Criterion                                                                                         | Level | Source                                           |
| --- | ------------------------------------------------------------------------------------------------- | ----- | ------------------------------------------------ |
| C01 | Launch evidence exists, and differs from the evidence of a boot without a launch                  | L1    | [PTP] DRTM PCRs; [MLE]; [SKL]                    |
| C02 | The evidence replays: the event log reproduces the measurement registers                          | L1    | [PFP] event log replay                           |
| C03 | The measurements are reproducible off the device from the binaries and data they cover            | L2    | [MLE] Table 37; the DLME's own measurements      |
| C04 | Events, their order, types and data follow the implementation's schema                            | L2    | [MLE] Table 37; [SKL]; TrenchBoot Linux          |
| C05 | The same inputs give the same evidence on every launch, and other inputs give other evidence      | L2    | [DRTM]                                           |
| C06 | The OS cannot reset or forge the evidence: the first extend and resets are reserved to the launch | L3    | [PTP] locality rules                             |
| C07 | The launch-time write access closes once the DLME has measured itself                             | L3    | [PTP] locality rules; [DRTM]                     |
| C08 | The evidence is attestable: a fresh, signed statement a verifier checks against a pinned root     | L2    | TCG TPM2_Quote                                   |
| C09 | No launch gives no launch evidence (fail-closed)                                                  | L1    | [PTP] DRTM PCRs                                  |
| C10 | A failed launch is reported, persists across the reset, and does not pass for a launch            | L3    | [MLE] TXT.ERRORCODE; [DRTM]                      |
| C11 | A second launch or a kexec relaunch does not reuse the evidence of the first                      | L3    | [DRTM]                                           |
| C12 | DMA cannot reach the DLME from the launch until the DLME's own IOMMU setup takes over             | L3    | [MLE] PMRs; AMD DEV                              |
| C13 | Every active bank either carries the launch or is visibly unusable for it                         | L2    | [PFP] crypto-agile log                           |
| C14 | A local secret can be bound to the launch state, and a changed launch cannot release it           | L3    | TCG sealing with PCR and locality policy         |
| C15 | The launch's security configuration is in the evidence: debug state, Non-secure state, TCB hashes | L2    | [MLE] Table 37 (STM, LCP, CPU S-CRTM status)     |

## Bindings

What the x86 TrenchBoot suites check for each criterion. "(new)" is a check
that does not exist yet. "N/A" at the start of a cell means the path has no way
to meet the criterion, and the report shows N/A for it rather than "not
checked". The `tpm` column is the evidence path of the runs of
[trenchboot/](../trenchboot/).

| ID  | `tpm`                                                                                                                                                         |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| C01 | PCR 17 and 18 extended, 19 to 22 zero: WTD002.001, WTD010.001; against WOD003.001                                                                             |
| C02 | the DRTM event log is exposed and replays to PCR 17 and 18: WTD004.001, WTD006.001                                                                            |
| C03 | the digests whose data the OS has (SINIT ACM data, kernel command line, initrd): WTD009.001; PCR 17 from the SINIT ACM or SKL binary: (new)                    |
| C04 | the launch's and the kernel's events, their types, PCRs and order: WTD005.001                                                                                 |
| C05 | PCR 17 and 18 equal over two launches, PCR 18 moves with the command line: (new)                                                                              |
| C06 | `tpm2_pcrreset` and `tpm2_pcrextend` of PCR 17 and 18 fail from the OS, in the boot without the launch: (new)                                                 |
| C07 | an extend of PCR 17 or 18 from the OS after the launch is refused: WTD012.001, see [Locality 2 after the launch](#locality-2-after-the-launch)                 |
| C08 | a fresh quote of PCR 17 and 18 verifies with the AK: WTD011.001                                                                                               |
| C09 | PCR 17 to 22 all ones and no DRTM event log without the launch: WOD003.001, WOD004.001                                                                        |
| C10 | TXT.ERRORCODE after a failed launch, kept across the reset: (new)                                                                                             |
| C11 | PCR values fresh after a kexec relaunch: (new)                                                                                                                |
| C12 | launch refused without DMA protection, the PMRs or the DEV cover the kernel: (new)                                                                            |
| C13 | every active bank in the DRTM event log: WTD008.001                                                                                                           |
| C14 | seal to PCR 17 and 18 with a locality policy, unseal fails after a command line change: (new)                                                                 |
| C15 | the SINIT ACM's STM, LCP and CPU S-CRTM status events: (new)                                                                                                  |

WTD001.001, WTD003.001, WTD007.001, WOD001.001 and WOD002.001, the cores and
the SRTM log, check the boot, not the launch, so they have no criterion.

## Locality 2 after the launch

TrenchBoot Linux at the revision meta-trenchboot builds (6e037afa) sets the
kernel's TPM locality to 2 once, in `slaunch_pcr_extend()` of
`arch/x86/kernel/slmodule.c`, and keeps it: every later TPM command, also one
from userspace through `/dev/tpm0`, goes out at locality 2, and the kernel logs
no close. So nothing in the kernel log says whether the launch's write access
closed, and WTD012.001 tries an extend from the OS instead. PCR 17 and 18
accept an extend at locality 2 ([PTP]), so expect it to fail on that revision.

## References

- [DRTM]: TCG D-RTM Architecture, version 1.0.0
- [PTP]: TCG PC Client Platform TPM Profile Specification for TPM 2.0
- [PFP]: TCG PC Client Platform Firmware Profile Specification
- [MLE]: Intel Trusted Execution Technology (Intel TXT) Measured Launch
  Environment Developer's Guide (315168)
- [SKL]: TrenchBoot secure-kernel-loader

[DRTM]: https://trustedcomputinggroup.org/resource/d-rtm-architecture-specification/
[PTP]: https://trustedcomputinggroup.org/resource/pc-client-platform-tpm-profile-ptp-specification/
[PFP]: https://trustedcomputinggroup.org/resource/pc-client-specific-platform-firmware-profile-specification/
[MLE]: https://www.intel.com/content/www/us/en/content-details/315168/intel-trusted-execution-technology-intel-txt-measured-launch-environment-developer-s-guide.html
[SKL]: https://github.com/TrenchBoot/secure-kernel-loader
