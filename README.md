# Windows 11 IT Help Desk Lab

**Hands-on Windows administration, network diagnostics, and ticket documentation in a local virtual machine.**

I built a Windows 11 Enterprise evaluation virtual machine on an Ubuntu laptop using QEMU/KVM, libvirt, and Virtual Machine Manager. This repository documents exercises I performed and their evidence. It is a learning portfolio, **not a claim of professional help-desk employment or a production support environment**.

## Lab environment

| Item | Configuration |
| --- | --- |
| Host | Ubuntu Linux laptop; Intel Core i5-8250U; 14 GiB RAM |
| Hypervisor | QEMU/KVM, libvirt, Virtual Machine Manager |
| Guest | Windows 11 Enterprise Evaluation |
| Guest allocation | 2 vCPUs, 4,096 MiB memory, 80 GiB virtual disk |
| VM firmware | UEFI with Secure Boot-capable OVMF firmware; virtual TPM 2.0 |
| Networking | libvirt `default` NAT network; virtual gateway `192.168.122.1` |

**Scope note:** Secure Boot-capable firmware was configured, but active enforcement and enrolled keys were not independently verified. NAT networking allows outbound internet access; it is not an offline isolated network.

## Completed case studies

### HD-001 — Domain-specific DNS resolution failure (November 15, 2026)

**Problem:** In the Windows VM, an external IP address was reachable, but `example.com` returned a DNS *Non-existent domain* response through the default DNS service.

**Investigation:** Compared DNS lookups through the VM's default resolver (`192.168.122.1`), the home router (`192.168.2.1`), a configured secondary resolver (`207.164.234.193`), and Cloudflare (`1.1.1.1`). Reproduced the failure on the Ubuntu host. The secondary resolver and Cloudflare successfully resolved the domain.

**Action and verification:** Configured only the Windows VM to use `1.1.1.1` and `1.0.0.1` for DNS. Subsequent queries for `example.com` and `microsoft.com` succeeded.

**Outcome:** **Resolved with workaround.** The cause of the router-side response remains **unconfirmed**; no change to router or Ubuntu DNS configuration was made.

[Read HD-001](tickets/HD-001-dns-resolution.md) · [HD-001 screenshots](evidence/README.md)

### HD-002 — Local user accounts, UAC, and least privilege (November 18, 2026)

**Scenario:** A new user needs access to a shared Windows lab computer but should not have administrator permissions.

**Action:** Created a local `LabUser` account and checked membership with `net user LabUser` and `net localgroup Administrators`.

**Verification:** Signed in as `LabUser`, ran `whoami` and `whoami /groups` in a non-elevated Command Prompt, and confirmed `BUILTIN\\Users` membership with a Medium integrity level and no Administrators group. When `Run as administrator` was selected, Windows requested administrator credentials (reported by the lab operator).

**Outcome:** **Completed — standard-user access and UAC behavior verified.** See the [HD-002 support ticket](tickets/HD-002-standard-user-and-uac.md) and the [original exercise plan](labs/HD-002-local-accounts-plan.md).

## Planned exercises (not yet performed)

- Windows Event Viewer diagnostics and support-ticket recording
- Windows services and update troubleshooting
- Further account and file-permission testing

## Evidence and documentation

Each completed ticket separates **observations**, **tests**, **actions taken**, **verified results**, and **remaining uncertainty**. The [evidence index](evidence/README.md) covers HD-001; the HD-002 account screenshot was captured and is awaiting upload to GitHub. HD-001 screenshots were cropped and a unique Windows device identifier was obscured before public packaging.

> **Safety:** Exercises were performed in a personally controlled VM. Commands that change settings are not intended for employer-managed systems without authorization. Passwords, recovery answers, and credentials are excluded from public documentation.
