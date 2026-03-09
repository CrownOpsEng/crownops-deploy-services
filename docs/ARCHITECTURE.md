# Architecture

This collection contains reusable service stacks and shared host-level deployment capabilities.

Intended dependency direction:
- site repo -> `crownops.deploy_services` -> `crownops.deploy_base` -> upstream collections

Public roles should represent stable operator-facing capabilities such as:
- `obsidian_livesync`
- `restic_host_backups`

Internal implementation details should stay inside those roles as task files and templates instead of becoming separate top-level site repo roles.
