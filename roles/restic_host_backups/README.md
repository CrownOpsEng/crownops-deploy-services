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
