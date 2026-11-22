# HD-006 — Test results and evidence

**Environment:** Windows 11 Enterprise Evaluation VM, Windows PowerShell **5.1**, standard local user `LabUser`. All results below were supplied by the operator from November 22, 2026. Personal account paths and the VM hostname have been omitted.

## 1. Setup and execution policy

- Script location: inside the standard user's Documents folder, project directory `HD006-PowerShell-Diagnostics`.
- `Test-Path` confirmed the script file existed.
- `Get-ExecutionPolicy -List` showed all scopes `Undefined`; effective `Get-ExecutionPolicy` was `Restricted`.
- The script ran using a **new PowerShell process** with `-NoProfile -ExecutionPolicy RemoteSigned -File`; the original PowerShell session still reported `Restricted` afterward.

## 2. Success-path test

Command executed:

```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "$Lab\Get-SystemHealth.ps1"
```

**Observed output:**

```text
System health report generated successfully.
Report saved to: [local user project directory]\reports\SystemHealth.json
```

A `Test-Path` check returned `True` for the report. An initial report contained:

| Field | Recorded value |
| --- | --- |
| CollectedAt | 2026-11-22T07:34:44.4758106-05:00 |
| OperatingSystem | Microsoft Windows 11 Enterprise Evaluation |
| UptimeHours | 5.62 |
| TotalMemoryGiB | 3.93 |
| FreeMemoryGiB | 1.24 |
| Drive | C: |
| TotalGiB | 78.92 |
| FreeGiB | 42.84 |
| Spooler | Running |
| wuauserv | Running |
| BITS | Stopped |

A stopped BITS service was recorded as an observation, **not** classified as a service failure.

## 3. JSON consistency checks

The operator parsed the saved file with `ConvertFrom-Json -ErrorAction Stop` and checked the following expressions:

| Check | Observed |
| --- | --- |
| JsonParsed | True |
| OperatingSystemRecorded | True |
| UptimeValid | True |
| MemoryValid | True |
| DiskRecorded | True |
| ServicesRecorded | True |

These are **basic structural and range checks**, not independent confirmation that every system measurement is accurate.

## 4. Repeatability

The script ran a second time without a reported error. The new report's collection timestamp was `2026-11-22T08:37:22.8666946-05:00`.

After the error-handling changes were saved, another execution printed:

```text
SUCCESS: System health report generated.
Report saved to: [local user project directory]\reports\SystemHealth.json
```

The operator queried the saved JSON and observed:

| Field | Recorded value |
| --- | --- |
| CollectedAt | 2026-11-22T08:39:52.8729500-05:00 |
| OperatingSystem | Microsoft Windows 11 Enterprise Evaluation |
| UptimeHours | 6.71 |
| TotalMemoryGiB | 3.93 |

## 5. Controlled failure test

The operator created an isolated timestamped test directory and copied the updated `Get-SystemHealth.ps1` there. Inside that directory a **regular file**, not a folder, was created with the name `reports`.

`Get-Item` confirmed:

```text
Name     PSIsContainer
reports  False
```

The test copy was executed with the same temporary process policy. It could not save `reports\SystemHealth.json`. The supplied error reported:

```text
FAILED: Could not find a part of the path '...\reports\SystemHealth.json'.
```

The operator saved `$LASTEXITCODE` and observed **1**.

**Interpretation:** The controlled output-path conflict produced an error and a nonzero child process exit. This demonstrates one failure path, but not all possible collection or report-write failures. Because `Write-Error` occurs under a global Stop preference, this run does not establish whether the explicit `exit 1` statement itself was reached.

## 6. Limits and publication handling

- The script was not independently rerun by a second reviewer or tested on other Windows installations.
- No deliberate service interruption or system-configuration change was part of the script execution.
- Raw machine output, screenshots and locally generated JSON are deliberately **not** included in this public repository.
- The documentation describes the operator's tests and AI-assisted review, not a production rollout.

[Project README](README.md)
