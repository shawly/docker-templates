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
# do not add the container name to the domain, it's already been set to pihole.$DOMAIN
MYDOMAIN=example.com
echo DOMAIN=$MYDOMAIN >> .env
# to adjust the subdomain you have to edit the SUBDOMAIN env var as well
MYSUBDOMAIN=pms
echo SUBDOMAIN=$MYSUBDOMAIN >> .env
```

After that you can run 

```shell
docker-compose -f docker-compose.yml -f docker-compose.traefik.yml [-f docker-compose.ports.traefik.yml] up -d
```

Now the PiHole webgui should be served as subdomain under the domain you specified, e.g. ```pihole.example.com``` or ```pihole.subdomain.example.com```.  
Make sure to include the `ports.traefik` delta if you want the DNS ports to be exposed!

### Internal mode (for VPN servers or GUI containers)

To run this container in internal mode without exposing ports (for usage with other containers like a VPN server for example or [jlesage/firefox](https://hub.docker.com/r/jlesage/firefox)), you can execute

```shell
docker-compose -f docker-compose.yml  -f docker-compose.internal.yml [-f docker-compose.traefik.yml] up -d
```

This will serve the DNS only internally in it's own `pihole_net` network, you can add containers to that network to give them access.  
The default internal IP of the pihole container is `172.253.0.2`, if you want to change this create an `.env` file and add the `PIHOLE_INTERNAL_STATIC_IP` and `PIHOLE_INTERNAL_STATIC_SUBNET` with the subnet and ip of your choice.  
Make sure the containers which should use the PiHole as DNS have the IP of your PiHole set as DNS.

## DHCP

If you plan to use PiHole as DHCP server you have to give the container the NET_ADMIN permission, to do this just include the `dhcp` delta.

```shell
docker-compose -f docker-compose.yml -f docker-compose.dhcp.yml [-f docker-compose.ports.yml] [-f docker-compose.traefik.yml] up -d
```

## NFS

If you want to store your data on an NFS share, there is no need to mount it yourself, this is what docker volumes are good for.

```shell
# open .env
editor .env
# and add
PIHOLE_NFS_SERVER=your.nfs.host.or.ip.com
PIHOLE_NFS_MOUNT=/mnt/nfs/share/to/mount
PIHOLE_TRANSCODE_NFS_SERVER=your.nfs.host.or.ip.com
PIHOLE_TRANSCODE_NFS_MOUNT=/mnt/nfs/share/to/mount
# optional, will default to rw,nolock
PIHOLE_NFS_MOUNTOPTS=rw,nolock
PIHOLE_TRANSCODE_NFS_MOUNTOPTS=rw,nolock
```

Save the ```.env``` file and add the compose file to your docker-compose command with the ```-f``` arg again and make sure to run the ```config``` command first to check for errors!

```shell
docker-compose -f docker-compose.yml -f docker-compose.traefik.yml -f docker-compose.nfs.yml [-f docker-compose.transcode.nfs.yml] up -d
```

### Troubleshooting

#### Port 53 is already taken

This means your host is using this port for it's own DNS, Ubuntu 18 for example does that.  
You can either disable the internal DNS of your host or make sure the ports are bound to an external IP on your host.
I prefer [macvlan networks](https://docs.docker.com/network/macvlan/) for this as I can expose containers to my local network with their own IPs which makes things a lot easier (for me atleast).

**I DO NOT RECOMMEND** changing PIHOLE_DNS_PORT or PIHOLE_DHCP_PORT as normally there is no way to get a device to check for DHCP or DNS servers on other ports.

#### Port 80 and 443 are already taken

Fret not, you don't need to adjust my compose files, you can just create an ```.env``` file and adjust the ports through that, for example

```shell
# open .env
editor .env
# and add
PIHOLE_HTTP_PORT=81
PIHOLE_HTTPS_PORT=444
```

Though you might want to look at Traefik or another reverse proxy for this scenario.

#### It's still not working

Consult [the support page](https://discourse.pi-hole.net/) first.  

If you **made sure** the issue is related to my compose files, create an issue.
