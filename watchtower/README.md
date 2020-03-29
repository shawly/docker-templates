# Read this first!

## Validation

Before running the template with ```up -d``` I recommend you to always check the template first with ```config```.

```shell
docker-compose config
```

That way you can make sure no environment variables are missing.

## Setup

You first need to mount a config.json into the container, there are two ways, either creating config.json for watchtower specifically

```shell
echo {} > config.json
```

or link an already existing one from your $HOME/.docker folder

```shell
ln -s $HOME/.docker/config.json $(pwd)/config.json
```

If you are working behind a proxy or need some specific registries I recommend the latter option as you'd have to maintain two config.json files otherwise.

## Run

To run this container just execute

```shell
docker-compose up -d
```

### Troubleshooting

#### Port 9000 or 8000 are already taken

Fret not, you don't need to adjust my compose files, you can just create an ```.env``` file and adjust the ports through that, for example

```shell
# open .env
editor .env
# and add
PORTAINER_AGENT_PORT=8001
PORTAINER_PORT=9001
```

Now Portainer runs on port 9001 and the agent can access the api through port 8001.

#### It's still not working

Consult [the manual](https://portainer.readthedocs.io/en/stable/) first and the [FAQ](https://portainer.readthedocs.io/en/stable/faq.html).  

If you **made sure** the issue is related to my compose files, create an issue.
