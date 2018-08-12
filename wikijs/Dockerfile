FROM alpine:3.6

ENV BUILD_DEPS="gettext"  \
    RUNTIME_DEPS="libintl openssh-keygen"

ADD entrypoint.sh /usr/local/bin

RUN set -x && \
    apk add --update $RUNTIME_DEPS && \
    apk add --virtual build_deps $BUILD_DEPS &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps && \
    chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /tmp

CMD /usr/local/bin/entrypoint.sh
