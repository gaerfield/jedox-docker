# jedox-docker
Containerized Jedox-Instance

# FAQ

## Why does the container need tty and privileged - flags?

Jedox gets distributed with change-root-jails. The startup-script of "jedox-suite.sh" mounts several directories after applying changeroot, which needs privileged access.

## Is there a way to summarize all mutable data into a single volume?

I tried to put all data in a single share-folder, with jedox (in `/opt/jedox/ps`) symlinking the folders within the share. Sadly this doesn't work with changeroot. I'm open to alternative ideas.

# Links

* [jedox](https://www.jedox.com/en/)
  * [backup jedox](https://knowledgebase.jedox.com/knowledgebase/backup-jedox-data-batch-files/)
  * [jedox linux installation/update](https://knowledgebase.jedox.com/knowledgebase/jedox-installation-linux-update/)
