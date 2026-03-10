# host_restic

Reusable host backup capability for site repos that need composable restic jobs.

The role contract is:

- `host_restic.targets`: where data is stored
- `host_restic.datasets`: durable backup datasets contributed by the host composition layer
- `host_restic.jobs`: logical host-owned backup policy that selects datasets and targets
- `host_restic.feature_owned_jobs`: reserved and intentionally unsupported in this refactor

Each enabled target defines:

- `name`
- `repository`
- `password`
- optional `ssh_private_key`
- `ssh_known_hosts` when `ssh_private_key` uses the generated SFTP transport
- optional `sftp_command` when the target needs a custom transport command instead of the generated one
- optional `environment`
- optional `auto_init`

Each enabled dataset defines:

- `name`
- `owner`
- `paths`
- optional `excludes`
- optional `tags`
- optional `quiesce.pre_commands`
- optional `quiesce.post_commands`

Role-level operational defaults:

- `host_restic.defaults` is optional; the role merges caller overrides onto internal schedule and retention defaults before composing jobs
- `host_restic.apt_cache_valid_time` defaults to `86400` so repeat converges reuse a fresh apt cache instead of forcing `apt update` every time
- the standalone backup playbooks are intended to run with fact gathering disabled because this role does not consume host facts

Each enabled job defines:

- `name`
- optional `dataset_names`
- optional `selector_tags`
- optional `tags`
- optional `target_names`
- optional `backup_schedule`
- optional `backup_randomized_delay`
- optional `maintenance_schedule`
- optional `maintenance_randomized_delay`
- optional `retention_daily`
- optional `retention_weekly`
- optional `retention_monthly`

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
- datasets are composed before this role runs; the role does not accept feature self-registration at runtime
- features should contribute backup datasets through the site composition layer instead of mutating host-wide policy directly
- prefer precise durable paths over broad parent directories; for example back up `.../data`, `acme.json`, or a workspace root rather than the whole service directory when configuration is reproducible
- use `ansible-playbook ... playbooks/backup.yml` to converge backup configuration, then test execution by starting the relevant `crownops-restic-backup-*.service` units directly instead of rerunning the full converge loop
