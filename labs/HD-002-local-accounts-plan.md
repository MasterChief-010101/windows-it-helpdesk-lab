# HD-002 — Windows local accounts and least-privilege testing

**Status: COMPLETED 2026-11-18**

This document preserves the original exercise plan. The executed steps, observations, corrections, and evidence limitations are documented in the [completed support ticket](../tickets/HD-002-standard-user-and-uac.md).

## Goal

Demonstrate local account creation, inspect local group membership, distinguish a standard session from an administrator session, and test how Windows handles a request for elevation.

## Scenario

A new user needs access to a shared lab PC for routine work, but does **not** need administrator privileges. The work was performed **only in the Windows 11 VM**.

## Planned steps and observed completion

1. Create a local `LabUser` account using Windows account settings — **completed**.
2. Verify the account type using `net user LabUser` and `net localgroup Administrators` — **completed**.
3. Sign in as `LabUser`, inspect `whoami` and `whoami /groups` in a **non-elevated** shell — **completed** after an initial administrator-shell mix-up.
4. Request `Run as administrator` and observe Windows prompting for administrator credentials — **operator confirmed**.
5. Record results and limitations in an IT support ticket — **completed**.

## Safety and evidence notes

- The work was performed in a personal Windows VM, not on the Ubuntu host or Cortana service account.
- No passwords, security answers, or privileged credentials were intentionally published.
- The UAC credential prompt was reported but not captured in a screenshot.
- The screenshot of the final standard-user session was reviewed; publication of the cropped screenshot is pending.

[Read the HD-002 support ticket](../tickets/HD-002-standard-user-and-uac.md)
