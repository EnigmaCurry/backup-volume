# backup-volume

Backup Docker volumes locally or to any S3, WebDAV, Azure Blob
Storage, Dropbox or SSH compatible storage.

`backup-volume` is a fork of
[offen/docker-volume-backup](https://github.com/offen/docker-volume-backup)
Copyright &copy; 2024 [offen.software](https://www.offen.software) and
contributors. Distributed under the [MPL-2.0 License](LICENSE).

## Quickstart

### Recurring backups in a compose setup

Add a `backup` service to your compose setup and mount the volumes you would like to see backed up:

```yml
version: '3'

services:
  volume-consumer:
    build:
      context: ./my-app
    volumes:
      - data:/var/my-app
    labels:
      # This means the container will be stopped during backup to ensure
      # backup integrity. You can omit this label if stopping during backup
      # not required.
      - backup-volume.stop-during-backup=true

  backup:
    image: ghcr.io/enigmacurry/backup-volume:v3
    restart: always
    env_file: ./backup.env # see below for configuration reference
    volumes:
      - data:/backup/my-app-backup:ro
      # Mounting the Docker socket allows the script to stop and restart
      # the container during backup. You can omit this if you don't want
      # to stop the container. In case you need to proxy the socket, you can
      # also provide a location by setting `DOCKER_HOST` in the container
      - /var/run/docker.sock:/var/run/docker.sock:ro
      # If you mount a local directory or volume to `/archive` a local
      # copy of the backup will be stored there. You can override the
      # location inside of the container by setting `BACKUP_ARCHIVE`.
      # You can omit this if you do not want to keep local backups.
      - /path/to/local_backups:/archive
volumes:
  data:
```

### One-off backups using Docker CLI

To run a one time backup, mount the volume you would like to see backed up into a container and run the `backup` command:

```console
docker run --rm \
  -v data:/backup/data \
  --env AWS_ACCESS_KEY_ID="<xxx>" \
  --env AWS_SECRET_ACCESS_KEY="<xxx>" \
  --env AWS_S3_BUCKET_NAME="<xxx>" \
  --entrypoint backup \
  enigmacurry/backup-volume:v3
```

Alternatively, pass a `--env-file` in order to use a full config as described below.

## New features

These features have since been added in this version, compared to
docker-volume-backup:

### Plain language explanation for cron expressions

The new log message will confirm you got your cron expression correct
by explaining it back to you:

```
time=2024-10-10T20:20:32.828Z level=INFO msg="Successfully scheduled backup from environment with expression 11 1 */2 * MON-WED"
time=2024-10-10T20:20:32.829Z level=INFO msg="The backup will start at 01:11 AM, every 2 days, Monday through Wednesday"
```

### Environment vars for disabling archive lifecycle

There are certain advantages and disadvantages to the way that
backup-volume does backups:

 * Archives are always full backups, not incremental.
 * Theres no way to turn off the creation of the tarballs. If you turn
   off archives and storage, the tarballs are still created into /tmp
   even if they are not saved anywhere else (and then immediately
   deleted).
 
You can now use the following environment variables to disable the
archive lifecycles:

 * `BACKUP_LIFECYCLE_PHASE_ARCHIVE=true` - enables/disables the
   creation of a new tarball backup archive. This has two dependent
   lifecycles (so disabling archive disables the dependent ones too,
   regardless of their setting):
   
   * `BACKUP_LIFECYCLE_PHASE_PROCESS=true` - enables/disables the
     process phase (e.g., encryption).
   * `BACKUP_LIFECYCLE_PHASE_COPY=true` - enables/disables the copy
     phase (e.g., copy to `/archive`).
   
 * `BACKUP_LIFECYCLE_PHASE_PRUNE=true` - enables/disables the prune
   phase. Prune just removes old backups, so it is not dependent on
   creating a new archive.
