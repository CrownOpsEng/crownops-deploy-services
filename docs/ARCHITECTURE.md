# Architecture

This collection contains reusable service stacks and shared host-level deployment capabilities.

Intended dependency direction:

- site repo -> `crownops.deploy_services` -> `crownops.deploy_base` -> upstream collections

Public roles should represent stable operator-facing capabilities such as:

- `obsidian_livesync`
- `restic_host_backups`

`obsidian_livesync` intentionally separates the shared service stack from site-level ingress choices, so consuming repos can switch between `public_https` and `private_mesh` without forking the role.

Internal implementation details should stay inside those roles as task files and templates instead of becoming separate top-level site repo roles.

This collection is the place for:

- reusable service stacks
- reusable host-level backup capabilities
- shared compose-based service deployment logic
- application-aware bootstrap and backup hooks that belong to a reusable stack

This collection is not the place for:

- site inventory
- public repo example management
- host bootstrap and security baseline
- operator-only hand-edited environment docs
