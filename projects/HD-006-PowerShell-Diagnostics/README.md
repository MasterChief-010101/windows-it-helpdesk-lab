# HD-006 — Windows system-health diagnostics with PowerShell

**A self-directed Windows help-desk lab script, developed and tested with AI-assisted guidance.** This is not a production monitoring tool or a claim of professional help-desk employment.

## Purpose

Collect a snapshot of operating-system details, uptime, installed and free memory, fixed-disk capacity, and current state of three Windows services. Write a structured JSON report into a local reports directory.

The script **reads system state**, but **writes or overwrites** its local report file. It does not change services, accounts, registry settings or system permissions.

## Requirements

- Windows with **Windows PowerShell 5.1**
- A standard user permitted to read the queried system information and write within the script directory
- CIM and service-management cmdlets available

## Run

Open a normal (not elevated) PowerShell session in the folder containing the script. To use a temporary process-specific execution policy where the effective policy is Restricted:

```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File ".\Get-SystemHealth.ps1"
```

The script saves the result to **reports/SystemHealth.json**, relative to its own location. The original session's execution policy is not changed by the above invocation. Do not run an unfamiliar downloaded script without inspecting it. On managed endpoints, obey organizational policy; Group Policy may override command-line execution policy.

## Report fields

| Field | Description |
| --- | --- |
| CollectedAt | ISO-like timestamp with local time offset |
| OperatingSystem | Windows OS caption |
| UptimeHours | Hours since last boot (rounded) |
| TotalMemoryGiB / FreeMemoryGiB | Memory as calculated from the OS CIM values |
| Disks | Fixed logical drives with total and free space in GiB |
| Services | Current status of Spooler, wuauserv, and BITS |

A Stopped service, including BITS, is not automatically evidence of a fault. The script reports state without applying health thresholds.

## Testing performed

The lab operator ran the script as `LabUser` on November 22, 2026; successfully generated and parsed JSON; reran it and observed a new timestamp; and reproduced a file/directory conflict in an isolated copied script. That controlled failure produced a `FAILED` error and child process exit code **1**.

See [Test-Results.md](Test-Results.md) for observed outputs, methodology and limitations.

## Known limitations and next improvements

1. **Collection-phase errors:** The `try/catch` surrounds the report-writing section, not the earlier CIM and service collection. Failure handling across all collection steps is not yet tested.
2. **Service lookup ambiguity:** `Get-Service -ErrorAction SilentlyContinue` can suppress errors other than an absent service, so a `NotFound` status is not always conclusive.
3. **Failure reporting:** The test confirms a nonzero exit code. With `$ErrorActionPreference = "Stop"`, `Write-Error` inside `catch` can terminate before the explicit `exit 1`; the intended exit path has not been independently isolated.
4. **Output atomicity:** The script overwrites the output file directly; an interrupted write could leave incomplete JSON. A safer future version could write to a temporary file and then replace the destination.
5. **No broad compatibility or security audit:** This version was tested on one Windows 11 evaluation VM only.

These are documented limitations of the **tested v1**. The published script is intentionally the version supplied and exercised during the lab, not an untested rewrite.

## Data safety

**Do not commit `reports/SystemHealth.json` or raw diagnostic screenshots without reviewing and removing identifiers and environment details.** This repository publishes source code and the test narrative, not the machine's actual report.

## References

- [Microsoft: Get-CimInstance](https://learn.microsoft.com/en-us/powershell/module/cimcmdlets/get-ciminstance?view=powershell-5.1)
- [Microsoft: About execution policies](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-5.1)
- [Microsoft: Error handling](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_error_handling?view=powershell-5.1)

[Back to main Windows help-desk portfolio](../../README.md)
