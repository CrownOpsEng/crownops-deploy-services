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

Read first:
- `docs/ARCHITECTURE.md`
- `docs/QUICKSTART.md`
