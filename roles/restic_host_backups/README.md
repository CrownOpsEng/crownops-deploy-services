# restic_host_backups

Reusable host backup capability for site repos that need composable restic jobs.

The role contract is:

- `restic_targets`: where data is stored
- `restic_backup_jobs`: what logical backup jobs exist on the host
- `restic_backup_contributions`: optional per-feature additions merged into named jobs

Each enabled target defines:

- `name`
- `repository`
- `password`
- optional `ssh_private_key`
- optional `ssh_known_hosts`
- optional `sftp_command`
- optional `environment`
- optional `auto_init`

Role-level operational defaults:

- `restic_apt_cache_valid_time` defaults to `86400` so repeat converges reuse a fresh apt cache instead of forcing `apt update` every time
- the standalone backup playbooks are intended to run with fact gathering disabled because this role does not consume host facts

Each enabled job defines:

- `name`
- `paths`
- optional `excludes`
- optional `pre_commands`
- optional `post_commands`
- optional `tags`
- optional `target_names`
- optional `backup_schedule`
- optional `backup_randomized_delay`
- optional `maintenance_schedule`
- optional `maintenance_randomized_delay`
- optional `retention_daily`
- optional `retention_weekly`
- optional `retention_monthly`

Each contribution defines:

- `job`
- optional `paths`
- optional `excludes`
- optional `pre_commands`
- optional `post_commands`
- optional `tags`

Rendered artifacts:

- target env files under `/opt/crownops-backup/targets/`
- password files under `/opt/crownops-backup/passwords/`
- job config fragments under `/opt/crownops-backup/jobs/`
- generic runners:
  - `/usr/local/sbin/crownops-restic-backup`
  - `/usr/local/sbin/crownops-restic-maintain`
- per-job per-target systemd units and timers

Design notes:

- target credentials are stored root-only on disk
- passwords are rendered to dedicated files instead of inline env vars
- timers are generated per job/target pair so schedules can vary by data class
- features should contribute backup paths and hooks through inventory or host-class vars instead of hard-coding one host-global backup list
- prefer precise durable paths over broad parent directories; for example back up `.../data`, `acme.json`, or a workspace root rather than the whole service directory when configuration is reproducible
- use `ansible-playbook ... playbooks/backup.yml` to converge backup configuration, then test execution by starting the relevant `crownops-restic-backup-*.service` units directly instead of rerunning the full converge loop
