FROM alpine:3.6

ENV BUILD_DEPS="gettext"  \
    RUNTIME_DEPS="libintl"

RUN set -x && \
    apk add --update $RUNTIME_DEPS && \
    apk add --virtual build_deps $BUILD_DEPS &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps

ADD config.template.yml /tmp

WORKDIR /tmp

CMD envsubst < /tmp/config.template.yml > /tmp/config.yml
