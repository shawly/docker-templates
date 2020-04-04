# Read this first!

## Validation

Before running the template with ```up -d``` I recommend you to always check the template first with ```config```.

```shell
docker-compose -f docker-compose.yml -f docker-compose.traefik.yml -f docker-compose.ports.yml config
```

That way you can make sure no environment variables are missing and the labels for Traefik are correct.

## Setup

A claim token from https://plex.tv/claim is required to access the server, login with your Plex account and generate one, then add it to your `plex.env` file.

```shell
cp plex.example.env plex.env
editor plex.env
# now add your token to the PLEX_CLAIM variable
```

## Standalone

To run this container in standalone mode **without Traefik** reverse proxy, you can execute

```shell
docker-compose -f docker-compose.yml -f docker-compose.ports.yml up -d
```

## Traefik

If you are using Traefik you need to create an .env file first which specifies your domain.  
For example like this (replace example.com with your domain or subdomain):

```shell
# do not add the container name to the domain, it's already been set to plex.$DOMAIN
MYDOMAIN=example.com
echo DOMAIN=$MYDOMAIN >> .env
# to adjust the subdomain you have to edit the SUBDOMAIN env var as well
MYSUBDOMAIN=pms
echo SUBDOMAIN=$MYSUBDOMAIN >> .env
```

After that you can run 

```shell
docker-compose -f docker-compose.yml -f docker-compose.traefik.yml up -d
```

Now Plex Media Server should be served as subdomain under the domain you specified, e.g. ```plex.example.com``` or ```plex.subdomain.example.com```.

## Transcoding

If you plan to use transcoding you can choose where the transcodes will be done, you can choose between `local`, `ram` (tmpfs) and `nfs`.

```shell
docker-compose -f docker-compose.yml -f docker-compose.transcode.(local|ram|nfs).yml [-f docker-compose.ports.yml] [-f docker-compose.traefik.yml] up -d
```

If you chose `nfs` make sure to read the section below.

## NFS

If you want to store your data on an NFS share, there is no need to mount it yourself, this is what docker volumes are good for.

```shell
# open .env
editor .env
# and add
PLEX_NFS_SERVER=your.nfs.host.or.ip.com
PLEX_NFS_MOUNT=/mnt/nfs/share/to/mount
PLEX_TRANSCODE_NFS_SERVER=your.nfs.host.or.ip.com
PLEX_TRANSCODE_NFS_MOUNT=/mnt/nfs/share/to/mount
# optional, will default to rw,nolock
PLEX_NFS_MOUNTOPTS=rw,nolock
PLEX_TRANSCODE_NFS_MOUNTOPTS=rw,nolock
```

Save the ```.env``` file and add the compose file to your docker-compose command with the ```-f``` arg again and make sure to run the ```config``` command first to check for errors!

```shell
docker-compose -f docker-compose.yml -f docker-compose.traefik.yml -f docker-compose.nfs.yml [-f docker-compose.transcode.nfs.yml] up -d
```

### Troubleshooting

#### Port 32400 is already taken

Fret not, you don't need to adjust my compose files, you can just create an ```.env``` file and adjust the ports through that, for example

```shell
# open .env
editor .env
# and add
PLEX_PORT=32401
```

Now Plex runs on port 32401.

#### It's still not working

Consult [the support page](https://support.plex.tv/) first.  

If you **made sure** the issue is related to my compose files, create an issue.
