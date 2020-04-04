# Read this first!

## Validation

Before running the template with ```up -d``` I recommend you to always check the template first with ```config```.

```shell
docker-compose -f docker-compose.yml -f docker-compose.ports.yml [-f docker-compose.mysql.yml] [-f docker-compose.tsdns.yml] config
```

## Standalone

To run this container in standalone mode **with an sqlite db**, you can execute

```shell
docker-compose -f docker-compose.yml -f docker-compose.ports.yml up -d
```

If you want to host a single server there is no real reason to use a separate database.

## MYSQL Database

If you want or need to use a MySQL database you can just apply the **mysql** delta like this

```shell
docker-compose -f docker-compose.yml -f docker-compose.ports.yml -f docker-compose.mysql.yml up -d
```

## TSDNS

If you host multiple servers on different domains and or subdomains but on the same server with a single IP it makes sense to use TSDNS to redirect domains to specific ports.  
For that you can add the **tsdns** delta. Make sure you create a **tsdns_settings.ini** first with your entries

```shell
cp tsdns_settings.example.ini tsdns_settings.ini
editor tsdns_settings.ini
# save and quit
```

Now run ```docker-compose``` with the **tsdns** delta

```shell
docker-compose -f docker-compose.yml -f docker-compose.ports.yml -f docker-compose.tsdns.yml [-f docker-compose.mysql.yml] up -d
```

## NFS

If you want to store your data on an NFS share, there is no need to mount it yourself, this is what docker volumes are good for.

```shell
# open .env
editor .env
# and add
DB_NFS_SERVER=your.nfs.host.or.ip.com
DB_NFS_MOUNT=/mnt/nfs/share/to/mount
TS3_NFS_SERVER=your.nfs.host.or.ip.com
TS3_NFS_MOUNT=/mnt/nfs/share/to/mount
# optional, will default to rw,nolock
DB_NFS_MOUNTOPTS=rw,nolock
TS3_NFS_MOUNTOPTS=rw,nolock
```

Save the ```.env``` file and add the compose file to your docker-compose command with the ```-f``` arg again and make sure to run the ```config``` command first to check for errors!

```shell
docker-compose -f docker-compose.yml -f docker-compose.nfs.yml [-f docker-compose.mysql.yml -f docker-compose.mysql.nfs.yml] up -d
```

### Troubleshooting

#### Port xy is already taken

Fret not, you don't need to adjust my compose files, you can just create an ```.env``` file and adjust the ports through that, for example

```shell
# open .env
editor .env
# and add
TS3_ACCOUNTING_PORT=2009
TS3_WEBLIST_PORT=2011
TS3_PORT=9988
TS3_SERVERQUERY_PORT=10012
TS3_FILETRANSFER_PORT=30034
```

Now all ports have been counted up by +1. I'm not acutally sure though if changing anything else other than the TS3_PORT and the TS3_SERVERQUERY_PORT actually works properly.  

#### It's still not working

Consult [the forums](https://forum.teamspeak.com/forums/100-Server-Support) first or contact [the support](https://teamspeak.com/en/more/contact/).  

If you **made sure** the issue is related to my compose files, create an issue.
