# HD-005 — NTFS permissions: read succeeds, write denied, targeted access granted

| Field | Detail |
| --- | --- |
| Date | November 22, 2026 |
| Environment | Windows 11 Enterprise Evaluation VM, NTFS system drive |
| Classification | Controlled, self-directed home-lab exercise |
| Scenario | A standard user can read a document but cannot update it |
| Outcome | **Passed:** read-only restriction reproduced, then file-specific Write permission verified |

## 1. Objective and scope

Demonstrate how to inspect Windows NTFS access-control lists (ACLs), reproduce an `Access Denied` failure as a non-administrator, and grant only the access needed for an authorized editing task. The work was confined to the local test directory `C:\HD005-NTFS-Lab`.

This was a **simulated employee-access request**, not a production help desk ticket. The test file contained sample text, not confidential information.

## 2. Initial setup and account verification

The operator verified that C: uses NTFS. The existing local account `LabUser` was enabled and absent from the Administrators group. The administrator group membership check listed other accounts, but not `LabUser`.

A test directory and initial document were created:

```text
C:\HD005-NTFS-Lab\
├── test-document.txt
├── restricted-acl-backup.txt
└── Restricted\
    └── confidential.txt
```

The backup was produced with `icacls` before changing the *Restricted folder* ACL; it is a folder ACL backup, not a full filesystem backup.

A baseline `icacls` check on the new folder showed these **inherited** entries:

```text
BUILTIN\Administrators:(I)(OI)(CI)(F)
NT AUTHORITY\SYSTEM:(I)(OI)(CI)(F)
BUILTIN\Users:(I)(OI)(CI)(RX)
NT AUTHORITY\Authenticated Users:(I)(M)
NT AUTHORITY\Authenticated Users:(I)(OI)(CI)(IO)(M)
```

The Authenticated Users Modify entries meant that the folder was not yet suitably restricted for the planned test.

## 3. Configure the restricted folder

Using administrator PowerShell, the operator created `Restricted\confidential.txt` with the following harmless contents:

```text
HD-005: Sample document for access testing.
```

The ACL was saved and the following commands were run:

```powershell
icacls "C:\HD005-NTFS-Lab\Restricted" /save "C:\HD005-NTFS-Lab\restricted-acl-backup.txt"
icacls "C:\HD005-NTFS-Lab\Restricted" /inheritance:d
icacls "C:\HD005-NTFS-Lab\Restricted" /remove:g "NT AUTHORITY\Authenticated Users"
```

The first saves the selected directory's existing ACL, the second disables inheritance while copying the inherited ACEs as explicit entries, and the third removes the Authenticated Users Allow entries **on that directory**. The commands reported successful processing.

The resulting folder ACL:

```text
BUILTIN\Administrators:(OI)(CI)(F)
NT AUTHORITY\SYSTEM:(OI)(CI)(F)
BUILTIN\Users:(OI)(CI)(RX)
```

`AreAccessRulesProtected : True` confirmed inheritance was disabled on the Restricted folder. The specific file ACL was inspected separately and showed:

```text
BUILTIN\Administrators:(I)(F)
NT AUTHORITY\SYSTEM:(I)(F)
BUILTIN\Users:(I)(RX)
```

Thus the file inherited the restricted directory's Read & Execute permission for Users.

## 4. Reproduce the access failure as a standard user

Signed into Windows as `LabUser` with a regular (non-elevated) PowerShell session, the operator ran:

```powershell
whoami
Get-Content "C:\HD005-NTFS-Lab\Restricted\confidential.txt"
Add-Content "C:\HD005-NTFS-Lab\Restricted\confidential.txt" "HD-005: Modification test." -ErrorAction Stop
```

**Observed:**

- `whoami` identified the active `LabUser` account.
- `Get-Content` returned `HD-005: Sample document for access testing.`
- `Add-Content` failed with `PermissionDenied`, `UnauthorizedAccessException`, and an access-denied message naming the test file.

**Interpretation:** The observed results were consistent with the ACL: the account could read the file via Users:(RX), but did not have file Write access. This was a deliberately configured restriction, not an accidental system fault.

## 5. Authorized remediation

The scenario was then changed to an authorized request to edit **this one file**. The guided remediation was to add a file-specific Write allowance for `LabUser`, not grant administrator rights or write access to the whole folder:

```powershell
icacls "C:\HD005-NTFS-Lab\Restricted\confidential.txt" /grant "LabUser:(W)"
```

The transcript does not contain the administrator command's direct execution output, but the subsequent verification **does show** the resulting `LabUser:(W)` ACE.

## 6. Final verification

Signed in as `LabUser`, the operator successfully ran:

```powershell
Add-Content "C:\HD005-NTFS-Lab\Restricted\confidential.txt" "HD-005: Authorized modification successful." -ErrorAction Stop
Get-Content "C:\HD005-NTFS-Lab\Restricted\confidential.txt"
whoami
icacls "C:\HD005-NTFS-Lab\Restricted\confidential.txt"
```

The `Add-Content` operation completed without error and the final file contents were:

```text
HD-005: Sample document for access testing.
HD-005: Authorized modification successful.
```

The active session was confirmed as `LabUser`. The final file ACL was:

```text
LabUser:(W)
BUILTIN\Administrators:(I)(F)
NT AUTHORITY\SYSTEM:(I)(F)
BUILTIN\Users:(I)(RX)
```

The machine name was omitted from this public write-up. The output demonstrates that Write was granted to the named user on the file, while the other displayed entries remained Read & Execute or Full Control as before. File-specific Write is **not** Full Control; it does include several Windows write-related rights.

### Result

**Passed:** Access Denied was reproduced, a targeted Write permission was confirmed on the file, and the same standard-user account then appended content successfully.

### Evidence limits

- The supplied record demonstrates reading and appending one file, **not** broader permission testing such as deletion, ownership changes, editing other files, or durable persistence after a reboot.
- No raw screenshots or machine-specific identifiers are included in this public case study.
- This lab followed AI-assisted instructions. Commands and outputs were executed and supplied by the operator.

## 7. Skills practiced

- Confirming NTFS volume type and local account membership
- Inspecting folder ownership, inherited ACLs and explicit ACEs with `Get-Acl` and `icacls`
- Preserving a directory ACL before modifying inheritance
- Applying a least-privilege, file-specific Write grant
- Reproducing and interpreting a permission-denied exception
- Testing actual read/write behavior under a non-administrator account
- Documenting the distinction between an expected security boundary and a software defect

**Reference:** [Microsoft — icacls](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/icacls).

[Back to Windows Helpdesk Lab](../README.md)
