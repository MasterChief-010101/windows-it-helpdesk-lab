# HD-002 — Windows local accounts and least-privilege testing

**Status: PLANNED / NOT YET PERFORMED**

## Goal

Demonstrate how a technician creates a local **standard** user, inspects local group membership, distinguishes standard and administrator permissions, and documents an authorization-safe troubleshooting ticket.

## Proposed scenario

A new user needs access to a shared lab PC for routine work, but does **not** need administrator privileges. Create an appropriate local account in the Windows 11 **VM only**, check its effective privileges, and record the evidence.

## Steps to perform (only after starting the exercise)

1. Open **Settings → Accounts → Other users** (menu labels may vary in Windows 11 Enterprise).
2. Add a **local account** named `LabUser` with a unique password not included in screenshots or GitHub.
3. Confirm the account type is **Standard user**, not Administrator.
4. Open a Windows Command Prompt and record read-only checks:
   ```cmd
   net user LabUser
   net localgroup Administrators
   ```
5. Sign in to `LabUser`, inspect `whoami` and `whoami /groups`, and confirm routine sign-in works.
6. Observe an administrator-privilege prompt for a task requiring elevation **without entering credentials or changing settings unless needed for the lab**.
7. Create a new support ticket that separates account creation, verification, UAC behavior, and any unresolved questions.

## Safety and evidence

- Run entirely in the personal Windows VM, not the Ubuntu host or Cortana service account.
- Never share passwords, recovery questions, tokens, or unique machine IDs.
- Do not run destructive commands or change privileged group membership for the new user.
- Evidence should show local-account properties and group membership without sensitive identifiers.

**Completion criteria:** Screenshots or text logs showing the standard account exists, is not in the local Administrators group, and can sign in. This document is a plan, **not a claim that the exercise has been completed**.
