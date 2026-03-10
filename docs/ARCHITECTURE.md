# Architecture

This collection contains reusable service stacks and shared host-level deployment capabilities.

Intended dependency direction:

- site repo -> `crownops.deploy_services` -> `crownops.deploy_base` -> upstream collections

Public roles should represent stable operator-facing capabilities such as:

- `host_traefik`
- `host_restic`
- `obsidian_livesync`
- `restic_sftp_target_bootstrap`

`obsidian_livesync` owns only CouchDB and Obsidian-specific bootstrap concerns.
`host_traefik` owns shared ingress lifecycle and managed route fragments.
`host_restic` owns host-wide backup policy, while site composition decides which datasets exist.

Internal implementation details should stay inside those roles as task files and templates instead of becoming separate top-level site repo roles.

This collection is the place for:

- reusable service stacks
- reusable host-level backup capabilities
- shared compose-based service deployment logic
- ingress configuration that avoids handing public-facing containers direct Docker daemon access
- application-aware bootstrap and backup hooks that belong to a reusable stack
- backup contracts that let site repos compose host policy separately from feature data ownership
- explicit managed-adoption validation for shared ingress instead of split ownership modes

This collection is not the place for:

- site inventory
- public repo example management
- host bootstrap and security baseline
- operator-only hand-edited environment docs
