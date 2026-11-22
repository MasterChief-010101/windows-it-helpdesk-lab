# HD-003 — Windows Print Spooler service troubleshooting and event-log investigation

| Field | Detail |
| --- | --- |
| Date | November 21–22, 2026 |
| Environment | Windows 11 Enterprise Evaluation VM on Ubuntu / QEMU-KVM |
| Ticket classification | **Controlled home-lab exercise**; no genuine user printing outage was reported |
| Scope | Service state changes, event-log investigation and service-level recovery |
| Status | **Completed at the service-diagnostic level**; end-to-end printing not tested |

## 1. Scenario and objective

A user reports that printing is unavailable. In this lab, the operator deliberately stops the Windows **Print Spooler** service to practice collecting evidence, investigating relevant logs and restoring the service.

This is a simulated incident. No physical printer, queued print job or employer-managed system was used as evidence of an actual outage.

## 2. Initial state

The lab operator queried the service:

```powershell
Get-Service Spooler | Select-Object Name, Status, StartType
```

**Observed:** `Spooler — Running — Automatic`. This baseline was re-established after a Windows VM restart performed during an unrelated clipboard-driver repair (HD-004).

## 3. Controlled interruption

In administrator PowerShell:

```powershell
$IncidentStart = Get-Date
Stop-Service -Name Spooler
Get-Service Spooler | Select-Object Name, Status, StartType
```

**Observed:** `Spooler — Stopped — Automatic`. The startup configuration remained Automatic while the current service status changed to Stopped.

The operator then searched recent service events:

```powershell
Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    ProviderName = 'Service Control Manager'
    StartTime = $IncidentStart
} | Select-Object TimeCreated, Id, LevelDisplayName, Message | Format-List
```

**Observed:** `NoMatchingEventsFound`: no events met that provider-and-time filter. This is not evidence that the stop command failed or that all Windows logging was malfunctioning.

## 4. Broader event-log investigation

The operator checked the newest System events:

```powershell
Get-WinEvent -LogName System -MaxEvents 15 |
    Select-Object TimeCreated, Id, ProviderName, Message |
    Format-List
```

The returned entries included other Service Control Manager events (for example, event 7040 concerning an unrelated service's startup configuration and event 7023 for an unrelated service), plus events from other Windows providers. **None of the supplied 15 event messages established the Print Spooler transition.** The visible data supports only that Windows was recording other events; it does not establish the cause of the absent Spooler entry in the narrower search.

Printing-specific log configuration was checked:

```powershell
Get-WinEvent -ListLog '*PrintService*' |
    Select-Object LogName, IsEnabled, RecordCount
```

| Log | Enabled | Record count |
| --- | --- | ---: |
| Microsoft-Windows-PrintService/Operational | False | Not reported |
| Microsoft-Windows-PrintService/Admin | True | 0 |

Because the PrintService Operational log was disabled, it could not provide operational records from that period. **This does not, by itself, explain the absence of Service Control Manager events under the earlier filter.** No logging configuration was changed during the exercise.

## 5. Recovery

The operator issued:

```powershell
Start-Service -Name Spooler

Get-Service Spooler |
    Select-Object Name, DisplayName, Status, StartType

Get-Process spoolsv |
    Select-Object ProcessName, Id, StartTime
```

The start command completed without a reported error. The submitted outputs were:

```text
Name     DisplayName     Status    StartType
Spooler  Print Spooler   Running   Automatic

ProcessName   Id    StartTime
spoolsv       2764  2026-11-22 1:57:37 AM
```

**Verified:** The service reported Running with Automatic startup, and a `spoolsv` process was present.

**Evidence limitation:** The reported `spoolsv` process start time predates the latest controlled stop. Therefore the process listing does **not** establish that a new process was created by `Start-Service`; the exact process/service lifecycle across the interruption was not independently reconciled. The recovery is confirmed at the service-status level, not by an end-to-end print job.

## 6. Outcome

**Service-status recovery passed.** The controlled interruption was observed, the service was returned to a Running state, and a Print Spooler process was detected.

**Not demonstrated:** Successfully printing a test page, the behavior of a real print queue, the cause of missing filtered System events, or a fresh process spawn after service restoration.

## 7. Skills practiced

- Establishing a baseline and documenting changes to service status
- Using `Get-Service`, `Stop-Service` and `Start-Service`
- Querying Windows System event logs with `Get-WinEvent`
- Distinguishing unmatched log filters from command syntax errors
- Examining print-specific log availability
- Checking service processes and interpreting timestamps carefully
- Documenting observations and evidence limitations without overstating results

## 8. Documentation note

This case study is based on PowerShell results supplied by the lab operator during the guided exercise. The work was performed in a personal Windows VM with AI-assisted guidance. Command examples are provided for educational purposes; intentionally stopping the Print Spooler on a production system can interrupt users' printing workflows.

[Back to portfolio README](../README.md)
