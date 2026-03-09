# Quick Start

Build locally:

```bash
ansible-galaxy collection install -r requirements.yml
ansible-galaxy collection build . --output-path dist
ansible-galaxy collection install -p ./.ansible/collections dist/crownops-deploy_services-0.1.0.tar.gz --force
ansible-playbook --syntax-check -i examples/inventory/hosts.yml playbooks/obsidian.yml
ansible-playbook --syntax-check -i examples/inventory/hosts.yml playbooks/backups.yml
```

Consuming repos should install this collection from GitHub via `ansible-galaxy collection install`.

Role notes:

- `obsidian_livesync` bootstraps CouchDB users, databases, and security objects automatically
- `obsidian_livesync` supports `public_https` via Traefik + ACME and `private_mesh` via a caller-supplied base URL; the consuming repo must keep CouchDB off the public firewall in `private_mesh`
- `restic_host_backups` supports the generic `restic_targets` and `restic_backup_jobs` model, including SSH-key-backed SFTP targets
- `restic_host_backups` also supports pre/post backup command hooks for small-scope service quiesce
