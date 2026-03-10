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
- `obsidian_livesync` renders its Traefik route through the file provider, so the stack does not need `/var/run/docker.sock`
- `restic_host_backups` models backup policy as targets, logical jobs, and feature contributions
- `restic_host_backups` supports SSH-key-backed SFTP and target-specific environment variables
- `restic_host_backups` supports job-scoped pre/post backup command hooks for service quiesce
- `restic_host_backups` defaults `restic_apt_cache_valid_time` to `86400` and expects backup playbooks to skip unused fact gathering for faster repeat converges
