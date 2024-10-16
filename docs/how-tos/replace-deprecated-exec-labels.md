---
title: Replace deprecated exec-pre and exec-post labels
layout: default
parent: How Tos
nav_order: 18
---

# Replace deprecated `exec-pre` and `exec-post` labels

Version 2.19.0 introduced the option to run labeled commands at multiple points in time during the backup lifecycle.
In order to be able to use more obvious terminology in the new labels, the existing `exec-pre` and `exec-post` labels have been deprecated.
If you want to emulate the existing behavior, all you need to do is change `exec-pre` to `archive-pre` and `exec-post` to `archive-post`:

```diff
    labels:
-     - backup-volume.exec-pre=cp -r /var/my_app /tmp/backup/my-app
+     - backup-volume.archive-pre=cp -r /var/my_app /tmp/backup/my-app
-     - backup-volume.exec-post=rm -rf /tmp/backup/my-app
+     - backup-volume.archive-post=rm -rf /tmp/backup/my-app
```

The `EXEC_LABEL` setting and the `backup-volume.exec-label` label stay as is.
Check the additional documentation on running commands during the backup lifecycle to find out about further possibilities.
