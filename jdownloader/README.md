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
