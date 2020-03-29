# Read this first!

## Validation

Before running the template with ```up -d``` I recommend you to always check the template first with ```config```.

```shell
docker-compose -f docker-compose.yml -f docker-compose.traefik.yml -f docker-compose.ports.yml -f config
```

That way you can make sure no environment variables are missing and the labels for Traefik are correct.

# Setup

You need to create an acme.json first and apply the correct attributes before running this.

```shell
echo {} > ./config/acme/acme.json
chmod 0600 ./config/acme/acme.json
```

That's it, add your environment variables and run 

```shell
docker-compose -f docker-compose.yml -f docker-compose.ports.yml
```

or to enable the dashboard aswell run

```shell
docker-compose -f docker-compose.yml -f docker-compose.ports.yml -f docker-compose.traefik.yml
```

## Enabling traefik for your own containers

To proxy a container through traefik you need to enable this via labels, I've included compose files in most of my templates but here is an example with some explanation for you.  
It's important to note that traefik can't route to your container if they aren't in the same network, keep that in mind.

```yml
...
    labels:
      # to enable the container for traefik reverse proxying
      traefik.enable: true
      # creates a middleware which redirects http to https
      traefik.http.middlewares.portainer-https.redirectscheme.scheme: https
      # creates a router for http traffic for portainer
      traefik.http.routers.portainer-http.entrypoints: web
      # adds a rule to portainer's http router to listen on a domain, this can also be a subdomain or multiple domains
      traefik.http.routers.portainer-http.rule: "Host(`portainer.example.com`)"
      # adds the http to https redirection middleware to portainer's router
      traefik.http.routers.portainer-http.middlewares: portainer-https@docker
      # creates a router for https traffic for portainer
      traefik.http.routers.portainer.entrypoints: web-secure
      # adds a rule to portainer's https router to listen on a domain, this can also be a subdomain or multiple domains
      traefik.http.routers.portainer.rule: "Host(`portainer.example.com`)"
      # enables ssl for portainer's https router
      traefik.http.routers.portainer.tls: true
      # defines the certificate resolver for this router
      traefik.http.routers.portainer.tls.certresolver: default
      # defines secure header middleware to use for the router, defined in config/dynamic.toml
      traefik.http.routers.portainer.middlewares: secHeaders@file
      # the port which traefik shall reverse proxy
      traefik.http.services.portainer.loadbalancer.server.port: 9000
      # the port which should be used for healthchecks (optional)
      traefik.http.services.portainer.loadbalancer.healthcheck.port: 9000
...
    networks:
      # if your service doesn't need it's own network, you can omit the default network
      default:
      # this has to be adjusted if you changed the network name in the docker-compose.yml
      traefik_net:
...
networks:
  # remove the default network from here as well if your service doesn't need it
  default:
  # this has to be adjusted if you changed the network name in the docker-compose.yml
  traefik_net:
    external: true

```

Here is a clean version without comments, you can search and replace <servicename>, <serviceport> and <servicedomain> with your own identifiers and values.  
<servicename> does not have to be the name of your container, it just has to be a unique identifier for traefik.

```yml
...
    labels:
      traefik.enable: true
      traefik.http.middlewares.<servicename>-https.redirectscheme.scheme: https
      traefik.http.routers.<servicename>-http.entrypoints: web
      traefik.http.routers.<servicename>-http.rule: "Host(`<servicedomain>`)"
      traefik.http.routers.<servicename>-http.middlewares: <servicename>-https@docker
      traefik.http.routers.<servicename>.entrypoints: web-secure
      traefik.http.routers.<servicename>.rule: "Host(`<servicedomain>`)"
      traefik.http.routers.<servicename>.tls: true
      traefik.http.routers.<servicename>.tls.certresolver: default
      traefik.http.routers.<servicename>.middlewares: secHeaders@file
      traefik.http.services.<servicename>.loadbalancer.server.port: <serviceport>
      traefik.http.services.<servicename>.loadbalancer.healthcheck.port: <serviceport>
    networks:
      default:
      traefik_net:

networks:
  default:
  traefik_net:
    external: true
...
```

## Enabling the dashboard

To access traefiks dashboard you need to include the docker-compose.traefik.yml in your docker-compose command.  
BEWARE, if your domain is public, everyone will have access to the dashboard, I recommend to enable basic auth if your server is publicly accessible.

```shell
docker-compose -f docker-compose.yml -f docker-compose.traefik.yml up -d
```

### Enabling basic auth for dashboard

First you need to generate a basic auth user/password combination.

You can either install ```apache2-utils``` for this and run:

```shell
echo $(htpasswd -nbB <USER> "<PASS>") | sed -e s/\\$/\\$\\$/g
```

or simply use an online service for this, like [this one](https://hostingcanada.org/htpasswd-generator/). (make sure to thoose bcrypt)

Now you can add the generated basic auth to the docker-compose.traefik.yml, like this

```yml
...
       traefik.http.routers.api.rule: "PathPrefix(`/api`) || PathPrefix(`/dashboard`)"
       traefik.http.routers.api.service: api@internal
       # this is necessary for basic auth for the dashboard, check the README first before uncommenting
       traefik.http.routers.api.middlewares: api-auth
       traefik.http.middlewares.api-auth.basicauth.users: "test:$2y$10$EbI9jlFjpPdEAtpG9KRjWeULZP4zl6vyfQThUURfKdJxq4qAPMr5m"
...
```

