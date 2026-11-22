# HD-004 — Windows VM clipboard failure: VirtIO serial driver and SPICE recovery

| Field | Detail |
| --- | --- |
| Dates | November 21–22, 2026 |
| Environment | Windows 11 Enterprise Evaluation guest on Ubuntu, QEMU/KVM, libvirt, SPICE |
| Ticket type | Genuine lab incident encountered while working on HD-003 |
| Impact | Host-to-guest clipboard sharing unavailable; lengthy diagnostic commands had to be typed manually |
| Status | **Resolved — functional and post-reboot checks passed** |

## 1. Symptoms and scope

Copying text from Ubuntu into Windows PowerShell and Notepad failed. Virtual Machine Manager showed a SPICE display, SPICE channel, QXL video and a VirtIO serial controller. SPICE guest tools were installed from the official distribution during troubleshooting. The guest service `vdservice` was present but stopped; manually starting it briefly produced a Running status, then it stopped again.

## 2. Investigation

| Diagnostic step | Observation |
| --- | --- |
| `Get-Service vdservice` | Service started temporarily, then returned to Stopped |
| `Get-Process vd*` | No matching agent processes at the time of the failed check |
| `Get-EventLog System -Newest 10` and expanded messages | Guest tools installation recorded; separate QEMU Guest Agent connection timeouts and a Balloon driver load warning |
| `gc C:\Windows\Temp\vdservice.log -Tail 20` | Repeated agent termination followed by “Agent restarted too many times” and service stop |
| `gc C:\Windows\Temp\vdagent.log -Tail 20` | Repeated failure to open the SPICE communication device, error 2 |
| Device Manager, VirtIO Serial Driver properties | Yellow warning and Code 52: Windows could not verify the driver's digital signature |
| Driver tab | Red Hat, Inc.; version 100.74.104.14100; dated July 19, 2017; listed signer Red Hat, Inc. |

The QEMU Guest Agent timeouts and Balloon driver warning were not treated as proof of the clipboard fault. The SPICE application's own logs pointed more specifically to the inaccessible serial communication device.

## 3. Diagnosis

The immediate failure was the agent's inability to open the SPICE VirtIO serial channel. Device Manager independently showed that the serial driver had a signature-verification problem (Code 52). The successful targeted driver replacement and recovery support this diagnosis. The exact reason Windows rejected the old signature was not independently established.

## 4. Corrective action

1. Obtained the stable VirtIO driver ISO, `virtio-win-0.1.302.iso`, from the [official VirtIO distribution](https://github.com/virtio-win/virtio-win-pkg-scripts).
2. An initial attempt to attach the ISO from the host Downloads directory raised an emulator search-permission warning. Rather than broaden home-directory permissions, copied the ISO to the standard libvirt image storage directory using `sudo cp`, and verified the destination file using `ls -lh`.
3. Attached the ISO to the existing virtual SATA CD-ROM (not the Windows system disk). Windows detected the CD as D:.
4. In Windows Device Manager, updated only the VirtIO Serial Driver using `D:\vioserial\w11\amd64`. Windows reported successful installation, and the serial device warning disappeared.
5. Started/checked the SPICE service and tested clipboard sharing. No Windows reinstall, disabling of signature enforcement or intentional Secure Boot configuration change was performed.

The Balloon driver warning was left outside the scope of this repair. Secure Boot enforcement was not independently tested.

## 5. Verification

The operator successfully pasted text into Notepad and subsequently supplied PowerShell output from the copied diagnostic block:

```powershell
Get-Service vdservice | Select-Object Name, Status, StartType
Get-Process vd*
Get-PnpDevice -FriendlyName "VirtIO Serial Driver" | Format-List Status, FriendlyName, Problem
```

Observed values (normalized for readability):

```text
vdservice   Running   Automatic
Processes: vdagent, vdservice
Status: OK
FriendlyName: VirtIO Serial Driver
Problem: CM_PROB_NONE
```

The operator restarted the Windows guest, repeated the verification, and supplied the same healthy status without reporting a manual service start. The following read-only checks also returned a boot timestamp on November 22, 2026 and replacement driver details:

```powershell
Get-CimInstance Win32_OperatingSystem | Select-Object LastBootUpTime
Get-CimInstance Win32_PnPSignedDriver |
    Where-Object {$_.DeviceName -eq "VirtIO Serial Driver"} |
    Format-List DeviceName, DriverVersion, DriverDate, DriverProviderName, IsSigned, Signer
```

| Property | Before | After |
| --- | --- | --- |
| Driver version | 100.74.104.14100 | 100.103.104.30200 |
| Provider | Red Hat, Inc. | Red Hat, Inc. |
| Driver date | July 2017 | July 2026 |
| Listed signer | Red Hat, Inc. | Microsoft Windows Hardware Compatibility Publisher |
| Windows signature status | Code 52 | IsSigned: True |
| Device problem | Code 52 | CM_PROB_NONE |
| SPICE service | Stopped after repeated agent failures | Running, Automatic |
| Host-to-guest clipboard | Failed | Successful |

**Outcome:** Host-to-guest text clipboard functionality restored; service and driver health verified after a reported reboot. Guest-to-host clipboard, longer-term stability, Balloon driver health and QEMU Guest Agent recovery were not tested as part of this ticket.

## 6. Evidence and contribution

This report is based on screenshots and command output supplied by the lab operator during the incident. Raw screenshots are not included in this publication; the text excerpts above are normalized from the observed logs and supplied output. The operator performed the diagnostic commands, driver installation, host ISO handling and functional tests on a personally controlled lab, using AI-assisted guidance. This is not a claim of production IT employment.

## 7. Lessons learned

- A Running service snapshot does not establish continued health; recheck service and process state.
- Distinguish system log errors from application-specific evidence before assigning a cause.
- Use Device Manager problem codes and driver metadata to investigate hardware interface failures.
- Prefer a compatible signed driver over weakening operating-system security controls.
- Keep remediation narrowly scoped, then verify the original affected function and repeat checks after restart.

References: [Microsoft Code 52 documentation](https://learn.microsoft.com/en-us/windows-hardware/drivers/install/cm-prob-unsigned-driver), [SPICE agent protocol](https://spice.pages.freedesktop.org/spice-space/agent-protocol.html), [VirtIO driver distribution](https://github.com/virtio-win/virtio-win-pkg-scripts).

[Back to portfolio README](../README.md)
