# HD-002 — Standard Windows user account and UAC verification

| Field | Detail |
| --- | --- |
| Date | 2026-11-18 |
| Environment | Windows 11 Enterprise Evaluation VM on QEMU/KVM |
| Ticket classification | Self-directed IT Help Desk lab exercise |
| Scenario | New employee needs a local Windows account for ordinary tasks, without administrative privileges |
| Status | **Completed — account and permissions verified** |

## Objective

Provision a local standard user and validate least-privilege access using Windows account-management and identity tools. This exercise is performed in a personal VM, not an organizational production environment.

## 1. Account creation and initial checks

A local account named `LabUser` was created in the Windows 11 VM.

From a Windows administrator Command Prompt, the following commands were run:

```cmd
net user LabUser
net localgroup Administrators
```

The submitted screenshot showed:

- `LabUser` account **active: Yes**.
- **Password required: Yes**.
- Local group membership: **Users**.
- `LabUser` was **not listed** among members of the local Administrators group.

This established the account's configuration, but did not by itself prove the identity of an active sign-in session.

## 2. Elevated-session verification mistake and correction

The first `whoami /groups` capture was taken in an **elevated administrator Command Prompt** and displayed an account other than `LabUser`, membership of **BUILTIN\\Administrators**, and **High Mandatory Level**.

That result described the elevated administrator session, **not** `LabUser`'s privileges, so it was not used as evidence that the new account was standard or administrative.

The operator closed the elevated prompt, signed in as `LabUser`, and opened a normal Command Prompt without `Run as administrator`.

## 3. Correct standard-user verification

In the ordinary `LabUser` session:

```cmd
whoami
whoami /groups
```

The submitted screenshot showed:

- `whoami` returned a Windows account ending in **\\labuser**.
- `whoami /groups` listed **BUILTIN\\Users**.
- The token included **Medium Mandatory Level**.
- **BUILTIN\\Administrators** was not shown in the group list.

These observations support that the captured session was running as a **standard user**, not an elevated administrator.

**Screenshot status:** The original verification image was supplied during the lab and reviewed. A cropped copy with the VM hostname obscured was prepared for publication; the image will appear in this repository after upload under `evidence/hd-002/01-standard-user-verification.png`.

## 4. User Account Control (UAC) test

While using the standard account, the operator selected **Run as administrator** for Command Prompt.

- **Operator-reported observation:** Windows requested administrator credentials.
- **Action:** The operator had been instructed not to enter administrator credentials and to cancel the prompt.
- **Evidence limit:** There is **no screenshot** of the UAC dialog. The request for credentials is recorded as the operator's statement rather than an independently captured UI result. Cancellation was instructed, not independently demonstrated.

The credential request is consistent with expected UAC behavior for a standard-user session.

## 5. Outcome and scope

**Completed:** Local user creation; account status and group verification; a non-elevated sign-in-session check; observation of an administrator credential prompt.

**Not tested:** Access to restricted files, attempts to modify protected system settings, domain/Entra account administration, or production account provisioning.

No user password, security question answer, or administrative credentials are included in this report.

## 6. Skills practiced

- Local account provisioning and verification.
- Differentiating local group membership from an active process security token.
- Identifying the active Windows account with `whoami`.
- Inspecting token groups and integrity levels with `whoami /groups`.
- Understanding standard-user elevation requests under UAC.
- Recording and correcting a misleading test result before drawing a conclusion.

[Back to portfolio README](../README.md) · [Original lab plan](../labs/HD-002-local-accounts-plan.md)
