# Evidence index — HD-001

These images were taken from the owner's real Windows 11 VM session on **November 15, 2026**. They are **cropped and enlarged screenshots**, not recreated command output. The `08:09` verification screenshot has a unique Windows DHCPv6 client identifier obscured; no troubleshooting result was changed.

| Image | What it shows |
| --- | --- |
| [01 — Initial connectivity and DNS failure](01-initial-connectivity-and-dns-failure.png) | Successful IP ping and failed default-DNS lookup for `example.com`. |
| [02 — Public resolver comparison](02-public-resolver-comparison.png) | `microsoft.com` resolved through default DNS; `example.com` resolved through Cloudflare. |
| [03 — Home router versus secondary DNS](03-router-versus-secondary-resolver.png) | Router DNS (`192.168.2.1`) returned Non-existent domain; configured secondary resolver succeeded. |
| [04 — Workaround verification](04-dns-workaround-verified.png) | Windows VM DNS now lists `1.1.1.1`/`1.0.0.1`, and both domains resolve through `1.1.1.1`. |

**Limitations:** Screenshots capture selected command-window views, not comprehensive machine logs or a packet capture. Ubuntu terminal outputs were supplied as text and are summarized in the [HD-001 ticket](../tickets/HD-001-dns-resolution.md).
