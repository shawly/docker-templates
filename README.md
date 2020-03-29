# shawly's docker-templates - easy, maintainable, flexible, no-fuss, docker-compose only

My personal collection of docker-compose files. Make sure to read the description, of course you can just use the templates, but I recommend to understand the file structure so you can get the most out of it!

# Table of Contents

   * [shawly's docker-templates - easy, maintainable, flexible, no-fuss, docker-compose only](#shawlys-docker-templates---easy-maintainable-flexible-no-fuss-docker-compose-only)
   * [Table of Contents](#table-of-contents)
   * [Description](#description)
      * [What's different about these templates?](#whats-different-about-these-templates)
         * [Compose file structure explained](#compose-file-structure-explained)
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
         * [Docker](#docker)
            * [Utility](#utility)
         * [Download Managers](#download-managers)
         * [Voice Chat](#voice-chat)
         * [PlayStation 3 Tools](#playstation-3-tools)
      * [Not ready yet](#not-ready-yet)
      * [How to use?](#how-to-use)
         * [The proper way to use](#the-proper-way-to-use)
      * [TODOs](#todos)
   * [Issues?](#issues)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)

# Description

Over the years I've been trying to optimize the setup of my containers to be faster, more generic and applicable to multiple systems as my home server as well as my virtual private servers often change according to my mood or because of technical experiments.  
So to get my docker hosts up and running fast without relying on dependencies other than docker and docker-compose I've been trying to achieve a quick and easy to understand way of orchestrating my containers.

## What's different about these templates?

I'm not a fan of maintaining big compose files, they get messy, hard to read and are mostly inflexible. What I've learned over the years is that almost 80% of compose files I find on the net and Github need adjustments because they are either too specific or too unspecific to just run out of the box.

My goal is to get around this and provide myself and other users a way to setup containers with different confiuguration options without anyone having to touch the compose files themselves.

For this I split my compose files into multiple parts, one main compose file and different deltas to include functionality.  

### Compose file structure explained

#### template/docker-compose.yml

The main compose file, containing the minimum configuration necessary for deltas to complete the container as a whole.  
It consists of essential data like the service itself, the image as well as volumes for data persistence.
Ports are ommitted, labels, environment variables and networks.

##### Why named volumes?

If the container doesn't require me to provide any configuration data I explicitly recommend to use named volumes as they have the advantage to be used with different driver options, like NFS or SSHFS.  
My idea of a host running docker is that the host itself is volatile, so all volumes with important data are backed by a storage driver like nfs.  
In case the host needs to be migrated, becomes unrecoverable or you simply want to change the OS, the only thing you'd have to do is install **docker & docker-compose** checkout this repository (or rather your private fork with sensitive data and your personal configurations) and run the ```docker-compose``` commands to get everything up and running again.

#### template/docker-compose.ports.yml

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

#### template/docker-compose.traefik.yml

Since I'm a big fan of Traefik I've included deltas for every container (with a webinterface) with the easiest possible setup.  
Creating an ```.env``` file with the DOMAIN environment variable is usually enough, to setup the stack just run

```shell
# you can still expose ports if you want
docker-compose -f docker-compose.yml -f docker-compose.traefik.yml [-f docker-compose.ports.yml] up -d
```

#### template/docker-compose.nfs.yml

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

#### template/docker-compose.sshfs.yml

*TBD, I don't use SSHFS (yet) but if one wants to add this feel free to [create a pull request](https://github.com/shawly/docker-templates/pulls).*

#### template/docker-compose.\<custom>.yml

As always the real world scenario isn't always as simple and there are cases where you just need more deltas, so certain containers contain addition configurations in custom YAMLs, usually these consist of additional but optional configuraton options or additional services which compliment the overall service stack.  
For example a small socks5 proxy would be nice addition for a vpn-client container, but not essential, so it would be contained in a different delta.

#### template/docker-compose.override*.yml

Just like me, some people like to host their compose files in a remote repository like GitHub but feel the need to share it with the world.  
But where do you keep the stuff that's private then? That's what the docker-compose.override*.yml are intended for, this is where you keep your private information, so you can easily fork this repository and add your own stuff without worrying about pushing sensitive data into public eyes.  

For certain things it's simply not possible to be kept in a YAML file (like certs or acme data), so I usually add a **.gitignore**  which excludes sensitive data for that specific application.

#### template/\<container>.env vs template/.env

There are two different environment files. The first one is the **\<container>.env** which holds environment variables specifically for the application, it is a required file in most templates as many applications need a timezone or other variables to run. An **\<container>.example.env** is located in every template where it's essential, copy that and adjust it to your needs.

Then there is the **.env** file, this one is optional and only becomes necessary when your combination of deltas actually requires some user input. One example would be the use of **docker-compose.traefik.yml** deltas, as they require a domain to be set for reverse proxying. Same goes for the **docker-compose.ports.yml** when you need to adjust the default exposed port.

In short, the **\<container>.env** only contains variables for the application within the container, where **.env** variables can also be used within the docker-compose files themselves.

# Containers

## Ready to use

 ### Docker
 #### Utility
 - [Traefik](https://github.com/shawly/docker-templates/tree/master/traefik) - a flexible, extensive reverse proxy
 - [Portainer](https://github.com/shawly/docker-templates/tree/master/portainer) - monitoring and simple management of containers
 - [Watchtower](https://github.com/shawly/docker-templates/tree/master/watchtower) - automatic update your containers
 ### Download Managers
 - [JDownloader2](https://github.com/shawly/docker-templates/tree/master/jdownloader) - popular Java based download manager
 ### Voice Chat
 - [TeamSpeak](https://github.com/shawly/docker-templates/tree/master/teamspeak) - popular, easy to setup VoIP server
 ### PlayStation 3 Tools
 - [ps3netsrv](https://github.com/shawly/docker-templates/tree/master/ps3netsrv) - custom file server for PS3 tools like webMAN-MOD and MultiMAN

## Not ready yet

Everything that is not listed above. They usually work but I haven't been maintaining them on GitHub so they are outdated and there are lot more on my private repo. I'm currently cleaning them up and adjusting them to the new template structure so I can upload them here as well.

## How to use?

Every template should contain a **README.md** with instructions to setup. For simple applications it's usually enough to execute ```docker-compose``` with the **ports** and/or the **traefik** delta included.

### The proper way to use

The whole purpose of providing examples and ignoring overrides is for people to define this repository as upstream for their own personal collection of docker-compose templates located on a private repository where it's safe to commit sensitive data and personal configurations.
Just fork this repository and make it private, that's it. Your personal repository is now invisible for the public and allows storing API keys or passwords and is still updatable by fetching upstream data from my public repository, so you always get the latest template updates if you want.

Since you shouldn't really trust third parties to store your private configuration data, like on a private Github repository, it's probably better to host your own Git server and init a repository there with this repository as upstream, like this:

```shell
# add this repository to your own fork as upstream
git remote add upstream https://github.com/shawly/docker-templates.git
```

Now you need to make sure to adjust the **.gitignore** files in your repsitory to allow your **.env** and **\<container>.env** files to not be excluded anymore so you can commit your personal configurations.  
That's it, now you can fetch updates with

```shell
# fetch upstream
git fetch upstream
# merge updates from https://github.com/shawly/docker-templates.git into your current branch
git merge upstream/master
```

If you made sure to **not adjust any files from the upstream** (use override deltas!) you will not get any merge conflicts and have an updated repository.

## TODOs

 - Create scripts for execution of ```docker-compose``` without having to append every delta with the ```-f``` argument.
 - Create a basic template for creating new templates via copy & paste. (maybe integrate template creation into the scipts?)

# Issues?

Should a **problem** arise that is **directly related** to my compose files, feel free to [create a ticket](https://github.com/shawly/docker-templates/issues).

**Please refrain** from asking for support for specific applications, please contact the developers of the containers or applications if you have issues with anything that is not related to my compose files.
