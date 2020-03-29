# Read this first!

## Validation

Before running the template with ```up -d``` I recommend you to always check the template first with ```config```.

```shell
docker-compose -f docker-compose.yml -f docker-compose.traefik.yml -f docker-compose.ports.yml config
```

That way you can make sure no environment variables are missing and the labels for Traefik are correct.

## Standalone

To run this container in standalone mode **without Traefik** reverse proxy, you can execute

```shell
docker-compose -f docker-compose.yml -f docker-compose.ports.yml up -d
```

## Traefik

If you are using Traefik you need to create an .env file first which specifies your domain.  
For example like this (replace example.com with your domain or subdomain):

```shell
# do not add the container name to the domain, it's already been set to jdownloader2.$DOMAIN
MYDOMAIN=example.com
echo DOMAIN=$MYDOMAIN >> .env
# to adjust the subdomain you have to edit the SUBDOMAIN env var as well
MYSUBDOMAIN=jd
echo SUBDOMAIN=$MYSUBDOMAIN >> .env
```

After that you can run 

```shell
docker-compose -f docker-compose.yml -f docker-compose.traefik.yml -f docker-compose.myjd.ports.yml up -d
```

Now JDownloader should be served as subdomain under the domain you specified, e.g. ```jdownloader2.example.com``` or ```jdownloader2.subdomain.example.com```.
Make sure to include the **myjd.ports** delta, otherwise my.jdownloader.org won't have direct access.  
If you use a macvlan network you don't have to expose ports btw and can skip adding any **ports** deltas.

## NFS

If you want to store your data on an NFS share, there is no need to mount it yourself, this is what docker volumes are good for.

```shell
# open .env
editor .env
# and add
# JD2_ is for the /config folder of jdownloader itself
JD2_NFS_SERVER=your.nfs.host.or.ip.com
JD2_NFS_MOUNT=/mnt/nfs/share/to/mount
# DL_ is for the /output folder where downloads will be stored
DL_NFS_SERVER=your.nfs.host.or.ip.com
DL_NFS_MOUNT=/mnt/nfs/share/to/mount
# optional, will default to rw,nolock
JD2_NFS_MOUNTOPTS=rw,nolock
DL_NFS_MOUNTOPTS=rw,nolock
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
# now get the volume path via, copy the internal path e.g. /data for jdownloader2
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

#### Port 5800 and 5900 are already taken

Fret not, you don't need to adjust my compose files, you can just create an ```.env``` file and adjust the ports through that, for example

```shell
# open .env
editor .env
# and add
JD2_HTTP_PORT=5801
JD2_VNC_PORT=5901
# make sure to adjust the port on my.jdownloader.org as well
JD2_MYJD_PORT=3130
```

Now the webinterface runs on port 5801, the vnc server on port 5901 and the MyJD port to 3130.

#### It's still not working

Consult [the manual](https://support.jdownloader.org/Knowledgebase/List) first or search through the [forums](https://board.jdownloader.org/).

If you **made sure** the issue is related to my compose files, create an issue.
