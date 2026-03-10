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

- `crownops.deploy_services.host_traefik`
- `crownops.deploy_services.host_restic`
- `crownops.deploy_services.obsidian_livesync`
- `crownops.deploy_services.restic_sftp_target_bootstrap`

Current capabilities:

- Obsidian LiveSync deployment that owns only CouchDB, bootstrap, and handoff behavior
- shared Traefik ingress with explicit `managed` and `adopt_managed` modes
- Traefik routes rendered through the file provider instead of a Docker socket mount
- automated CouchDB account, database, and security bootstrap
- host-owned restic policy with composable targets, datasets, and jobs
- optional SSH-key-based SFTP backup transport
- optional Linux SFTP destination bootstrap for controlled backup targets
- dataset-scoped pre/post backup hooks for service quiesce

Read first:

- `docs/ARCHITECTURE.md`
- `docs/QUICKSTART.md`

Quality controls:

- collection dependency metadata declared in `galaxy.yml`
- GitHub Actions CI builds the collection and syntax-checks the public service playbooks
