# shawly's docker-templates - easy, maintainable, flexible, no-fuss, docker-compose only

My personal collection of docker-compose files.

# Table of Contents

   * [shawly's docker-templates - easy, maintainable, flexible, no-fuss, docker-compose only](#shawlys-docker-templates---easy-maintainable-flexible-no-fuss-docker-compose-only)
   * [Table of Contents](#table-of-contents)
   * [Description](#description)
      * [What's different about these templates?](#whats-different-about-these-templates)
         * [template/docker-compose.yml](#templatedocker-composeyml)
            * [Why named volumes?](#why-named-volumes)
         * [template/docker-compose.ports.yml](#templatedocker-composeportsyml)
         * [template/docker-compose.traefik.yml](#templatedocker-composetraefikyml)
         * [template/docker-compose.nfs.yml](#templatedocker-composenfsyml)
         * [template/docker-compose.sshfs.yml](#templatedocker-composesshfsyml)
         * [template/docker-compose.&lt;custom&gt;.yml](#templatedocker-composecustomyml)
         * [template/docker-compose.override*.yml](#templatedocker-composeoverrideyml)
         * [template/&lt;container&gt;.env vs template/.env](#templatecontainerenv-vs-templateenv)
   * [Containers](#containers)
      * [Ready to use](#ready-to-use)
         * [How to use?](#how-to-use)
      * [Not ready](#not-ready)
      * [Planned](#planned)
   * [Issues?](#issues)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)

# Description

Over the years I've been trying to optimize the setup of my containers to be faster, more generic and applicable to multiple systems as my home server as well as my virtual private servers often change according to my mood or because of technical experiments.  
So to get my docker hosts up and running fast without relying on dependencies other than docker and docker-compose I've been trying to achieve a quick and easy to understand way of orchestrating my containers.

## What's different about these templates?

I'm not a fan of maintaining big compose files, they get messy, hard to read and are mostly inflexible. What I've learned over the years is that almost 80% of compose files I find on the net and Github need adjustments because they are either too specific or too unspecific to just run out of the box.

My goal is to get around this and provide myself and other users a way to setup their containers like they want without anyone having to touch the compose files themselves.

For this I split my compose files into multiple parts, one main compose file and different deltas to include functionality.  
The main structure looks like this:

### template/docker-compose.yml

The main compose file, containing the minimum configuration necessary for deltas to complete the container as a whole.  
It consists of essential data like the service itself, the image as well as volumes for data persistence.
Ports are ommitted, labels, environment variables and networks.

#### Why named volumes?

If the container doesn't require me to provide any configuration data I explicitly recommend to use named volumes as they have the advantage to be used with different driver options, like NFS or SSHFS.

### template/docker-compose.ports.yml

This compose file only contains ports, as a user should have the option to use reverse proxies or external macvlan networks where exposing ports on the host is mostly unnecessary and often not wanted, especially if the ports are shared by multiple containers.  
While I personally prefer exposing containers with an external macvlan network or webinterfaces via a reverse proxy (namely Traefik), I see why users still want to expose ports or run their containers standalone, for example on remote hosted servers with a single IP.  

To still provide a user the ability to change ports without touching the YAML file directly, I simply use shell variables with defaults, for example:
```yml
    ports:
      - "${PORTAINER_AGENT_PORT:-8000}:8000"
      - "${PORTAINER_PORT:-9000}:9000"
```

This way a user can simply create a ```.env``` file and set those environment variables to change port exposure if necessary and if one just wants to run the container standalone they don't have to do anything.

If one would just want to test out the application in standalone mode, the only command necessary to run is

```shell
docker-compose -f docker-compose.yml -f docker-compose.ports.yml up -d
```

Of course this can change for certain applications, but usually it's enough.

### template/docker-compose.traefik.yml

Since I'm a big fan of Traefik I've included deltas for every container (with a webinterface) with the easiest possible setup.  
Creating an ```.env``` file with the DOMAIN environment variable is usually enough, to setup the stack just run

```shell
# you can still expose ports if you want
docker-compose -f docker-compose.yml -f docker-compose.traefik.yml [-f docker-compose.ports.yml] up -d
```

### template/docker-compose.nfs.yml

As I'd like to be my Docker host to be as volatile as possible I need to persist my data elsewhere, this is where NFS comes in handy as I can easily setup a share on my NAS and persist my data there. This is why I add **docker-compose.nfs.yml** to every template with named volumes, that way it's possible to easily connect the volumes of a container to my NFS shares.

For this to work you only need to add an **.env** file with the proper environment variables to point to your NFS server and share, e.g.

```shell
editor .env
NFS_SERVER=freenas.lan.example.com
NFS_MOUNT=/mnt/tank/docker/containername_volumename
```

After saving the **.env** file you just have to append the **docker-compose.nfs.yml** to your compose command.

```shell
# remember to add traefik and/or ports deltas aswell
docker-compose -f docker-compose.yml -f docker-compose.nfs.yml [-f docker-compose.traefik.yml] [-f docker-compose.ports.yml] up -d
```

### template/docker-compose.sshfs.yml

TBD, I don't use SSHFS (yet) but if one wants to add this feel free to [create a pull request](https://github.com/shawly/docker-templates/pulls).

### template/docker-compose.\<custom>.yml

As always the real world scenario isn't always as simple and there are cases where you just need more deltas, so certain containers contain addition configurations in custom YAMLs, usually these consist of additional but optional configuraton options or additional services which compliment the overall service stack.  
For example a small socks5 proxy would be nice addition for a vpn-client container, but not essential, so it would be contained in a different delta.

### template/docker-compose.override*.yml

Just like me, some people like to host their compose files in a remote repository like GitHub but feel the need to share it with the world.  
But where do you keep the stuff that's private then? That's what the docker-compose.override*.yml are intended for, this is where you keep your private information, so you can easily fork this repository and add your own stuff without worrying about pushing sensitive data into public eyes.  

For certain things it's simply not possible to be kept in a YAML file (like certs or acme data), so I usually add a **.gitignore**  which excludes sensitive data for that specific application.

### template/\<container>.env vs template/.env

There are two different environment files. The first one is the **\<container>.env** which holds environment variables specifically for the application, it is a required file in most templates as many applications need a timezone or other variables to run. An **\<container>.example.env** is located in every template where it's essential, copy that and adjust it to your needs.

Then there is the **.env** file, this one is optional and only becomes necessary when your combination of deltas actually requires some user input. One example would be the use of **docker-compose.traefik.yml** deltas, as they require a domain to be set for reverse proxying. Same goes for the **docker-compose.ports.yml** when you need to adjust the default exposed port.

In short, the **\<container>.env** only contains variables for the application within the container, where **.env** variables can also be used within the docker-compose files themselves.

# Containers

## Ready to use

 - [Traefik](https://github.com/shawly/docker-templates/tree/master/traefik)
 - [Portainer](https://github.com/shawly/docker-templates/tree/master/portainer)
 - [ps3netsrv](https://github.com/shawly/docker-templates/tree/master/ps3netsrv)
 - [TeamSpeak](https://github.com/shawly/docker-templates/tree/master/teamspeak)
 - [Watchtower](https://github.com/shawly/docker-templates/tree/master/watchtower)

## How to use?

Every template should contain a **README.md** with instructions to setup. For simple applications it's usually enough to execute ```docker-compose``` with the **ports** and/or the **traefik** delta included.

## Not ready yet

Everything that is not listed above. They usually work but I haven't been maintaining them on GitHub so they are outdated and there are lot more on my private repo. I'm currently cleaning them up and adjusting them to the new template structure so I can upload them here as well.

## Planned

 - Shell scripts for execution of ```docker-compose``` without having to append every delta with the ```-f``` argument.
 - A basic template for creating new templates via copy & pasting.
 - Add descriptions and order as soon as the list of containers increases.

# Issues?

Should a **problem** arise that is **directly related** to my compose files, feel free to [create a ticket](https://github.com/shawly/docker-templates/issues).

**Please refrain** from asking for support for specific applications, please contact the developers of the containers or applications if you have issues with anything that is not related to my compose files.
