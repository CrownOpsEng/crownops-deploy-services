# CrownOps Deploy Services Collection

Reusable Ansible collection for service stacks and shared deployment capabilities.

This repo sits between:

- `crownops-deploy-base` for host foundation
- site repos such as `crownops-deploy-core` and `crownops-deploy-edge` for inventory and orchestration

Design rules:

- publish a small public role surface
- keep service implementation details inside the collection
- keep site inventory and secrets out of this repo

Current public roles:

- `crownops.deploy_services.obsidian_livesync`
- `crownops.deploy_services.restic_host_backups`
- `crownops.deploy_services.restic_sftp_target_bootstrap`

Current capabilities:

- Obsidian LiveSync deployment for either `public_https` (Traefik + ACME) or `private_mesh`
- automated CouchDB account, database, and security bootstrap
- restic backup scripts and timers driven by generic `restic_targets` and `restic_backup_jobs`
- optional SSH-key-based SFTP backup transport
- optional Linux SFTP destination bootstrap for controlled backup targets
- optional pre/post backup hooks for service quiesce

Read first:

- `docs/ARCHITECTURE.md`
- `docs/QUICKSTART.md`

Quality controls:

- collection dependency metadata declared in `galaxy.yml`
- GitHub Actions CI builds the collection and syntax-checks the public service playbooks
