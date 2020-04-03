# Read this first!

## Validation

Before running the template with ```up -d``` I recommend you to always check the template first with ```config```.

```shell
docker-compose -f docker-compose.yml -f docker-compose.traefik.yml -f docker-compose.ports.yml config
```

That way you can make sure no environment variables are missing and the labels for Traefik are correct.

## Setup

To configure Wiki.js you have two choices, either using the config.yml or environment variables. (see [WikiJS documentation](https://docs.requarks.io/install/docker))

### config.yml

```shell
cp config.example.yml config.yml
# adjust the config via
editor config.yml
# done, make sure to use the 'config.file' delta like this
docker-compose -f docker-compose.yml -f docker-compose.config.file.yml [-f docker-compose.db.sqlite|postgres|mariadb.yml] [-f docker-compose.traefik.yml] [-f docker-compose.ports.yml] up -d
```

### wikijs.env

```shell
cp wikijs.example.env wikijs.env
# adjust the config via
editor wikijs.env
# done, make sure to use the 'config.env' delta like this
docker-compose -f docker-compose.yml -f docker-compose.config.env.yml [-f docker-compose.db.sqlite|postgres|mariadb.yml] [-f docker-compose.traefik.yml] [-f docker-compose.ports.yml] up -d
```

## Standalone

To run this container in standalone mode **without Traefik** reverse proxy, you can execute

```shell
docker-compose -f docker-compose.yml -f docker-compose.ports.yml [-f docker-compose.config.env|file.yml] [-f docker-compose.db.sqlite|postgres|mariadb.yml] up -d
```

## Traefik

If you are using Traefik you need to create an .env file first which specifies your domain.  
For example like this (replace example.com with your domain or subdomain):

```shell
# do not add the container name to the domain, it's already been set to wikijs.$DOMAIN
MYDOMAIN=example.com
echo DOMAIN=$MYDOMAIN >> .env
# to adjust the subdomain you have to edit the SUBDOMAIN env var as well
MYSUBDOMAIN=wiki
echo SUBDOMAIN=$MYSUBDOMAIN >> .env
```

After that you can run 

```shell
docker-compose -f docker-compose.yml -f docker-compose.traefik.yml [-f docker-compose.config.env|file.yml] [-f docker-compose.db.sqlite|postgres|mariadb|mysql.yml] up -d
```

Now Wiki.js should be served as subdomain under the domain you specified, e.g. ```wikijs.example.com``` or ```wikijs.subdomain.example.com```.

## Database

You get to use different choices for databases, ```mysql```, ```postgres```, ```mariadb```, ```mssql``` or ```sqlite```. (see [WikiJS documentation](https://docs.requarks.io/install/docker))  
I included deltas for ```sqlite```, ```mariadb```, ```mysql``` and ```postgres```. Depending on the configuration choice you made you either need to adjust the ```wikijs.env``` or your ```config.yml```.

### sqlite

To use sqlite you only need to add the ```db.sqlite``` delta and adjust your config to use sqlite as database type.

```shell
docker-compose -f docker-compose.yml -f docker-compose.db.sqlite.yml [-f docker-compose.config.env|file.yml] [-f docker-compose.traefik.yml] [-f docker-compose.ports.yml] up -d
```

A **db.sqlite** file will be created in the current directory, if you want this file to be located somewhere else you need to create an ```.env``` file and add the environment variable **WIKIJS_SQLITE_DBFILE** to it to adjust the path to where you want it, for example ```WIKIJS_SQLITE_DBFILE=/mnt/nas/myshare/db.sqlite```.

### PostgreSQL/MariaDB/MySQL

For PostgreSQL, MariaDB or MySQL you need to add the ```db.postgres```, ```db.mariadb``` or ```db.mysql``` delta and adjust your config to use one of the database types.  
*FYI you don't need to include the ```config.env``` delta anymore since it is required for your databases to work. The ```config.file``` delta however is still optional if you want to use it you need to include it.*

```shell
# for postgres
docker-compose -f docker-compose.yml -f docker-compose.db.postgres.yml [-f docker-compose.config.file.yml] [-f docker-compose.traefik.yml] [-f docker-compose.ports.yml] up -d
# for mariadb
docker-compose -f docker-compose.yml -f docker-compose.db.mariadb.yml [-f docker-compose.config.file.yml] [-f docker-compose.traefik.yml] [-f docker-compose.ports.yml] up -d
# for mysql
docker-compose -f docker-compose.yml -f docker-compose.db.mysql.yml [-f docker-compose.config.file.yml] [-f docker-compose.traefik.yml] [-f docker-compose.ports.yml] up -d
```

## NFS

If you want to store your data on an NFS share, there is no need to mount it yourself, this is what docker volumes are good for.

```shell
# open .env
editor .env
# and add
NFS_SERVER=your.nfs.host.or.ip.com
NFS_MOUNT=/mnt/nfs/share/to/mount
# optional, will default to rw,nolock
NFS_MOUNTOPTS=rw,nolock
```

Save the ```.env``` file and add the compose file to your docker-compose command with the ```-f``` arg again and make sure to run the ```config``` command first to check for errors!

```shell
docker-compose -f docker-compose.yml -f docker-compose.traefik.yml -f docker-compose.nfs.yml up -d
```

### Migrate to NFS?

You want to migrate to NFS as storage backend but don't want to copy everything manually or resetup your application? Don't worry, it's fairly easy.

#### Backup everything

```shell
# to get the name of the container to back up execute this and copy the name
docker-compose ps
# now paste the name into this variable like this
CONTAINER_NAME=yourcontainername
# now get the volume path via, copy the internal path e.g. /data for wikijs
docker-compose config
# paste the internal path into this variable like this
CONTAINER_PATH=/path/to/backup
# now run this to create an archive of the container data
docker run --rm --volumes-from $CONTAINER_NAME \
       -v $(pwd):/backup alpine tar czvf /backup/$CONTAINER_NAME.tar.gz $CONTAINER_PATH
```

Your files are now backed up, you can view the archive with ```tar -tf $CONTAINER_NAME.tar.gz```.

#### Restore the data

To restore the archive on a new volume or even into a new container execute the following

```shell
# if you want to migrate to NFS on your current container you need to remove the local volume first, the easiest way is to purge the container
# ATTENTION check your backups, the following command will delete the volumes and their data too!
docker-compose down -v
# now start up your container again but this time include the docker-compose.nfs.yml aswell (make sure to set up your .env file accordingly!)
# also don't forget to add the traefik or ports (or both) compose files aswell
docker-compose -f docker-compose.yml -f docker-compose.nfs.yml [-f docker-compose.traefik.yml] [-f docker-compose.ports.yml] up -d
# now your container will have a volume backed by your nfs storage, lets restore the data, but stop the container first
docker-compose stop
# FYI if you changed your shell you need to set up the CONTAINER_NAME and CONTAINER_PATH vars again!
docker run --rm --volumes-from $CONTAINER_NAME \
       -v $(pwd):/backup alpine sh -c "cd $CONTAINER_PATH && tar xvf /backup/$CONTAINER_NAME.tar --strip 1"
# finished, start your container again
docker-compose -f docker-compose.yml -f docker-compose.nfs.yml [-f docker-compose.traefik.yml] [-f docker-compose.ports.yml] start
```

That's it, your data should be restored and you can now save the archive somewhere else or remove it if you think it's a good idea.  
FYI if you want to write a proper script for this, I'd be happy if you'd share it with everyone through a pull request. :)

### Troubleshooting

#### Port 3000 is already taken

Fret not, you don't need to adjust my compose files, you can just create an ```.env``` file and adjust the ports through that, for example

```shell
# open .env
editor .env
# and add
WIKIJS_PORT=3001
```

Now Wiki.js runs on port 3001.

#### It's still not working

Consult [the manual](https://docs.requarks.io/) first.  

If you **made sure** the issue is related to my compose files, create an issue.
