# HD-002 evidence — local user and UAC

**Session date:** November 18, 2026

## Verification record

The owner submitted screenshots showing:

1. An administrator console running `net user LabUser` and `net localgroup Administrators`, where the local account was active, had `Users` membership, and was absent from Administrators.
2. An initially misleading `whoami /groups` screenshot from an elevated administrator console (not evidence of the `LabUser` session).
3. A correctly non-elevated `LabUser` console running `whoami` and `whoami /groups`, showing `BUILTIN\\Users`, no Administrators membership, and Medium Mandatory Level.

**Published image:** [01-standard-user-verification.png](01-standard-user-verification.png)

**Image status:** Uploaded. The published image is a crop of the actual submitted screenshot, with the VM hostname obscured; the displayed account suffix (`labuser`), group membership, and Medium integrity label remain visible. No command result was synthesized.

**Limitations:** The administrator credential prompt was reported by the owner but not captured; no protected-resource access tests were performed.

[HD-002 ticket](../../tickets/HD-002-standard-user-and-uac.md)
