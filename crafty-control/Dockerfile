FROM ubuntu:20.04

WORKDIR /tmp

RUN \
  set -ex && \
  echo "Installing runtime dependencies..." && \
    apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    python3 python3-dev python3-pip openjdk-8-jdk openjdk-8-jre libmysqlclient-dev git && \
  echo "Cloning crafty-web..." && \
    mkdir -p /crafty_web /minecraft_servers /crafty_db && \
    git clone --depth 1 https://gitlab.com/crafty-controller/crafty-web.git -b snapshot crafty_web && \
    cp -rv crafty_web/* /crafty_web && \
  echo "Installing crafty controller..." && \
    cd /crafty_web && \
    pip3 install -r requirements.txt && \
  echo "Creating crafty user..." && \
    groupadd -r -g 500 crafty && \
    useradd -u 500 -g 500 -M -s /bin/false crafty && \
    chown -R 500:500 /crafty_web /minecraft_servers /crafty_db && \
  echo "Cleaning up temp directory..." && \
    rm -rf /tmp/*

WORKDIR /crafty_web

USER crafty

# Define mountable directories.
VOLUME ["/minecraft_servers", "/crafty_db"]

EXPOSE 8000 \
  25500-25600

CMD ["python3", "crafty.py", "-c", "/crafty_web/configs/docker_config.yml"]