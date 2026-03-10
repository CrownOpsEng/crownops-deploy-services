# Quick Start

Build locally:

```bash
ansible-galaxy collection install -r requirements.yml
ansible-galaxy collection build . --output-path dist
ansible-galaxy collection install -p ./.ansible/collections dist/crownops-deploy_services-0.1.0.tar.gz --force
ansible-playbook --syntax-check -i examples/inventory/hosts.yml playbooks/obsidian.yml
ansible-playbook --syntax-check -i examples/inventory/hosts.yml playbooks/traefik.yml
ansible-playbook --syntax-check -i examples/inventory/hosts.yml playbooks/backups.yml
```

Consuming repos should install this collection from GitHub via `ansible-galaxy collection install`.

Role notes:

- `obsidian_livesync` bootstraps CouchDB users, databases, and security objects automatically, but it no longer owns shared ingress
- `host_traefik` manages shared ingress layout, ACME state, and managed route fragments; `adopt_managed` only accepts installs that already match the managed contract
- `host_restic` models backup policy as targets, datasets, and host-owned jobs
- `host_restic` supports SSH-key-backed SFTP and target-specific environment variables
- `host_restic` supports dataset-scoped pre/post backup command hooks for service quiesce
- `host_restic` rejects `feature_owned_jobs` for now so schedule ownership stays host-scoped during the refactor
- `host_restic` defaults `host_restic.apt_cache_valid_time` to `86400` and expects backup playbooks to skip unused fact gathering for faster repeat converges
